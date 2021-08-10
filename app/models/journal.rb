class Journal < ApplicationRecord
  attr_accessor :month, :day, :debit_code, :credit_code, :debit_name, :credit_name

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

  # 追加メソッド
  # 入力画面から送られてきたパラメータを保存可能な形式に整えて保存する
  def arrange_and_save(user)
    month = self.month.to_i
    day = self.day.to_i
    self.date = Date.new(user.year, month, day)
    debit_id = Account.find_by(user_id: user.id, year: user.year, code: self.debit_code).id
    credit_id = Account.find_by(user_id: user.id, year: user.year, code: self.credit_code).id
    self.user_id = user.id
    self.debit_id = debit_id
    self.credit_id = credit_id
    if self.save
      # 科目残高更新
      debit_account = Account.find(debit_id)
      debit_account.update_balance(self.amount, month, 'debit')
      credit_account = Account.find(credit_id)
      credit_account.update_balance(self.amount, month, 'credit')
    end
  end

  # 入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display
    self.month = self.date.month
    self.day = self.date.day
    self.debit_code = Account.find(self.debit_id).code
    self.credit_code = Account.find(self.credit_id).code
    self.debit_name = Account.find(self.debit_id).name
    self.credit_name = Account.find(self.credit_id).name
  end

  # 残高更新後仕訳削除
  def delete_after_updating_balance
    debit_account = Account.find(self.debit_id)
    debit_account.update_balance(- self.amount, self.date.month, 'debit')
    credit_account = Account.find(self.credit_id)
    credit_account.update_balance(- self.amount, self.date.month, 'credit')
    self.destroy
  end

end
