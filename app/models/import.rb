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
  # CSVの取込を行う
  def self.create_import_from_csv(user, file)
    # 変数定義
    n = 2 # 取込行
    result_hash = {success_count: 0, error_count: 0, error_rows: ''}
    # csv取込実行
    CSV.foreach(file.path, headers: true) do |row|
      is_true = true
      import = Import.new
      import.user_id = user.id
      if Date.valid_date?(row[0].to_i, row[1].to_i, row[2].to_i) && user.year == row[0].to_i
        import.date = Date.new(row[0].to_i, row[1].to_i, row[2].to_i)
      else
        is_true = false
      end
      if Account.find_by(user_id: user.id, year: user.year, code: row[3].to_i).present?
        import.debit_id = user.code_id(row[3].to_i)
      else
        is_true = false
      end
      if Account.find_by(user_id: user.id, year: user.year, code: row[4].to_i).present?
        import.credit_id = user.code_id(row[4].to_i)
      else
        is_true = false
      end
      if row[5].to_i > 0
        import.amount = row[5].to_i
      else
        is_true = false
      end
      if row[6].nil?
        import.description = ''
      else
        import.description = row[6]
      end
      if is_true == false
        result_hash[:error_count] += 1
        result_hash[:error_rows] = result_hash[:error_rows] + "#{n}行."
      elsif is_true == true
        if import.save
          result_hash[:success_count] += 1
        end
      end
      n += 1
    end
    result_hash
  end

  # 入力画面から送られてきたパラメータを保存可能な形式に整えて保存する
  def arrange_and_save(user)
    is_true = true
    month = self.month.to_i
    day = self.day.to_i
    if Date.valid_date?(user.year, month, day)
      self.date = Date.new(user.year, month, day)
    else
      is_true = false
    end
    if Account.find_by(user_id: user.id, year: user.year, code: debit_code).present?
      self.debit_id = user.code_id(debit_code)
    else
      is_true = false
    end
    if Account.find_by(user_id: user.id, year: user.year, code: credit_code).present?
      self.credit_id = user.code_id(credit_code)
    else
      is_true = false
    end
    self.user_id = user.id
    is_true &= save
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

  # 仕訳の更新を行う
  def self_update(user, import_params)
    is_true = true
    Import.transaction(joinable: false, requires_new: true) do
      # パラメータの値にて更新
      is_true &= self.update(import_params)
      is_true &= self.arrange_and_save(user)

      unless is_true
        raise ActiveRecord::Rollback
      end
    end
    is_true
  end

  # importからjournal作成
  def create_journal_from_import
    is_true = true
    Import.transaction(joinable: false, requires_new: true) do
      journal = Journal.new
      journal.user_id = self.user_id
      journal.debit_id = self.debit_id
      journal.credit_id = self.credit_id
      journal.date = self.date
      journal.amount = self.amount
      journal.description = self.description
      is_true &= journal.save
      # 残高の更新
      is_true &= journal.update_debit_and_credit_balance
      # importの削除
      is_true &= self.destroy

      unless is_true
        raise ActiveRecord::Rollback
      end
    end
    is_true
  end
  
  # 全ての取込仕訳を削除する
  def self.all_destroy(user)
    imports = Import.where(user_id: user.id)
    imports.destroy_all
  end
end
