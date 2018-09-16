module GenronSf
  module Models
    class Subject < Base
      attr_reader :year, :number

      def post_initialize(options)
        @year   = options[:year]
        @number = options[:number]
      end

      def title
        @title ||= doc.at_css('#main h1.entry-title').content.gsub(/[「」]/, '')
      end

      def detail
        @detail ||= doc.at_css('#main .entry-content').content.strip
      end

      def deadline_date
        @deadline_date ||= parse_date(doc.at_css('#main .entry-description .date-deadline .date')&.content)
      end

      def comment_date
        @comment_date ||= parse_date(doc.at_css('#main .entry-description .date-comment .date')&.content)
      end

      def work_deadline_date
        @work_deadline_date ||= parse_date(doc.at_css('#main .entry-description .date-deadline-work .date').content)
      end

      def work_comment_date
        @work_comment_date ||= parse_date(doc.at_css('#main .entry-description .date-comment-work .date').content)
      end

      def work_id_to_score
        @work_id_to_score ||= doc.css('.type-excellents').map do |element|
          work_id = element.at_css('a')['href']&.split('/')&.last
          score   = element.at_css('.score')&.content
          [work_id, score] unless work_id.nil?
        end.compact.to_h
      end

      private

      def parse_date(date_str)
        Date.strptime(date_str&.strip, '%Y年%m月%d日') rescue nil
      end
    end
  end
end
