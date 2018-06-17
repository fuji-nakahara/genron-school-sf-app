require 'open-uri'

class ScrapeStudentsJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      original_ids = scrape_original_ids(year)
      original_ids.each do |original_id|
        student = Student.find_or_initialize_by(original_id: original_id)
        student.update_info(year)
      end
    end
  end

  private

  def scrape_original_ids(year)
    doc = Nokogiri::HTML(open(original_students_url(year)))
    doc.css('.student-list-item a').map { |e| e['href'].split('/').last }
  end
end
