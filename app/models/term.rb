class Term < ApplicationRecord
  has_and_belongs_to_many :students
  has_many :subjects

  def to_s
    id
  end
end
