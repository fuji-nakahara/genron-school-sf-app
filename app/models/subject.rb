class Subject < ApplicationRecord
  belongs_to :term

  scope :latest, -> { order(:term_id, :number).last }
end
