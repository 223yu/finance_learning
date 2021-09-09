FactoryBot.define do
  factory :user do
    name { Faker::Lorem.characters(number: 10) }
    email { Faker::Internet.email }
    year { 0 }
    password { 'password' }
    password_confirmation { 'password' }
  end
end