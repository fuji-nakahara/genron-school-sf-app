namespace :ebook do
  desc 'Generate subject based EPUB and MOBI files'
  task subject: :environment do
    Subject.includes(synopses: :student, works: :student).ordered.each do |subject|
      GenerateSubjectEbookJob.perform_now(subject)
      puts "Generated: #{subject.year} #{subject.display_number}"
    end
  end

  desc 'Generate student based EPUB and MOBI files'
  task student: :environment do
    Student.includes(:terms, synopses: :subject, works: :subject).each do |student|
      student.terms.each do |term|
        GenerateStudentEbookJob.perform_now(student, term.year)
        puts "Generated: #{student.name} #{term.year}"
      end
    end
  end
end
