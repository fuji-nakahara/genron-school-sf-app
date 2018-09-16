require 'genron_sf/client'

class Student < ApplicationRecord
  has_and_belongs_to_many :terms, -> { reverse_order }
  has_many :synopses, -> { ordered }
  has_many :works, -> { ordered }

  scope :by, ->(original_id) { find_by(original_id: original_id) }

  def score(year)
    synopses.includes(:subject).where('subjects.term_id': year).count + works.includes(:subject).where('subjects.term_id': year).sum(:score)
  end

  def update_info!(year)
    student = GenronSf::Client.get_student(year, original_id)

    self.name    = student.name
    self.profile = student.profile
    self.terms << Term.find(year) unless terms.pluck(:id).include?(year)

    save!
  end

  def original_url(year = terms.last.id)
    Rails.application.routes.url_helpers.original_student_url(year, self)
  end

  def original_urls
    terms.map { |term| original_url(term.id) }
  end

  def twitter_screen_name
    Twitter::TwitterText::Extractor.extract_mentioned_screen_names(profile).first
  end
end
