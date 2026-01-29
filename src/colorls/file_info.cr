require "c/grp"

module Colorls
  class FileInfo
    @@users = {} of UInt32 => String
    @@groups = {} of UInt32 => String

    getter name : String
    getter parent : String
    getter path : String
    getter? dead : Bool = false

    @info : File::Info
    @show_name : String
    @target : String? = nil

    def initialize(@name : String, @parent : String, path : String? = nil,
                   link_info : Bool = true, show_filepath : Bool = false)
      @path = path || File.join(@parent, @name)
      @info = File.info(@path, follow_symlinks: false)

      handle_symlink if link_info && @info.symlink?
      @show_name = set_show_name(show_filepath)
    end

    def self.info(path : String, link_info : Bool = true, show_filepath : Bool = false) : FileInfo
      FileInfo.new(
        name: File.basename(path),
        parent: File.dirname(path),
        path: path,
        link_info: link_info,
        show_filepath: show_filepath
      )
    end

    def self.dir_entry(dir : String, child : String, link_info : Bool = true) : FileInfo
      FileInfo.new(name: child, parent: dir, link_info: link_info)
    end

    def show : String
      @show_name
    end

    def hidden? : Bool
      @name.starts_with?('.')
    end

    def directory? : Bool
      @info.directory?
    end

    def symlink? : Bool
      @info.symlink?
    end

    def socket? : Bool
      @info.type.socket?
    end

    def chardev? : Bool
      @info.type == File::Type::CharacterDevice
    end

    def blockdev? : Bool
      @info.type == File::Type::BlockDevice
    end

    def executable? : Bool
      @info.permissions.owner_execute? ||
        @info.permissions.group_execute? ||
        @info.permissions.other_execute?
    end

    def size : Int64
      @info.size
    end

    def mtime : Time
      @info.modification_time
    end

    def link_target : String?
      @target
    end

    # Raw stat for mode bits and nlink
    def raw_stat : ::LibC::Stat
      stat = uninitialized ::LibC::Stat
      if ::LibC.lstat(@path, pointerof(stat)) != 0
        raise RuntimeError.new("lstat failed for #{@path}")
      end
      stat
    end

    def nlink : Int64
      raw_stat.st_nlink.to_i64
    end

    def mode : UInt32
      raw_stat.st_mode.to_u32
    end

    def setuid? : Bool
      (mode & 0o4000) != 0
    end

    def setgid? : Bool
      (mode & 0o2000) != 0
    end

    def sticky? : Bool
      (mode & 0o1000) != 0
    end

    def owner : String
      uid = @info.owner_id.to_u32
      return @@users[uid] if @@users.has_key?(uid)
      buf = Bytes.new(1024)
      pwd = uninitialized ::LibC::Passwd
      result = Pointer(::LibC::Passwd).null
      ret = ::LibC.getpwuid_r(uid, pointerof(pwd), buf.to_unsafe.as(Pointer(::LibC::Char)), buf.size, pointerof(result))
      if ret == 0 && !result.null?
        @@users[uid] = String.new(pwd.pw_name)
      else
        @@users[uid] = uid.to_s
      end
      @@users[uid]
    end

    def group : String
      gid = @info.group_id.to_u32
      return @@groups[gid] if @@groups.has_key?(gid)
      buf = Bytes.new(1024)
      grp = uninitialized ::LibC::Group
      result = Pointer(::LibC::Group).null
      ret = ::LibC.getgrgid_r(gid, pointerof(grp), buf.to_unsafe.as(Pointer(::LibC::Char)), buf.size, pointerof(result))
      if ret == 0 && !result.null?
        @@groups[gid] = String.new(grp.gr_name)
      else
        @@groups[gid] = gid.to_s
      end
      @@groups[gid]
    end

    def to_s(io : IO) : Nil
      io << @name
    end

    private def handle_symlink
      @target = File.readlink(@path)
      @dead = !File.exists?(@path)
    rescue ex
      STDERR.puts "cannot read symbolic link: #{ex}"
    end

    private def set_show_name(show_filepath : Bool) : String
      if show_filepath && !directory?
        @path
      else
        @name
      end
    end
  end
end
