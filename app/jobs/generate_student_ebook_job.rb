require 'ebook_generator'

class GenerateStudentEbookJob < ApplicationJob
  queue_as :default

  def perform(student, year, generator: EbookGenerator.new)
    generator.identifier  = student.original_url
    generator.title       = "#{student.name} SF創作講座 #{year} 作品集"
    generator.creator     = student.name
    generator.contributor = 'ゲンロン 大森望 SF創作講座'
    generator.add_contributor 'フジ・ナカハラ'

    submitted_subjects = (student.synopses.map(&:subject) + student.works.map(&:subject)).uniq.select { |s| s.year == year }.sort_by(&:number)
    return if submitted_subjects.empty?

    submitted_subjects.each do |subject|
      generator.add_chapter_title("#{subject.display_number}「#{subject.title}」", file_name: "#{subject.number}-title")

      if (synopsis = student.synopses.find { |s| s.subject == subject })
        generator.add_submitted(synopsis, file_path: "#{subject.number}-synopsis")
      end

      if (work = student.works.find { |w| w.subject == subject })
        generator.add_submitted(work, file_path: "#{subject.number}-work")
      end
    end

    file_path = "students/#{year}/#{student.name.tr('/', '|')} #{year}"
    generator.generate(file_path)
  end
end
