require "test_helper"

module Twemoji
  module Utils
    class DataTest < Minitest::Test
      def test_unpack
        result = Twemoji::Utils::Data.unpack("🇲🇾")
        assert_equal "1f1f2-1f1fe", result
      end


      def test_unpack_with_skin
        result = Twemoji::Utils::Data.unpack("👩‍❤️‍💋‍👩")
        assert_equal "1f469-200d-2764-fe0f-200d-1f48b-200d-1f469", result
      end


      def test_get_unicode_emoji_data
        num, folder = Twemoji::Utils::Data.get_unicode_emoji_data
        puts "#{num}, #{folder}"
        assert num == 6
      end


      def test_format_twemoji_data
        result = Twemoji::Utils::Data.format_unpacked('1f004-fe0f')
        expected = '1f004'
        puts "result==#{result}"
        assert result == expected
      end


      def test_get_twemoji_data_complete
        result = Twemoji::Utils::Data.get_twemoji_maxcdn_emoji_list
        expected = 3245  # num emoji in v 12.1
        num_emoji = result.length
        puts "num_emoji==#{num_emoji}"
        assert num_emoji >= expected
      end


      def test_get_twemoji_data_outputs_expected_fields
        result = Twemoji::Utils::Data.get_twemoji_maxcdn_emoji_list
        #  unless result.nil? or result.length < 1
          puts result[0]
        #end
        assert result[0] == {:text=>"🀄️",
                             :hex=>"1f004",
                             :png=>"https://twemoji.maxcdn.com/v/latest/72x72/1f004.png",
                             :svg=>"https://twemoji.maxcdn.com/v/latest/svg/1f004.svg",
                             :legacy_name=>':mahjong:'}
      end


      def test_archive_yml_maps
        num_copied = Twemoji::Utils::Data.archive_yml_maps
        assert 3 == num_copied
      end

    end
  end
end
