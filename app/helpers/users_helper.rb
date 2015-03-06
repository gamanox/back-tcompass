module UsersHelper
  def full_name(name,last_name)
    begin
      if !name.nil? && !last_name.nil?
        "#{name} #{last_name}"
      elsif !name.nil? && last_name.nil?
        name
      elsif name.nil? && !last_name.nil?
        last_name
      end
    rescue
      "N/A"
    end
  end
end
