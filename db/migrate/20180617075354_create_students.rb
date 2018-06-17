class CreateStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :name, null: false
      t.text :profile

      t.timestamps
    end

    create_table :students_terms, id: false do |t|
      t.belongs_to :term, index: true
      t.belongs_to :student, index: true
    end
  end
end
