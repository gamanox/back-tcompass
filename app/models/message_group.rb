class MessageGroup < ActiveRecord::Base
  belongs_to :group
  belongs_to :message
end
