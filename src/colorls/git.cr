require "set"

module Colorls
  module Git
    EMPTY_SET = Set(String).new

    # Returns a hash mapping relative file/dir names to sets of git status modes,
    # or nil if the path is not in a git repo.
    alias GitStatus = Hash(String, Set(String))

    # Wrapper that stores a default value for missing keys
    class StatusHash
      getter data : GitStatus
      property default_value : Set(String) = EMPTY_SET

      def initialize
        @data = GitStatus.new
      end

      def [](key : String) : Set(String)
        @data.fetch(key, @default_value)
      end

      def []?(key : String) : Set(String)?
        @data[key]?
      end

      def has_key?(key : String) : Bool
        @data.has_key?(key)
      end

      def values : Array(Set(String))
        @data.values
      end

      def empty? : Bool
        @data.empty?
      end
    end

    def self.status(repo_path : String) : StatusHash?
      prefix, success = git_prefix(repo_path)
      return nil unless success && prefix

      result = StatusHash.new

      git_subdir_status(repo_path) do |mode, file|
        if file == prefix
          result.default_value = Set{mode}
        else
          rel = relative_first_component(file, prefix)
          if rel
            if result.data.has_key?(rel)
              result.data[rel].add(mode)
            else
              result.data[rel] = Set{mode}
            end
          end
        end
      end

      result
    end

    def self.colored_status_symbols(modes : Set(String) | Enumerable(String), colors : Hash(String, String)) : String
      if modes.empty?
        return StringUtils.colorize("  \u2713 ", colors["unchanged"]? || "green")
      end

      joined = modes.to_a.join
      unique = StringUtils.uniq_chars(joined).delete('!')
      padded = unique.rjust(3).ljust(4)

      padded
        .sub("?", StringUtils.colorize("?", colors["untracked"]? || "orange"))
        .sub("A", StringUtils.colorize("A", colors["addition"]? || "green"))
        .sub("M", StringUtils.colorize("M", colors["modification"]? || "yellow"))
        .sub("D", StringUtils.colorize("D", colors["deletion"]? || "red"))
    end

    private def self.git_prefix(repo_path : String) : {String?, Bool}
      output = IO::Memory.new
      status = Process.run("git", ["-C", repo_path, "rev-parse", "--show-prefix"],
        output: output, error: Process::Redirect::Close)
      if status.success?
        {output.to_s.chomp, true}
      else
        {nil, false}
      end
    rescue
      {nil, false}
    end

    private def self.git_subdir_status(repo_path : String, &)
      output = IO::Memory.new
      Process.run("git", ["-C", repo_path, "status", "--porcelain", "-z", "-unormal", "--ignored", "."],
        output: output, error: Process::Redirect::Close)

      data = output.to_s
      parts = data.split('\0')
      i = 0
      while i < parts.size
        part = parts[i]
        i += 1
        next if part.empty?

        # Format: "XY file" or "XY file" with space at position 2
        if part.size >= 4 && part[2] == ' '
          mode = part[0..1].strip
          file = part[3..]
        else
          next
        end

        yield mode, file

        # Skip the next entry for renames
        if mode.starts_with?('R')
          i += 1
        end
      end
    end

    private def self.relative_first_component(file : String, prefix : String) : String?
      if prefix.empty?
        path = Path.new(file)
      elsif file.starts_with?(prefix)
        path = Path.new(file[prefix.size..])
      else
        return nil
      end

      parts = path.parts
      return nil if parts.empty?
      parts.first
    end
  end
end
