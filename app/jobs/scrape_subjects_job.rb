require 'open-uri'

class ScrapeSubjectsJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  SubjectInfo = Struct.new(:number, :title, :deadline_date, :comment_date, :work_deadline_date, :work_comment_date)

  NO_SYNOPSIS_NUMBER = 11

  def perform(*years)
    years = years.presence || Term.pluck(:id)
    years.each do |year|
      subject_infos = scrape_subject_info(year)
      subject_infos.each do |subject_info|
        Subject.create_with(
          title:              subject_info.title,
          deadline_date:      subject_info.number.to_i == NO_SYNOPSIS_NUMBER ? nil : subject_info.deadline_date,
          comment_date:       subject_info.number.to_i == NO_SYNOPSIS_NUMBER ? nil : subject_info.comment_date,
          work_deadline_date: subject_info.work_deadline_date,
          work_comment_date:  subject_info.work_comment_date,
        ).find_or_create_by(term_id: year, number: subject_info.number)
      end
    end
  end

  private

  def scrape_subject_info(year)
    doc = Nokogiri::HTML(open(original_subjects_url(year)))
    doc.css('.page-content article').map do |e|
      number             = e.at_css('.number').content.scan(/\d+/).first
      title              = e.at_css('h1').content.gsub(/[「」]/, '')
      deadline_date      = parse_date(e.at_css('.date-deadline .date')&.content)
      comment_date       = parse_date(e.at_css('.date-comment .date')&.content)
      work_deadline_date = parse_date(e.at_css('.date-deadline-work .date').content)
      work_comment_date  = parse_date(e.at_css('.date-comment-work .date').content)
      SubjectInfo.new(number, title, deadline_date, comment_date, work_deadline_date, work_comment_date)
    end
  end

  def parse_date(date_str)
    Date.strptime(date_str&.strip, '%Y年%m月%d日') rescue nil
  end
end
