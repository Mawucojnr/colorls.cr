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

    it "sorts by extension" do
      config = default_config
      config.sort = Colorls::SortMode::Extension
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "sorts by version" do
      config = default_config
      config.sort = Colorls::SortMode::Version
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles no sort" do
      config = default_config
      config.sort = Colorls::SortMode::None
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

    it "handles commas mode" do
      config = default_config
      config.mode = Colorls::DisplayMode::Commas
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

  describe "filtering" do
    it "shows dirs only" do
      config = default_config
      config.show = Colorls::ShowFilter::DirsOnly
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(File.dirname(__DIR__))
      core.ls_dir(info)
    end

    it "shows files only" do
      config = default_config
      config.show = Colorls::ShowFilter::FilesOnly
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "grouping" do
    it "groups dirs first" do
      config = default_config
      config.group = Colorls::GroupMode::DirsFirst
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(File.dirname(__DIR__))
      core.ls_dir(info)
    end

    it "groups files first" do
      config = default_config
      config.group = Colorls::GroupMode::FilesFirst
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(File.dirname(__DIR__))
      core.ls_dir(info)
    end
  end

  describe "pattern filtering" do
    it "ignores backups" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      File.write(File.join(tmpdir, "file.txt"), "data")
      File.write(File.join(tmpdir, "file.txt~"), "backup")
      begin
        config = default_config
        config.ignore_backups = true
        config.all = true
        core = Colorls::Core.new(config)
        info = Colorls::FileInfo.info(tmpdir)
        core.ls_dir(info)
      ensure
        FileUtils.rm_rf(tmpdir)
      end
    end

    it "applies hide patterns" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      File.write(File.join(tmpdir, "file.txt"), "data")
      File.write(File.join(tmpdir, "file.bak"), "backup")
      begin
        config = default_config
        config.hide_patterns << "*.bak"
        config.all = true
        core = Colorls::Core.new(config)
        info = Colorls::FileInfo.info(tmpdir)
        core.ls_dir(info)
      ensure
        FileUtils.rm_rf(tmpdir)
      end
    end

    it "applies ignore patterns" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      File.write(File.join(tmpdir, "file.txt"), "data")
      File.write(File.join(tmpdir, "file.log"), "log")
      begin
        config = default_config
        config.ignore_patterns << "*.log"
        config.all = true
        core = Colorls::Core.new(config)
        info = Colorls::FileInfo.info(tmpdir)
        core.ls_dir(info)
      ensure
        FileUtils.rm_rf(tmpdir)
      end
    end
  end

  describe "long format extras" do
    it "handles numeric IDs" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.numeric_ids = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles show author" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.show_author = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles show blocks" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.show_blocks = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "indicator styles" do
    it "handles classify indicator" do
      config = default_config
      config.indicator_style = Colorls::IndicatorStyle::Classify
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles file-type indicator" do
      config = default_config
      config.indicator_style = Colorls::IndicatorStyle::FileType
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles no indicator" do
      config = default_config
      config.indicator_style = Colorls::IndicatorStyle::None
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "time field" do
    it "uses access time" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.time_field = Colorls::TimeField::Access
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "uses change time" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.time_field = Colorls::TimeField::Change
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "size options" do
    it "handles si units" do
      config = default_config
      config.mode = Colorls::DisplayMode::Long
      config.si_units = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles custom block size" do
      config = default_config
      config.show_blocks = true
      config.block_size = 4096_i64
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles kibibytes" do
      config = default_config
      config.show_blocks = true
      config.kibibytes = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "width override" do
    it "respects width_override" do
      config = default_config
      config.width_override = 40
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "name transforms" do
    it "handles escape_chars" do
      config = default_config
      config.escape_chars = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles hide_control_chars" do
      config = default_config
      config.hide_control_chars = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles quote_name" do
      config = default_config
      config.quote_name = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles quoting_style shell" do
      config = default_config
      config.quoting_style = Colorls::QuotingStyle::Shell
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end

    it "handles quoting_style C" do
      config = default_config
      config.quoting_style = Colorls::QuotingStyle::C
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "recursive" do
    it "handles recursive listing" do
      config = default_config
      config.recursive = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end

  describe "reverse sort" do
    it "handles reverse sorting" do
      config = default_config
      config.reverse = true
      core = Colorls::Core.new(config)
      info = Colorls::FileInfo.info(__DIR__)
      core.ls_dir(info)
    end
  end
end
