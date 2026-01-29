module Colorls
  # Maps CSS color names to RGB tuples and nearest ANSI 256-color indices.
  # Used to render colors from YAML config files.
  module ColorMap
    record Color, r : UInt8, g : UInt8, b : UInt8

    # Detect true-color support at load time
    class_getter? true_color : Bool = ENV["COLORTERM"]?.try { |v| v == "truecolor" || v == "24bit" } || false

    # CSS color name → RGB
    COLORS = {
      "aliceblue"            => Color.new(240, 248, 255),
      "antiquewhite"         => Color.new(250, 235, 215),
      "aqua"                 => Color.new(0, 255, 255),
      "aquamarine"           => Color.new(127, 255, 212),
      "azure"                => Color.new(240, 255, 255),
      "beige"                => Color.new(245, 245, 220),
      "bisque"               => Color.new(255, 228, 196),
      "black"                => Color.new(0, 0, 0),
      "blanchedalmond"       => Color.new(255, 235, 205),
      "blue"                 => Color.new(0, 0, 255),
      "blueviolet"           => Color.new(138, 43, 226),
      "brown"                => Color.new(165, 42, 42),
      "burlywood"            => Color.new(222, 184, 135),
      "cadetblue"            => Color.new(95, 158, 160),
      "chartreuse"           => Color.new(127, 255, 0),
      "chocolate"            => Color.new(210, 105, 30),
      "coral"                => Color.new(255, 127, 80),
      "cornflowerblue"       => Color.new(100, 149, 237),
      "cornsilk"             => Color.new(255, 248, 220),
      "crimson"              => Color.new(220, 20, 60),
      "cyan"                 => Color.new(0, 255, 255),
      "darkblue"             => Color.new(0, 0, 139),
      "darkcyan"             => Color.new(0, 139, 139),
      "darkgoldenrod"        => Color.new(184, 134, 11),
      "darkgray"             => Color.new(169, 169, 169),
      "darkgreen"            => Color.new(0, 100, 0),
      "darkgrey"             => Color.new(169, 169, 169),
      "darkkhaki"            => Color.new(189, 183, 107),
      "darkmagenta"          => Color.new(139, 0, 139),
      "darkolivegreen"       => Color.new(85, 107, 47),
      "darkorange"           => Color.new(255, 140, 0),
      "darkorchid"           => Color.new(153, 50, 204),
      "darkred"              => Color.new(139, 0, 0),
      "darksalmon"           => Color.new(233, 150, 122),
      "darkseagreen"         => Color.new(143, 188, 143),
      "darkslateblue"        => Color.new(72, 61, 139),
      "darkslategray"        => Color.new(47, 79, 79),
      "darkslategrey"        => Color.new(47, 79, 79),
      "darkturquoise"        => Color.new(0, 206, 209),
      "darkviolet"           => Color.new(148, 0, 211),
      "deeppink"             => Color.new(255, 20, 147),
      "deepskyblue"          => Color.new(0, 191, 255),
      "dimgray"              => Color.new(105, 105, 105),
      "dimgrey"              => Color.new(105, 105, 105),
      "dodgerblue"           => Color.new(30, 144, 255),
      "firebrick"            => Color.new(178, 34, 34),
      "floralwhite"          => Color.new(255, 250, 240),
      "forestgreen"          => Color.new(34, 139, 34),
      "fuchsia"              => Color.new(255, 0, 255),
      "gainsboro"            => Color.new(220, 220, 220),
      "ghostwhite"           => Color.new(248, 248, 255),
      "gold"                 => Color.new(255, 215, 0),
      "goldenrod"            => Color.new(218, 165, 32),
      "gray"                 => Color.new(128, 128, 128),
      "green"                => Color.new(0, 128, 0),
      "greenyellow"          => Color.new(173, 255, 47),
      "grey"                 => Color.new(128, 128, 128),
      "honeydew"             => Color.new(240, 255, 240),
      "hotpink"              => Color.new(255, 105, 180),
      "indianred"            => Color.new(205, 92, 92),
      "indigo"               => Color.new(75, 0, 130),
      "ivory"                => Color.new(255, 255, 240),
      "khaki"                => Color.new(240, 230, 140),
      "lavender"             => Color.new(230, 230, 250),
      "lavenderblush"        => Color.new(255, 240, 245),
      "lawngreen"            => Color.new(124, 252, 0),
      "lemonchiffon"         => Color.new(255, 250, 205),
      "lightblue"            => Color.new(173, 216, 230),
      "lightcoral"           => Color.new(240, 128, 128),
      "lightcyan"            => Color.new(224, 255, 255),
      "lightgoldenrodyellow" => Color.new(250, 250, 210),
      "lightgray"            => Color.new(211, 211, 211),
      "lightgreen"           => Color.new(144, 238, 144),
      "lightgrey"            => Color.new(211, 211, 211),
      "lightpink"            => Color.new(255, 182, 193),
      "lightsalmon"          => Color.new(255, 160, 122),
      "lightseagreen"        => Color.new(32, 178, 170),
      "lightskyblue"         => Color.new(135, 206, 250),
      "lightslategray"       => Color.new(119, 136, 153),
      "lightslategrey"       => Color.new(119, 136, 153),
      "lightsteelblue"       => Color.new(176, 196, 222),
      "lightyellow"          => Color.new(255, 255, 224),
      "lime"                 => Color.new(0, 255, 0),
      "limegreen"            => Color.new(50, 205, 50),
      "linen"                => Color.new(250, 240, 230),
      "magenta"              => Color.new(255, 0, 255),
      "maroon"               => Color.new(128, 0, 0),
      "mediumaquamarine"     => Color.new(102, 205, 170),
      "mediumblue"           => Color.new(0, 0, 205),
      "mediumorchid"         => Color.new(186, 85, 211),
      "mediumpurple"         => Color.new(147, 112, 219),
      "mediumseagreen"       => Color.new(60, 179, 113),
      "mediumslateblue"      => Color.new(123, 104, 238),
      "mediumspringgreen"    => Color.new(0, 250, 154),
      "mediumturquoise"      => Color.new(72, 209, 204),
      "mediumvioletred"      => Color.new(199, 21, 133),
      "midnightblue"         => Color.new(25, 25, 112),
      "mintcream"            => Color.new(245, 255, 250),
      "mistyrose"            => Color.new(255, 228, 225),
      "moccasin"             => Color.new(255, 228, 181),
      "navajowhite"          => Color.new(255, 222, 173),
      "navyblue"             => Color.new(0, 0, 128),
      "navy"                 => Color.new(0, 0, 128),
      "oldlace"              => Color.new(253, 245, 230),
      "olive"                => Color.new(128, 128, 0),
      "olivedrab"            => Color.new(107, 142, 35),
      "orange"               => Color.new(255, 165, 0),
      "orangered"            => Color.new(255, 69, 0),
      "orchid"               => Color.new(218, 112, 214),
      "palegoldenrod"        => Color.new(238, 232, 170),
      "palegreen"            => Color.new(152, 251, 152),
      "paleturquoise"        => Color.new(175, 238, 238),
      "palevioletred"        => Color.new(219, 112, 147),
      "papayawhip"           => Color.new(255, 239, 213),
      "peachpuff"            => Color.new(255, 218, 185),
      "peru"                 => Color.new(205, 133, 63),
      "pink"                 => Color.new(255, 192, 203),
      "plum"                 => Color.new(221, 160, 221),
      "powderblue"           => Color.new(176, 224, 230),
      "purple"               => Color.new(128, 0, 128),
      "rebeccapurple"        => Color.new(102, 51, 153),
      "red"                  => Color.new(255, 0, 0),
      "rosybrown"            => Color.new(188, 143, 143),
      "royalblue"            => Color.new(65, 105, 225),
      "saddlebrown"          => Color.new(139, 69, 19),
      "salmon"               => Color.new(250, 128, 114),
      "sandybrown"           => Color.new(244, 164, 96),
      "seagreen"             => Color.new(46, 139, 87),
      "seashell"             => Color.new(255, 245, 238),
      "sienna"               => Color.new(160, 82, 45),
      "silver"               => Color.new(192, 192, 192),
      "skyblue"              => Color.new(135, 206, 235),
      "slateblue"            => Color.new(106, 90, 205),
      "slategray"            => Color.new(112, 128, 144),
      "slategrey"            => Color.new(112, 128, 144),
      "snow"                 => Color.new(255, 250, 250),
      "springgreen"          => Color.new(0, 255, 127),
      "steelblue"            => Color.new(70, 130, 180),
      "tan"                  => Color.new(210, 180, 140),
      "teal"                 => Color.new(0, 128, 128),
      "thistle"              => Color.new(216, 191, 216),
      "tomato"               => Color.new(255, 99, 71),
      "turquoise"            => Color.new(64, 224, 208),
      "violet"               => Color.new(238, 130, 238),
      "wheat"                => Color.new(245, 222, 179),
      "white"                => Color.new(255, 255, 255),
      "whitesmoke"           => Color.new(245, 245, 245),
      "yellow"               => Color.new(255, 255, 0),
      "yellowgreen"          => Color.new(154, 205, 50),
    }

    # Parse a color string — either a CSS name or a #hex value
    def self.parse(color_str : String) : Color?
      color_str = color_str.strip.downcase
      if color_str.starts_with?('#') && color_str.size == 7
        r = color_str[1..2].to_u8(16)
        g = color_str[3..4].to_u8(16)
        b = color_str[5..6].to_u8(16)
        Color.new(r, g, b)
      else
        COLORS[color_str]?
      end
    end

    # Return the ANSI escape sequence to set foreground color
    def self.fg(color : Color) : String
      if @@true_color
        "\e[38;2;#{color.r};#{color.g};#{color.b}m"
      else
        "\e[38;5;#{to_ansi256(color)}m"
      end
    end

    # Reset ANSI color
    RESET = "\e[0m"

    # Bold/bright
    BOLD = "\e[1m"

    # Colorize a string with a named color
    def self.colorize(str : String, color_name : String) : String
      color = parse(color_name)
      return str unless color
      "#{fg(color)}#{str}#{RESET}"
    end

    # Colorize with bold
    def self.colorize_bold(str : String, color_name : String) : String
      color = parse(color_name)
      return str unless color
      "#{BOLD}#{fg(color)}#{str}#{RESET}"
    end

    # Convert RGB to nearest ANSI 256-color index
    def self.to_ansi256(color : Color) : Int32
      r, g, b = color.r.to_i, color.g.to_i, color.b.to_i

      # Check if it's close to a grayscale
      if r == g && g == b
        return 16 if r < 8
        return 231 if r > 248
        return (((r - 8).to_f / 247 * 24).round + 232).to_i
      end

      # Map to 6x6x6 color cube (indices 16-231)
      ri = (r.to_f / 255 * 5).round.to_i
      gi = (g.to_f / 255 * 5).round.to_i
      bi = (b.to_f / 255 * 5).round.to_i
      16 + 36 * ri + 6 * gi + bi
    end
  end
end
