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
    is_true = true
    month = self.month.to_i
    day = self.day.to_i
    self.user_id = user.id
    if Date.valid_date?(user.year, month, day)
      self.date = Date.new(user.year, month, day)
    else
      is_true = false
    end
    unless self_account = Account.find_by(user_id: user.id, year: user.year, code: self.self_code )
      is_true = false
    end
    unless nonself_account = Account.find_by(user_id: user.id, year: user.year, code: self.nonself_code )
      is_true = false
    end

    if is_true
      if self.received_amount != '' && self.received_amount.to_i >= 0
        self.debit_id = self_account.id
        self.credit_id = nonself_account.id
        self.amount = received_amount
      elsif self.invest_amount != '' && self.invest_amount.to_i >= 0
        self.debit_id = nonself_account.id
        self.credit_id = self_account.id
        self.amount = invest_amount
      else
        is_true = false
      end
    end
    is_true &= self.save
  end

  # 入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display
    debit_account = Account.find(debit_id)
    credit_account = Account.find(credit_id)
    self.month = date.month
    self.day = date.day
    self.debit_code = debit_account.code
    self.credit_code = credit_account.code
    self.debit_name = debit_account.name
    self.credit_name = credit_account.name
  end

  # 簡易入力において入力画面に表示するために受け渡すパラメータを整える
  def arrange_for_display_in_simple_entry(self_id)
    debit_account = Account.find(debit_id)
    credit_account = Account.find(credit_id)
    self.month = date.month
    self.day = date.day
    if debit_id == self_id
      self.self_code = debit_account.code
      self.nonself_code = credit_account.code
      self.nonself_name = credit_account.name
      self.received_amount = amount
    elsif credit_id == self_id
      self.self_code = credit_account.code
      self.nonself_code = debit_account.code
      self.nonself_name = debit_account.name
      self.invest_amount = amount
    end
  end

  # 科目残高更新
  def update_debit_and_credit_balance(reverse = false)
    is_valid = true
    Account.transaction(joinable: false, requires_new: true) do
      if Account.find_by(id: self.debit_id).present? && Account.find_by(id: self.credit_id).present?
        if reverse
          debit_account = Account.find(self.debit_id)
          is_valid &= debit_account.update_balance(- self.amount, self.date.month, 'debit')
          credit_account = Account.find(self.credit_id)
          is_valid &= credit_account.update_balance(- self.amount, self.date.month, 'credit')
        else
          debit_account = Account.find(self.debit_id)
          is_valid &= debit_account.update_balance(self.amount, self.date.month, 'debit')
          credit_account = Account.find(self.credit_id)
          is_valid &= credit_account.update_balance(self.amount, self.date.month, 'credit')
        end
      else
        is_valid = false
      end

      unless is_valid
        raise ActiveRecord::Rollback
      end
    end
    is_valid
  end

  # 簡易入力画面において仕訳の作成を行う
  def self_create_and_update_account_balance_in_simple_entry(user)
    is_valid = true
    Journal.transaction(joinable: false, requires_new: true) do
      is_valid &= self.arrange_and_save_in_simple_entry(user)
      is_valid &= self.update_debit_and_credit_balance

      unless is_valid
        raise ActiveRecord::Rollback
      end
    end
    is_valid
  end

  # 簡易入力画面において仕訳の更新を行う
  def self_update_and_update_account_balance_in_simple_entry(user, journal_params)
    is_valid = true
    Journal.transaction(joinable: false, requires_new: true) do
      # 更新前に残高を戻す処理
      is_valid &= self.update_debit_and_credit_balance(true)
      # パラメータの値にて更新
      is_valid &= self.update(journal_params)
      is_valid &= self.arrange_and_save_in_simple_entry(user)
      is_valid &= self.update_debit_and_credit_balance

      unless is_valid
        raise ActiveRecord::Rollback
      end
    end
    is_valid
  end

  # 残高更新後仕訳削除
  def delete_after_updating_balance
    is_valid = true
    Journal.transaction(joinable: false, requires_new: true) do
      is_valid &= self.update_debit_and_credit_balance(true)
      is_valid &= self.destroy

      unless is_valid
        raise ActiveRecord::Rollback
      end
    end
    is_valid
  end
end
