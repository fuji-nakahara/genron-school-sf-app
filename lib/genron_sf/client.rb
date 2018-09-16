require 'open-uri'
require 'nokogiri'

require_relative 'models/student_list'

module GenronSf
  class Client
    BASE_URL = 'http://school.genron.co.jp/works/sf'.freeze

    attr_reader :url

    class << self
      def get_student_list(year)
        doc = new("/#{year}/students/").parse
        Models::StudentList.new(doc, year: year)
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
