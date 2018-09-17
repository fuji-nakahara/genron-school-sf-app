namespace :ebook do
  desc <<~DESC
    Generate epub and mobi

      $ bundle exec rake ebook:generate YEAR=2018 NUMBER=1
  DESC
  task generate: :environment do
    subject = Subject.find_by!(term_id: ENV['YEAR'], number: ENV['NUMBER'])

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
            .add_item("work/#{work.student.original_id}.xhtml")
            .add_content(StringIO.new(work.to_xhtml(style_path: "../#{STYLE_FILE_NAME}")))
            .toc_text(work.title_and_student_name)
        end
      end
    end

    file_name = "#{subject.term_id}-#{subject.number.to_s.rjust(2, '0')} #{subject.title}"
    epub_path = Rails.root.join('output', "#{file_name}.epub")

    book.generate_epub(epub_path)

    Kindlegen.run(epub_path.to_s, '-o', "#{file_name}.mobi")
  end
end
