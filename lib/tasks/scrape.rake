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

    ScrapeSubjectsJob.perform_now(Term.last.id)
    Subject.where('created_at > ?', start_time).each do |subject|
      twitter_client.update "課題が公開されました！ #SF創作講座\n「#{subject.title}」\n#{subject.original_url}"
    end

    ScrapeSynopsesJob.perform_now
    Synopsis.includes(:student, :subject).where('created_at > ?', start_time).each do |synopsis|
      twitter_client.update %(梗概が提出されました！ #SF創作講座\n#{synopsis.student.name}『#{synopsis.title}』\n"#{synopsis.content.truncate(80, separator: '。')}"\n#{synopsis.original_url})
    end

    ScrapeWorksJob.perform_now
    Work.includes(:student, :subject).where('created_at > ?', start_time).each do |work|
      twitter_client.update %(実作が提出されました！ #SF創作講座\n#{work.student.name}『#{work.title}』\n"#{work.content.truncate(80, separator: '。')}"\n#{work.original_url})
    end
  end

  desc 'Scrape scores'
  task scores: :environment do
    ScrapeScoresJob.perform_now
  end
end
