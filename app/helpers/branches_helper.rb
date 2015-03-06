module BranchesHelper
  def branches_data_table(branches)
    branches.map do |b|
      [b.id,b.name,b.address,b.latlng,b.is_active]
    end
  end
end
