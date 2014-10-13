require 'nkf'

module Scraping
  module Frame
    class Rakuten
      include Scraping::Frame
      URL="http://kw.travel.rakuten.co.jp/keyword/Search.do?charset=utf-8&f_max=30&lid=topC_search_keyword&f_query="
      # URL="http://localhost:3000/jalan_test"
      def http_open(key, area_code = nil)
        @list = Hash.new
        super(@list)
        # key = NKF.nkf("-s",key)
        keyword = key
        url = "#{URL}#{CGI.escape(key)}"
        if area_code
          # url.concat("&serviceAreaCd=#{area_code}")
        end
        Rails.logger.info "request rakutenTravel url: #{url}"
        arr_list = Array.new
        begin
          html = NKF.nkf("--utf8",open(url).read)
          doc = Nokogiri::HTML(html,nil,'utf-8')
          page = doc.css('p[@class="pagingTitle"]').css('span').css('em')[0].inner_text.to_i / 30 + 1
          if page > 0
            page.times do |page_no|
              page_url = url + "&f_next=#{page_no+1}"
              Rails.logger.info "request jalan url: #{page_url}"
              
              html = NKF.nkf("--utf8",open(page_url).read)
              doc = Nokogiri::HTML(html,nil,'utf-8')
              lists = doc.xpath('//div[@class="hotelBox"]')
              lists.each do |i|
                next unless i.present?
                arr_list.push(i)
              end
            end
          end

          arr_list.each_with_index do |value, key|
            area_text = value.css('span[@class="city"]').inner_text
            next_flg = false
            keyword.split(" ").each do |kw|
              next_flg = true unless area_text.include?(kw)
            end
            next if next_flg

            @list[key] = Hash.new
            @list[key][:title] = value.css('span[@class="hotelName"]').inner_text
            @list[key][:url] = value.css('h2').css('a').attribute('href').value 
            @list[key][:img] = value.css('p[@class="hotelPhoto"]').css('a').css('img').attribute('src').value
            @list[key][:description] = value.css('dl[@class="hotelOutline"]').css('dd[@class="hotelCharacter"]').inner_text
            @list[key][:area_word] = value.css('span[@class="city"]').inner_text
            menu = value.css('dd[@class="planInfo"]').css('div[@class="planBox"]')
            set_menu(key, menu)
          end
        rescue Exception => e
          Rails.logger.error e.message
        end
      end

      def set_menu(key, value)
        cache = extraction(value)
        menu = menu_selection(cache)
        @list[key][:menus] = menu
      end

      def menu_selection(cache)
        cache
      end

      def extraction(value)
        cache = Array.new
        value.each do |i|
          h = Hash.new
          h[:title] = i.css('h3').css('a').inner_text
          h[:price] = i.css('dd[@class="plnPrc"]').inner_text
          h[:plan_url] = i.css('h3').css('a').attribute('href').value

          cache.push(h)
        end

        price_sort(cache)
      end

      def price_sort(value)
        no_price = Array.new
        price = Array.new
        value.each do |i|
          if i[:price].blank?
            no_price.push(i)
          else
            price.push(i)
          end
        end
        data = price.sort_by {|i| i[:price].to_i}
        no_price.each {|v| data[data.size] = v}
        data
      end
    end
  end
end
