class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses
  has_many :works

  scope :latest, -> { order(:term_id, :number).last }
end
