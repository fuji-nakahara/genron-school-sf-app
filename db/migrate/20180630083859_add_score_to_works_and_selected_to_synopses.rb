class AddScoreToWorksAndSelectedToSynopses < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :score, :integer, null: false, default: 0
    add_column :synopses, :selected, :boolean, null: false, default: false
  end
end
