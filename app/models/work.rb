class Work < ApplicationRecord
  belongs_to :subject, counter_cache: true, touch: true
  belongs_to :student, counter_cache: true, touch: true

  scope :ordered, -> { includes(:subject).order('subjects.term_id desc', 'subjects.number desc') }

  def self.of(original_id)
    find_by(original_id: original_id)
  end

  def synopsis
    Synopsis.of(original_id)
  end

  def content
    Nokogiri::HTML(body).content
  end

  def original_url
    Rails.application.routes.url_helpers.original_work_url(self)
  end
end
