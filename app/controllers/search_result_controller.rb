require 'nkf'

class SearchResultController < ApplicationController
  def index
    @select_forms = Hash.new
    @selected = Hash.new{|h,k| h[k] = ""}
    @scraping = Hash.new
    @select_forms[:pre] = create_select_box(PREFECTURES)
    if params[:pre].present?
      @select_forms[:area] = create_select_box(PRE_AREA[params[:pre][:code].to_i])
      @selected[:pre] = params[:pre][:code].to_i
      if params[:area].present? && PRE_AREA[params[:pre][:code].to_i]
        pre_str = PREFECTURES[params[:pre][:code].to_i]
        area_str = PRE_AREA[params[:pre][:code].to_i][params[:area][:code].to_i]
        @selected[:area] = params[:area][:code].to_i
        word = [area_str].join(" ")
        scraping = Scraping::Html.new
        scraping.open(word, params[:state])
        @scraping = scraping.html
      end
    end
    @format_scraping = format_scraping
  end

  private
  def create_select_box(hs)
    return if hs.nil?
    option_list = Array.new
    hs.each do |code,value|
      if value.instance_of?(Array)
        option_list << [value.join("・"),code]
      else
        option_list << [value,code]
      end
    end

    return option_list
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
