class RemoveAvailableColumnFromStudents < ActiveRecord::Migration[5.2]
  def change
    remove_column :students, :available, :boolean
  end
end
