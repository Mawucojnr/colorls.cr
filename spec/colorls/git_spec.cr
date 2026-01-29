require "../spec_helper"
require "file_utils"

describe Colorls::Git do
  describe ".status" do
    it "returns nil for non-git directories" do
      tmpdir = File.tempname("colorls_git_test")
      Dir.mkdir(tmpdir)
      begin
        Colorls::Git.status(tmpdir).should be_nil
      ensure
        Dir.delete(tmpdir)
      end
    end

    it "returns hash for git repositories" do
      tmpdir = File.tempname("colorls_git_test")
      Dir.mkdir(tmpdir)
      begin
        Process.run("git", ["init"], chdir: tmpdir, output: Process::Redirect::Close, error: Process::Redirect::Close)
        Process.run("git", ["config", "user.email", "test@test.com"], chdir: tmpdir, output: Process::Redirect::Close)
        Process.run("git", ["config", "user.name", "Test"], chdir: tmpdir, output: Process::Redirect::Close)

        result = Colorls::Git.status(tmpdir)
        result.should_not be_nil
      ensure
        FileUtils.rm_rf(tmpdir) if Dir.exists?(tmpdir)
      end
    end

    it "detects untracked files" do
      tmpdir = File.tempname("colorls_git_test")
      Dir.mkdir(tmpdir)
      begin
        Process.run("git", ["init"], chdir: tmpdir, output: Process::Redirect::Close, error: Process::Redirect::Close)
        Process.run("git", ["config", "user.email", "test@test.com"], chdir: tmpdir, output: Process::Redirect::Close)
        Process.run("git", ["config", "user.name", "Test"], chdir: tmpdir, output: Process::Redirect::Close)
        File.write(File.join(tmpdir, "newfile.txt"), "hello")

        result = Colorls::Git.status(tmpdir)
        result.should_not be_nil
        if result
          result.data["newfile.txt"]?.should_not be_nil
          result["newfile.txt"].should contain("??")
        end
      ensure
        FileUtils.rm_rf(tmpdir) if Dir.exists?(tmpdir)
      end
    end
  end

  describe ".colored_status_symbols" do
    it "returns checkmark for empty modes" do
      result = Colorls::Git.colored_status_symbols(Set(String).new, {} of String => String)
      result.should contain("\u2713")
    end

    it "formats status symbols" do
      modes = Set{"M"}
      result = Colorls::Git.colored_status_symbols(modes, {"modification" => "yellow"})
      result.should contain("M")
    end
  end
end
