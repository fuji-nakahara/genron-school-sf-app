class TwitterClient < Twitter::REST::Client
  def initialize(options = {}, &block)
    @consumer_key        = Rails.application.credentials.dig(:twitter, :consumer_key)
    @consumer_secret     = Rails.application.credentials.dig(:twitter, :consumer_secret)
    @access_token        = Rails.application.credentials.dig(:twitter, :access_token)
    @access_token_secret = Rails.application.credentials.dig(:twitter, :access_token_secret)
    super(options, &block)
  end

  def update_subject(subject)
    date_prefix = subject.no_synopsis? ? 'work_' : ''
    update <<~EOS
      【課題】 第#{subject.number}回「#{subject.title}」#{subject.proposers.present? ? "\n#{Lecturer::ROLE_NAME_PROPOSER}: #{subject.proposers.join('、')}" : ''}
      #{subject.no_synopsis? ? '実作' : '梗概'}締切: #{I18n.l(subject.send("#{date_prefix}deadline_date"), format: :long)}
      講評会: #{I18n.l(subject.send("#{date_prefix}comment_date"), format: :long)}
      #SF創作講座
      #{subject.original_url}
    EOS
  end

  def update_synopsis(synopsis)
    screen_name = synopsis.student.twitter_screen_name.nil? ? nil : " @#{synopsis.student.twitter_screen_name} "

    title  = "【梗概】#{synopsis.student.name}#{screen_name}『#{synopsis.title.truncate(80)}』"
    quote  = %(\n"#{synopsis.content.truncate(80, separator: '。')}")
    footer = "\n#SF創作講座\n#{synopsis.original_url} "

    result = Twitter::TwitterText::Validation.parse_tweet(title + quote + footer)

    if result[:valid]
      update(title + quote + footer)
    else
      update(title + footer)
    end
  end

  def update_work(work)
    screen_name = work.student.twitter_screen_name.nil? ? nil : " @#{work.student.twitter_screen_name} "

    title  = "【実作】#{work.student.name}#{screen_name}『#{work.title.truncate(80)}』"
    quote  = %(\n"#{work.content.truncate(80, separator: '。')}")
    footer = "\n#SF創作講座\n#{work.original_url}"

    result = Twitter::TwitterText::Validation.parse_tweet(title + quote + footer)

    if result[:valid]
      update(title + quote + footer)
    else
      update(title + footer)
    end
  end
end
