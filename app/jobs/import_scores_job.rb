require 'genron_sf/client'

class ImportScoresJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.previous)
    original_id_to_score = GenronSf::Client.get_subject(subject.year, subject.number).work_id_to_score
    return if original_id_to_score.empty?

    Synopsis.where(original_id: original_id_to_score.keys).update_all(selected: true)

    original_id_to_score.each do |original_id, score|
      Work.find_by!(original_id: original_id).update_attribute(:score, score) if score.present? && score.to_i > 0
    end
  end
end
