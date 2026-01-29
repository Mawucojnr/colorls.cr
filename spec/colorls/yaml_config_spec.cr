require "../spec_helper"

describe Colorls::YamlConfig do
  describe "#load" do
    it "loads dark_colors.yaml" do
      config = Colorls::YamlConfig.new("dark_colors.yaml")
      colors = config.load
      colors.should be_a(Hash(String, String))
      colors["dir"].should eq("dodgerblue")
      colors["dead_link"].should eq("red")
      colors["report"].should eq("white")
    end

    it "loads light_colors.yaml" do
      config = Colorls::YamlConfig.new("light_colors.yaml")
      colors = config.load
      colors["dir"].should eq("navyblue")
      colors["recognized_file"].should eq("darkgreen")
    end

    it "loads files.yaml" do
      config = Colorls::YamlConfig.new("files.yaml")
      files = config.load
      files.should be_a(Hash(String, String))
      files.size.should be > 0
    end

    it "loads folders.yaml" do
      config = Colorls::YamlConfig.new("folders.yaml")
      folders = config.load
      folders.should be_a(Hash(String, String))
      folders.size.should be > 0
    end

    it "loads file_aliases.yaml" do
      config = Colorls::YamlConfig.new("file_aliases.yaml")
      aliases = config.load(aliase: true)
      aliases.should be_a(Hash(String, String))
      aliases.size.should be > 0
    end

    it "loads folder_aliases.yaml" do
      config = Colorls::YamlConfig.new("folder_aliases.yaml")
      aliases = config.load(aliase: true)
      aliases.should be_a(Hash(String, String))
    end

    it "keys are sorted consistently" do
      config = Colorls::YamlConfig.new("dark_colors.yaml")
      colors = config.load
      colors.keys.should contain("unrecognized_file")
      colors.keys.should contain("recognized_file")
      colors.keys.should contain("dir")
    end
  end
end
