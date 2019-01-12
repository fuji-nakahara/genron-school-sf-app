desc 'Tweet new subjects, synopses and works'
task tweet: :environment do
  require 'twitter_client'

  CACHE_KEY = 'tasks/tweet'

  last_tweet_time = Rails.cache.read(CACHE_KEY) or raise "There is no cache with key: #{CACHE_KEY}"

  twitter_client = TwitterClient.new

  subjects = Subject.where('created_at > ?', last_tweet_time).to_a
  synopses = Synopsis.includes(:student, :subject).where('created_at > ?', last_tweet_time).to_a
  works    = Work.includes(:student, :subject).where('created_at > ?', last_tweet_time).to_a

  Rails.cache.write(CACHE_KEY, Time.zone.now)

  subjects.each do |subject|
    twitter_client.update_subject(subject)
    sleep 1
  end

  synopses.each do |synopsis|
    twitter_client.update_synopsis(synopsis)
    sleep 1
  end

  works.each do |work|
    twitter_client.update_work(work)
    sleep 1
  end
end
