[2016, 2017, 2018].each do |id|
  Term.create(id: id) unless Term.exists?(id: id)
end

ImportStudentsJob.perform_now

ScrapeSubjectsJob.perform_now

Subject.all.each do |subject|
  ScrapeSynopsesJob.perform_now(subject)
  ScrapeWorksJob.perform_now(subject)
  ScrapeScoresJob.perform_now(subject)
end
