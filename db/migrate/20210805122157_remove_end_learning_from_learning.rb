class RemoveEndLearningFromLearning < ActiveRecord::Migration[5.2]
  def change
    remove_column :learnings, :end_learning, :boolean
  end
end
