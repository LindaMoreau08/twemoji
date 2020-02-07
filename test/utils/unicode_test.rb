require "test_helper"

module Twemoji
  module Utils
    class UnicodeTest < Minitest::Test
      def test_unpack
        result = Twemoji::Utils::Unicode.unpack("🇲🇾")
        assert_equal "1f1f2-1f1fe", result
      end


      def test_unpack_with_skin
        result = Twemoji::Utils::Unicode.unpack("👩‍❤️‍💋‍👩")
        assert_equal "1f469-200d-2764-fe0f-200d-1f48b-200d-1f469", result
      end

      def test_get_unicode_emoji_data
        result = Twemoji::Utils::Unicode.get_unicode_emoji_data
        assert_nothing_raised
      end


    end
  end
end
