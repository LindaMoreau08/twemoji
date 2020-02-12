
require 'net/http'
require 'openssl'
require 'uri'

module Twemoji
  module Utils
    module Web

    def self.resolve_url(uri_str, agent = 'curl/7.43.0', max_attempts = 10, timeout = 10)
      attempts = 0
      cookie = nil

      until attempts >= max_attempts
        attempts += 1

        url = URI.parse(uri_str)
        http = Net::HTTP.new(url.host, url.port)
        http.open_timeout = timeout
        http.read_timeout = timeout
        path = url.path
        path = '/' if path == ''
        path += '?' + url.query unless url.query.nil?

        params = { 'User-Agent' => agent, 'Accept' => '*/*' }
        params['Cookie'] = cookie unless cookie.nil?
        request = Net::HTTP::Get.new(path, params)

        if url.instance_of?(URI::HTTPS)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = http.request(request)

        case response
        when Net::HTTPSuccess then
          break
        when Net::HTTPRedirection then
          location = response['Location']
          cookie = response['Set-Cookie']
          new_uri = URI.parse(location)
          uri_str = if new_uri.relative?
                      url + location
                    else
                      new_uri.to_s
                    end
        else
          raise 'Unexpected response: ' + response.inspect
        end

      end
      raise 'Too many http redirects' if attempts == max_attempts
      uri_str
      # response.body
    end

    # TODO: make url_base and file list into parameters
    def self.get_files(base_url, files)
      require 'net/http'
      require 'uri'
      require_relative 'web.rb'

      url_base = Web.resolve_url(base_url)
      folder_name = URI(url_base).path.split('/').last
      output_dir = create_folders(folder_name)
      files_retrieved = 0
      files.each do |file|
        url = url_base + file
        # puts url
        begin
        url = URI.parse(url)
        #url = URI.parse(url)
        Net::HTTP.start(url.host) do |http|
          resp = http.get(url.path)
          outfile =  output_dir + '/' + file
          open(outfile, "wb") do |outfile|
            outfile.write( resp.body)
          end
          files_retrieved += 1
        end
        end
      rescue StandardError => err
        puts "error retrieving file #{file}: "
        puts err.message + "\n"
      end
      unless files_retrieved == files.length
        diff = files.length - files_retrieved
        warn("#{diff} files not retrieved.")
      end
      puts "#{files_retrieved} files saved in #{folder_name}."
      return files_retrieved, output_dir
    end

    def self.create_folders(folder_name)
      base_dir = File.join(File.dirname(__FILE__), '../data/')
        date_folder = Time.now.strftime("%F")
        date_dir = File.join(base_dir, date_folder)
        unless Dir.exists?(date_dir)
          Dir.mkdir(date_dir)
        end
        unless folder_name
          folder_name = Time.now.strftime("%H_%M_%S")
        end
        folder_dir = File.join(date_dir,folder_name)
        unless Dir.exists?(folder_dir)
          Dir.mkdir(folder_dir)
        end
        File.absolute_path(folder_dir)
    end


   end
 end
end


