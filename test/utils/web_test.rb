require "test_helper"
require_relative '../../lib/twemoji/utils/web.rb'

module Twemoji
  module Utils
    class WebTest < Minitest::Test


      def test_resolve_url
        result = Twemoji::Utils::Web.resolve_url('https://unicode.org/Public/emoji/latest/')
        assert result == 'https://unicode.org/Public/emoji/12.1/'
      end


    end
  end
end
