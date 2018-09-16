require 'genron_sf/client'

class ImportWorksJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.previous)
    work_infos = GenronSf::Client.get_subject(subject.term_id, subject.number).works(no_synopsis: subject.no_synopsis?)
    work_infos.each do |work_info|
      work = GenronSf::Client.get_work(subject.term_id, work_info.student_id, work_info.id)
      student = Student.find_by!(original_id: work.student_id)
      Work.find_or_create_by!(subject: subject, student: student, original_id: work.id) do |w|
        w.title  = work.work_title
        w.body   = work.body
        w.appeal = work.appeal if subject.no_synopsis?
      end
    end
  end
end
