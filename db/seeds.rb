# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(
  email: 'sample@gmail.com',
  password: 'foobar',
  name: '山田　太郎',
  year: '2021'
)

5.times do |n|
  Content.create!(
    title: "title#{n}",
    body: "body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}
    body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}body#{n}"
  )

  Account.create!(
    user_id: 1,
    year: 2021,
    code: "#{n+1}",
    name: "科目#{n+1}",
    total_account: "現預金"
  )
end

Journal.create!(
  user_id: 1,
  debit_id: 1,
  credit_id: 2,
  date: Date.new(2021, 6, 30),
  amount: 500,
  description: '食費'
)