require "../spec_helper"

describe Colorls::FileInfo do
  describe ".info" do
    it "creates FileInfo for an existing file" do
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

  describe "#atime" do
    it "returns a Time" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.atime.should be_a(Time)
    end
  end

  describe "#ctime" do
    it "returns a Time" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.ctime.should be_a(Time)
    end
  end

  describe "#blocks" do
    it "returns an Int64" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.blocks.should be_a(Int64)
      info.blocks.should be >= 0
    end
  end

  describe "#uid and #gid" do
    it "uid returns UInt32" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.uid.should be_a(UInt32)
    end

    it "gid returns UInt32" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.gid.should be_a(UInt32)
    end
  end

  describe "#owner_or_uid" do
    it "returns numeric string when numeric=true" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      result = info.owner_or_uid(true)
      result.should eq(info.uid.to_s)
    end

    it "returns name string when numeric=false" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      result = info.owner_or_uid(false)
      result.should eq(info.owner)
    end
  end

  describe "#group_or_gid" do
    it "returns numeric string when numeric=true" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      result = info.group_or_gid(true)
      result.should eq(info.gid.to_s)
    end

    it "returns name string when numeric=false" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      result = info.group_or_gid(false)
      result.should eq(info.group)
    end
  end

  describe "#author" do
    it "returns same as owner" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.author.should eq(info.owner)
    end
  end

  describe "#time_for" do
    it "returns mtime for Modification" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.time_for(Colorls::TimeField::Modification).should be_a(Time)
    end

    it "returns atime for Access" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.time_for(Colorls::TimeField::Access).should be_a(Time)
    end

    it "returns ctime for Change" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.time_for(Colorls::TimeField::Change).should be_a(Time)
    end
  end

  describe "#size" do
    it "returns Int64" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.size.should be_a(Int64)
      info.size.should be > 0
    end
  end

  describe "#mode" do
    it "returns UInt32" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.mode.should be_a(UInt32)
    end
  end

  describe "#executable?" do
    it "detects executable files" do
      tmpdir = File.tempname("colorls_test")
      Dir.mkdir(tmpdir)
      exe = File.join(tmpdir, "test_exec")
      File.write(exe, "#!/bin/sh\necho hi")
      File.chmod(exe, 0o755)
      begin
        info = Colorls::FileInfo.info(exe)
        info.executable?.should be_true
      ensure
        File.delete(exe)
        Dir.delete(tmpdir)
      end
    end

    it "returns false for non-executable files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.executable?.should be_false
    end
  end

  describe "#pipe?" do
    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.pipe?.should be_false
    end
  end

  describe "#socket?" do
    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.socket?.should be_false
    end
  end

  describe "#chardev?" do
    it "returns true for /dev/null" do
      info = Colorls::FileInfo.info("/dev/null")
      info.chardev?.should be_true
    end

    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.chardev?.should be_false
    end
  end

  describe "#blockdev?" do
    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.blockdev?.should be_false
    end
  end

  describe "#setuid? #setgid? #sticky?" do
    it "returns false for regular files" do
      path = File.join(__DIR__, "../spec_helper.cr")
      info = Colorls::FileInfo.info(path)
      info.setuid?.should be_false
      info.setgid?.should be_false
      info.sticky?.should be_false
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
