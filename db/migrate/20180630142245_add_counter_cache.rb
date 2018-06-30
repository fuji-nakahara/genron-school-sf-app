class AddCounterCache < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :synopses_count, :integer, null: false, default: 0
    add_column :students, :works_count, :integer, null: false, default: 0
    add_column :subjects, :synopses_count, :integer, null: false, default: 0
    add_column :subjects, :works_count, :integer, null: false, default: 0
  end
end
