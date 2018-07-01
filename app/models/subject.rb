class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses, -> { order(selected: :desc, created_at: :asc) }
  has_many :works, -> { order(score: :desc, created_at: :asc) }

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
