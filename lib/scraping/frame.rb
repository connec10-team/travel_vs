require 'nokogiri'
require 'open-uri'

module Scraping
  module Frame
    def http_open(source)
      @list = source
    end

    def get_html?
      @list.present?
    end

    # タイトルに含まれているもののみ抽出する
    def title_search(key)
      str_pattern = key.gsub(/　/," ")
      delete_key = Hash.new
      @list.each do |k, v|
        str_pattern.scan(/\S+/).each do |str|
          next if str.blank?
          if v[:title].index(/#{str}/i).blank?
            delete_key.store(k, false)
          end
        end
      end
      delete_key.each do |k,v|
        # @list.delete(k)
      end
    end

    def output
      no_price = Array.new
      data = Hash.new
      @list.each do |k,v|
        if v[:menus].blank?
        elsif v[:menus][0].blank?
        elsif v[:menus][0][:price].blank?
          no_price.push(v)
        else
          data.store(k,v)
        end
      end
      data_source = data.sort_by {|k,v| v[:menus][0][:price].to_i}
      no_price.each{ |v| data_source[data_source.size] = [data_source.size, v]}
      data_source
    end

    def max_count
      3
    end

    def test_output
      @list
    end
  end
end
