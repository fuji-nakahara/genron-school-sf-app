require 'open-uri'

class ScrapeStudentsJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      profile_uris = scrape_profile_uris(year)
      profile_uris.each do |uri|
        wp_id = uri.split('/').last
        Student.find_or_create_by(wp_id: wp_id) do |s|
          s.name, s.profile = scrape_name_and_profile(uri)
        end.add_term(year)
      end
    end
  end

  private

  def scrape_profile_uris(year)
    doc = Nokogiri::HTML(open(original_students_url(year)))
    doc.css('.student-list-item a').map { |e| e['href'] }
  end

  def scrape_name_and_profile(uri)
    doc = Nokogiri::HTML(open(uri))
    name = doc.at_css('main header h1').content
    profile = doc.at_css('main header p').content.strip
    [name, profile != 'プロフィールが設定されていません。' ? profile : nil]
  end
end
