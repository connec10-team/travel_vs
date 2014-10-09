require 'nkf'

class AreaSelectController < ApplicationController
  def index
    @select_forms = Hash.new
    @selected = Hash.new{|h,k| h[k] = ""}
    @select_forms[:pre] = create_select_box(PREFECTURES)
    if params[:pre].present?
      @select_forms[:area] = create_select_box(PRE_AREA[params[:pre][:code].to_i])
      @selected[:pre] = params[:pre][:code].to_i
      if params[:area].present? && PRE_AREA[params[:pre][:code].to_i]
        @selected[:area] = params[:area][:code].to_i
      end
    end
    p "test"
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
end
