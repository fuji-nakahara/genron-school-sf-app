class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses

  scope :latest, -> { order(:term_id, :number).last }
end
