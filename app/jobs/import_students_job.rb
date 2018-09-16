require 'genron_sf/client'

class ImportStudentsJob < ApplicationJob
  queue_as :default

  def perform(*years)
    years = years.presence || Term.pluck(:id)

    years.each do |year|
      original_ids = GenronSf::Client.get_student_list(year).map(&:id)
      original_ids.each do |original_id|
        student = Student.find_or_initialize_by(original_id: original_id)
        student.update_info!(year)
      end
    end
  end
end
