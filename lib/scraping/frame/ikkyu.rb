require 'nkf'

module Scraping
  module Frame
    class Ikkyu
      include Scraping::Frame
      URL="http://www.ikyu.com/ap/srch/UspW11103.aspx?kwd="
      def http_open(key, area_code = nil)

        @list = Hash.new
        super(@list)
        key = NKF.nkf("-w",key)
        url = "#{URL}#{CGI.escape(key)}"
        keyword = key

        Rails.logger.info "request Ikkyu url: #{url}"
        arr_list = Array.new
        begin
          #html = NKF.nkf("--utf8",open(url).read)
          html = open(url).read
          doc = Nokogiri::HTML(html,nil,'utf-8')
          page = doc.css('div[@class="ikyu_box_01_text m"]').css('b[@class="ll"]').inner_text.to_i / 10 + 1

          if page > 0
            page.times do |page_no|
              page_url = url + "&st=1&si=3&abc=2&pn=#{page_no + 1}"
              Rails.logger.info "request Ikkyu url: #{page_url}"
              html = NKF.nkf("--utf8",open(page_url).read)
              doc = Nokogiri::HTML(html,nil,'utf-8')
              # lists = doc.xpath('//div[@class="w740 bottom_p_5px clearfix"]')
              if page_no == 0
                lists = doc.xpath('//div[@class="w11108_eachbox clearfix bottom_m_20px"]')
              else
                lists = doc.xpath('//div[@class="w11108_eachbox clearfix bottom_m_20px mixedsrch-biz"]')
              end
              lists.each do |i|
                next unless i.present?
                arr_list.push(i)
              end
            end

          end

          arr_list.each_with_index do |value, key|
            area_text = value.css('td[@class="w11104-accinfo_h_name"]').css('span[@class="divlist_text_sub"]').inner_text
            next_flg = false
            keyword.split(" ").each do |kw|
              next_flg = true unless area_text.include?(kw)
            end
            next if next_flg
            @list[key] = Hash.new
            @list[key][:title] = value.css('span[@class="h_name"]').inner_text
            @list[key][:url] = value.css('td[@class="w11104-accinfo_h_name"]').css('a').attribute('href').value 
            @list[key][:img] = value.css('div[@class="w11104-accimg"]').css('a').css('img').attribute('src').value
            @list[key][:description] = value.css('span[@class="divlist_text_sub"]').inner_text
            @list[key][:area_word] = value.css('td[@class="w11104-accinfo_h_name"]').css('span[@class="divlist_text_sub"]').inner_text
            menu = value.css('div[@class="keyword_result_rates"]').css('tr')
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
          next if i.css('td[@class="col1 m"]').blank?
          h[:title] = i.css('td[@class="col1 m"]').inner_text
          h[:price] = i.css('td[@class="col4"]').inner_text
          h[:plan_url] = "http://www.ikyu.com"+ i.css('td[@class="col1 m"]').css('a').attribute('href').value
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
