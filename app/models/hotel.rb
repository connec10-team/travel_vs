class Hotel < ActiveRecord::Base
  has_many :plans
  
  def self.save_hotel_by_scraping(name, hotels)

    hotels.each do |site, hotel|
      next if hotel.nil?
      new_hotel = self.new
      new_hotel.site_id = SITE_ID[site]
      new_hotel.name = name
      new_hotel.url = hotel[:url]
      new_hotel.image_url = hotel[:img]
      new_hotel.description = hotel[:description]
      new_hotel.search_area_word = hotel[:area_word]
      new_hotel.save

      Plan.save_hotel_plan_by_scraping(new_hotel.id, hotel[:menus])

    end
  end

end
