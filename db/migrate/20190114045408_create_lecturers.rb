class CreateLecturers < ActiveRecord::Migration[5.2]
  def change
    create_table :lecturers do |t|
      t.references :subject, foreign_key: true, null: false
      t.string :name, null: false, index: true
      t.string :note
      t.string :roles, array: true, null: false, default: []

      t.timestamps
    end
    add_index :lecturers, :roles, using: 'gin'
  end
end
