module Colorls
  enum SortMode
    None
    Name
    Time
    Size
    Extension
  end

  enum DisplayMode
    Vertical
    Horizontal
    OnePerLine
    Long
    Tree
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
    Slash
    None
  end

  enum ReportMode
    Off
    Short
    Long
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
  end
end
