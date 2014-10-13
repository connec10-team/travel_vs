require 'nkf'

class ScrapingController < ApplicationController
  before_filter :admin_basic_authenticate

  def hotel_save
    @format_scrapings = Array.new

    PREFECTURES.each_value do |pre_word|
      # next if pre_word != "青森"
      @scraping = Hash.new
      scraping = Scraping::Html.new
      scraping.open(pre_word, params[:state])
      @scraping = scraping.html
      @format_scrapings << format_scraping
    end

    save_scraping

    redirect_to controller: "index"
  end

  private
  def admin_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "travel" && password == "travel_0118"
    end
  end

  def save_scraping
    Hotel.transaction do
      # データを更新するために、一度レコードを全削除（hotels,plans）
      Hotel.destroy_all
      Plan.destroy_all

      # scrapingをもとにhotels,plansを登録
      @format_scrapings.each do |fs|
        fs.each do |h_name, h_info|
          Hotel.save_hotel_by_scraping(h_name, h_info)
        end
      end
    end
  end

  def format_scraping
    format_scraping = Hash.new{|h,k| h[k]={Jalan: nil,Rakuten: nil,Ikkyu: nil}}
    @scraping.each do |site_name,scr_arr|
      scr_arr.each do |hotel_info|
        hotel_name = NKF::nkf('-WwZ0', hotel_info[1][:title] )
        format_scraping[hotel_name][site_name.to_sym] = hotel_info[1]
      end
    end
    return format_scraping
  end

end
