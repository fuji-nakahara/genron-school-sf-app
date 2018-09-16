namespace :scrape do
  desc 'Scrape and tweet latest subjects, synopses and works'
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
        課題が公開されました！ #SF創作講座
        第#{subject.number}回「#{subject.title}」
        #{subject.no_synopsis? ? '実作' : '梗概'}締切: #{I18n.l(subject.send("#{date_prefix}deadline_date"), format: :long)}
        講評会: #{I18n.l(subject.send("#{date_prefix}comment_date"), format: :long)}
        #{subject.original_url}
      EOS
    end

    Subject.where('deadline_date >= ?', date).each { |subject| ScrapeSynopsesJob.perform_now(subject) }
    Synopsis.includes(:student, :subject).where('created_at > ?', start_time).each do |synopsis|
      title = "梗概が提出されました！ #SF創作講座\n#{synopsis.student.name}『#{synopsis.title.truncate(80)}』"
      quote = %(\n"#{synopsis.content.truncate(80, separator: '。')}")
      url   = "\n#{synopsis.original_url}"

      result = Twitter::TwitterText::Validation.parse_tweet(title + quote + url)

      if result[:valid]
        twitter_client.update(title + quote + url)
      else
        twitter_client.update(title + url)
      end
    end

    Subject.where('work_deadline_date >= ?', date).each { |subject| ScrapeWorksJob.perform_now(subject) }
    Work.includes(:student, :subject).where('created_at > ?', start_time).each do |work|
      title = "実作が提出されました！ #SF創作講座\n#{work.student.name}『#{work.title.truncate(80)}』"
      quote = %(\n"#{work.content.truncate(80, separator: '。')}")
      url   = "\n#{work.original_url}"

      result = Twitter::TwitterText::Validation.parse_tweet(title + quote + url)

      if result[:valid]
        twitter_client.update(title + quote + url)
      else
        twitter_client.update(title + url)
      end
    end
  end

  desc <<~DESC
    Scrape scores.
    
      $ bundle exec rake scrape:scores SUBJECT_IDS=1,2
  DESC
  task scores: :environment do
    ids = ENV.fetch('SUBJECT_IDS', '').split(',').map(&:to_i)
    subjects = ids.empty? ? Subject.latest3.last(2) : Subject.where(id: ids)
    subjects.each do |subject|
      ImportScoresJob.perform_now(subject)
      sleep 1
    end
  end

  desc <<~DESC
    Scrape students.

      $ bundle exec rake scrape:students YEARS=2016,2017
  DESC
  task students: :environment do
    years = ENV.fetch('YEARS', '').split(',').map(&:to_i).presence || [Term.last.id]
    ImportStudentsJob.perform_now(*years)
  end
end
