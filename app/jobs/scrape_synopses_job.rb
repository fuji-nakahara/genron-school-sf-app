require 'open-uri'

class ScrapeSynopsesJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(subject = Subject.latest)
    student_id_to_synopsis_id = scrape_synopses_info(subject)
    student_id_to_synopsis_id.each do |student_id, synopsis_id|
      student = Student.find_by(original_id: student_id)
      Synopsis.find_or_create_by(subject: subject, student: student, original_id: synopsis_id, &:update_contents)
    end
  end

  private

  def scrape_synopses_info(subject)
    doc = Nokogiri::HTML(open(original_subject_url(subject)))
    doc.css('.student-list .written a').map { |e| e['href'].split('/').slice(-2..-1) }
  end
end
