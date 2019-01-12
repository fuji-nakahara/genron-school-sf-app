namespace :import do
  desc 'Import latest subjects, synopses and works'
  task latest: :environment do
    date = Time.zone.yesterday # with 1 day margin

    ImportSubjectsJob.perform_now(Term.last.id)
    Subject.where('deadline_date >= ?', date).each { |subject| ImportSynopsesJob.perform_now(subject) }
    Subject.where('work_deadline_date >= ?', date).each { |subject| ImportWorksJob.perform_now(subject) }
  end

  desc <<~DESC
    Import scores.
    
      $ bundle exec rake import:scores SUBJECT_IDS=1,2
  DESC
  task scores: :environment do
    ids      = ENV.fetch('SUBJECT_IDS', '').split(',').map(&:to_i)
    subjects = ids.empty? ? Subject.latest3.last(2) : Subject.where(id: ids)
    subjects.each do |subject|
      ImportScoresJob.perform_now(subject)
    end
  end

  desc <<~DESC
    Import students.

      $ bundle exec rake import:students YEARS=2016,2017
  DESC
  task students: :environment do
    years = ENV.fetch('YEARS', '').split(',').map(&:to_i).presence || [Term.last.id]
    ImportStudentsJob.perform_now(*years)
  end
end
