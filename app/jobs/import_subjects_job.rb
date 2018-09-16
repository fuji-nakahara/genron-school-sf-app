require 'genron_sf/client'

class ImportSubjectsJob < ApplicationJob
  queue_as :default

  NO_SYNOPSIS_NUMBER = 11

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      subjects = GenronSf::Client.get_subject_list(year)
      subjects.each do |subject|
        Subject.create_with(
          title:              subject.title,
          deadline_date:      subject.number == NO_SYNOPSIS_NUMBER ? nil : subject.deadline_date,
          comment_date:       subject.number == NO_SYNOPSIS_NUMBER ? nil : subject.comment_date,
          work_deadline_date: subject.work_deadline_date,
          work_comment_date:  subject.work_comment_date,
        ).find_or_create_by(term_id: year, number: subject.number)
      end
    end
  end
end
