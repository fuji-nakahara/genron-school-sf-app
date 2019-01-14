require 'nokogiri'
require 'open-uri'

require_relative 'models/student'
require_relative 'models/student_list'
require_relative 'models/subject'
require_relative 'models/subject_list'
require_relative 'models/work'
require_relative 'models/scores'

module GenronSf
  class Client
    BASE_URL = 'https://school.genron.co.jp/works/sf'.freeze

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

      def get_subject(year, number)
        doc = new("/#{year}/subjects/#{number}/").parse
        Models::Subject.new(doc, year: year, number: number)
      end

      def get_work(year, student_id, id)
        doc = new("/#{year}/students/#{student_id}/#{id}/").parse
        Models::Work.new(doc, year: year, student_id: student_id, id: id)
      end

      def get_scores(year)
        doc = new("/#{year}/scores").parse
        Models::Scores.new(doc, year: year)
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
