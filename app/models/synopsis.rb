class Synopsis < ApplicationRecord
  belongs_to :subject, counter_cache: true, touch: true
  belongs_to :student, counter_cache: true, touch: true

  scope :ordered, -> { includes(:subject).order('subjects.term_id desc', 'subjects.number desc') }

  def work
    Work.find_by(subject_id: subject_id, student_id: student_id)
  end

  def update_contents
    doc         = Nokogiri::HTML(open(original_url))
    self.title  = doc.at_css('.summary-title')&.content
    self.body   = doc.at_css('.summary-content').tap { |e| e.at_css('.count-character').remove }.children.to_html.strip
    self.appeal = doc.at_css('.appeal-content')&.tap { |e| e.at_css('.count-character')&.remove }&.children&.to_html&.strip
  end

  def content
    Nokogiri::HTML(body).content
  end

  def original_url
    Rails.application.routes.url_helpers.original_work_url(self)
  end
end
