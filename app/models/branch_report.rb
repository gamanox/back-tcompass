class BranchReport
  include ActiveModel::Serialization
  attr_accessor :id,:user_id,:branch_id,:name,:created_at,:created_by,:created_in

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
