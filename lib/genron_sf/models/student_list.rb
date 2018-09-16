require_relative 'base'

module GenronSf
  module Models
    class StudentList < Base
      Student = Struct.new(:name, :id)

      include Enumerable

      attr_reader :year

      def post_initialize(options)
        @year = options[:year]
      end

      def each(&block)
        students.each(&block)
      end

      private

      def students
        @students ||= doc.css('.student-list-item a').map do |element|
          Student.new(element.css('.name').content, element['href'].split('/').last)
        end
      end
    end
  end
end
