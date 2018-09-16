namespace :ebook do
  desc <<~DESC
    Generate epub and mobi

      $ bundle exec rake ebook:generate SUBJECT_ID=1
  DESC
  task generate: :environment do
    subject_id = ENV.fetch('SUBJECT_ID', '').to_i
    subject    = subject_id.zero? ? Subject.includes(synopses: :student, works: :student).latest : Subject.includes(synopses: :student, works: :student).find(subject_id)

    book = GEPUB::Book.new do |book|
      book.identifier                 = subject.original_url
      book.title                      = subject.title
      book.contributor                = 'フジ・ナカハラ'
      book.language                   = 'ja'
      book.page_progression_direction = 'rtl'

      STYLE_FILE_NAME = 'style.css'

      css = <<~CSS
        html {
          -epub-writing-mode: vertical-rl;
          -webkit-writing-mode: vertical-rl;
          writing-mode: vertical-rl;
        }

        p {
          text-indent: 1em;
        }

        .botenparent {
          text-emphasis: sesame filled;
          -webkit-text-emphasis: sesame filled;
        }
      CSS

      book
        .add_item(STYLE_FILE_NAME)
        .add_content(StringIO.new(css))

      book.ordered do
        synopsis_title = <<~HTML
          <html>
          <head>
            <link rel="stylesheet" href="#{STYLE_FILE_NAME}" type="text/css">
          </head>
          <body>
            <h1>梗概</h1>
          </body
          </html>
        HTML

        book
          .add_item('synopsis.xhtml')
          .add_content(StringIO.new(Nokogiri::HTML(synopsis_title).to_xhtml))
          .toc_text('梗概')

        subject.synopses.each do |synopsis|
          book
            .add_item("synopses/#{synopsis.student.original_id}.xhtml")
            .add_content(StringIO.new(synopsis.to_xhtml(style_path: "../#{STYLE_FILE_NAME}")))
            .toc_text(synopsis.title_and_student_name)
        end

        work_title = <<~HTML
          <html>
          <head>
            <link rel="stylesheet" href="#{STYLE_FILE_NAME}" type="text/css">
          </head>
          <body>
            <h1>実作</h1>
          </body
          </html>
        HTML

        book
          .add_item('work.xhtml')
          .add_content(StringIO.new(Nokogiri::HTML(work_title).to_xhtml))
          .toc_text('実作')

        subject.works.each do |work|
          book
            .add_item("synopses/#{work.student.original_id}.xhtml")
            .add_content(StringIO.new(work.to_xhtml(style_path: "../#{STYLE_FILE_NAME}")))
            .toc_text(work.title_and_student_name)
        end
      end
    end

    dir = Rails.root.join('tmp', 'ebook', subject.term.id.to_s)
    FileUtils.mkdir_p(dir)

    file_name = "#{subject.term_id}-#{subject.number.to_s.rjust(2, '0')} #{subject.title}"

    book.generate_epub("#{dir}/#{file_name}.epub")
    Kindlegen.run("#{dir}/#{file_name}.epub", '-o', "#{file_name}.mobi")
  end
end
