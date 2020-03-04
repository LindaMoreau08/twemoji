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
        #  assert '1f004' == Twemoji::Utils::Data.format_unpacked('1f004-fe0f')
        assert "'1234'" == Twemoji::Utils::Data.format_unpacked('1234')
      end


      # TODO: change to true for testing or debugging data updater capability, this writes and alters yaml files
      test_data_updater = true
      if test_data_updater

        def test_get_twemoji_data_complete
          result, num_unicode_names = Twemoji::Utils::Data.get_twemoji_maxcdn_emoji_list
          expected = 3245  # num emoji in v 12.1
          num_emoji = result.length
          puts "num_emoji==#{num_emoji}"
          assert num_emoji >= expected
          assert num_emoji == num_unicode_names
        end


        def test_get_twemoji_data_outputs_expected_fields
          result, num_uninames = Twemoji::Utils::Data.get_twemoji_maxcdn_emoji_list
          #  unless result.nil? or result.length < 1
            puts result[0]
            puts num_uninames
          #end
          assert result[0] == {:text=>"🀄️",
                               :hex=>"1f004",
                               :png=>"https://twemoji.maxcdn.com/v/latest/72x72/1f004.png",
                               :svg=>"https://twemoji.maxcdn.com/v/latest/svg/1f004.svg",
                               :legacy_name=>':mahjong:',
                               :unicode_name=>':mahjong_red_dragon:'
          }
        end

        def test_load_supplemental
          supplemental = Twemoji::Utils::Data.load_supplemental
          assert supplemental.length > 1
        end

        def test_archive_yml_maps
          data_dir, num_copied = Twemoji::Utils::Data.archive_yml_maps
          puts "data dir is #{data_dir}"
          assert 4 == num_copied
        end


        if false
          def test_backup_yaml_in_place
            num_bak = Twemoji::Utils::Data.backup_yaml_in_place
            assert 4 == num_bak
          end
        end


        def test_write_yaml
            emoji_data = [{:text=>"🀄️",
                        :hex=>"1f004",
                        :png=>"https://twemoji.maxcdn.com/v/latest/72x72/1f004.png",
                        :svg=>"https://twemoji.maxcdn.com/v/latest/svg/1f004.svg",
                        :legacy_name=>':mahjong:',
                        :unicode_name=>':mahjong_red_dragon:'
                       }]
            num_written, num_emoji = Twemoji::Utils::Data.write_yaml_files(emoji_data, false)
            assert  num_written == num_emoji
        end


        def test_update_data
          num_written, num_expected = Twemoji::Utils::Data.update_data(false)
          puts "num written: #{num_written}"
          puts "num expected: #{num_expected}"
          assert 3245 <= num_written
        end

        def test_handle_variation_selector
          assert Twemoji::Utils::Data.handle_variation_selector('1234-fe0f') == '1234'
          assert Twemoji::Utils::Data.handle_variation_selector('1234-5678-fe0f') == '1234-5678-fe0f'
        end

      end # (end .if test_data_updater)
    end
  end
end
