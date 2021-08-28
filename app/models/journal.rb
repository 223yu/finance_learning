class Journal < ApplicationRecord
  attr_accessor :month, :day, :debit_code, :credit_code, :debit_name, :credit_name, :self_code, :nonself_code, :nonself_name, :received_amount, :invest_amount

  with_options presence: true do
    validates :user_id
    validates :debit_id
    validates :credit_id
    validates :date
    validates :amount
  end

  validates :amount, :numericality => { :greater_than => 0 }

  belongs_to :user
  belongs_to :debit, class_name: 'Account'
  belongs_to :credit, class_name: 'Account'

  # 追加メソッド
  # 入力画面から送られてきたパラメータを保存可能な形式に整えて保存する
  def arrange_and_save(user)
    # 最後のsaveまでエラーが発生しないように各値を整える
    month = self.month.to_i
    day = self.day.to_i
    if Date.valid_date?(user.year, month, day)
      self.date = Date.new(user.year, month, day)
    else
      self.date = ''
    end
    if Account.find_by(user_id: user.id, year: user.year, code: debit_code).present?
      self.debit_id = user.code_id(debit_code)
    else
      self.debit_id = ''
    end
    if Account.find_by(user_id: user.id, year: user.year, code: credit_code).present?
      self.credit_id = user.code_id(credit_code)
    else
      self.credit_id = ''
    end
    self.user_id = user.id
    save
  end

  # 簡易入力において入力画面から送られてきたパラメータを保存可能な形式に整えて保存する
  def arrange_and_save_in_simple_entry(user)
    if received_amount != ''
      self.debit_code = self_code.to_i
      self.credit_code = nonself_code.to_i
      self.amount = received_amount.to_i
    elsif invest_amount != ''
      self.debit_code = nonself_code.to_i
      self.credit_code = self_code.to_i
      self.amount = invest_amount.to_i
    end
    arrange_and_save(user)
  end

  # 入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display
    self.month = date.month
    self.day = date.day
    self.debit_code = Account.find(debit_id).code
    self.credit_code = Account.find(credit_id).code
    self.debit_name = Account.find(debit_id).name
    self.credit_name = Account.find(credit_id).name
  end

  # 簡易入力において入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display_in_simple_entry(self_id)
    self.month = date.month
    self.day = date.day
    if debit_id == self_id
      self.self_code = Account.find(debit_id).code
      self.nonself_code = Account.find(credit_id).code
      self.nonself_name = Account.find(credit_id).name
      self.received_amount = amount
    elsif credit_id == self_id
      self.self_code = Account.find(credit_id).code
      self.nonself_code = Account.find(debit_id).code
      self.nonself_name = Account.find(debit_id).name
      self.invest_amount = amount
    end
  end

  # 残高更新後仕訳削除
  def delete_after_updating_balance
    debit_account = Account.find(debit_id)
    debit_account.update_balance(- amount, date.month, 'debit')
    credit_account = Account.find(credit_id)
    credit_account.update_balance(- amount, date.month, 'credit')
    destroy
  end
end
