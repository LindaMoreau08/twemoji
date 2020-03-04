# frozen_string_literal: true

require_relative "./web.rb"

require 'fileutils'
require 'nokogiri'
require 'iso_country_codes'

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

      @unicode_map = nil
      @twemoji_list = []

        def self.update_data(backup_yml_inplace=false)
          # archive yaml
          yaml_bak_dir, num_archived = archive_yml_maps
          puts "#{num_archived} existing yaml files archived to #{yaml_bak_dir}"

          # get unicode data
          get_unicode
          load_supplemental

          # get twejomi preview list
          puts "\n\ngetting twemoji preview list..."
          @twemoji_list, num_emoji = get_twemoji_maxcdn_emoji_list
          num_emoji = @twemoji_list.length
          puts "  #{num_emoji} emoji retrieved.\n"

          # write new yaml data
          write_yaml_files(@twemoji_list, backup_yml_inplace)
        end


      def self.get_unicode
        puts "getting unicode emoji data..."
        files_retrieved, file_dir = get_unicode_emoji_data
        puts "  #{files_retrieved} files retrieved.\n"
        if files_retrieved > 0
          @unicode_map = load_unicode_map(File.join(file_dir,'emoji-test.txt'))
        else
          warn "No files retrieved from unicode site."
        end
      end

        # TODO: make url_base and file list into parameters
        def self.get_unicode_emoji_data
          unicode_url = 'https://unicode.org/Public/emoji/latest/'
          unicode_files = %w[emoji-data.txt emoji-sequences.txt emoji-test.txt emoji-variation-sequences.txt emoji-zwj-sequences.txt ReadMe.txt]
          # num_retrieved, folder = Twemoji::Utils::Web.get_files(unicode_url, unicode_files)
          files_retrieved, output_dir = Twemoji::Utils::Web.get_files(unicode_url, unicode_files, 'unicode')
          return files_retrieved, output_dir
        end

        def self.load_unicode_map(unicode_file)
          unicode_map = {}
          entry_num = 0
          File.open(unicode_file).each do |line|
            line = line.strip
            unless line == '' or line[0] == '#'
              # 1F441 FE0F 200D 1F5E8 FE0F                 ; fully-qualified     # 👁️‍🗨️ E2.0 eye in speech bubble
              code, description = line.match(/^([0-9A-F]{4,5}(?:\s[0-9A-F]{4,5})*)\s+;[^#]+#[^E]+E[0-9.]+\s+(.+)$/).captures
              if code
                entry_num += 1
                code = code.strip.downcase.gsub(' ','-')
                description = ':' + get_unicode_shortname(description, code) + ':'
                # puts "#{entry_num}  #{code}  #{description}"
                unicode_map[code] = description
              end
            end
          end
          unicode_map
        end


      def self.load_supplemental(overwrite=false)
        if @unicode_map.nil?
          @unicode_map = {}
        end
        supplemental = Twemoji.load_yaml(Configuration::CODE_SUPP_FILE).invert
        if overwrite
          @unicode_map.merge!(supplemental)
        else
          @unicode_map = supplemental.merge!(@unicode_map)
        end
      end

        def self.get_unicode_shortname(description, code)
          description = description.strip.downcase.gsub(': ','-').gsub(' ','_')
          if description.include?('flag')
            codes = code.split('-')
            unless codes.nil? or codes.length != 2 or codes[1] == 'fe0f'
              #code_str = codes.join('')
              #code_str = [codes[0]].pack('H*').unicode_normalize(:nfd) + ' ' + [codes[1]].pack('H*')
              #puts "codestr== #{code_str} "
              description = description.gsub('flag-','').gsub('_',' ')
              begin
                country_code = IsoCountryCodes.search_by_name(description)
                alpha2 = country_code[0].alpha2.downcase
                #puts "FLAG== #{description}   CODE=#{alpha2}"
                description = "flag-#{alpha2}"
              rescue StandardError => e
                warn "No country code found for:  #{description}  (#{e.message})"
              end
            end
          end
          description
        end

        def self.get_twemoji_maxcdn_emoji_list
          twemoji_list = []
          list_file = 'preview.html'
          num_retrieved, folder = Twemoji::Utils::Web.get_files(Twemoji.configuration.preview_base, [list_file], 'twemoji')
          if num_retrieved == 1
            begin
              local_file = folder+'/'+list_file
              document = Nokogiri::HTML.parse(open(local_file))
              tags = document.xpath("//li")
              num_unicode_names = 0
              tags.each do |tag|
                hex_string = format_unpacked(unpack("#{tag.text}"))
                new_entry =    { text: "#{tag.text}",
                                  hex: format_unpacked(hex_string),
                                  png: construct_twemoji_png_path(hex_string),
                                  svg: construct_twemoji_svg_path(hex_string),
                                  legacy_name: assign_legacy_name(hex_string),
                                  unicode_name: assign_unicode_name(hex_string)
                                }
                 twemoji_list << new_entry
                if new_entry[:unicode_name]
                  num_unicode_names += 1
                end
              end
            rescue StandardError => err
              warn "error parsing file #{list_file}: "
              warn err.message + "\n"
            end
          end
          return twemoji_list, num_unicode_names
        end

        def self.format_unpacked(hex_string)
          hex_string = hex_string.strip.downcase
          hex_string = handle_variation_selector(hex_string)
          if hex_string =~ /^[0-9]+$/
            hex_string = "'" + hex_string + "'"
          end
          hex_string
        end

        def self.construct_twemoji_png_path(hex_string)
          hex_string = hex_string.gsub("'","")
          Twemoji.configuration.png_base + hex_string + '.png'
        end

        def self.construct_twemoji_svg_path(hex_string)
          hex_string = hex_string.gsub("'","")
          Twemoji.configuration.svg_base + hex_string + '.svg'
        end

      def self.archive_yml_maps
        yaml_dir = Twemoji::Utils::Web.create_folders('yaml_bak')
        bak_dir = Twemoji::Utils::Web.create_folders(File.join('yaml_bak', Time.now.strftime("%H_%M_%S")))
        data_dir = Configuration::DATA_DIR
        num_copied = 0
        yml_maps = [Configuration::CODE_MAP_FILE,
                    Configuration::PNG_MAP_FILE,
                    Configuration::SVG_MAP_FILE,
                    Configuration::CODE_SUPP_FILE]
        yml_maps.each do|f|
          FileUtils.copy(f, bak_dir)
          num_copied += 1
        end
        return data_dir, num_copied
      end

      def self.backup_yaml_in_place
        yml_maps = [Configuration::CODE_MAP_FILE,
                    Configuration::PNG_MAP_FILE,
                    Configuration::SVG_MAP_FILE,
                    Configuration::CODE_SUPP_FILE]
        date_time = Time.now.strftime("%F_%H_%M_%S")
        num_copied = 0
        yml_maps.each do|f|
          backup_file = f + ".bak_#{date_time}"
          FileUtils.copy(f, backup_file)
          num_copied += 1
        end
        num_copied
      end


        def self.assign_legacy_name(codepoints)
          codes = codepoints.gsub("'",'')
          Twemoji::invert_codes.has_key?(codes) ? Twemoji::invert_codes[codes] : ''
        end

        def self.assign_unicode_name(codepoints)
          @unicode_map ||= get_unicode
          # special handling for flags, skin-tones and maybe gender?  Multi-token unicode names may need head finding
          #
          # TODO: add tests to verify that all legacy names are accounted for (numbers match up)
          # also, make a name builder based on individual codepoints
          codes = codepoints.gsub("'",'')
          short_name = @unicode_map.key?(codes) ? @unicode_map[codes] : ''
          if short_name.nil? or short_name.strip()==''
            codes = handle_variation_selector(codes)
            short_name = @unicode_map.key?(codes) ? @unicode_map[codes] : ''
          end
          short_name.gsub(/\p{Z}+/,'_').strip
        end


      def self.handle_variation_selector(codes)
        code_list = codes.split('-')
        if code_list.length == 2 and code_list[1] == 'fe0f'
          code_list = [code_list[0]]
        end
        code_list.join('-')
      end

        # TODO:  Add option to write only unicode names (use_legacy=false)
      def self.write_yaml_files(emoji_data, backup_yml_in_place, check_urls=false)
        data_dir = Configuration::DATA_DIR
        num_written = 0
        if emoji_data
          if backup_yml_in_place
            puts "redundantly backing up yaml in place..."
            backup_yaml_in_place
            extension = ""
          else
            extension =  ".new." + Time.now.strftime("%F_%H_%M_%S")
          end
          uni_file = File.open(File.join(data_dir,"emoji-unicode.yml"+extension), "w:UTF-8")  #  ":mahjong:": 1f004
          png_file = File.open(File.join(data_dir,"emoji-unicode-png.yml"+extension), "w:UTF-8")  # ":mahjong:": https://twemoji.maxcdn.com/2/72x72/1f004.png
          svg_file = File.open(File.join(data_dir,"emoji-unicode-svg.yml"+extension), "w:UTF-8")  # ":mahjong:": https://twemoji.maxcdn.com/2/svg/1f004.svg
          err_file = File.open(File.join(data_dir,"unknown_names.yml"), "w:UTF-8")  # ":mahjong:": https://twemoji.maxcdn.com/2/svg/1f004.svg
          uni_file.write("---\n")
          png_file.write("---\n")
          svg_file.write("---\n")

          num_checked = 0
          emoji_data.each do | emoji_info|
            begin
                short_name = (emoji_info[:legacy_name].nil? or emoji_info[:legacy_name] =='') ? emoji_info[:unicode_name] : emoji_info[:legacy_name]
                num_checked += 1
                if num_checked % 100 == 0
                  warn "NUM CHECKED: #{num_checked}"
                end
                if short_name.nil? or short_name == ''
                  err_file.write("no short name for: #{emoji_info[:hex]}\n")
                else
                  uni_file.write("\"#{short_name}\": #{emoji_info[:hex]}\n")
                  if check_urls
                    if Web.url_exists(emoji_info[:png])
                      png_file.write("\"#{short_name}\": #{emoji_info[:png]}\n")
                    else
                      err_file.write("file not found: \"#{short_name}\": #{emoji_info[:png]}\n")
                    end
                    if  Web.url_exists(emoji_info[:svg])
                      svg_file.write("\"#{short_name}\": #{emoji_info[:svg]}\n")
                    else
                      err_file.write("file not found:  \"#{short_name}\": #{emoji_info[:svg]}\n")
                    end
                  else
                    png_file.write("\"#{short_name}\": #{emoji_info[:png]}\n")
                    svg_file.write("\"#{short_name}\": #{emoji_info[:svg]}\n")
                  end
                end
                num_written += 1
              rescue StandardError => e
                warn e.message
                err_file.write("#{e.message}\n")
              end
            end
            uni_file.close
            png_file.close
            svg_file.close
            err_file.close
          end
          return num_written, emoji_data.length
        end


      end
    end
   end


# process these like https://github.com/twitter/twemoji-parser/blob/4ac567db6fd31f516765a844c4ded12f339002bb/src/index.js
#  `https://twemoji.maxcdn.com/v/latest/72x72/${codepoints}.png`
#  : `https://twemoji.maxcdn.com/v/latest/svg/${codepoints}.svg`;
