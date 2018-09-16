require_relative 'base'

module GenronSf
  module Models
    class Work < Base
      attr_reader :year, :student_id, :id

      def post_initialize(options)
        @year = options[:year]
        @student_id = options[:student_id]
        @id = options[:id]
      end

      def summary_title
        @summary_title ||= doc.at_css('.summary-title')&.content
      end

      def summary
        @summary ||= doc.at_css('.summary-content').tap { |e| e.at_css('.count-character').remove }.children.to_html.strip
      end

      def work_title
        @work_title ||= doc.at_css('.work-title')&.content
      end

      def body
        @body ||= doc.at_css('.work-content').tap { |e| e.at_css('.count-character').remove }.children.to_html.strip
      end

      def appeal
        @appeal ||= doc.at_css('.appeal-content')&.tap { |e| e.at_css('.count-character')&.remove }&.children&.to_html&.strip
      end
    end
  end
end
