require "option_parser"

module Colorls
  class Flags
    @args : Array(String)
    @config : Config
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
          if info.directory?
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

    private def parse_options
      @parser = OptionParser.new do |opts|
        opts.banner = "Usage:  colorls [OPTION]... [FILE]..."
        opts.separator ""

        add_common_options(opts)
        add_format_options(opts)
        add_long_style_options(opts)
        add_sort_options(opts)
        add_compatibility_options(opts)
        add_general_options(opts)

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
      opts.on("-d", "--dirs", "show only directories") { @config.show = ShowFilter::DirsOnly }
      opts.on("-f", "--files", "show only files") { @config.show = ShowFilter::FilesOnly }
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
      opts.on("--indicator-style=STYLE", "append indicator: none, slash") do |style|
        @config.indicator_style = style == "none" ? IndicatorStyle::None : IndicatorStyle::Slash
      end
    end

    private def add_format_options(opts : OptionParser)
      opts.on("--format=WORD", "use format: across, horizontal, long, single-column, vertical") do |word|
        @config.mode = case word
                       when "across", "horizontal" then DisplayMode::Horizontal
                       when "vertical"             then DisplayMode::Vertical
                       when "long"                 then DisplayMode::Long
                       when "single-column"        then DisplayMode::OnePerLine
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
      opts.on("--sort=WORD", "sort by WORD: none, size, time, extension") do |word|
        @config.sort = case word
                       when "none"      then SortMode::None
                       when "time"      then SortMode::Time
                       when "size"      then SortMode::Size
                       when "extension" then SortMode::Extension
                       else                  SortMode::Name
                       end
      end
      opts.on("-r", "--reverse", "reverse order while sorting") { @config.reverse = true }
    end

    private def add_compatibility_options(opts : OptionParser)
      opts.separator ""
      opts.separator "options for compatibility with ls (ignored):"
      opts.separator ""
      opts.on("-h", "--human-readable", "") { } # always active
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
