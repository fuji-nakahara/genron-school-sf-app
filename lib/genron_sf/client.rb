require 'nokogiri'
require 'open-uri'

require_relative 'models/student'
require_relative 'models/student_list'
require_relative 'models/subject_list'

module GenronSf
  class Client
    BASE_URL = 'http://school.genron.co.jp/works/sf'.freeze

    attr_reader :url

    class << self
      def get_student_list(year)
        doc = new("/#{year}/students/").parse
        Models::StudentList.new(doc, year: year)
      end

      def get_student(year, id)
        doc = new("/#{year}/students/#{id}/").parse
        Models::Student.new(doc, id: id)
      end

      def get_subject_list(year)
        doc = new("/#{year}/").parse
        Models::SubjectList.new(doc, year: year)
      end
    end

    def initialize(path)
      @url = "#{BASE_URL}#{path}"
    end

    def parse
      Nokogiri::HTML(open(url))
    end
  end
end
