class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses, -> { includes(:student).order('selected desc', 'students.original_id') }
  has_many :works, -> { includes(:student).order('score desc', 'students.original_id') }

  scope :ordered, -> { order(term_id: :desc, number: :desc) }
  scope :latest, -> { ordered.first }
  scope :latest2, -> { ordered.limit(2) }
  scope :previous, -> { ordered.second }

  def display_number
    "第#{number}回"
  end

  def original_url
    Rails.application.routes.url_helpers.original_subject_url(self)
  end
end
