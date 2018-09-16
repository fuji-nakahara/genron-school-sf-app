[2016, 2017, 2018].each do |id|
  Term.create(id: id) unless Term.exists?(id: id)
end

ImportStudentsJob.perform_now

ImportSubjectsJob.perform_now

Subject.all.each do |subject|
  ImportSynopsesJob.perform_now(subject)
  ImportWorksJob.perform_now(subject)
  ImportScoresJob.perform_now(subject)
end
