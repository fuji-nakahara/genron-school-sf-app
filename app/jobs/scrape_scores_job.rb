require 'open-uri'

class ScrapeScoresJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(subject = Subject.latest)
    original_id_to_score = scrape_scores_info(subject)
    return if original_id_to_score.empty?
    Synopsis.where(original_id: original_id_to_score.keys).update_all(selected: true)
    original_id_to_score.each do |original_id, score|
      Work.find_by(original_id: original_id)&.update_attribute(:score, score) if score.present? && score.to_i > 0
    end
  end

  private

  def scrape_scores_info(subject)
    doc = Nokogiri::HTML(open(original_subject_url(subject)))
    doc.css('.type-excellents')
      .map { |e| [e.at_css('a')['href']&.split('/')&.last, e.at_css('.score')&.content] }
      .reject { |original_id, _| original_id.nil? }
      .to_h
  end
end
