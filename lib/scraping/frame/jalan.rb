require 'nkf'

module Scraping
  module Frame
    class Jalan
      include Scraping::Frame
      URL="http://www.jalan.net/uw/uwp2011/uww2011init.do?keyword="
      # URL="http://localhost:3000/jalan_test"
      def http_open(key, area_code = nil)
        @list = Hash.new
        super(@list)
        key = NKF.nkf("-s",key)
        url = "#{URL}#{CGI.escape(key)}"
        arr_list = Array.new

        begin
          html = NKF.nkf("--utf8",open(url).read)
          doc = Nokogiri::HTML(html,nil,'utf-8')
          page = doc.css('div[@class="src-navi clearfix"]').css('span[@class="s18_f60b"]').inner_text.to_i / 30 + 1

          if page > 0
            page.times do |page_no|
              page_url = url + "&dispStartIndex=#{30*page_no}"
              Rails.logger.info "request jalan url: #{page_url}"
              
              html = NKF.nkf("--utf8",open(page_url).read)
              doc = Nokogiri::HTML(html,nil,'utf-8')
              lists = doc.xpath('//div[@class="result"]')

              lists.each do |i|
                next unless i.present?
                arr_list.push(i)
              end
            end

            arr_list.each_with_index do |value, key|
              @list[key] = Hash.new
              title = value.css('p[@class="s16_33b"]').css('a').inner_text
              @list[key][:title] = value.css('p[@class="s16_33b"]').css('a').inner_text
              turl = value.css('p[@class="s16_33b"]').css('a').attribute('href').value
              turl = turl[turl.index("'")+1..turl.rindex("'")-1]
              @list[key][:url] = "http://www.jalan.net/yad#{turl}" 
              @list[key][:img] = "http://www.jalan.net" + value.css('div').css('a').css('img').attribute('src').value
              @list[key][:description] = value.css('p[@class="exp s12_33"]').inner_text
              @list[key][:area_word] = value.css('p[@class="hd-l"]').inner_text
              menu = value.css('div[@class="plan-box"]').css('li')
              set_menu(key, menu)
            end
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
          h[:title] = i.css('p[@class="detail"]').css('a').inner_text
          h[:price] = i.css('p[@class="price"]').inner_text
          h[:plan_url] = create_plan_url(i.css('p[@class="detail"]').css('a').attribute('href').value)
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

      def create_plan_url(href)
        arr = href.scan(/[0-9]+/)
        return "http://www.jalan.net/uw/uwp3200/uww3201init.do?yadNo=#{arr[0]}&planCd=#{arr[1]}&roomTypeCd=#{arr[2]}"
      end
    end
  end
end
