FactoryBot.define do
  factory :account do
    code { 100 }
    name { 'テスト' }
    year { 2021 }
    total_account { '現預金' }
    user
  end
end