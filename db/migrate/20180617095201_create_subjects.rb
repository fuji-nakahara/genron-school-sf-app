class CreateSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects do |t|
      t.references :term, foreign_key: true, null: false
      t.integer :number, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :subjects, %i[term_id number], unique: true
  end
end
