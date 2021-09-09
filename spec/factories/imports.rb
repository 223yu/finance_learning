FactoryBot.define do
  factory :import do
    date { Date.new(2021,1,1) }
    amount { 500 }
    description { 'テスト取込仕訳' }
    user
    association :debit, factory: :account
    association :credit, factory: :account
  end
end