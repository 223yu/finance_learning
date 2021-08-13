class Account < ApplicationRecord

  enum total_account: { '現預金': 0, '他流動資産': 1, '固定資産': 2, 'カード': 3,
    '他流動負債': 4, '固定負債': 5, '収入': 6, '原価': 7, '販管費': 8,
    '営業外収入': 9, '営業外費用': 10
  }

  # 定数定義
  BALANCE_SHEETS_ACCOUNTS = ['現預金', '他流動資産', '固定資産', 'カード',
    '他流動負債', '固定負債']
  PROFIT_AND_LOSS_STATEMENT = ['収入', '原価', '販管費', '営業外収入', '営業外費用']
  DEBIT_ACCOUNTS = ['現預金', '他流動資産', '固定資産', '原価', '販管費', '営業外費用']
  CREDIT_ACCOUNTS = ['カード', '他流動負債', '固定負債', '収入', '営業外収入']
  ALL_ACCOUNTS = BALANCE_SHEETS_ACCOUNTS + PROFIT_AND_LOSS_STATEMENT

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

  validates :code, :numericality => { :greater_than => 0 }
  validates_uniqueness_of :code, scope: [:user_id, :year]

  belongs_to :user
  has_many :debit_journals, class_name: 'Journal',
    foreign_key: 'debit_id', dependent: :destroy
  has_many :credit_journals, class_name: 'Journal',
    foreign_key: 'credit_id', dependent: :destroy

  # 追加メソッド
  # 勘定科目の残高を更新
  def update_balance(amount, month, debit_or_credit)
    # monthの借方or貸方残高を更新
    if debit_or_credit == 'debit'
      update_amount = self.send("debit_balance_#{month}")
      update_amount += amount
      update_attributes("debit_balance_#{month}".to_sym => update_amount)
    elsif debit_or_credit == 'credit'
      update_amount = self.send("credit_balance_#{month}")
      update_amount += amount
      update_attributes("credit_balance_#{month}".to_sym => update_amount)
    end

    # 借方科目か貸方科目かで期首残高を更新する金額の正負を決める
    if DEBIT_ACCOUNTS.include?(self.total_account)
      if debit_or_credit == 'debit'
        update_balance = amount
      else
        update_balance = -amount
      end
    else
      if debit_or_credit == 'credit'
        update_balance = amount
      else
        update_balance = -amount
      end
    end

    # monthより後の期首残高を更新
    ("#{month + 1}".to_i..12).to_a.each do |mon|
      update_opening_balance = self.send("opening_balance_#{mon}")
      update_opening_balance += update_balance
      update_attributes("opening_balance_#{mon}".to_sym => update_opening_balance)
    end
  end

  # 月から[期首残高, 借方残高, 貸方残高, 期末残高]を返す
  def return_balances(start_month, end_month)
    debit_balance = 0
    credit_balance = 0
    opening_balance = self.send("opening_balance_#{start_month}")
    (start_month..end_month).to_a.each do |mon|
      debit_balance += self.send("debit_balance_#{mon}")
      credit_balance += self.send("credit_balance_#{mon}")
    end
    if DEBIT_ACCOUNTS.include?(self.total_account)
      ending_balance = opening_balance + debit_balance - credit_balance
    else
      ending_balance = opening_balance - debit_balance + credit_balance
    end
    return [opening_balance, debit_balance, credit_balance, ending_balance]
  end

end
