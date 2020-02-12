# frozen_string_literal: true

require_relative "./web.rb"

require 'fileutils'
require 'nokogiri'

module Twemoji
  module Utils
    module Data
      # Convert raw unicode to string key version.
      #
      # e.g. 🇲🇾 converts to "1f1f2-1f1fe"
      #
      # @param unicode [String] Unicode codepoint.
      # @param connector [String] (optional) connector to join codepoints
      #
      # @return [String] codepoints of unicode join by connector argument, defaults to "-".


      def self.unpack(unicode, connector: "-")
        unicode.split("").map { |r| "%x" % r.ord }.join(connector)
      end


      # TODO: make url_base and file list into parameters
      def self.get_unicode_emoji_data
        unicode_url = 'https://unicode.org/Public/emoji/latest/'
        unicode_files = %w[emoji-data.txt emoji-sequences.txt emoji-test.txt emoji-variation-sequences.txt emoji-zwj-sequences.txt ReadMe.txt]
        # num_retrieved, folder = Twemoji::Utils::Web.get_files(unicode_url, unicode_files)
        Twemoji::Utils::Web.get_files(unicode_url, unicode_files)
      end

      def self.get_twemoji_maxcdn_emoji_list
        twemoji_list = []
        list_file = 'preview.html'
        num_retrieved, folder = Twemoji::Utils::Web.get_files(Twemoji.configuration.preview_base, [list_file])
        if num_retrieved == 1
          begin
            local_file = folder+'/'+list_file
            document = Nokogiri::HTML.parse(open(local_file))
            tags = document.xpath("//li")
            tags.each do |tag|
              hex_string = format_unpacked(unpack("#{tag.text}"))
              twemoji_list << { text: "#{tag.text}",
                                hex: format_unpacked(hex_string),
                                png: construct_twemoji_png_path(hex_string),
                                svg: construct_twemoji_svg_path(hex_string),
                                legacy_name: assign_legacy_name(hex_string)
              }
            end
          rescue StandardError => err
             warn "error parsing file #{list_file}: "
             warn err.message + "\n"
            end
          end
        return twemoji_list
      end

      def self.format_unpacked(hex_string)
        hex_string = hex_string.strip.downcase
        hex_string.sub(/-fe0f[\n\r]?$/, '')
      end

      def self.construct_twemoji_png_path(hex_string)
        Twemoji.configuration.png_base + hex_string + '.png'
      end

      def self.construct_twemoji_svg_path(hex_string)
        Twemoji.configuration.svg_base + hex_string + '.svg'
      end

      def self.archive_yml_maps
        yaml_dir = Twemoji::Utils::Web.create_folders('yaml_bak')
        data_dir = File.join(File.dirname(__FILE__), '../data/*.yml')
        num_copied = 0
        Dir.glob(data_dir).each do|f|
          FileUtils.copy(f, yaml_dir)
          num_copied += 1
        end
        num_copied
      end

      def self.assign_legacy_name(codepoints)
        Twemoji::invert_codes.has_key?(codepoints) ? Twemoji::invert_codes[codepoints] : ''
      end

      def self.assign_unicode_name(codepoints)
        #TODO:  read unicode file into hash, split by codepoints by hyphen, foreach codepoint assign name from unicode file
        # special handling for flags, skintones and maybe gender?  Multi-token unicode names may need head finding
      end

      end
    end
  end

# process these like https://github.com/twitter/twemoji-parser/blob/4ac567db6fd31f516765a844c4ded12f339002bb/src/index.js
#  `https://twemoji.maxcdn.com/v/latest/72x72/${codepoints}.png`
#  : `https://twemoji.maxcdn.com/v/latest/svg/${codepoints}.svg`;
