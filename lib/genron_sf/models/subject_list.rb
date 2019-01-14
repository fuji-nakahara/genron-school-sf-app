require_relative 'base'
require_relative 'lecturer_list'

module GenronSf
  module Models
    class SubjectList < Base
      Subject = Struct.new(:number, :title, :deadline_date, :comment_date, :work_deadline_date, :work_comment_date, :lecturer_list)

      include Enumerable

      attr_reader :year

      def post_initialize(options)
        @year = options[:year]
      end

      def each(&block)
        subjects.each(&block)
      end

      private

      def subjects
        @subjects ||= doc.css('.page-content article').map do |e|
          number             = e.at_css('.number').content.scan(/\d+/).first.to_i
          title              = e.at_css('h1').content.strip[/\A「(.*)」\z/, 1]
          deadline_date      = parse_date(e.at_css('.date-deadline .date')&.content)
          comment_date       = parse_date(e.at_css('.date-comment .date')&.content)
          work_deadline_date = parse_date(e.at_css('.date-deadline-work .date').content)
          work_comment_date  = parse_date(e.at_css('.date-comment-work .date').content)
          lecturer_list      = LecturerList.new(e.at_css('.lecturer-name-list'), year: year, number: number)
          Subject.new(number, title, deadline_date, comment_date, work_deadline_date, work_comment_date, lecturer_list)
        end
      end

      def parse_date(date_str)
        Date.strptime(date_str&.strip, '%Y年%m月%d日') rescue nil
      end
    end
  end
end
