require "option_parser"

module Colorls
  class Flags
    @args : Array(String)
    getter config : Config
    @report_mode : ReportMode = ReportMode::Off
    @exit_status_code : Int32 = 0
    @parse_error : Bool = false
    @parser : OptionParser?

    def initialize(args : Array(String))
      @args = args.dup
      @config = Config.new
      @config.mode = STDOUT.tty? ? DisplayMode::Vertical : DisplayMode::OnePerLine

      parse_options

      if @config.mode == DisplayMode::Tree
        @config.almost_all = true if @config.all?
        @config.all = false
      end
    end

    def process : Int32
      return @exit_status_code if @parse_error

      init_locale

      @args = ["."] if @args.empty?

      process_args
    end

    private def init_locale
      ::LibC.setlocale(::LibC::LC_COLLATE, "")
    end

    private def group_files_and_directories : {Array(FileInfo), Array(FileInfo)}
      dirs = [] of FileInfo
      files = [] of FileInfo

      @args.each do |arg|
        begin
          info = FileInfo.info(arg, show_filepath: true)
          if info.directory? && !@config.directory_mode?
            dirs << info
          else
            files << info
          end
        rescue ex : File::NotFoundError
          STDERR.puts colorize("colorls: Specified path '#{arg}' doesn't exist.", "error")
          @exit_status_code = 2
        rescue ex
          STDERR.puts colorize("#{arg}: #{ex}", "error")
          @exit_status_code = 2
        end
      end

      {dirs, files}
    end

    private def process_args : Int32
      set_color_opts
      core = Core.new(@config)

      dirs, files = group_files_and_directories

      core.ls_files(files) unless files.empty?

      dirs.sort_by! { |dir| strxfrm(dir.name) }
      dirs.each_with_index do |dir, _idx|
        puts "\n#{dir.show}:" if @args.size > 1
        begin
          core.ls_dir(dir)
        rescue ex
          STDERR.puts colorize("#{dir}: #{ex}", "error")
        end
      end

      core.display_report(@report_mode) if @report_mode != ReportMode::Off

      @exit_status_code
    end

    private def set_color_opts
      color_scheme = @config.light_colors? ? "light_colors.yaml" : "dark_colors.yaml"
      @config.colors = YamlConfig.new(color_scheme).load(aliase: true)
    end

    # Flags that take a separate argument (e.g. -I PATTERN, -w COLS, -T COLS).
    # When expanding combined short flags like "-laI", the character after one of
    # these becomes the start of its argument value, not another flag.
    FLAGS_WITH_ARGS = Set{'I', 'w', 'T'}

    # Crystal's OptionParser doesn't support combined short flags (e.g. "-lart").
    # GNU ls and most POSIX tools do via getopt. This method expands them so that
    # "-lart" becomes ["-l", "-a", "-r", "-t"] before the parser sees them.
    private def expand_combined_flags(args : Array(String)) : Array(String)
      result = [] of String
      args.each do |arg|
        if arg.starts_with?("-") && !arg.starts_with?("--") && arg.size > 2
          i = 1
          while i < arg.size
            ch = arg[i]
            if FLAGS_WITH_ARGS.includes?(ch)
              result << "-#{ch}"
              rest = arg[(i + 1)..]
              result << rest unless rest.empty?
              break
            else
              result << "-#{ch}"
            end
            i += 1
          end
        else
          result << arg
        end
      end
      result
    end

    private def parse_options
      @args = expand_combined_flags(@args)
      @parser = OptionParser.new do |opts|
        opts.banner = "Usage:  colorls [OPTION]... [FILE]..."
        opts.separator ""

        add_common_options(opts)
        add_format_options(opts)
        add_long_style_options(opts)
        add_sort_options(opts)
        add_filter_options(opts)
        add_name_transform_options(opts)
        add_size_options(opts)
        add_time_options(opts)
        add_symlink_options(opts)
        add_compatibility_options(opts)
        add_general_options(opts)
        add_stub_options(opts)

        opts.separator ""
        opts.on("--help", "prints this help") { show_help(opts); exit }
        opts.on("--version", "show version") { puts Colorls::VERSION; exit }

        opts.unknown_args do |positional, _|
          @args = positional
        end
      end

      # Show help if only -h
      if !@args.empty? && @args.all? { |arg| arg == "-h" }
        if parser = @parser
          show_help(parser)
        end
        exit
      end

      if parser = @parser
        parser.parse(@args)
      end
    rescue ex : OptionParser::Exception
      STDERR.puts "colorls: #{ex}\nSee 'colorls --help'."
      @exit_status_code = 2
      @parse_error = true
    end

    private def add_common_options(opts : OptionParser)
      opts.on("-a", "--all", "do not ignore entries starting with .") { @config.all = true }
      opts.on("-A", "--almost-all", "do not list . and ..") { @config.almost_all = true }
      opts.on("--dirs", "show only directories") { @config.show = ShowFilter::DirsOnly }
      opts.on("--files", "show only files") { @config.show = ShowFilter::FilesOnly }
      opts.on("-d", "--directory", "list directories themselves, not their contents") { @config.directory_mode = true }
      opts.on("-f", "do not sort, enable -aU, disable color") do
        @config.sort = SortMode::None
        @config.all = true
        @config.color_enabled = false
      end
      opts.on("--gs", "show git status for each file") { @config.show_git = true }
      opts.on("--git-status", "show git status for each file") { @config.show_git = true }
      opts.on("-p", "append / indicator to directories") { @config.indicator_style = IndicatorStyle::Slash }
      opts.on("-i", "--inode", "show inode number") { @config.show_inode = true }
      opts.on("--report=WORD", "show report: short, long") do |word|
        @report_mode = case word
                       when "short" then ReportMode::Short
                       else              ReportMode::Long
                       end
      end
      opts.on("--indicator-style=STYLE", "append indicator: none, slash, classify, file-type") do |style|
        @config.indicator_style = case style
                                  when "none"      then IndicatorStyle::None
                                  when "slash"     then IndicatorStyle::Slash
                                  when "classify"  then IndicatorStyle::Classify
                                  when "file-type" then IndicatorStyle::FileType
                                  else                  IndicatorStyle::Slash
                                  end
      end
      opts.on("-F", "--classify", "append indicator (*/=>@|) to entries") { @config.indicator_style = IndicatorStyle::Classify }
      opts.on("--file-type", "like -F but do not append *") { @config.indicator_style = IndicatorStyle::FileType }
      opts.on("-R", "--recursive", "list subdirectories recursively") { @config.recursive = true }
    end

    private def add_format_options(opts : OptionParser)
      opts.on("--format=WORD", "use format: across, horizontal, long, single-column, vertical, commas") do |word|
        @config.mode = case word
                       when "across", "horizontal" then DisplayMode::Horizontal
                       when "vertical"             then DisplayMode::Vertical
                       when "long"                 then DisplayMode::Long
                       when "single-column"        then DisplayMode::OnePerLine
                       when "commas"               then DisplayMode::Commas
                       else                             @config.mode
                       end
      end
      opts.on("-1", "list one file per line") { @config.mode = DisplayMode::OnePerLine }
      opts.on("--tree=DEPTH", "shows tree view of the directory") do |depth|
        @config.tree_depth = depth.to_i? || 3
        @config.mode = DisplayMode::Tree
      end
      opts.on("-x", "list entries by lines instead of by columns") { @config.mode = DisplayMode::Horizontal }
      opts.on("-C", "list entries by columns instead of by lines") { @config.mode = DisplayMode::Vertical }
      opts.on("-m", "fill width with a comma separated list of entries") { @config.mode = DisplayMode::Commas }
      opts.on("--without-icons", "list entries without icons") { @config.icons = false }
    end

    private def add_long_style_options(opts : OptionParser)
      opts.on("-l", "--long", "use a long listing format") { @config.mode = DisplayMode::Long }
      opts.on("-o", "long format without group") do
        @config.mode = DisplayMode::Long
        lso = @config.long_style_options
        lso.show_group = false
        @config.long_style_options = lso
      end
      opts.on("-g", "long format without owner") do
        @config.mode = DisplayMode::Long
        lso = @config.long_style_options
        lso.show_user = false
        @config.long_style_options = lso
      end
      opts.on("-G", "--no-group", "show no group information") do
        lso = @config.long_style_options
        lso.show_group = false
        @config.long_style_options = lso
      end
      opts.on("--time-style=FORMAT", "use time display format") do |fmt|
        lso = @config.long_style_options
        lso.time_style = fmt
        @config.long_style_options = lso
      end
      opts.on("--full-time", "like -l --time-style=full-iso") do
        @config.mode = DisplayMode::Long
        lso = @config.long_style_options
        lso.time_style = "+%Y-%m-%d %H:%M:%S.%N %z"
        @config.long_style_options = lso
      end
      opts.on("--no-hardlinks", "show no hard links count") do
        lso = @config.long_style_options
        lso.hard_links_count = false
        @config.long_style_options = lso
      end
      opts.on("-L", "show information on symlink destination") do
        lso = @config.long_style_options
        lso.show_symbol_dest = true
        @config.long_style_options = lso
      end
      opts.on("--non-human-readable", "show file sizes in bytes only") do
        lso = @config.long_style_options
        lso.human_readable_size = false
        @config.long_style_options = lso
      end
      opts.on("-n", "--numeric-uid-gid", "like -l, but list numeric user and group IDs") do
        @config.mode = DisplayMode::Long
        @config.numeric_ids = true
      end
      opts.on("--author", "with -l, print the author of each file") { @config.show_author = true }
    end

    private def add_sort_options(opts : OptionParser)
      opts.separator ""
      opts.separator "sorting options:"
      opts.separator ""
      opts.on("--sd", "sort directories first") { @config.group = GroupMode::DirsFirst }
      opts.on("--sort-dirs", "sort directories first") { @config.group = GroupMode::DirsFirst }
      opts.on("--group-directories-first", "sort directories first") { @config.group = GroupMode::DirsFirst }
      opts.on("--sf", "sort files first") { @config.group = GroupMode::FilesFirst }
      opts.on("--sort-files", "sort files first") { @config.group = GroupMode::FilesFirst }
      opts.on("-t", "sort by modification time") { @config.sort = SortMode::Time }
      opts.on("-U", "do not sort") { @config.sort = SortMode::None }
      opts.on("-S", "sort by file size") { @config.sort = SortMode::Size }
      opts.on("-X", "sort by file extension") { @config.sort = SortMode::Extension }
      opts.on("-v", "natural sort of (version) numbers within text") { @config.sort = SortMode::Version }
      opts.on("--sort=WORD", "sort by WORD: none, size, time, extension, version") do |word|
        @config.sort = case word
                       when "none"      then SortMode::None
                       when "time"      then SortMode::Time
                       when "size"      then SortMode::Size
                       when "extension" then SortMode::Extension
                       when "version"   then SortMode::Version
                       else                  SortMode::Name
                       end
      end
      opts.on("-r", "--reverse", "reverse order while sorting") { @config.reverse = true }
    end

    private def add_filter_options(opts : OptionParser)
      opts.separator ""
      opts.separator "filter options:"
      opts.separator ""
      opts.on("-B", "--ignore-backups", "do not list entries ending with ~") { @config.ignore_backups = true }
      opts.on("--hide=PATTERN", "do not list entries matching shell PATTERN") do |pattern|
        @config.hide_patterns << pattern
      end
      opts.on("-I PATTERN", "--ignore=PATTERN", "do not list entries matching shell PATTERN") do |pattern|
        @config.ignore_patterns << pattern
      end
    end

    private def add_name_transform_options(opts : OptionParser)
      opts.separator ""
      opts.separator "name options:"
      opts.separator ""
      opts.on("-b", "--escape", "print C-style escapes for nongraphic characters") { @config.escape_chars = true }
      opts.on("-q", "--hide-control-chars", "print ? instead of nongraphic characters") { @config.hide_control_chars = true }
      opts.on("--show-control-chars", "show nongraphic characters as-is") { @config.show_control_chars = true }
      opts.on("-N", "--literal", "print entry names without quoting") { } # already default behavior
      opts.on("-Q", "--quote-name", "enclose entry names in double quotes") { @config.quote_name = true }
      opts.on("--quoting-style=WORD", "use quoting style WORD") do |word|
        @config.quoting_style = case word
                                when "literal"             then QuotingStyle::Literal
                                when "shell"               then QuotingStyle::Shell
                                when "shell-always"        then QuotingStyle::ShellAlways
                                when "shell-escape"        then QuotingStyle::ShellEscape
                                when "shell-escape-always" then QuotingStyle::ShellEscapeAlways
                                when "c"                   then QuotingStyle::C
                                when "escape"              then QuotingStyle::Escape
                                when "locale"              then QuotingStyle::Locale
                                when "clocale"             then QuotingStyle::Clocale
                                else                            QuotingStyle::Literal
                                end
      end
    end

    private def add_size_options(opts : OptionParser)
      opts.separator ""
      opts.separator "size options:"
      opts.separator ""
      opts.on("-s", "--size", "print the allocated size of each file, in blocks") { @config.show_blocks = true }
      opts.on("--block-size=SIZE", "scale sizes by SIZE before printing") do |size_str|
        @config.block_size = parse_block_size(size_str)
      end
      opts.on("--si", "like -h but use powers of 1000 not 1024") { @config.si_units = true }
      opts.on("-k", "--kibibytes", "default to 1024-byte blocks for -s") { @config.kibibytes = true }
      opts.on("-w COLS", "--width=COLS", "set output width to COLS") do |cols|
        @config.width_override = cols.to_i? || 80
      end
      opts.on("-T COLS", "--tabsize=COLS", "assume tab stops at each COLS instead of 8") do |cols|
        @config.tab_size = cols.to_i? || 8
      end
    end

    private def add_time_options(opts : OptionParser)
      opts.separator ""
      opts.separator "time options:"
      opts.separator ""
      opts.on("-c", "with -lt: sort by, and show, ctime; with -l: show ctime and sort by name") do
        @config.time_field = TimeField::Change
      end
      opts.on("-u", "with -lt: sort by, and show, atime; with -l: show atime and sort by name") do
        @config.time_field = TimeField::Access
      end
      opts.on("--time=WORD", "select time: atime, access, use, ctime, status, birth") do |word|
        @config.time_field = case word
                             when "atime", "access", "use" then TimeField::Access
                             when "ctime", "status"        then TimeField::Change
                             when "birth", "creation"      then TimeField::Birth
                             else                               TimeField::Modification
                             end
      end
    end

    private def add_symlink_options(opts : OptionParser)
      opts.separator ""
      opts.separator "symlink options:"
      opts.separator ""
      opts.on("-H", "--dereference-command-line", "follow symbolic links listed on the command line") do
        @config.dereference_mode = DereferenceMode::CommandLine
      end
      opts.on("--dereference-command-line-symlink-to-dir", "follow command line symlinks that point to directories") do
        @config.dereference_mode = DereferenceMode::CommandLineDirs
      end
    end

    private def add_compatibility_options(opts : OptionParser)
      opts.separator ""
      opts.separator "options for compatibility with ls:"
      opts.separator ""
      opts.on("-h", "--human-readable", "with -l, print sizes in human readable format") { } # always active
    end

    private def add_general_options(opts : OptionParser)
      opts.separator ""
      opts.separator "general options:"
      opts.separator ""
      opts.on("--color=WHEN", "colorize: auto, always, never") do |word|
        @config.color_enabled = (word != "never") unless word == "auto"
      end
      opts.on("--light", "use light color scheme") { @config.light_colors = true }
      opts.on("--dark", "use dark color scheme") { @config.light_colors = false }
      opts.on("--hyperlink", "show hyperlinks") { @config.hyperlink = true }
    end

    private def add_stub_options(opts : OptionParser)
      opts.separator ""
      opts.on("-D", "--dired", "generate output designed for Emacs' dired mode") do
        STDERR.puts "colorls: --dired is not implemented"
      end
      opts.on("-Z", "--context", "print any security context of each file") do
        # Accept but no-op on non-SELinux systems
      end
    end

    private def parse_block_size(str : String) : Int64
      multiplier = 1_i64
      s = str.strip.upcase
      if s.ends_with?("K")
        multiplier = 1024_i64
        s = s.chomp("K")
      elsif s.ends_with?("M")
        multiplier = 1024_i64 * 1024
        s = s.chomp("M")
      elsif s.ends_with?("G")
        multiplier = 1024_i64 * 1024 * 1024
        s = s.chomp("G")
      elsif s.ends_with?("KB")
        multiplier = 1000_i64
        s = s.chomp("KB")
      elsif s.ends_with?("MB")
        multiplier = 1000_i64 * 1000
        s = s.chomp("MB")
      elsif s.ends_with?("GB")
        multiplier = 1000_i64 * 1000 * 1000
        s = s.chomp("GB")
      end
      base = s.to_i64? || 1_i64
      base * multiplier
    end

    private def show_help(opts : OptionParser)
      puts opts
      puts <<-EXAMPLES

      examples:

        * show the given file:

          colorls README.md

        * show matching files and list matching directories:

          colorls *

        * filter output by a regular expression:

          colorls | grep PATTERN

        * several short options can be combined:

          colorls -d -l -a
          colorls -dla

      EXAMPLES
    end

    private def colorize(str : String, color_key : String) : String
      return str unless @config.color_enabled?
      color_name = @config.colors[color_key]? || color_key
      ColorMap.colorize(str, color_name)
    end

    private def strxfrm(str : String) : String
      needed = ::LibC.strxfrm(nil, str, 0)
      buf = Bytes.new(needed + 1)
      ::LibC.strxfrm(buf.to_unsafe.as(Pointer(::LibC::Char)), str, buf.size)
      String.new(buf.to_unsafe, needed)
    end
  end
end
