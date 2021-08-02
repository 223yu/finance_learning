class CreateLearnings < ActiveRecord::Migration[5.2]
  def change
    create_table :learnings do |t|
      t.integer :user_id, null: false
      t.integer :content_id, null: false
      t.boolean :end_learning, null: false, default: false

      t.timestamps
    end
  end
end
