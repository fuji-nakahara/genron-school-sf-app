require 'genron_sf/client'

class ImportSynopsesJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.latest)
    return if subject.no_synopsis?
    work_infos = GenronSf::Client.get_subject(subject.term_id, subject.number).synopses
    work_infos.each do |work_info|
      work = GenronSf::Client.get_work(subject.term_id, work_info.student_id, work_info.id)
      student = Student.find_by!(original_id: work.student_id)
      Synopsis.find_or_create_by!(subject: subject, student: student, original_id: work.id) do |s|
        s.title  = work.summary_title
        s.body   = work.summary
        s.appeal = work.appeal
      end
    end
  end
end