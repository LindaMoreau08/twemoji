require "test_helper"
require_relative '../../lib/twemoji/utils/web.rb'

module Twemoji
  module Utils
    class WebTest < Minitest::Test

      def test_resolve_url_unicode_latest
        result = Twemoji::Utils::Web.resolve_url('https://unicode.org/Public/emoji/latest/')
        assert result == 'https://unicode.org/Public/emoji/12.1/'
      end

      def test_create_folders
        folder_name = 'testname'
        result = Twemoji::Utils::Web.create_folders(folder_name)
        expected = File.absolute_path(File.join(File.dirname(__FILE__), '../../lib/twemoji/data/'+Time.now.strftime("%F"),folder_name))
        assert result == expected
        assert Dir.exist?(expected)
      end

    end
  end
end
