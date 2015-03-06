class Response < ActiveRecord::Base
  belongs_to :question
  belongs_to :user
  has_many :branch_responses

  mount_uploader :image_resp, ImageRespUploader

  def get_answer
    if self.question_type.in?([1,3,4])
      self.single_resp
    elsif self.question_type == 2
      self.multiple_resp.join(",")
    elsif self.question_type == 5
      self.bool_resp
    elsif self.question_type == 6
      ENV['SERVER_HOST']+self.image_resp.url
    end
  end
end
