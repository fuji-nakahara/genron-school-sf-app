namespace :denden do
  desc <<~DESC
    Create denden markdown files

      $ bundle exec rake denden:create SUBJECT_ID=1 DEFAULT_STYLE=tmp/denden/default_vertical.css
  DESC
  task create: :environment do
    style_path = ENV.fetch('DEFAULT_STYLE_PATH', Rails.root.join('tmp', 'denden', 'default_vertical.css'))
    subject_id = ENV.fetch('SUBJECT_ID', '').to_i

    subject    = subject_id.zero? ? Subject.includes(synopses: :student, works: :student).latest : Subject.includes(synopses: :student, works: :student).find(subject_id)

    dir = Rails.root.join('tmp', 'denden', subject.term.id.to_s, subject.number.to_s)
    FileUtils.mkdir_p(dir)

    File.write("#{dir}/synopsis.txt", "# 梗概\n")

    subject.synopses.each do |synopsis|
      body    = Nokogiri::HTML(synopsis.body).tap { |doc| doc.css('img, iframe').remove }
      appeal  = Nokogiri::HTML(synopsis.appeal).tap { |doc| doc.css('img, iframe').remove }

      text = "## #{synopsis.title}／#{synopsis.student.name}\n\n#{body.css('body').children.to_xhtml}"
      text += "\n\n### アピール文\n\n#{appeal.css('body').children.to_xhtml}" unless appeal.css('body').empty?
      text += "\n\n### プロフィール\n\n#{synopsis.student.profile}" if synopsis.student.profile.present?

      File.write("#{dir}/synopsis_#{synopsis.student.original_id}.txt", text)
    end

    File.write("#{dir}/work.txt", "# 実作\n")

    subject.works.each do |work|
      body    = Nokogiri::HTML(work.body).tap { |doc| doc.css('img, iframe').remove }
      appeal  = Nokogiri::HTML(work.appeal).tap { |doc| doc.css('img, iframe').remove }

      text = "## #{work.title}／#{work.student.name}\n\n#{body.css('body').children.to_xhtml}"
      text += "\n\n### アピール文\n\n#{appeal.css('body').children.to_xhtml}" unless appeal.css('body').empty?

      File.write("#{dir}/work_#{work.student.original_id}.txt", text)
    end

    settings = <<~YAML
      ddconvVersion: '1.0'
      titles:
        - content: '#{subject.title}'
      creators:
        - content: フジ・ナカハラ
          role: edt
      pageDirection: rtl
      language: ja
      options:
        titlepage: true
        tocInSpine: true
        tocDisplayDepth: 2
        autoTcy: true
        tcyDigit: 2
        autoSentenceWrap: false
    YAML
    File.write("#{dir}/ddconv.yml", settings)

    style = File.read(style_path)
    style += <<~CSS
    
      /* My styles */

      p {
        margin-left: .5em !important;
        text-indent: 1em;
      }
      
      .botenparent {
        text-emphasis: sesame filled;
        -webkit-text-emphasis: sesame filled;
      }
    CSS
    File.write("#{dir}/style.css", style)
  end
end
