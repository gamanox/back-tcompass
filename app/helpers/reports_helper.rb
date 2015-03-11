module ReportsHelper
  def reports_data_table(reports)
    reports.map do |r|
      group_ids = GroupReport.select(:group_id).where(report_id: r.id)
      unless group_ids.empty?
        group_string = []
        groups = Group.select(:name).where("groups.id IN (?)",group_ids)
        groups.each do |g|
          group_string.push(g.name)
        end
      else
        group_string = ["-"]
      end
      [r.id,r.title,group_string.join(","),true]
    end
  end

  def create_csv(report)
    headers,report_responses = [],[]
    empleados = []
    places = []
    index_row = 0
    uresp = []
    uresp = report.pages.first.questions.first.responses
    
    headers.push("Empleado")
    headers.push("Lugar")
    
    report.pages.first.questions.first.responses.each do |respuesta|
      place = BranchResponse.find_by_response_id(Response.find(respuesta.id)).branch.name
      puts respuesta.to_yaml
      fullname= respuesta.user.name+" "+respuesta.user.last_name
      empleados.push(fullname)
      places.push(place)

    end



    report.pages.each do |page|

      page.questions.each do |question|
        headers.push(question.title)
        
        question.filtered_responses.map do |response|
          if report_responses[index_row].nil?
            report_responses[index_row] = []
          end
          report_responses[index_row].push(response.get_answer)
          index_row += 1
        end
        index_row = 0
      end
    end
    report_responses.each_with_index do |f, i|
      f.insert(0,places[i])
    end
    report_responses.each_with_index do |f, i|
      f.insert(0,empleados[i])
    end
    report_responses.insert(0,headers)
  end
  
end
