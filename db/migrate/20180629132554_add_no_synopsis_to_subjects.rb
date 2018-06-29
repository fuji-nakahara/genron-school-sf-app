class AddNoSynopsisToSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :subjects, :no_synopsis, :boolean, null: false, default: false
  end
end
