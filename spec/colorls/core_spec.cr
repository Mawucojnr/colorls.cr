require "../spec_helper"
require "file_utils"

private def default_config : Colorls::Config
  config = Colorls::Config.new
  config.colors = Colorls::YamlConfig.new("dark_colors.yaml").load
  config
end

describe Colorls::Core do
  describe "#initialize" do
    it "creates a Core instance with default config" do
      core = Colorls::Core.new(default_config)
      core.should be_a(Colorls::Core)
    end
  end

  describe "#ls_dir" do
    it "lists current directory without error" do
      config = default_config
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      # Just test it doesn't raise
      core.ls_dir(info)
    end
  end

  describe "#ls_files" do
    it "lists files without error" do
      config = default_config
      core = Colorls::Core.new(config)
      files = [Colorls::FileInfo.info(File.join(__DIR__, "../spec_helper.cr"))]
      core.ls_files(files)
    end
  end

  describe "#display_report" do
    it "displays short report" do
      config = default_config
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
      core.display_report(Colorls::ReportMode::Short)
    end

    it "displays long report" do
      config = default_config
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
      core.display_report(Colorls::ReportMode::Long)
    end
  end

  describe "sorting" do
    it "sorts by name" do
      config = default_config
      config.sort = Colorls::SortMode::Name
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "sorts by size" do
      config = default_config
      config.sort = Colorls::SortMode::Size
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "sorts by time" do
      config = default_config
      config.sort = Colorls::SortMode::Time
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "display modes" do
    it "handles long format" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles one per line" do
      config = default_config
      config.mode = Colorls::DisplayMode::OnePerLine
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles horizontal" do
      config = default_config
      config.mode = Colorls::DisplayMode::Horizontal
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "tree mode" do
    it "handles tree display" do
      config = default_config
      config.mode = Colorls::DisplayMode::Tree
      config.tree_depth = 1
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end
end
