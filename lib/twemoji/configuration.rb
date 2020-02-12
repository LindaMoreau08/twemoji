# frozen_string_literal: true

require "yaml"

module Twemoji
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(configuration)
    @configuration = configuration
  end

  def self.configure
    yield configuration
  end

  def self.load_yaml(path)
    YAML.safe_load(IO.read(path))
  end

  class Configuration
    DATA_DIR = File.join(File.dirname(__FILE__), "data")
    CODE_MAP_FILE = File.join(DATA_DIR, "emoji-unicode.yml")
    PNG_MAP_FILE = File.join(DATA_DIR, "emoji-unicode-png.yml")
    SVG_MAP_FILE = File.join(DATA_DIR, "emoji-unicode-svg.yml")

    attr_accessor :asset_root, :png_base, :svg_base, :preview_base, :file_ext, :class_name, :img_attrs

    def initialize
      @asset_root = "https://twemoji.maxcdn.com/2"
      @png_base = 'https://twemoji.maxcdn.com/v/latest/72x72/'
      @svg_base = 'https://twemoji.maxcdn.com/v/latest/svg/'
      @preview_base = 'https://twitter.github.io/twemoji/2/test/'
      @file_ext   = "svg"
      @class_name = "emoji"
      @img_attrs  = {}
    end
  end
end
