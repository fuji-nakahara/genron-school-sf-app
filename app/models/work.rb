class Work < ApplicationRecord
  include Submitted

  has_one :synopsis, foreign_key: :original_id, primary_key: :original_id
end
