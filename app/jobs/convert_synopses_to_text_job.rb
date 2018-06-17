class ConvertSynopsesToTextJob < ApplicationJob
  queue_as :default

  def perform(subject = Subject.includes(synopses: :student).latest)
    dir = Rails.root.join('tmp', 'outputs', subject.term.id.to_s, subject.number.to_s)
    FileUtils.mkdir_p(dir)
    subject.synopses.each do |synopsis|
      body   = Nokogiri::HTML(synopsis.body).tap { |doc| doc.css('img, iframe').remove }
      appeal = Nokogiri::HTML(synopsis.appeal)&.tap { |doc| doc.css('img, iframe').remove }

      text = <<~EOS
        # #{synopsis.title}／#{synopsis.student.name}

        #{body.css('body').children.to_html}

        ## アピール文

        #{appeal.css('body').children.to_html.presence || 'なし'}

        ## プロフィール

        #{synopsis.student.profile.presence || 'なし'}
      EOS

      File.write("#{dir}/#{synopsis.student.original_id}.txt", text.gsub(/<br>/, '<br />'))
    end
  end
end
