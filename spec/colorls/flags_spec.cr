require "../spec_helper"

describe Colorls::Flags do
  describe "#initialize" do
    it "creates with default args" do
      flags = Colorls::Flags.new([] of String)
      flags.should be_a(Colorls::Flags)
    end

    it "parses -a flag" do
      flags = Colorls::Flags.new(["-a"])
      flags.config.all?.should be_true
    end

    it "parses -A flag" do
      flags = Colorls::Flags.new(["-A"])
      flags.config.almost_all?.should be_true
    end

    it "parses -l flag" do
      flags = Colorls::Flags.new(["-l"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
    end

    it "parses -1 flag" do
      flags = Colorls::Flags.new(["-1"])
      flags.config.mode.should eq(Colorls::DisplayMode::OnePerLine)
    end

    it "parses --tree flag" do
      flags = Colorls::Flags.new(["--tree=2"])
      flags.config.mode.should eq(Colorls::DisplayMode::Tree)
      flags.config.tree_depth.should eq(2)
    end

    it "parses combined flags" do
      flags = Colorls::Flags.new(["-l", "-a"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.all?.should be_true
    end

    it "parses -t sort flag" do
      flags = Colorls::Flags.new(["-t"])
      flags.config.sort.should eq(Colorls::SortMode::Time)
    end

    it "parses --gs flag" do
      flags = Colorls::Flags.new(["--gs"])
      flags.config.show_git?.should be_true
    end

    it "parses --light flag" do
      flags = Colorls::Flags.new(["--light"])
      flags.config.light_colors?.should be_true
    end

    it "parses --dark flag" do
      flags = Colorls::Flags.new(["--dark"])
      flags.config.light_colors?.should be_false
    end
  end

  describe "breaking changes" do
    it "parses -d (directory mode)" do
      flags = Colorls::Flags.new(["-d"])
      flags.config.directory_mode?.should be_true
    end

    it "parses -f (GNU unsort)" do
      flags = Colorls::Flags.new(["-f"])
      flags.config.sort.should eq(Colorls::SortMode::None)
      flags.config.all?.should be_true
      flags.config.color_enabled?.should be_false
    end

    it "parses --dirs (backward compat)" do
      flags = Colorls::Flags.new(["--dirs"])
      flags.config.show.should eq(Colorls::ShowFilter::DirsOnly)
    end

    it "parses --files (backward compat)" do
      flags = Colorls::Flags.new(["--files"])
      flags.config.show.should eq(Colorls::ShowFilter::FilesOnly)
    end
  end

  describe "filter flags" do
    it "parses -B (ignore backups)" do
      flags = Colorls::Flags.new(["-B"])
      flags.config.ignore_backups?.should be_true
    end

    it "parses --hide=PATTERN" do
      flags = Colorls::Flags.new(["--hide=*.bak"])
      flags.config.hide_patterns.should eq(["*.bak"])
    end

    it "parses -I PATTERN" do
      flags = Colorls::Flags.new(["-I", "*.tmp"])
      flags.config.ignore_patterns.should eq(["*.tmp"])
    end

    it "parses --ignore=PATTERN" do
      flags = Colorls::Flags.new(["--ignore=*.log"])
      flags.config.ignore_patterns.should eq(["*.log"])
    end

    it "accumulates multiple hide patterns" do
      flags = Colorls::Flags.new(["--hide=*.bak", "--hide=*.tmp"])
      flags.config.hide_patterns.should eq(["*.bak", "*.tmp"])
    end
  end

  describe "format flags" do
    it "parses -m (commas)" do
      flags = Colorls::Flags.new(["-m"])
      flags.config.mode.should eq(Colorls::DisplayMode::Commas)
    end

    it "parses -x (horizontal)" do
      flags = Colorls::Flags.new(["-x"])
      flags.config.mode.should eq(Colorls::DisplayMode::Horizontal)
    end

    it "parses -C (vertical)" do
      flags = Colorls::Flags.new(["-C"])
      flags.config.mode.should eq(Colorls::DisplayMode::Vertical)
    end

    it "parses --format=long" do
      flags = Colorls::Flags.new(["--format=long"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
    end

    it "parses --format=single-column" do
      flags = Colorls::Flags.new(["--format=single-column"])
      flags.config.mode.should eq(Colorls::DisplayMode::OnePerLine)
    end

    it "parses --format=commas" do
      flags = Colorls::Flags.new(["--format=commas"])
      flags.config.mode.should eq(Colorls::DisplayMode::Commas)
    end

    it "parses --format=across" do
      flags = Colorls::Flags.new(["--format=across"])
      flags.config.mode.should eq(Colorls::DisplayMode::Horizontal)
    end

    it "parses --format=vertical" do
      flags = Colorls::Flags.new(["--format=vertical"])
      flags.config.mode.should eq(Colorls::DisplayMode::Vertical)
    end
  end

  describe "sort flags" do
    it "parses -U (no sort)" do
      flags = Colorls::Flags.new(["-U"])
      flags.config.sort.should eq(Colorls::SortMode::None)
    end

    it "parses -S (sort by size)" do
      flags = Colorls::Flags.new(["-S"])
      flags.config.sort.should eq(Colorls::SortMode::Size)
    end

    it "parses -X (sort by extension)" do
      flags = Colorls::Flags.new(["-X"])
      flags.config.sort.should eq(Colorls::SortMode::Extension)
    end

    it "parses -v (version sort)" do
      flags = Colorls::Flags.new(["-v"])
      flags.config.sort.should eq(Colorls::SortMode::Version)
    end

    it "parses --sort=none" do
      flags = Colorls::Flags.new(["--sort=none"])
      flags.config.sort.should eq(Colorls::SortMode::None)
    end

    it "parses --sort=size" do
      flags = Colorls::Flags.new(["--sort=size"])
      flags.config.sort.should eq(Colorls::SortMode::Size)
    end

    it "parses --sort=time" do
      flags = Colorls::Flags.new(["--sort=time"])
      flags.config.sort.should eq(Colorls::SortMode::Time)
    end

    it "parses --sort=extension" do
      flags = Colorls::Flags.new(["--sort=extension"])
      flags.config.sort.should eq(Colorls::SortMode::Extension)
    end

    it "parses --sort=version" do
      flags = Colorls::Flags.new(["--sort=version"])
      flags.config.sort.should eq(Colorls::SortMode::Version)
    end

    it "parses -r (reverse)" do
      flags = Colorls::Flags.new(["-r"])
      flags.config.reverse?.should be_true
    end
  end

  describe "long format flags" do
    it "parses -o (no group)" do
      flags = Colorls::Flags.new(["-o"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.long_style_options.show_group?.should be_false
    end

    it "parses -g (no owner)" do
      flags = Colorls::Flags.new(["-g"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.long_style_options.show_user?.should be_false
    end

    it "parses -G (no group info)" do
      flags = Colorls::Flags.new(["-G"])
      flags.config.long_style_options.show_group?.should be_false
    end

    it "parses -n (numeric IDs)" do
      flags = Colorls::Flags.new(["-n"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.numeric_ids?.should be_true
    end

    it "parses --author" do
      flags = Colorls::Flags.new(["--author"])
      flags.config.show_author?.should be_true
    end

    it "parses --full-time" do
      flags = Colorls::Flags.new(["--full-time"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.long_style_options.time_style.should eq("+%Y-%m-%d %H:%M:%S.%N %z")
    end

    it "parses --time-style=FORMAT" do
      flags = Colorls::Flags.new(["--time-style=+%Y-%m-%d"])
      flags.config.long_style_options.time_style.should eq("+%Y-%m-%d")
    end
  end

  describe "indicator flags" do
    it "parses -F (classify)" do
      flags = Colorls::Flags.new(["-F"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::Classify)
    end

    it "parses --file-type" do
      flags = Colorls::Flags.new(["--file-type"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::FileType)
    end

    it "parses --indicator-style=none" do
      flags = Colorls::Flags.new(["--indicator-style=none"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::None)
    end

    it "parses --indicator-style=classify" do
      flags = Colorls::Flags.new(["--indicator-style=classify"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::Classify)
    end

    it "parses --indicator-style=file-type" do
      flags = Colorls::Flags.new(["--indicator-style=file-type"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::FileType)
    end

    it "parses -p (slash indicator)" do
      flags = Colorls::Flags.new(["-p"])
      flags.config.indicator_style.should eq(Colorls::IndicatorStyle::Slash)
    end
  end

  describe "name transform flags" do
    it "parses -b (escape)" do
      flags = Colorls::Flags.new(["-b"])
      flags.config.escape_chars?.should be_true
    end

    it "parses -q (hide control chars)" do
      flags = Colorls::Flags.new(["-q"])
      flags.config.hide_control_chars?.should be_true
    end

    it "parses -Q (quote name)" do
      flags = Colorls::Flags.new(["-Q"])
      flags.config.quote_name?.should be_true
    end

    it "parses --quoting-style=shell" do
      flags = Colorls::Flags.new(["--quoting-style=shell"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::Shell)
    end

    it "parses --quoting-style=shell-always" do
      flags = Colorls::Flags.new(["--quoting-style=shell-always"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::ShellAlways)
    end

    it "parses --quoting-style=c" do
      flags = Colorls::Flags.new(["--quoting-style=c"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::C)
    end

    it "parses --quoting-style=escape" do
      flags = Colorls::Flags.new(["--quoting-style=escape"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::Escape)
    end

    it "parses --quoting-style=locale" do
      flags = Colorls::Flags.new(["--quoting-style=locale"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::Locale)
    end

    it "parses --quoting-style=clocale" do
      flags = Colorls::Flags.new(["--quoting-style=clocale"])
      flags.config.quoting_style.should eq(Colorls::QuotingStyle::Clocale)
    end
  end

  describe "size flags" do
    it "parses -s (show blocks)" do
      flags = Colorls::Flags.new(["-s"])
      flags.config.show_blocks?.should be_true
    end

    it "parses --block-size=4096" do
      flags = Colorls::Flags.new(["--block-size=4096"])
      flags.config.block_size.should eq(4096_i64)
    end

    it "parses --block-size=1K" do
      flags = Colorls::Flags.new(["--block-size=1K"])
      flags.config.block_size.should eq(1024_i64)
    end

    it "parses --block-size=1M" do
      flags = Colorls::Flags.new(["--block-size=1M"])
      flags.config.block_size.should eq(1024_i64 * 1024)
    end

    it "parses --si" do
      flags = Colorls::Flags.new(["--si"])
      flags.config.si_units?.should be_true
    end

    it "parses -k (kibibytes)" do
      flags = Colorls::Flags.new(["-k"])
      flags.config.kibibytes?.should be_true
    end

    it "parses -w COLS" do
      flags = Colorls::Flags.new(["-w", "120"])
      flags.config.width_override.should eq(120)
    end

    it "parses -T COLS (tabsize)" do
      flags = Colorls::Flags.new(["-T", "4"])
      flags.config.tab_size.should eq(4)
    end
  end

  describe "time flags" do
    it "parses -c (ctime)" do
      flags = Colorls::Flags.new(["-c"])
      flags.config.time_field.should eq(Colorls::TimeField::Change)
    end

    it "parses -u (atime)" do
      flags = Colorls::Flags.new(["-u"])
      flags.config.time_field.should eq(Colorls::TimeField::Access)
    end

    it "parses --time=atime" do
      flags = Colorls::Flags.new(["--time=atime"])
      flags.config.time_field.should eq(Colorls::TimeField::Access)
    end

    it "parses --time=ctime" do
      flags = Colorls::Flags.new(["--time=ctime"])
      flags.config.time_field.should eq(Colorls::TimeField::Change)
    end

    it "parses --time=birth" do
      flags = Colorls::Flags.new(["--time=birth"])
      flags.config.time_field.should eq(Colorls::TimeField::Birth)
    end

    it "parses --time=access" do
      flags = Colorls::Flags.new(["--time=access"])
      flags.config.time_field.should eq(Colorls::TimeField::Access)
    end

    it "parses --time=status" do
      flags = Colorls::Flags.new(["--time=status"])
      flags.config.time_field.should eq(Colorls::TimeField::Change)
    end
  end

  describe "recursive flag" do
    it "parses -R" do
      flags = Colorls::Flags.new(["-R"])
      flags.config.recursive?.should be_true
    end
  end

  describe "symlink flags" do
    it "parses -H (dereference command line)" do
      flags = Colorls::Flags.new(["-H"])
      flags.config.dereference_mode.should eq(Colorls::DereferenceMode::CommandLine)
    end

    it "parses --dereference-command-line-symlink-to-dir" do
      flags = Colorls::Flags.new(["--dereference-command-line-symlink-to-dir"])
      flags.config.dereference_mode.should eq(Colorls::DereferenceMode::CommandLineDirs)
    end
  end

  describe "stub flags" do
    it "parses -D without error" do
      flags = Colorls::Flags.new(["-D"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses -Z without error" do
      flags = Colorls::Flags.new(["-Z"])
      flags.should be_a(Colorls::Flags)
    end
  end

  describe "general flags" do
    it "parses --color=always" do
      flags = Colorls::Flags.new(["--color=always"])
      flags.config.color_enabled?.should be_true
    end

    it "parses --color=never" do
      flags = Colorls::Flags.new(["--color=never"])
      flags.config.color_enabled?.should be_false
    end

    it "parses --hyperlink" do
      flags = Colorls::Flags.new(["--hyperlink"])
      flags.config.hyperlink?.should be_true
    end

    it "parses --without-icons" do
      flags = Colorls::Flags.new(["--without-icons"])
      flags.config.icons?.should be_false
    end

    it "parses -i (inode)" do
      flags = Colorls::Flags.new(["-i"])
      flags.config.show_inode?.should be_true
    end
  end

  describe "flag interactions" do
    it "-f sets sort=None, all, no-color" do
      flags = Colorls::Flags.new(["-f"])
      flags.config.sort.should eq(Colorls::SortMode::None)
      flags.config.all?.should be_true
      flags.config.color_enabled?.should be_false
    end

    it "--full-time sets long + time-style" do
      flags = Colorls::Flags.new(["--full-time"])
      flags.config.mode.should eq(Colorls::DisplayMode::Long)
      flags.config.long_style_options.time_style.should_not be_empty
    end

    it "--sd sets dirs first grouping" do
      flags = Colorls::Flags.new(["--sd"])
      flags.config.group.should eq(Colorls::GroupMode::DirsFirst)
    end

    it "--sf sets files first grouping" do
      flags = Colorls::Flags.new(["--sf"])
      flags.config.group.should eq(Colorls::GroupMode::FilesFirst)
    end

    it "--group-directories-first sets dirs first" do
      flags = Colorls::Flags.new(["--group-directories-first"])
      flags.config.group.should eq(Colorls::GroupMode::DirsFirst)
    end
  end

  describe "#process" do
    it "processes current directory" do
      flags = Colorls::Flags.new([] of String)
      exit_code = flags.process
      exit_code.should eq(0)
    end

    it "returns 2 for nonexistent path" do
      flags = Colorls::Flags.new(["/nonexistent/path/that/does/not/exist"])
      exit_code = flags.process
      exit_code.should eq(2)
    end
  end
end
