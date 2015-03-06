class Embedded::ResponseSerializer < ActiveModel::Serializer
  attributes :id,:question_id,:user_id,:question_type,:single_resp,
    :multiple_resp,:bool_resp,:image_resp

  def image_resp
   ENV['SERVER_HOST']+object.image_resp.url unless object.image_resp.url.nil?
  end
end
