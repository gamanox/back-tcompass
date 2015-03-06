module EmployeesHelper
  # TODO: it works to a single group per user
  def employees_data_table(employees)
    employees.map do |e|
      group_ids = GroupsUser.select(:group_id).where(user_id: e.id)
      unless group_ids.empty?
        group_string = []
        groups = Group.select(:name).where("groups.id IN (?)",group_ids)
        groups.each do |g|
          group_string.push(g.name)
        end
      else
        group_string = ["-"]
      end
      # nombre,group,horas trabajadas,version de software,status
      [e.id,full_name(e.name,e.last_name), group_string.join(","), "-","-",e.is_active]
    end
  end

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

  def filter_by_date(users,date_params,time_zone = TIMEZONE.cst)
    case date_params[:type].to_i
    when 1
      users.each do |u|
        u.filtered_dates =
        u.employee_locations.where("employee_locations.created_at BETWEEN ? AND ? ",
        DateTime.parse("#{date_params[:start]}").beginning_of_day + time_zone,
        DateTime.parse("#{date_params[:start]}").end_of_day + time_zone)
      end
    when 2
      users.each do |u|
        u.filtered_dates =
        u.employee_locations.where("employee_locations.created_at BETWEEN ? AND ? ",
        DateTime.parse("#{date_params[:start]}").beginning_of_day + time_zone,
        DateTime.parse("#{date_params[:end]}").end_of_day + time_zone)
      end
    end
  end

  def get_kpis(users,date_params,time_zone = TIMEZONE.cst)
    case date_params[:type].to_i
    when 1
      day_start = DateTime.parse("#{date_params[:start]}").beginning_of_day
      day_end = DateTime.parse("#{date_params[:start]}").end_of_day
    when 2
      day_start = DateTime.parse("#{date_params[:start]}").beginning_of_day
      day_end = DateTime.parse("#{date_params[:end]}").end_of_day
    end
    # Lambda to get worked hours of an employee and assistances count
    time_metrics_for =
      lambda do |u|
        hour_count = 0
        assistances_count = 0

        # Get all the login and logout locations for a user
        # Order asc with created_at
        locations = u.employee_locations.select("
          employee_locations.created_at,employee_locations.location_type").
          where("employee_locations.created_at BETWEEN ? AND ? AND
          employee_locations.location_type IN (?)",
          (day_start + time_zone),(day_end + time_zone),[1,2]).order(created_at: :asc)

        # Get count of assistances
        # First get all the logins make by the user
        # Add 1 every first login of the day
        flag = true
        logins =
          locations.where("employee_locations.location_type = 1").order(created_at: :asc)
        login = logins.first.created_at unless logins.first.nil?
        logins.each do |loc|
          if flag
            flag = false
            assistances_count += 1
          elsif login.beginning_of_day < loc.created_at.beginning_of_day
            flag = true
            login = loc.created_at
          end
        end

        # This is to make sure that we end with an array of
        # [login,logout,login,logout,login,logout]
        # It iterates over the result set and ignores all the first locations
        # if they are logout.
        # From [logout,logout,login,logout,login,logout]
        # To [login,logout,login,logout]
        # TODO: what to do when [login,logout,logout,login,logout]
        flag = true
        fixed_locations = []
        locations.each do |loc|
          if flag && loc.location_type == 2 && fixed_locations.empty?
            flag = true
          else
            fixed_locations << loc
          end
        end

        # Form a new array with the form of
        # [[login,logout],[login,logout],[login,logout]]
        # Using the fixed array
        locations = fixed_locations.enum_for(:each)
        locations_ary = []
        loop do
          locations_ary << [locations.next,locations.next]
        end # EOLoop

        # Get count of worked hours
        # Worked hours: get deltas of logout-login for every time span (ary inside
        # ary returned above)
        locations_ary.each do |time_span|
          unless time_span.length < 2
            login = time_span[0].created_at
            logout = time_span[1].created_at
            hour_count += ((logout - login) / 3600)
          end
        end

        return hour_count.round(2),assistances_count
      end#EOlamda

    # Get all the counts using lambda
    attend_count = 0
    wrkd_hrs_count = 0
    reports_count = 0
    users.each do |u|
      hours,assists = time_metrics_for.call(u)
      attend_count += assists
      wrkd_hrs_count += hours
      reports_count += u.user_reports.where("user_reports.created_at BETWEEN"+
      " ? AND ?",day_start + time_zone,day_end + time_zone).count
    end
    {attendance_count: attend_count,hour_count: wrkd_hrs_count,report_count: reports_count}
  end
end
