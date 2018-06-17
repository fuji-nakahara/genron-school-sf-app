class Term < ApplicationRecord
  has_and_belongs_to_many :students

  def to_s
    id
  end
end
