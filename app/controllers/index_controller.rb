require 'nkf'

class IndexController < ApplicationController
  def index
    @select_forms = Hash.new
    @select_forms[:pre] = create_select_box(PREFECTURES)
    @select_forms[:area] = create_select_box(PRE_AREA[params[:pre][:code].to_i]) if params[:pre].present?
    @scraping = Hash.new
    if params[:area].present?
      pre_str = PREFECTURES[params[:pre][:code].to_i]
      area_str = PRE_AREA[params[:pre][:code].to_i][params[:area][:code].to_i]
      word = [pre_str,area_str].join(" ")
      scraping = Scraping::Html.new
      scraping.open(word, params[:state])
      @scraping = scraping.html
    end
    @format_scraping = format_scraping
    # @format_scraping = DBG
  end

  private
  def create_select_box(hs)
    return if hs.nil?
    option_list = Array.new
    hs.each do |code,str|
      option_list << [str,code]
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
