require 'genron_sf/client'

class ImportSubjectsJob < ApplicationJob
  queue_as :default

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      logger.info "Importing subjects of #{year}"

      subject_list = GenronSf::Client.get_subject_list(year)
      subject_list.each do |fetched_subject|
        subject = Subject.find_or_create_by!(term_id: year, number: fetched_subject.number) do |s|
          s.title              = fetched_subject.title
          s.deadline_date      = fetched_subject.number == Subject::LAST_WORK_NUMBER ? nil : fetched_subject.deadline_date
          s.comment_date       = fetched_subject.number == Subject::LAST_WORK_NUMBER ? nil : fetched_subject.comment_date
          s.work_deadline_date = fetched_subject.work_deadline_date
          s.work_comment_date  = fetched_subject.work_comment_date
        end

        fetched_subject.lecturer_list.each do |lecturer|
          next if %w[ゲスト編集者 過去のゲスト講師].include?(lecturer.name)

          Lecturer.find_or_create_by!(subject: subject, name: lecturer.name) do |l|
            l.note  = lecturer.note
            l.roles = lecturer.roles
          end
        end
      end
    end
  end
end
