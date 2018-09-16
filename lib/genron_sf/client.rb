require 'open-uri'
require 'nokogiri'

require_relative 'models/student_list'
require_relative 'models/student'

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
    end

    def initialize(path)
      @url = "#{BASE_URL}#{path}"
    end

    def parse
      Nokogiri::HTML(open(url))
    end
  end
end
