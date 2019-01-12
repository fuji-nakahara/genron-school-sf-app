class AddCharacterCountToWorksAndSynopses < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :character_count, :integer
    add_column :works, :appeal_character_count, :integer
    add_column :synopses, :character_count, :integer
    add_column :synopses, :appeal_character_count, :integer
  end
end
