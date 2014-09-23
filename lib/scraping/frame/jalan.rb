require 'nkf'

module Scraping
  module Frame
    class Jalan
      include Scraping::Frame
      URL="http://www.jalan.net/uw/uwp2011/uww2011init.do?keyword="
      # URL="http://localhost:3000/jalan_test"
      def http_open(key, area_code = nil)
        # hotpepperのリスト取得path
        # xpath('//body/div/div[@id="contents"]/div[@id="mainContents"]/ul[@id="listWrapper oh"]')
        # その後
        # count = 0
        # xx.children.each do |i|
        #   next if i.present?
        #   a[count] = i
        #   count += 1
        # end
        # 上記で各リストを配列でもたせることが出来る
        # エリア別設定
        # URL: serviceAreaCd=州のコード
        # エリア別コード
        # 北海道:SD
        # 北信越:SH
        # 東北:SE
        # 関東:SA
        # 東海:SC
        # 関西:SB
        # 中国:SF
        # 四国:SI
        # 九州・沖縄:SG
        #
        @list = Hash.new
        super(@list)
        key = NKF.nkf("-s",key)
        url = "#{URL}#{CGI.escape(key)}"
        if area_code
          # url.concat("&serviceAreaCd=#{area_code}")
        end
        Rails.logger.info "request jalan url: #{url}"
        arr_list = Array.new
        begin
          html = NKF.nkf("--utf8",open(url).read)
          doc = Nokogiri::HTML(html,nil,'utf-8')
          lists = doc.xpath('//div[@class="result"]')

          lists.each do |i|
            next unless i.present?
            arr_list.push(i)
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
            menu = value.css('div[@class="plan-box"]').css('li')
            # puts "#{key}xxxxxxxxxxxx",@list[key]
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
        cut = Array.new
        normal = Array.new
        cache.each do |i|
          if i[:title].index(/カット/)
            i[:type] = :cut
            cut.push(i)
          else
            i[:type] = :normal
            normal.push(i)
          end
        end
        count = max_count - cut.size
        if count > 0
          1.upto(count) do |i|
            cut.push(normal[i-1])
          end
        end
        cut
      end

      def extraction(value)
        cache = Array.new
        value.each do |i|
          h = Hash.new
          h[:title] = i.css('p[@class="detail"]').css('a').inner_text
          h[:price] = i.css('p[@class="price"]').inner_text
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
