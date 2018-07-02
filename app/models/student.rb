require 'open-uri'

class Student < ApplicationRecord
  has_and_belongs_to_many :terms, -> { reverse_order }
  has_many :synopses, -> { ordered }
  has_many :works, -> { ordered }

  def score(year)
    synopses.includes(:subject).where('subjects.term_id': year).count + works.includes(:subject).where('subjects.term_id': year).sum(:score)
  end

  def update_info(year)
    terms << Term.find(year) unless terms.pluck(:id).include?(year)
    self.name, self.profile = scrape_name_and_profile(year)
    save
  end

  def original_url(year = terms.last.id)
    Rails.application.routes.url_helpers.original_student_url(year, self)
  end

  def original_urls
    terms.map { |term| original_url(term.id) }
  end

  private

  def scrape_name_and_profile(year = nil)
    doc     = Nokogiri::HTML(open(original_url(year)))
    name    = doc.at_css('main header h1').content
    profile = doc.at_css('main header p').content.strip
    [name, profile != 'プロフィールが設定されていません。' ? profile : nil]
  end
end
