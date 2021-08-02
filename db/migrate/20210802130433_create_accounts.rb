class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :user_id, null: false
      t.integer :year, null: false
      t.integer :code, null: false
      t.string :name, null: false
      t.integer :total_account, null: false
      t.integer :opening_balance_1, null: false, default: 0
      t.integer :debit_balance_1, null: false, default: 0
      t.integer :credit_balance_1, null: false, default: 0
      t.integer :opening_balance_2, null: false, default: 0
      t.integer :debit_balance_2, null: false, default: 0
      t.integer :credit_balance_2, null: false, default: 0
      t.integer :opening_balance_3, null: false, default: 0
      t.integer :debit_balance_3, null: false, default: 0
      t.integer :credit_balance_3, null: false, default: 0
      t.integer :opening_balance_4, null: false, default: 0
      t.integer :debit_balance_4, null: false, default: 0
      t.integer :credit_balance_4, null: false, default: 0
      t.integer :opening_balance_5, null: false, default: 0
      t.integer :debit_balance_5, null: false, default: 0
      t.integer :credit_balance_5, null: false, default: 0
      t.integer :opening_balance_6, null: false, default: 0
      t.integer :debit_balance_6, null: false, default: 0
      t.integer :credit_balance_6, null: false, default: 0
      t.integer :opening_balance_7, null: false, default: 0
      t.integer :debit_balance_7, null: false, default: 0
      t.integer :credit_balance_7, null: false, default: 0
      t.integer :opening_balance_8, null: false, default: 0
      t.integer :debit_balance_8, null: false, default: 0
      t.integer :credit_balance_8, null: false, default: 0
      t.integer :opening_balance_9, null: false, default: 0
      t.integer :debit_balance_9, null: false, default: 0
      t.integer :credit_balance_9, null: false, default: 0
      t.integer :opening_balance_10, null: false, default: 0
      t.integer :debit_balance_10, null: false, default: 0
      t.integer :credit_balance_10, null: false, default: 0
      t.integer :opening_balance_11, null: false, default: 0
      t.integer :debit_balance_11, null: false, default: 0
      t.integer :credit_balance_11, null: false, default: 0
      t.integer :opening_balance_12, null: false, default: 0
      t.integer :debit_balance_12, null: false, default: 0
      t.integer :credit_balance_12, null: false, default: 0

      t.timestamps
    end

    add_index :accounts, [:user_id, :year, :code], unique: true
  end
end
