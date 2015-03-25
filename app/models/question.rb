class Question < ActiveRecord::Base
  attr_accessor :filtered_responses

  belongs_to :page
  has_many :responses,dependent: :destroy

  def detail_responses
    if self.question_type.in?([3,4])
      self.text_option_responses
    elsif self.question_type.in?([1,2])
      self.multiple_option_responses(self.question_type)
    elsif self.question_type == 5
      self.boolean_option_responses
    elsif self.question_type == 6 || self.question_type == 8
      self.image_option_response
    elsif self.question_type == 7
      self.matrix_option_response
    end
  end

  def text_option_responses
    self.filtered_responses.map{|r| r.single_resp}
  end

  def multiple_option_responses(question_type)
    counts = {}
    responses = self.filtered_responses
    self.options.each do |opt|
      counts[opt.to_sym] =
        if question_type == 1
          responses.where("? = responses.single_resp",opt).count
        elsif question_type == 2
          responses.where("? = ANY (responses.multiple_resp)",opt).count
        end
    end
    counts
  end

  def boolean_option_responses
    t_count = self.filtered_responses.where("responses.bool_resp = TRUE").count
    f_count = self.filtered_responses.where("responses.bool_resp = FALSE").count
    {t: t_count,f: f_count}
  end

  #TODO: check bashrc value of $URL
  def image_option_response
    self.filtered_responses.map do |q|
      ENV['URL']+q.image_resp.url
    end
  end

  def matrix_option_response
    responses = self.filtered_responses
    # First get all the responses as hashes
    resp_hashes = responses.map {|r| r.attributes}
    # For each sku,create a hash with val => empty_array
    # Used to create the string of values
    skus = self.skus
    string_hash = {}
    skus.each do |sku|
      string_hash[sku] = []
    end
    # Iterate over all the respones and add values to string array
    resp_hashes.each do |h|
      resp_hashes.each do |h|
        h["multiple_resp"].each do |table_row|
          hash_table_row = eval(table_row.gsub(/:/,"=>"))
          key = hash_table_row["sku"]
          string_hash[key].push(hash_table_row["value"])
        end
      end
    end
    # Create a row for each sku
    # Need to loop through both arrays at the same time
    skus.zip(self.options).map do |sku,name|
      # For each row
      # [sku_val,name_val,string_concat_vals]
      [sku,name,string_hash[sku].join(",")]
    end
  end

  def filter_responses(user_id = nil,branch_id = nil,date = nil,time_zone = TIMEZONE.cst)
    responses = self.responses.includes(:branch_responses)
    unless user_id.nil?
      responses = responses.where("responses.user_id = ?",user_id)
    end
    unless branch_id.nil?
      responses =
        responses.joins(:branch_responses).where("branch_responses.branch_id = ?",
        branch_id)
    end
    unless date.nil?
      responses =
        responses.joins(:branch_responses).where("responses.created_at BETWEEN ?
        AND ?",DateTime.parse(date[:start]).beginning_of_day + time_zone,
        DateTime.parse(date[:end]).end_of_day + time_zone)
    end
    self.filtered_responses = responses
    nil
  end
end
