FactoryBot.define do
  factory :journal do
    date { Date.new(2021,1,1) }
    amount { 500 }
    description { 'テスト仕訳' }
    user
    association :debit, factory: :account
    association :credit, factory: :account
  end
end