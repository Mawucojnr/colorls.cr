module Colorls
  module StringUtils
    # Returns unique characters in a string, preserving order
    def self.uniq_chars(str : String) : String
      seen = Set(Char).new
      result = String::Builder.new
      str.each_char do |char|
        if seen.add?(char)
          result << char
        end
      end
      result.to_s
    end

    # Colorize a string using the color map
    def self.colorize(str : String, color_name : String) : String
      ColorMap.colorize(str, color_name)
    end

    # Colorize bold
    def self.colorize_bold(str : String, color_name : String) : String
      ColorMap.colorize_bold(str, color_name)
    end

    # Strip ANSI escape sequences from a string
    def self.strip_ansi(str : String) : String
      str.gsub(/\e\[[0-9;]*m/, "")
    end
  end
end
