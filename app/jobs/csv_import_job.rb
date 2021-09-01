class CsvImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(user_id)
    imports = Import.where(user_id: user_id, pending: true)
    imports.each do |import|
      journal = Journal.new
      journal.user_id = import.user_id
      journal.debit_id = import.debit_id
      journal.credit_id = import.credit_id
      journal.date = import.date
      journal.amount = import.amount
      journal.description = import.description
      journal.save
      # 貸借の残高を更新（application controllerに定義したメソッドを利用する方法が分からなかったので再定義）
      debit_account = Account.find(journal.debit_id)
      debit_account.update_balance(journal.amount, journal.date.month, 'debit')
      credit_account = Account.find(journal.credit_id)
      credit_account.update_balance(journal.amount, journal.date.month, 'credit')
      import.destroy
    end
  end
end
