class EmployeeSerializer < ActiveModel::Serializer
  include UsersHelper

  attributes :id,:name,:first_name,:last_name,:email,:birthday,:phone,:stats,:is_active
  has_many :groups,serializer: Embedded::GroupSerializer
  has_many :locations
  has_many :reports,serializer: Embedded::ReportSerializer

  def name
    full_name(object.name,object.last_name)
  end

  def first_name
    object.name
  end

  def groups
    object.in_groups
  end

  def locations
    if object.filtered_dates
      object.filtered_dates.map do |loc|
        date = loc.created_at
        [loc.latlng,date.strftime("%d/%m/%Y"),date.strftime("%I:%M%p"),loc.location_type]
      end
    else
      object.employee_locations.map do |loc|
        date = loc.created_at
        [loc.latlng,date.strftime("%d/%m/%Y"),date.strftime("%I:%M%p"),loc.location_type]
      end
    end
  end

  def stats
    object.stats
  end

  def reports
    object.reports_done
  end
end
