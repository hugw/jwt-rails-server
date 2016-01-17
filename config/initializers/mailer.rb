ActionMailer::Base.delivery_method = :smtp

if Rails.env.development? or Rails.env.test?
  ActionMailer::Base.smtp_settings = {
    :port =>     '1025',
    :address =>  'localhost'
  }
else
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com',
    :enable_starttls_auto => true
  }
end
