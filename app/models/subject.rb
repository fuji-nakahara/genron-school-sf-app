class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses, -> { order(selected: :desc, created_at: :asc) }
  has_many :works, -> { order(score: :desc, created_at: :asc) }

  scope :ordered, -> { order(term_id: :desc, number: :desc) }
  scope :latest, -> { ordered.first }
  scope :latest2, -> { ordered.limit(2) }

  def display_number
    "第#{number}回"
  end
end
