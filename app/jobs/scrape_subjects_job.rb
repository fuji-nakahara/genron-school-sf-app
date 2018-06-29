require 'open-uri'

class ScrapeSubjectsJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      number_to_title = scrape_subject_info(year)
      number_to_title.each do |number, title|
        Subject.create_with(title: title).find_or_create_by(term_id: year, number: number)
      end
    end
  end

  private

  def scrape_subject_info(year)
    doc = Nokogiri::HTML(open(original_subjects_url(year)))
    doc.css('.page-content article').map do |e|
      number = e.at_css('.number').content.scan(/\d+/).first
      title = e.at_css('h1').content.gsub(/[「」]/, '')
      [number, title]
    end
  end
end
