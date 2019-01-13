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

  desc 'Update character_count columns'
  task character_counts: :environment do
    require 'genron_sf/client'

    Synopsis.includes(:subject, :student).all.each do |synopsis|
      result = GenronSf::Client.get_work(synopsis.subject.year, synopsis.student.original_id, synopsis.original_id)
      synopsis.update_columns(character_count: result.summary_character_count, appeal_character_count: result.appeal_character_count)
    end

    Work.includes(:subject, :student).all.each do |work|
      result = GenronSf::Client.get_work(work.subject.year, work.student.original_id, work.original_id)
      work.update_columns(character_count: result.work_character_count, appeal_character_count: result.appeal_character_count)
    end
  end
end
