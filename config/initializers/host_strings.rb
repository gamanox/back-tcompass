if Rails.env.development?
  ENV['URL'] = 'localhost:3000'
elsif Rails.env.test?
  ENV['URL'] = 'http://104.131.117.60'
elsif Rails.env.production?
  ENV['URL'] = ''
end
