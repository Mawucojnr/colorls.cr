require "yaml"

module Colorls
  class YamlConfig
    YAML_DIR = Path[__DIR__].parent / "yaml"

    # Embed all YAML files at compile time so the binary is self-contained.
    EMBEDDED_YAML = {
      "dark_colors.yaml"    => {{ read_file("#{__DIR__}/../yaml/dark_colors.yaml") }},
      "light_colors.yaml"   => {{ read_file("#{__DIR__}/../yaml/light_colors.yaml") }},
      "files.yaml"          => {{ read_file("#{__DIR__}/../yaml/files.yaml") }},
      "file_aliases.yaml"   => {{ read_file("#{__DIR__}/../yaml/file_aliases.yaml") }},
      "folders.yaml"        => {{ read_file("#{__DIR__}/../yaml/folders.yaml") }},
      "folder_aliases.yaml" => {{ read_file("#{__DIR__}/../yaml/folder_aliases.yaml") }},
    }

    def initialize(@filename : String)
      @user_config_path = Path.home / ".config" / "colorls" / @filename
    end

    # Load YAML config, merging user overrides if present.
    def load(aliase : Bool = false) : Hash(String, String)
      yaml = parse_yaml(EMBEDDED_YAML[@filename])

      if File.exists?(@user_config_path)
        user_yaml = parse_yaml(File.read(@user_config_path))
        yaml.merge!(user_yaml)
      end

      yaml
    end

    private def parse_yaml(content : String) : Hash(String, String)
      parsed = YAML.parse(content)
      result = {} of String => String
      parsed.as_h.each do |k, v|
        result[k.as_s] = v.as_s
      end
      result
    end
  end
end
