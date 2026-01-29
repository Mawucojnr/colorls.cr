require "yaml"

module Colorls
  class YamlConfig
    YAML_DIR = Path[__DIR__].parent / "yaml"

    def initialize(@filename : String)
      @user_config_path = Path.home / ".config" / "colorls" / @filename
    end

    # Load YAML config, merging user overrides if present.
    # If aliase is true, non-hex values are returned as-is (symbol references in Ruby;
    # in Crystal we just keep the string value).
    def load(aliase : Bool = false) : Hash(String, String)
      yaml = read_file(YAML_DIR / @filename)

      if File.exists?(@user_config_path)
        user_yaml = read_file(@user_config_path)
        yaml.merge!(user_yaml)
      end

      yaml
    end

    private def read_file(path : Path | String) : Hash(String, String)
      content = File.read(path.to_s)
      parsed = YAML.parse(content)
      result = {} of String => String
      parsed.as_h.each do |k, v|
        result[k.as_s] = v.as_s
      end
      result
    end
  end
end
