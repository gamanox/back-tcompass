class UserSerializer < ActiveModel::Serializer
  include UsersHelper

  attributes :id,:token,:name,:access_type

  def name
    full_name(object.name,object.last_name)
  end

  #TODO: extract method to helper or model
  def access_type
    if object.employee_id
      2
    elsif object.client_id
      1
    else
      0
    end
  end
end
