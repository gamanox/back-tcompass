module CustomErrors
  class Unauthorized < StandardError
    attr_reader :log_info

    #TODO: find why i can't add a method
    def initialize(data)
      @data = data
      @log_info = "User is not authorized to perform this action"
    end
  end

  class NoSession < StandardError
    attr_reader :log_info

    def initialize(data)
      @data = data
      @log_info = "No session"
    end
  end
end
