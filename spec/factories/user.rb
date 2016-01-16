FactoryGirl.define do
  factory :user do
    name                  { Faker::Name.name }
    email                 { Faker::Internet.email }
    password              "admin123"
    password_confirmation "admin123"
    status                "active"
  end
end
