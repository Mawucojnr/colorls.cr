require "../spec_helper"

describe Colorls::Flags do
  describe "#initialize" do
    it "creates with default args" do
      flags = Colorls::Flags.new([] of String)
      flags.should be_a(Colorls::Flags)
    end

    it "parses -a flag" do
      flags = Colorls::Flags.new(["-a"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses -l flag" do
      flags = Colorls::Flags.new(["-l"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses -1 flag" do
      flags = Colorls::Flags.new(["-1"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses --tree flag" do
      flags = Colorls::Flags.new(["--tree=2"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses combined flags" do
      flags = Colorls::Flags.new(["-l", "-a"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses sort flags" do
      flags = Colorls::Flags.new(["-t"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses --gs flag" do
      flags = Colorls::Flags.new(["--gs"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses --light flag" do
      flags = Colorls::Flags.new(["--light"])
      flags.should be_a(Colorls::Flags)
    end

    it "parses --dark flag" do
      flags = Colorls::Flags.new(["--dark"])
      flags.should be_a(Colorls::Flags)
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
