module Submitted
  extend ActiveSupport::Concern

  included do
    belongs_to :subject, counter_cache: true, touch: true
    belongs_to :student, counter_cache: true, touch: true

    scope :ordered, -> { includes(:subject).order('subjects.term_id desc', 'subjects.number desc') }
    scope :not_last, -> { includes(:subject).where.not('subjects.number': [Subject::LAST_WORK_NUMBER, Subject::LAST_SYNOPSIS_NUMBER])}
  end

  module ClassMethods
    def of(original_id)
      find_by(original_id: original_id)
    end
  end

  def content
    Nokogiri::HTML(body).content
  end

  def original_url
    Rails.application.routes.url_helpers.original_work_url(self)
  end

  def title_and_student_name
    "#{title}／#{student.name}"
  end
end
