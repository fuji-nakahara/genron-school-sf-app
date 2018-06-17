require 'open-uri'

class ScrapeStudentsJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      wp_ids = scrape_wp_ids(year)
      wp_ids.each do |wp_id|
        student = Student.find_or_initialize_by(wp_id: wp_id)
        student.update_info(year)
      end
    end
  end

  private

  def scrape_wp_ids(year)
    doc = Nokogiri::HTML(open(original_students_url(year)))
    doc.css('.student-list-item a').map { |e| e['href'].split('/').last }
  end
end
