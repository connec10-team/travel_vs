module Scraping
  module Frame
    class Vivivi
      include Scraping::Frame
      URL = "http://www.vi-vi-vi.com"
      def http_open(key, area_code = nil)
        # b = a.xpath('//body/div/div/div[@class="pos_r clearfix"]/div[@class="clearfix"]/div[@id="shop_main"]')
        # b.children.css('div[@class="outer_shop_li"]').each do |i|
        #   next unless i.present?
        # end
        url = "#{URL}/fword#{CGI.escape(key)}/"
        Rails.logger.info "rewuest vivivi url: #{url}"
        @list = Hash.new
        arr_list = Array.new
        begin
          html = Nokogiri::HTML(open(url))
          lists = html.xpath('//body/div/div/div[@class="pos_r clearfix"]/div[@class="clearfix"]/div[@id="shop_main"]')
          lists.children.css('div[@class="outer_shop_li"]').each do |i|
            next unless i.present?
            arr_list.push(i)
          end
          arr_list.each_with_index do |value, key|
            @list[key] = Hash.new
            @list[key][:title] = value.css('div').css('div').css('div').css('h4').inner_text
            @list[key][:url] = URL+ value.css('div').css('div').css('div').css('h4').css('a').attribute('href').value
            @list[key][:img] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="thumb_large"]').css('img').attribute('src').value
            #@list[key][:description] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="shop_txt b_spc5"]').inner_text
            @list[key][:description] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="shop_txt b_spc5"]').css('h5').inner_text
            @list[key][:menu] = value.css('div[@class="shop_list_inner clearfix"]').css('div[@class="coupon"]').css('ul').css('span[@class="wd420"]').first.inner_text
            @list[key][:menu_url] = @list[key][:url]
            set_menu(key,value.css('div[@class="shop_list_inner clearfix"]').css('div[@class="coupon"]'))
          #    @list[key][:price] = price.first.inner_text.gsub(/[^0-9]/,"")
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
        if value.css('div[@class="bg_pink"]')
          h = Hash.new
          h[:title] = value.css('div[@class="bg_pink"]').css('span[@class="bold"]').inner_text
          price = value.css('div[@class="bg_pink"]').css('div[@class="rignt_area"]').inner_text
          if price.blank?
            h[:price] = ""
          else
            h[:price] = price.gsub(/[^0-9]/,"")
          end
          cache.push(h)
        end
        value.css('li').each do |i|
          h = Hash.new
          h[:title] = i.css('span[@class="wd420"]').inner_text
          idx = i.css('span[@class="coupon_discount_price"]').inner_text
          if idx.blank?
            h[:price] = ""
          else
            h[:price] = idx.gsub(/[^0-9]/,"")
          end
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
