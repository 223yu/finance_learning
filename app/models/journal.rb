class Journal < ApplicationRecord

  with_options presence: true do
    validates :user_id
    validates :debit_id
    validates :credit_id
    validates :date
    validates :amount
    validates :description
  end

  belongs_to :user
  belongs_to :debit, class_name: 'Account'
  belongs_to :credit, class_name: 'Account'

end
