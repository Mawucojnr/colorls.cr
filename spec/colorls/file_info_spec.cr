require "../spec_helper"

describe Colorls::FileInfo do
  describe ".info" do
    it "creates FileInfo for an existing file" do
      # Use spec_helper.cr itself as a test file
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.name.should eq("spec_helper.cr")
      info.directory?.should be_false
      info.size.should be > 0
    end

    it "creates FileInfo for a directory" do
      info = Colorls::FileInfo.info(__DIR__)
      info.directory?.should be_true
    end
  end

  describe ".dir_entry" do
    it "creates FileInfo for a directory entry" do
      parent = File.dirname(__DIR__)
      info = Colorls::FileInfo.dir_entry(parent, "colorls")
      info.name.should eq("colorls")
      info.directory?.should be_true
    end
  end

  describe "#show" do
    it "returns basename by default" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.show.should eq("spec_helper.cr")
    end

    it "returns path for files with show_filepath" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path, show_filepath: true)
      info.show.should eq(path)
    end
  end

  describe "#hidden?" do
    it "returns true for dotfiles" do
      # Create a temporary dotfile
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      dotfile = File.join(tmpdir, ".hidden")
      File.write(dotfile, "test")
      begin
        info = Colorls::FileInfo.info(dotfile)
        info.hidden?.should be_true
      ensure
        File.delete(dotfile)
        Dir.delete(tmpdir)
      end
    end

    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.hidden?.should be_false
    end
  end

  describe "#owner" do
    it "returns a string" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.owner.should be_a(String)
      info.owner.size.should be > 0
    end
  end

  describe "#group" do
    it "returns a string" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.group.should be_a(String)
      info.group.size.should be > 0
    end
  end

  describe "#nlink" do
    it "returns positive number" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.nlink.should be > 0
    end
  end

  describe "#mtime" do
    it "returns a Time" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.mtime.should be_a(Time)
    end
  end

  describe "symlink handling" do
    it "handles symlinks" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      target = File.join(tmpdir, "target")
      File.write(target, "content")
      link = File.join(tmpdir, "link")
      File.symlink(target, link)
      begin
        info = Colorls::FileInfo.info(link)
        info.symlink?.should be_true
        info.link_target.should eq(target)
        info.dead?.should be_false
      ensure
        File.delete(link)
        File.delete(target)
        Dir.delete(tmpdir)
      end
    end

    it "detects dead symlinks" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      link = File.join(tmpdir, "dead_link")
      File.symlink("/nonexistent/path", link)
      begin
        info = Colorls::FileInfo.info(link)
        info.symlink?.should be_true
        info.dead?.should be_true
      ensure
        File.delete(link)
        Dir.delete(tmpdir)
      end
    end
  end
end
