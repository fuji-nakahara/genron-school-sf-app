desc 'Tweet new subjects, synopses and works'
task tweet: :environment do
  require 'twitter_client'

  CACHE_KEY = 'tasks/tweet'

  last_tweet_time = Rails.cache.read(CACHE_KEY) or raise "There is no cache with key: #{CACHE_KEY}"

  twitter_client = TwitterClient.new

  Subject.where('created_at > ?', last_tweet_time).each do |subject|
    twitter_client.update_subject(subject)
    sleep 1
  end

  Synopsis.includes(:student, :subject).where('created_at > ?', last_tweet_time).each do |synopsis|
    twitter_client.update_synopsis(synopsis)
    sleep 1
  end

  Work.includes(:student, :subject).where('created_at > ?', last_tweet_time).each do |work|
    twitter_client.update_work(work)
    sleep 1
  end

  Rails.cache.write(CACHE_KEY, Time.zone.now)
end
