class Plan < ActiveRecord::Base
  belongs_to :hotel

  def self.save_hotel_plan_by_scraping(hotel_id, menus)
    menus.each_with_index do |menu, index|
      new_menu = self.new
      new_menu.hotel_id = hotel_id
      new_menu.sort_no = index
      new_menu.title = menu[:title]
      new_menu.price = menu[:price]
      new_menu.url = menu[:plan_url]
      new_menu.type = nil

      new_menu.save
    end
  end

end
