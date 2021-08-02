class Account < ApplicationRecord
  
  enum total_account: { '現預金': 0, '他流動資産': 1, '固定資産': 2, 'カード': 3, 
    '他流動負債': 4, '固定負債': 5, '収入': 6, '原価': 7, '販管費': 8,
    '営業外収入': 9, '営業外費用': 10
  }

  with_options presence: true do
    validates :user_id
    validates :year
    validates :code
    validates :name
    validates :total_account
    validates :opening_balance_1
    validates :debit_balance_1
    validates :credit_balance_1
    validates :opening_balance_2
    validates :debit_balance_2
    validates :credit_balance_2
    validates :opening_balance_3
    validates :debit_balance_3
    validates :credit_balance_3
    validates :opening_balance_4
    validates :debit_balance_4
    validates :credit_balance_4
    validates :opening_balance_5
    validates :debit_balance_5
    validates :credit_balance_5
    validates :opening_balance_6
    validates :debit_balance_6
    validates :credit_balance_6
    validates :opening_balance_7
    validates :debit_balance_7
    validates :credit_balance_7
    validates :opening_balance_8
    validates :debit_balance_8
    validates :credit_balance_8
    validates :opening_balance_9
    validates :debit_balance_9
    validates :credit_balance_9
    validates :opening_balance_10
    validates :debit_balance_10
    validates :credit_balance_10
    validates :opening_balance_11
    validates :debit_balance_11
    validates :credit_balance_11
    validates :opening_balance_12
    validates :debit_balance_12
    validates :credit_balance_12
  end
  
  belongs_to :user
  has_many :debit_journals, class_name: 'Journal',
    foreign_key: 'debit_id', dependent: :destroy
  has_many :credit_journals, class_name: 'Journal',
    foreign_key: 'credit_id', dependent: :destroy

end
