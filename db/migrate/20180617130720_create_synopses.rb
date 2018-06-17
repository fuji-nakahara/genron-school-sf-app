class CreateSynopses < ActiveRecord::Migration[5.2]
  def change
    create_table :synopses do |t|
      t.references :subject, foreign_key: true, null: false
      t.references :student, foreign_key: true, null: false
      t.integer :original_id, null: false
      t.string :title
      t.text :body
      t.text :appeal

      t.timestamps
    end

    add_index :synopses, :original_id, unique: true
  end
end
