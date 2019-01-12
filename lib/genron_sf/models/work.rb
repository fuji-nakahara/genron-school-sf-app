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
        @summary ||= doc.at_css('.summary-content').children[0...-2].to_html.strip
      end

      def summary_character_count
        @summary_character_count ||= doc.at_css('.summary-content .count-character').content[/文字数：(\d+)/, 1].to_i
      end

      def work_title
        @work_title ||= doc.at_css('.work-title')&.content
      end

      def body
        @body ||= doc.at_css('.work-content')&.children&.slice(0...-2)&.to_html&.strip
      end

      def work_character_count
        @work_character_count ||= doc.at_css('.work-content .count-character')&.content&.slice(/文字数：(\d+)/, 1)&.to_i
      end

      def appeal
        @appeal ||= doc.at_css('.appeal-content')&.children&.slice(0...-2)&.to_html&.strip
      end

      def appeal_character_count
        @appeal_character_count ||= doc.at_css('.appeal-content .count-character')&.content&.slice(/文字数：(\d+)/, 1)&.to_i
      end
    end
  end
end
