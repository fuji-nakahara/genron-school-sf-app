require 'genron_sf/client'

class ImportScoresJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.previous)
    original_id_to_score = GenronSf::Client.get_subject(subject.term_id, subject.number).work_id_to_score
    return if original_id_to_score.empty?

    all_selected_synopses = YAML.load_file(Rails.root.join('data', 'selected_synopses.yml'))
    selected_synopsis_ids = all_selected_synopses[subject.year]&.[](subject.number) || original_id_to_score.keys
    subject.synopses.selected.update_all(selected: false)
    Synopsis.where(original_id: selected_synopsis_ids).update_all(selected: true)

    original_id_to_score.each do |original_id, score|
      Work.find_by!(original_id: original_id).update_attribute(:score, score) if score.present? && score.to_i > 0
    end
  end
end
