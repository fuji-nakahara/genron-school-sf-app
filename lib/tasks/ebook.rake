namespace :ebook do
  desc 'Generate subject based EPUB and MOBI files'
  task subject: :environment do
    Subject.includes(synopses: :student, works: :student).ordered.each do |subject|
      GenerateSubjectEbookJob.perform_now(subject)
      puts "Generated: #{subject.year} #{subject.display_number}"
    end
  end
end
