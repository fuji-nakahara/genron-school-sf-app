class Subject < ApplicationRecord
  belongs_to :term
  has_many :synopses, -> { includes(:student).order('selected desc', 'students.original_id') }
  has_many :works, -> { includes(:student).order('score desc', 'students.original_id') }

  scope :by, ->(year, number) { find_by(term_id: year, number: number) }
  scope :ordered, -> { order(term_id: :desc, number: :desc) }
  scope :latest, -> { ordered.first }
  scope :latest3, -> { ordered.limit(3) }
  scope :previous, -> { ordered.second }

  def no_synopsis?
    comment_date.nil?
  end

  def date
    comment_date || work_comment_date
  end

  def display_number
    "第#{number}回"
  end

  def original_url
    Rails.application.routes.url_helpers.original_subject_url(self)
  end
end
