class RenameWpIdColumnToOriginalId < ActiveRecord::Migration[5.2]
  def change
    rename_column :students, :wp_id, :original_id
  end
end
