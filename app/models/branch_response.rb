class BranchResponse < ActiveRecord::Base
  belongs_to :branch
  belongs_to :response
end
