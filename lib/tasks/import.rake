namespace :import do
  desc 'Import and tweet latest subjects, synopses and works'
  task latest: :environment do
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.dig(:twitter, :consumer_key)
      config.consumer_secret     = Rails.application.credentials.dig(:twitter, :consumer_secret)
      config.access_token        = Rails.application.credentials.dig(:twitter, :access_token)
      config.access_token_secret = Rails.application.credentials.dig(:twitter, :access_token_secret)
    end

    start_time = Time.zone.now
    date       = Time.zone.yesterday # with 1 day margin

    ImportSubjectsJob.perform_now(Term.last.id)
    Subject.where('created_at > ?', start_time).each do |subject|
      date_prefix = subject.no_synopsis? ? 'work_' : ''
      twitter_client.update <<~EOS
        【課題】 第#{subject.number}回「#{subject.title}」
        #{subject.no_synopsis? ? '実作' : '梗概'}締切: #{I18n.l(subject.send("#{date_prefix}deadline_date"), format: :long)}
        講評会: #{I18n.l(subject.send("#{date_prefix}comment_date"), format: :long)}
        #{subject.original_url} #SF創作講座
      EOS
    end

    Subject.where('deadline_date >= ?', date).each { |subject| ImportSynopsesJob.perform_now(subject) }
    Synopsis.includes(:student, :subject).where('created_at > ?', start_time).each do |synopsis|
      screen_name = synopsis.student.twitter_screen_name.nil? ? nil : " @#{synopsis.student.twitter_screen_name} "

      title  = "【梗概】#{synopsis.student.name}#{screen_name}『#{synopsis.title.truncate(80)}』"
      quote  = %(\n"#{synopsis.content.truncate(80, separator: '。')}")
      footer = "\n#{synopsis.original_url} #SF創作講座"

      result = Twitter::TwitterText::Validation.parse_tweet(title + quote + footer)

      if result[:valid]
        twitter_client.update(title + quote + footer)
      else
        twitter_client.update(title + footer)
      end
    end

    Subject.where('work_deadline_date >= ?', date).each { |subject| ImportWorksJob.perform_now(subject) }
    Work.includes(:student, :subject).where('created_at > ?', start_time).each do |work|
      screen_name = synopsis.student.twitter_screen_name.nil? ? nil : " @#{synopsis.student.twitter_screen_name} "

      title  = "【実作】#{work.student.name}#{screen_name}『#{work.title.truncate(80)}』"
      quote  = %(\n"#{work.content.truncate(80, separator: '。')}")
      footer = "\n#{work.original_url} #SF創作講座"

      result = Twitter::TwitterText::Validation.parse_tweet(title + quote + footer)

      if result[:valid]
        twitter_client.update(title + quote + footer)
      else
        twitter_client.update(title + footer)
      end
    end
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
