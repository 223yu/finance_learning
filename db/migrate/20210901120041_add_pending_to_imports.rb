class AddPendingToImports < ActiveRecord::Migration[5.2]
  def change
    add_column :imports, :pending, :boolean, default: false, null: false
  end
end
