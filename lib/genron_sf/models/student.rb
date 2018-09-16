require_relative 'base'

module GenronSf
  module Models
    class Student < Base
      attr_reader :id

      def post_initialize(options)
        @id = options[:id]
      end

      def name
        @name ||= doc.at_css('#main header h1').content
      end

      def profile
        @profile ||= doc.at_css('#main header p').content.strip
      end
    end
  end
end
