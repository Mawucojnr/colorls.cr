module Colorls
  enum SortMode
    None
    Name
    Time
    Size
    Extension
    Version
  end

  enum DisplayMode
    Vertical
    Horizontal
    OnePerLine
    Long
    Tree
    Commas
  end

  enum ShowFilter
    All
    DirsOnly
    FilesOnly
  end

  enum GroupMode
    None
    DirsFirst
    FilesFirst
  end

  enum IndicatorStyle
    None
    Slash
    Classify
    FileType
  end

  enum ReportMode
    Off
    Short
    Long
  end

  enum TimeField
    Modification
    Access
    Change
    Birth
  end

  enum QuotingStyle
    Literal
    Shell
    ShellAlways
    ShellEscape
    ShellEscapeAlways
    C
    Escape
    Locale
    Clocale
  end

  enum DereferenceMode
    None
    CommandLine
    CommandLineDirs
    All
  end

  struct LongStyleOptions
    property? show_group : Bool = true
    property? show_user : Bool = true
    property time_style : String = ""
    property? hard_links_count : Bool = true
    property? show_symbol_dest : Bool = false
    property? human_readable_size : Bool = true
  end

  struct Config
    property? all : Bool = false
    property? almost_all : Bool = false
    property show : ShowFilter = ShowFilter::All
    property sort : SortMode = SortMode::Name
    property? reverse : Bool = false
    property group : GroupMode = GroupMode::None
    property mode : DisplayMode = DisplayMode::Vertical
    property? show_git : Bool = false
    property colors : Hash(String, String) = {} of String => String
    property tree_depth : Int32 = 3
    property? show_inode : Bool = false
    property indicator_style : IndicatorStyle = IndicatorStyle::Slash
    property long_style_options : LongStyleOptions = LongStyleOptions.new
    property? hyperlink : Bool = false
    property? icons : Bool = true
    property? light_colors : Bool = false
    property? color_enabled : Bool = true

    # GNU ls compatibility fields
    property? directory_mode : Bool = false
    property? show_blocks : Bool = false
    property block_size : Int64 = 1024_i64
    property time_field : TimeField = TimeField::Modification
    property quoting_style : QuotingStyle = QuotingStyle::Literal
    property hide_patterns : Array(String) = [] of String
    property ignore_patterns : Array(String) = [] of String
    property? numeric_ids : Bool = false
    property? show_author : Bool = false
    property? si_units : Bool = false
    property tab_size : Int32 = 8
    property width_override : Int32? = nil
    property? recursive : Bool = false
    property dereference_mode : DereferenceMode = DereferenceMode::None
    property? ignore_backups : Bool = false
    property? escape_chars : Bool = false
    property? hide_control_chars : Bool = false
    property? show_control_chars : Bool = false
    property? quote_name : Bool = false
    property? kibibytes : Bool = false
  end
end
