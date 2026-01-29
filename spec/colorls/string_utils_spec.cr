require "../spec_helper"

describe Colorls::StringUtils do
  describe ".uniq_chars" do
    it "returns unique characters preserving order" do
      Colorls::StringUtils.uniq_chars("aabbcc").should eq("abc")
    end

    it "handles empty string" do
      Colorls::StringUtils.uniq_chars("").should eq("")
    end

    it "handles all unique" do
      Colorls::StringUtils.uniq_chars("abc").should eq("abc")
    end

    it "handles mixed duplicates" do
      Colorls::StringUtils.uniq_chars("AMMD").should eq("AMD")
    end
  end

  describe ".colorize" do
    it "wraps string with ANSI color codes" do
      result = Colorls::StringUtils.colorize("hello", "red")
      result.should contain("hello")
      result.should contain("\e[")
      result.should contain("\e[0m")
    end

    it "returns plain string for unknown color" do
      Colorls::StringUtils.colorize("hello", "nonexistent").should eq("hello")
    end
  end

  describe ".strip_ansi" do
    it "removes ANSI escape sequences" do
      Colorls::StringUtils.strip_ansi("\e[38;2;255;0;0mhello\e[0m").should eq("hello")
    end

    it "handles strings without escapes" do
      Colorls::StringUtils.strip_ansi("hello").should eq("hello")
    end
  end
end
