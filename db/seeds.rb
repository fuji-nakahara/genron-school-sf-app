[2016, 2017, 2018].each do |id|
  Term.create(id: id) unless Term.exists?(id: id)
end
puts "Created terms: #{Term.pluck(:id).join(',')}"

puts 'Importing students...'
ImportStudentsJob.perform_now
puts "Imported #{Student.count} students!"

puts 'Importing subjects...'
ImportSubjectsJob.perform_now
puts "Imported #{Subject.count} subjects!"

Subject.all.each do |subject|
  puts "Importing #{subject.year} #{subject.display_number}「#{subject.title}」 data..."
  ImportSynopsesJob.perform_now(subject)
  ImportWorksJob.perform_now(subject)
  ImportScoresJob.perform_now(subject)
  puts "Imported #{subject.reload.synopses.count} synopses and #{subject.works.count} works!"
end
