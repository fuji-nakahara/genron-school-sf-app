require 'ebook_generator'

class GenerateSubjectEbookJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.includes(synopses: :student, works: :student).latest, generator: EbookGenerator.new)
    generator.identifier  = subject.original_url
    generator.title       = subject.title
    generator.creator     = 'ゲンロン 大森望 SF創作講座'
    generator.contributor = subject.proposers.first&.name
    generator.contributor = subject.proposers.first&.name
    generator.add_contributor 'フジ・ナカハラ'

    submitted_students = (subject.synopses.map(&:student) + subject.works.map(&:student)).uniq.sort_by(&:original_id)

    submitted_students.each do |student|
      generator.add_chapter_title(student.name, file_name: student.original_id)

      if (synopsis = subject.synopses.find { |synopsis| synopsis.student == student })
        generator.add_submitted(synopsis, file_path: "#{student.original_id}/synopsis")
      end

      if (work = subject.works.find { |work| work.student == student })
        generator.add_submitted(work, file_path: "#{student.original_id}/work")
      end
    end

    file_path = "subjects/#{subject.year}/#{subject.year}-#{subject.number.to_s.rjust(2, '0')} #{subject.title}"
    generator.generate(file_path)
  end
end
