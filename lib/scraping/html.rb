module Scraping
  class Html
    @search_module = Hash.new
    def initialize
      # @search_module = {:Jalan => Scraping::Frame::Jalan.new}
      @search_module = {
        :Jalan => Scraping::Frame::Jalan.new, 
        :Rakuten => Scraping::Frame::Rakuten.new,
        :Ikkyu => Scraping::Frame::Ikkyu.new
      }
    end

    def open(key, area)
      @search_module.each_value do |model|
        model.http_open(key, area)
        model.title_search(key)
      end
    end

    def html
      html_hash = Hash.new
      @search_module.each do |key, model|
        next unless model.get_html?
        html_hash[key] = model.output
      end
      #html_hash = price_sort(html_hash)
      html_hash
    end

    private
    # 全データの金額ソート
    def price_sort(html_hash)
      price_list = Hash.new
      no_price = Hash.new
      count = 0
      html_hash.each do |key, value|
        value.each do |k, v|
          v[:site] = key.to_s
          if v[:price].blank?
            no_price.store("#{key}#{k}",v)
          else
            price_list.store(count,v)
            count += 1
          end
        end
      end
      html_hash = price_list.sort_by {|k,v| v[:price].to_i}
      no_price.each {|k,v| html_hash.push(v)}
      html_hash
    end
  end
end
