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
        num, folder = Twemoji::Utils::Unicode.get_unicode_emoji_data
        puts "#{num}, #{folder}"
        assert num == 6
        assert folder == "/Users/linda.moreau/dev/RubymineProjects/gems/twemoji/lib/twemoji/utils/../data/12.1_2020-02-07"
      end

      def test_get_twemoji_data_complete
        result = Twemoji::Utils::Unicode.get_twemoji_maxcdn_emoji_list
        expected = 3245
        num_emoji = result.length
        puts "num_emoji==#{num_emoji}"
        assert num_emoji == expected
      end


      def test_get_twemoji_data_outputs_expected_fields
        result = Twemoji::Utils::Unicode.get_unicode_emoji_data
        #  unless result.nil? or result.length < 1
          puts result[0]
        #end
        assert result[0] = {:text=>"🀄️", :raw_hex=>"1f004-fe0f"}
      end

    end
  end
end
