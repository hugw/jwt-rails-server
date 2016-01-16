ActionMailer::Base.smtp_settings = {
    :port =>           '587',
    :address =>        'smtp.mandrillapp.com',
    :user_name =>      ENV['mandrill_username'],
    :password =>       ENV['mandrill_key'],
    :domain =>         'heroku.com',
    :authentication => :plain
}
ActionMailer::Base.delivery_method = :smtp
