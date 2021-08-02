class CreateJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :journals do |t|
      t.integer :user_id, null: false
      t.integer :debit_id, null: false
      t.integer :credit_id, null: false
      t.date :date, null: false
      t.integer :amount, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
