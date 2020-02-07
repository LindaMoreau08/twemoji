# frozen_string_literal: true
require_relative "./web.rb"
require 'nokogiri'

module Twemoji
  module Utils
    module Unicode
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
        num_retrieved, folder = Twemoji::Utils::Web.get_files(unicode_url, unicode_files)

      end

      def self.get_twemoji_maxcdn_emoji_list
        twemoji_list = []
        # twitter_twemoji_list = 'https://twemoji.maxcdn.com/v/latest/'
        twitter_preview_base = 'https://twitter.github.io/twemoji/2/test/'
        list_file = 'preview.html'
        num_retrieved, folder = Twemoji::Utils::Web.get_files(twitter_preview_base, [list_file])
        if num_retrieved == 1
          begin
            local_file = folder+'/'+list_file
            document = Nokogiri::HTML.parse(open(local_file))
            tags = document.xpath("//li")
            tags.each do |tag|
              #puts "#{tag.text}"
              twemoji_list << "#{tag.text}"
              rescue StandardError => err
                puts "error parsing file #{list_file}: "
                puts err.message + "\n"
            end
          end
        end
        return twemoji_list
      end

      # the_list = self.get_twemoji_maxcdn_emoji_list
      # unless the_list.nil? or the_list.length < 1
      #   puts unpack(the_list[0])
      # end
      end
    end
  end

# process these like https://github.com/twitter/twemoji-parser/blob/4ac567db6fd31f516765a844c4ded12f339002bb/src/index.js
#  `https://twemoji.maxcdn.com/v/latest/72x72/${codepoints}.png`
#  : `https://twemoji.maxcdn.com/v/latest/svg/${codepoints}.svg`;
#
# https://en.wikipedia.org/wiki/Variation_Selectors_%28Unicode_block%29