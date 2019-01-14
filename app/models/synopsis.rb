class Synopsis < ApplicationRecord
  include Submitted

  has_one :work, foreign_key: :original_id, primary_key: :original_id

  scope :selected, -> { where(selected: true) }
end
