class AddWpIdToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :wp_id, :string, null: false

    add_index :students, :wp_id, unique: true
  end
end
