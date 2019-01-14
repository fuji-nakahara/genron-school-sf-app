class Subject < ApplicationRecord
  belongs_to :term
  has_many :lecturers, inverse_of: 'subject'
  has_many :synopses, -> { includes(:student).order('selected desc', 'students.original_id') }, inverse_of: 'subject'
  has_many :works, -> { includes(:student).order('score desc', 'students.original_id') }, inverse_of: 'subject'
  has_many :proposers, -> { proposers }, class_name: 'Lecturer', inverse_of: 'subject'

  scope :in, ->(year) { where(term_id: year) }
  scope :of, ->(number) { where(number: number) }
  scope :ordered, -> { order(term_id: :desc, number: :desc) }
  scope :latest, -> { ordered.first }
  scope :latest3, -> { ordered.limit(3) }
  scope :latest_second, -> { ordered.second }

  alias_attribute :year, :term_id

  LAST_NUMBER = 11

  def no_synopsis?
    number == LAST_NUMBER
  end

  def no_work?
    number == LAST_NUMBER - 1
  end

  def date
    comment_date || work_comment_date
  end

  def previous
    Subject.in(term.year).of(number - 1).first
  end

  def next
    Subject.in(term.year).of(number + 1).first
  end

  def proposer
    lecturers.find { |lecturer| lecturer.roles.include?(Lecturer::ROLE_NAME_PROPOSER) }
  end

  def synopsis_commenters
    lecturers.select { |lecturer| lecturer.roles.any? { |role| role.match?(/梗概(講評|審査)/) } }
  end

  def work_commenters
    lecturers.select { |lecturer| lecturer.roles.any? { |role| role.match?(/実作(講評|審査)|選考委員/) } }
  end

  def display_number
    "第#{number}回"
  end

  def original_url
    Rails.application.routes.url_helpers.original_subject_url(self)
  end
end
