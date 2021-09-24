class Import < ApplicationRecord
  attr_accessor :month, :day, :debit_code, :credit_code, :debit_name, :credit_name

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
end
