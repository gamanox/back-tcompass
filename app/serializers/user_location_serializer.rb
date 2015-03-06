class UserLocationSerializer < ActiveModel::Serializer
  include UsersHelper

  attributes :id,:name,:locations,:reports_count

  def name
    full_name(object.name,object.last_name)
  end

  def locations
    object.filtered_dates.map do |loc|
      date = loc.created_at
      [loc.latlng,date.strftime("%d/%m/%Y"),date.strftime("%I:%M%p"),loc.location_type]
    end
  end
end
