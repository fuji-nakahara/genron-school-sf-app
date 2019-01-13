require 'genron_sf/client'

class Student < ApplicationRecord
  has_and_belongs_to_many :terms, -> { reverse_order }
  has_many :synopses, -> { ordered }
  has_many :works, -> { ordered }

  scope :find_or_fetch_by!, ->(attributes) do
    record = Student.find_or_initialize_by(attributes)
    record.update_info! if record.new_record?
    record
  end

  def self.of(original_id)
    find_by(original_id: original_id)
  end

  def score(year)
    synopses.includes(:subject).where('subjects.term_id': year).count + works.includes(:subject).where('subjects.term_id': year).sum(:score)
  end

  def subject_number_to_score(year)
    number_to_synopsis_score = synopses.where('subjects.year': year).pluck('subjects.number').map { |number| [number, 1] }.to_h
    number_to_work_score     = works.where('subjects.year': year).where('score > 0').pluck('subjects.number', :score).to_h

    number_to_synopsis_score.merge(number_to_work_score) { |_, synopsis_score, work_score| synopsis_score + work_score }
  end

  def update_info!(year)
    student = GenronSf::Client.get_student(year, original_id)

    self.name    = student.name
    self.profile = student.profile
    self.terms << Term.find(year) unless terms.pluck(:id).include?(year)

    save!
  end

  def original_url(year = terms.last.id)
    Rails.application.routes.url_helpers.original_student_url(self, year)
  end

  def original_urls
    terms.map { |term| original_url(term.id) }
  end

  def twitter_screen_name
    @twitter_screen_name ||= Twitter::TwitterText::Extractor.extract_mentioned_screen_names(profile).first
  end

  def profile_urls
    URI.extract(profile, %w[http https]) if profile
  end
end
