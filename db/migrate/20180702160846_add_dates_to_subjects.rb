class AddDatesToSubjects < ActiveRecord::Migration[5.2]
  def change
    add_column :subjects, :deadline_date, :date
    add_column :subjects, :comment_date, :date
    add_column :subjects, :work_deadline_date, :date
    add_column :subjects, :work_comment_date, :date

    remove_column :subjects, :no_synopsis, :boolean
  end
end
