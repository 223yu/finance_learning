class CreateContents < ActiveRecord::Migration[5.2]
  def change
    create_table :contents do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :user_limited, null: false, default: true

      t.timestamps
    end
  end
end
