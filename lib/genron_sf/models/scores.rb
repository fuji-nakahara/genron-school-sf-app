require_relative 'base'

module GenronSf
  module Models
    class Scores < Base
      attr_reader :year

      def post_initialize(options)
        @year = options[:year]
      end

      def head
        doc.css('#table-scores thead th')[2..-1].map(&:content)
      end

      def body
        doc.css('#table-scores tbody tr').map do |tr|
          tds = tr.css('td')
          name = tds[0].content
          scores = tds[2..-1].map do |td|
            td.content[/\d+/]&.to_i
          end.compact
          [name, scores]
        end.to_h
      end
    end
  end
end
