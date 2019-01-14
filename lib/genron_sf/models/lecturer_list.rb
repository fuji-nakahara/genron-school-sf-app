require_relative 'base'

module GenronSf
  module Models
    class LecturerList < Base
      Lecturer = Struct.new(:name, :note, :roles)

      include Enumerable

      attr_reader :year, :number

      def post_initialize(options)
        @year   = options[:year]
        @number = options[:number]
      end

      def each(&block)
        lecturers.each(&block)
      end

      def to_a
        lecturers
      end

      private

      def lecturers
        @lecturers ||= doc.css('.lecturer-name-list-item').map do |e|
          name, note = extract_name_and_note(e.at_css('.lecturer-name'))
          roles = e.at_css('.lecturer-role').content[/([^：]+)：/, 1].split(/[、・]/)
          Lecturer.new(name, note, roles)
        end
      end

      def extract_name_and_note(element)
        match = element.content.match(/(?<name>[^（）]+)(（(?<note>.*)）)?/)
        [match[:name].strip, match[:note]]
      end
    end
  end
end
