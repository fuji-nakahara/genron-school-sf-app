require 'open-uri'

class ScrapeWorksJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(subject = Subject.latest)
    student_id_to_work_id = scrape_works_info(subject)
    student_id_to_work_id.each do |student_id, work_id|
      student = Student.find_by(original_id: student_id)
      Work.find_or_create_by(subject: subject, student: student, original_id: work_id, &:update_contents)
    end
  end

  private

  def scrape_works_info(subject)
    doc = Nokogiri::HTML(open(original_subject_url(subject)))
    if subject.no_synopsis
      doc.css('.student-list .written a').map { |e| e['href'].split('/').slice(-2..-1) }
    else
      doc.css('.has-work a').map { |e| e['href'].split('/').slice(-2..-1) }
    end
  end
end
