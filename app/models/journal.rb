class Journal < ApplicationRecord
  attr_accessor :month, :day, :debit_code, :credit_code, :debit_name, :credit_name, :self_code, :nonself_code, :nonself_name, :received_amount, :invest_amount

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
    debit_id = user.code_id(self.debit_code)
    credit_id = user.code_id(self.credit_code)
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

  # 簡易入力において入力画面から送られてきたパラメータを保存可能な形式に整えて保存する
  def arrange_and_save_in_simple_entry(user)
    if self.received_amount != ''
      self.debit_code = self.self_code.to_i
      self.credit_code = self.nonself_code.to_i
      self.amount = self.received_amount.to_i
    elsif self.invest_amount != ''
      self.debit_code = self.nonself_code.to_i
      self.credit_code = self.self_code.to_i
      self.amount = self.invest_amount.to_i
    end
    self.arrange_and_save(user)
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

  # 簡易入力において入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display_in_simple_entry(self_id)
    self.month = self.date.month
    self.day = self.date.day
    if self.debit_id == self_id
      self.self_code = Account.find(self.debit_id).code
      self.nonself_code = Account.find(self.credit_id).code
      self.nonself_name = Account.find(self.credit_id).name
      self.received_amount = self.amount
    elsif self.credit_id == self_id
      self.self_code = Account.find(self.credit_id).code
      self.nonself_code = Account.find(self.debit_id).code
      self.nonself_name = Account.find(self.debit_id).name
      self.invest_amount = self.amount
    end
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
