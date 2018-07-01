class AddAvailableToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :available, :boolean, null: false, default: false
  end
end
