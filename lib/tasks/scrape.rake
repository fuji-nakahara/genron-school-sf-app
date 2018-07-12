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

    ScrapeSubjectsJob.perform_now(Term.last.id)
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
      twitter_client.update %(梗概が提出されました！ #SF創作講座\n#{synopsis.student.name}『#{synopsis.title}』\n"#{synopsis.content.truncate(80, separator: '。')}"\n#{synopsis.original_url})
    end

    Subject.where('work_deadline_date >= ?', date).each { |subject| ScrapeWorksJob.perform_now(subject) }
    Work.includes(:student, :subject).where('created_at > ?', start_time).each do |work|
      twitter_client.update %(実作が提出されました！ #SF創作講座\n#{work.student.name}『#{work.title}』\n"#{work.content.truncate(80, separator: '。')}"\n#{work.original_url})
    end
  end

  desc 'Scrape scores'
  task scores: :environment do
    Subject.latest3.last(2).each do |subject|
      ScrapeScoresJob.perform_now(subject)
    end
  end
end
