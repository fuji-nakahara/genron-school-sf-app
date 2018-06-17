class Synopsis < ApplicationRecord
  belongs_to :subject
  belongs_to :student

  def update_contents
    doc         = Nokogiri::HTML(open(original_url))
    self.title  = doc.at_css('.summary-title')&.content
    self.body   = doc.at_css('.summary-content').tap { |e| e.at_css('.count-character').remove }.children.to_html.strip
    self.appeal = doc.at_css('.appeal-content')&.tap { |e| e.at_css('.count-character')&.remove }&.children&.to_html&.strip
  end

  def original_url
    Rails.application.routes.url_helpers.original_work_url(self)
  end
end
