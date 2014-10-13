module ApplicationHelper
  def get_logo(site_id,hotel)
  	if hotel.nil?
      return image_tag(SITE_ID_INFO[site_id][:logo], alt: SITE_ID_INFO[site_id][:sym_site])
  	else
  	  return link_to(image_tag(SITE_ID_INFO[site_id][:logo], alt: SITE_ID_INFO[site_id][:sym_site]), hotel.url, {target: ["_blank"], style: "display: block;"})
  	end
  end

  def get_hotel_plans(hotel)
  	hotel_plans = ["", "", ""]
  	if hotel.present? && hotel.plans.present?
  	  hotel.plans.each_with_index do |plan, index|
        break if (index + 1) > MAX_PLAN
  	  	hotel_plans[index] = plan
  	  end
  	end

  	return hotel_plans
  end
end
