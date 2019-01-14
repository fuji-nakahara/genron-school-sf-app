require 'genron_sf/client'

class ImportScoresJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.latest_second)
    excellent_works = GenronSf::Client.get_subject(subject.year, subject.number).excellent_works
    return if excellent_works.empty?

    all_selected_synopses = YAML.load_file(Rails.root.join('data', 'selected_synopses.yml'))
    selected_synopsis_ids = all_selected_synopses.dig(subject.year, subject.number) || excellent_works.map(&:id)
    subject.synopses.selected.update_all(selected: false)
    Synopsis.where(original_id: selected_synopsis_ids).update_all(selected: true)

    excellent_works.each do |excellent_work|
      if excellent_work.score&.> 0
        student = Student.of(excellent_work.student_id)
        Work.find_or_create_by!(subject: subject, student: student, original_id: excellent_work.id).update_attribute(:score, excellent_work.score)
      end
    end
  end
end
