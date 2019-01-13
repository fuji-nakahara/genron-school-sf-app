module GenronSf
  module Models
    class Subject < Base
      WorkInfo          = Struct.new(:student_id, :id)
      ExcellentWorkInfo = Struct.new(:student_id, :id, :score)

      attr_reader :year, :number

      def post_initialize(options)
        @year   = options[:year]
        @number = options[:number]
      end

      def title
        @title ||= doc.at_css('#main h1.entry-title').content.strip[/\A「(.*)」\z/, 1]
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

      def excellent_works
        @excellent_works ||= doc.css('.type-excellents').map do |element|
          arr = element.at_css('a')['href']&.split('/')&.slice(-2..-1)
          ExcellentWorkInfo.new(arr[0], arr[1], element.at_css('.score')&.content&.to_i) if arr.present?
        end.compact
      end

      def synopses
        @synopses ||= doc.css('.written a').map do |element|
          arr = element['href'].split('/').slice(-2..-1)
          WorkInfo.new(arr[0], arr[1]) if arr.present?
        end.compact
      end

      def works(no_synopsis: false)
        @works ||= doc.css(no_synopsis ? '.written a' : '.has-work a').map do |element|
          arr = element['href'].split('/').slice(-2..-1)
          WorkInfo.new(arr[0], arr[1]) if arr.present?
        end.compact
      end

      private

      def parse_date(date_str)
        Date.strptime(date_str&.strip, '%Y年%m月%d日') rescue nil
      end
    end
  end
end
