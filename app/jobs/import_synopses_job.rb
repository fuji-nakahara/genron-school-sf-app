require 'genron_sf/client'

class ImportSynopsesJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.latest)
    return if subject.no_synopsis?
    work_infos = GenronSf::Client.get_subject(subject.term_id, subject.number).synopses
    work_infos.each do |work_info|
      work = GenronSf::Client.get_work(subject.term_id, work_info.student_id, work_info.id)
      Synopsis.create_with(
        subject:    subject,
        student_id: work.student_id,
        title:      work.summary_title,
        body:       work.summary,
        appeal:     work.appeal,
      ).find_or_create_by!(original_id: work.id)
    end
  end
end
