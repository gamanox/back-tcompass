class AssetsValidator < ActiveModel::Validator
  #TODO: refactor error messages
  def validate(record)
    return unless record.new_record?
    if record.kind_of?(User)
      unless record.client.nil?
        client = record.client
        new_qty_employees =
          client.employees.where("users.is_active = true").count + 1
        if new_qty_employees > client.qty_employees
          record.errors[:qty_employees] =
            "Can't create employee,too many"
        end
      end
    elsif record.kind_of?(Branch)
      new_qty_branches =
        record.user.branches.where("branches.is_active = true").count + 1
      if new_qty_branches > record.user.qty_branches
        record.errors[:qty_branches] =
          "Can't create branch,too many"
      end
    elsif record.kind_of?(Report)
      new_qty_reports =
        record.user.reports.where("reports.is_active = true").count + 1
      if new_qty_reports > record.user.qty_reports
        record.errors[:qty_reports] =
          "Can't create report,too many"
      end
    end
  end
end
