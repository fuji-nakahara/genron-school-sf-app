class Term < ApplicationRecord
  has_and_belongs_to_many :students, -> { order(:original_id) }
  has_many :subjects, -> { order(:number) }

  scope :order_desc, -> { order(id: :desc) }
  scope :year_to_students, -> { includes(:students).order(id: :desc).map { |term| [term.id, term.students] }.to_h }

  alias_attribute :year, :id

  def to_s
    id.to_s
  end
end
