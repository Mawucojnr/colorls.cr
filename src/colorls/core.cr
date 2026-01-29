require "unicode_width"
require "uri"

module Colorls
  class Core
    MIN_SIZE_CHARS = 4

    @count : Hash(Symbol, Int32)
    @all : Bool
    @almost_all : Bool
    @hyperlink : Bool
    @sort : SortMode
    @reverse : Bool
    @group : GroupMode
    @show : ShowFilter
    @one_per_line : Bool
    @show_inode : Bool
    @long : Bool
    @show_group : Bool
    @show_user : Bool
    @show_symbol_dest : Bool
    @show_human_readable_size : Bool
    @tree : NamedTuple(mode: Bool, depth: Int32)
    @horizontal : Bool
    @show_git : Bool
    @git_status : Hash(String, Git::StatusHash?)
    @time_style : String
    @indicator_style : IndicatorStyle
    @hard_links_count : Bool
    @icons : Bool
    @colors : Hash(String, String)
    @contents : Array(FileInfo)
    @files : Hash(String, String)
    @file_aliases : Hash(String, String)
    @folders : Hash(String, String)
    @folder_aliases : Hash(String, String)
    @modes : Hash(String, String)
    @linklength : Int32 = 0
    @userlength : Int32 = 0
    @grouplength : Int32 = 0
    @chars_for_size : Int32? = nil
    @color_enabled : Bool

    def initialize(config : Config)
      @count = {:folders => 0, :recognized_files => 0, :unrecognized_files => 0}
      @all = config.all?
      @almost_all = config.almost_all?
      @hyperlink = config.hyperlink?
      @sort = config.sort
      @reverse = config.reverse?
      @group = config.group
      @show = config.show
      @one_per_line = config.mode == DisplayMode::OnePerLine
      @show_inode = config.show_inode?
      @long = config.mode == DisplayMode::Long
      @show_group = config.long_style_options.show_group?
      @show_user = config.long_style_options.show_user?
      @show_symbol_dest = config.long_style_options.show_symbol_dest?
      @show_human_readable_size = config.long_style_options.human_readable_size?
      @tree = {mode: config.mode == DisplayMode::Tree, depth: config.tree_depth}
      @horizontal = config.mode == DisplayMode::Horizontal
      @show_git = config.show_git?
      @git_status = {} of String => Git::StatusHash?
      @time_style = config.long_style_options.time_style
      @indicator_style = config.indicator_style
      @hard_links_count = config.long_style_options.hard_links_count?
      @icons = config.icons?
      @colors = config.colors
      @color_enabled = config.color_enabled?
      @contents = [] of FileInfo
      @modes = {} of String => String
      @files = {} of String => String
      @file_aliases = {} of String => String
      @folders = {} of String => String
      @folder_aliases = {} of String => String

      init_colors
      init_icons
    end

    def additional_chars_per_item : Int32
      12 + (@show_git ? 4 : 0) + (@show_inode ? 10 : 0)
    end

    def ls_dir(info : FileInfo)
      if @tree[:mode]
        print "\n"
        return tree_traverse(info.path, 0, 1, 2)
      end

      entries = Dir.entries(info.path)
      @contents = filter_hidden(entries)
        .map { |e| FileInfo.dir_entry(info.path, e, link_info: @long) }

      filter_contents if @show != ShowFilter::All
      sort_contents if @sort != SortMode::None
      group_contents if @group != GroupMode::None

      if @contents.empty?
        puts colorize("\n   Nothing to show here\n", "empty")
        return
      end

      ls
    end

    def ls_files(files : Array(FileInfo))
      @contents = files
      ls
    end

    def display_report(report_mode : ReportMode)
      return if report_mode == ReportMode::Off

      if report_mode == ReportMode::Short
        text = "\n    Folders: #{@count[:folders]}, Files: #{@count[:recognized_files] + @count[:unrecognized_files]}.\n"
        puts colorize(text, "report")
      else
        total = @count.values.sum
        text = <<-REPORT

              Found #{total} items in total.

          \tFolders\t\t\t: #{@count[:folders]}
          \tRecognized files\t: #{@count[:recognized_files]}
          \tUnrecognized files\t: #{@count[:unrecognized_files]}
        REPORT
        puts colorize(text, "report")
      end
    end

    private def ls
      init_column_lengths

      layout = if @horizontal
                 HorizontalLayout.new(@contents, item_widths, Colorls.screen_width)
               elsif @one_per_line || @long
                 SingleColumnLayout.new(@contents)
               else
                 VerticalLayout.new(@contents, item_widths, Colorls.screen_width)
               end

      layout.each_line do |line, widths|
        ls_line(line, widths)
      end
      @chars_for_size = nil
    end

    private def init_colors
      @modes = {} of String => String
      {"r" => "read", "w" => "write", "-" => "no_access",
       "x" => "exec", "s" => "exec", "S" => "exec", "t" => "exec", "T" => "exec"}.each do |key, color_key|
        color_name = @colors[color_key]? || "white"
        @modes[key] = colorize(key, color_name)
      end
    end

    private def init_icons
      @files = YamlConfig.new("files.yaml").load
      @file_aliases = YamlConfig.new("file_aliases.yaml").load(aliase: true)
      @folders = YamlConfig.new("folders.yaml").load
      @folder_aliases = YamlConfig.new("folder_aliases.yaml").load(aliase: true)
    end

    private def item_widths : Array(Int32)
      @contents.map { |item| UnicodeWidth.width(item.show) + additional_chars_per_item }
    end

    private def filter_hidden(entries : Array(String)) : Array(String)
      entries = entries - [".", ".."] unless @all
      unless @all || @almost_all
        entries = entries.reject(&.starts_with?('.'))
      end
      entries
    end

    private def init_column_lengths
      return unless @long

      maxlink = 0_i64
      maxuser = 0
      maxgroup = 0

      @contents.each do |content|
        nl = content.nlink
        maxlink = nl if nl > maxlink
        maxuser = content.owner.size if content.owner.size > maxuser
        maxgroup = content.group.size if content.group.size > maxgroup
      end

      @linklength = maxlink.to_s.size
      @userlength = maxuser
      @grouplength = maxgroup
    end

    private def filter_contents
      @contents.select! do |x|
        x.directory? == (@show == ShowFilter::DirsOnly)
      end
    end

    private def sort_contents
      case @sort
      when SortMode::Extension
        @contents.sort_by! do |entry|
          ext = File.extname(entry.name)
          base = ext.empty? ? entry.name : entry.name.chomp(ext)
          {strxfrm(ext), strxfrm(base)}
        end
      when SortMode::Time
        @contents.sort_by! { |entry| -entry.mtime.to_unix_f }
      when SortMode::Size
        @contents.sort_by! { |entry| -entry.size }
      else # Name
        @contents.sort_by! { |entry| strxfrm(entry.name) }
      end
      @contents.reverse! if @reverse
    end

    private def group_contents
      dirs, files = @contents.partition(&.directory?)
      @contents = case @group
                  when GroupMode::DirsFirst  then dirs + files
                  when GroupMode::FilesFirst then files + dirs
                  else                            @contents
                  end
    end

    private def format_mode(rwx : Int32, special : Bool, char : Char) : String
      m_r = (rwx & 4) == 0 ? "-" : "r"
      m_w = (rwx & 2) == 0 ? "-" : "w"
      m_x = if special
              (rwx & 1) == 0 ? char.upcase.to_s : char.to_s
            else
              (rwx & 1) == 0 ? "-" : "x"
            end

      (@modes[m_r]? || m_r) + (@modes[m_w]? || m_w) + (@modes[m_x]? || m_x)
    end

    private def mode_info(content : FileInfo) : String
      m = content.mode.to_i32
      format_mode(m >> 6, content.setuid?, 's') +
        format_mode(m >> 3, content.setgid?, 's') +
        format_mode(m, content.sticky?, 't')
    end

    private def user_info(content : FileInfo) : String
      colorize(content.owner.ljust(@userlength), "user")
    end

    private def group_info(grp : String) : String
      colorize(grp.ljust(@grouplength), "normal")
    end

    private def humanize_size(bytes : Int64) : String
      if bytes < 1024
        "#{bytes} B"
      elsif bytes < 1024 * 1024
        "#{"%.0f" % (bytes / 1024.0)} K"
      elsif bytes < 1024 * 1024 * 1024
        "#{"%.0f" % (bytes / (1024.0 * 1024))} M"
      else
        "#{"%.0f" % (bytes / (1024.0 * 1024 * 1024))} G"
      end
    end

    private def size_info(filesize : Int64) : String
      size_str = if @show_human_readable_size
                   humanize_size(filesize)
                 else
                   "#{filesize} B"
                 end

      parts = size_str.split
      size_num = parts[0].rjust(chars_for_size)
      size_unit = @show_human_readable_size ? parts[1]?.try(&.ljust(3)) || "   " : (parts[1]? || "")
      formatted = "#{size_num} #{size_unit}"

      large = 512_i64 * 1024 * 1024
      medium = 128_i64 * 1024 * 1024
      if filesize >= large
        colorize(formatted, "file_large")
      elsif filesize >= medium
        colorize(formatted, "file_medium")
      else
        colorize(formatted, "file_small")
      end
    end

    private def chars_for_size : Int32
      @chars_for_size ||= if @show_human_readable_size
                            MIN_SIZE_CHARS
                          else
                            max_size = @contents.max_of(&.size)
                            reqd = max_size.to_s.size
                            Math.max(reqd, MIN_SIZE_CHARS)
                          end
    end

    private def mtime_info(file_mtime : Time) : String
      mtime_str = if @time_style.starts_with?('+')
                    file_mtime.to_s(@time_style.lchop('+'))
                  else
                    file_mtime.to_s("%a %b %e %T %Y")
                  end
      now = Time.local
      diff = now - file_mtime
      if diff < 1.hour
        colorize(mtime_str, "hour_old")
      elsif diff < 1.day
        colorize(mtime_str, "day_old")
      else
        colorize(mtime_str, "no_modifier")
      end
    end

    private def git_info(content : FileInfo) : String
      return "" unless @show_git

      path = File.expand_path(content.parent)
      unless @git_status.has_key?(path)
        @git_status[path] = Git.status(path)
      end

      status = @git_status[path]?
      return "    " unless status

      if content.directory?
        git_dir_info(content, status)
      else
        git_file_info(status, content.name)
      end
    end

    private def git_file_info(status : Git::StatusHash, name : String) : String
      file_status = status[name]?
      if file_status
        Git.colored_status_symbols(file_status, @colors)
      else
        colorize("  \u2713 ", "unchanged")
      end
    end

    private def git_dir_info(content : FileInfo, status : Git::StatusHash) : String
      modes = if content.path == "."
                all_modes = Set(String).new
                status.data.each_value { |val| val.each { |mode| all_modes.add(mode) } }
                all_modes
              else
                s = status[content.name]?
                s || Set(String).new
              end

      if modes.empty? && Dir.empty?(content.path)
        "    "
      else
        Git.colored_status_symbols(modes, @colors)
      end
    end

    private def inode(content : FileInfo) : String
      return "" unless @show_inode
      colorize(content.raw_stat.st_ino.to_s.rjust(10), "inode")
    end

    private def long_info(content : FileInfo) : String
      return "" unless @long

      links = content.nlink.to_s.rjust(@linklength)

      parts = [mode_info(content)]
      parts << links if @hard_links_count
      parts << user_info(content) if @show_user
      parts << group_info(content.group) if @show_group
      parts << size_info(content.size)
      parts << mtime_info(content.mtime)
      parts.join("   ")
    end

    private def symlink_info(content : FileInfo) : String
      return "" unless @long && content.symlink?

      target = content.link_target || "\u2026"
      link_info = " \u21D2 #{target}"
      if content.dead?
        colorize("#{link_info} [Dead link]", "dead_link")
      else
        colorize(link_info, "link")
      end
    end

    private def update_content_if_show_symbol_dest(content : FileInfo) : FileInfo
      return content unless @show_symbol_dest
      return content unless content.symlink?
      return content if content.link_target.nil?
      return content if content.dead?
      if target = content.link_target
        FileInfo.info(target)
      else
        content
      end
    end

    private def decode_icon(value : String) : String
      value.gsub(/\\u[\da-f]{4}/i) do |match|
        match[-4..].to_i(16).chr.to_s
      end
    end

    private def icon_for(key : String, increment : Symbol) : String
      icon_map = increment == :folders ? @folders : @files
      fallback_key = increment == :folders ? "folder" : "file"
      value = icon_map[key]? || icon_map[fallback_key]? || ""
      decode_icon(value)
    end

    private def format_entry(content : FileInfo, key : String, color_name : String, increment : Symbol) : String
      logo = icon_for(key, increment)
      name = @hyperlink ? make_link(content) : content.show
      name += content.directory? && @indicator_style != IndicatorStyle::None ? "/" : " "

      entry = @icons ? "#{logo}  #{name}" : name
      if !content.directory? && content.executable?
        colorize_bold(entry, color_name)
      else
        colorize(entry, color_name)
      end
    end

    private def fetch_string(content : FileInfo, key : String, color_name : String, increment : Symbol) : String
      @count[increment] = (@count[increment]? || 0) + 1
      entry = format_entry(content, key, color_name, increment)
      symlink_str = symlink_info(content)
      display_content = update_content_if_show_symbol_dest(content)

      "#{inode(display_content)} #{long_info(display_content)} #{git_info(display_content)} #{entry}#{symlink_str}"
    end

    private def ls_line(chunk : Array(FileInfo), widths : Array(Int32))
      padding = 0
      line = String::Builder.new
      chunk.each_with_index do |content, i|
        key, color_name, group = options(content)
        entry = fetch_string(content, key, color_name, group)
        line << (" " * padding)
        line << "  " << entry
        padding = widths[i]? ? widths[i] - UnicodeWidth.width(content.show) - additional_chars_per_item : 0
      end
      puts line.to_s
    end

    private def file_color(file : FileInfo, key : String) : String
      color_key = if file.chardev?
                    "chardev"
                  elsif file.blockdev?
                    "blockdev"
                  elsif file.socket?
                    "socket"
                  elsif file.executable?
                    "executable_file"
                  elsif file.hidden?
                    "hidden"
                  elsif @files.has_key?(key)
                    "recognized_file"
                  else
                    "unrecognized_file"
                  end
      @colors[color_key]? || "white"
    end

    private def options(content : FileInfo) : {String, String, Symbol}
      if content.directory?
        options_directory(content)
      else
        options_file(content)
      end
    end

    private def options_directory(content : FileInfo) : {String, String, Symbol}
      key = content.name.downcase
      key = @folder_aliases[key]? || key unless @folders.has_key?(key)
      key = "folder" unless @folders.has_key?(key)

      color = content.hidden? ? (@colors["hidden_dir"]? || "gray") : (@colors["dir"]? || "blue")
      {key, color, :folders}
    end

    private def options_file(content : FileInfo) : {String, String, Symbol}
      ext = File.extname(content.name).lchop('.').downcase
      key = ext
      key = @file_aliases[key]? || key unless @files.has_key?(key)

      color = file_color(content, key)
      group = @files.has_key?(key) ? :recognized_files : :unrecognized_files
      key = "file" unless @files.has_key?(key)

      {key, color, group}
    end

    private def tree_contents(path : String) : Array(FileInfo)
      entries = Dir.entries(path)
      @contents = filter_hidden(entries).map { |e| FileInfo.dir_entry(path, e, link_info: @long) }
      filter_contents if @show != ShowFilter::All
      sort_contents if @sort != SortMode::None
      group_contents if @group != GroupMode::None
      @contents
    end

    private def tree_traverse(path : String, prespace : Int32, depth : Int32, indent : Int32)
      contents = tree_contents(path)
      contents.each do |content|
        icon = (content == contents.last || content.directory?) ? " \u2514\u2500\u2500" : " \u251C\u2500\u2500"
        print colorize(tree_branch_preprint(prespace, indent, icon), "tree")
        key, color_name, group = options(content)
        print " #{fetch_string(content, key, color_name, group)} \n"
        next unless content.directory?
        tree_traverse("#{path}/#{content.name}", prespace + indent, depth + 1, indent) if keep_going(depth)
      end
    end

    private def keep_going(depth : Int32) : Bool
      depth < @tree[:depth]
    end

    private def tree_branch_preprint(prespace : Int32, indent : Int32, prespace_icon : String) : String
      return prespace_icon if prespace == 0
      (" \u2502 " * (prespace // indent)) + prespace_icon + ("\u2500" * indent)
    end

    private def make_link(content : FileInfo) : String
      uri = URI.encode_path(File.expand_path(content.path))
      "\033]8;;file://#{uri}\007#{content.show}\033]8;;\007"
    end

    # LibC strxfrm for locale-aware sorting
    private def strxfrm(str : String) : String
      # First call to get required buffer size
      needed = ::LibC.strxfrm(nil, str, 0)
      buf = Bytes.new(needed + 1)
      ::LibC.strxfrm(buf.to_unsafe.as(Pointer(::LibC::Char)), str, buf.size)
      String.new(buf.to_unsafe, needed)
    end

    private def colorize(str : String, color_key : String) : String
      return str unless @color_enabled
      color_name = @colors[color_key]? || color_key
      ColorMap.colorize(str, color_name)
    end

    private def colorize_bold(str : String, color_key : String) : String
      return str unless @color_enabled
      color_name = @colors[color_key]? || color_key
      ColorMap.colorize_bold(str, color_name)
    end
  end
end
