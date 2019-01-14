namespace :ebook do
  desc <<~DESC
    Generate EPUB and MOBI files from a subject

      $ bundle exec rake ebook:generate YEAR=2018 NUMBER=1
  DESC
  task subject: :environment do
    STYLE_FILE_NAME = 'ebook.css'

    renderer     = ApplicationController.renderer.new(layout: 'ebook')
    view_helpers = ApplicationController.helpers

    subject = Subject.find_by!(year: ENV.fetch('YEAR'), number: ENV.fetch('NUMBER'))

    book = GEPUB::Book.new do |book|
      book.identifier  = subject.original_url
      book.title       = subject.title
      book.contributor = subject.proposers.first
      book.language    = 'ja'

      book
        .add_item(STYLE_FILE_NAME)
        .add_content(File.open(Rails.root.join('app/assets/stylesheets', STYLE_FILE_NAME)))

      book.ordered do
        synopsis_title = renderer.render(html: view_helpers.tag.h1('梗概'), layout: 'ebook', assigns: { css_path: STYLE_FILE_NAME })
        book
          .add_item('synopsis.xhtml')
          .add_content(StringIO.new(Nokogiri::HTML(synopsis_title).to_xhtml))
          .toc_text('梗概')

        subject.synopses.each do |synopsis|
          html  = renderer.render('ebooks/show', layout: 'ebook', assigns: { work: synopsis, css_path: "../#{STYLE_FILE_NAME}" })
          xhtml = Nokogiri::HTML(html).tap { |doc| doc.css('img, iframe').remove }.to_xhtml
          book
            .add_item("synopses/#{synopsis.student.original_id}.xhtml")
            .add_content(StringIO.new(xhtml))
            .toc_text(synopsis.title_and_student_name)
        end

        work_title = renderer.render(html: view_helpers.tag.h1('実作'), layout: 'ebook', assigns: { css_path: STYLE_FILE_NAME })
        book
          .add_item('work.xhtml')
          .add_content(StringIO.new(Nokogiri::HTML(work_title).to_xhtml))
          .toc_text('実作')

        subject.works.each do |work|
          html  = renderer.render('ebooks/show', layout: 'ebook', assigns: { work: work, css_path: "../#{STYLE_FILE_NAME}" })
          xhtml = Nokogiri::HTML(html).tap { |doc| doc.css('img, iframe').remove }.to_xhtml
          book
            .add_item("works/#{work.student.original_id}.xhtml")
            .add_content(StringIO.new(xhtml))
            .toc_text(work.title_and_student_name)
        end
      end
    end

    file_name = "#{subject.year}-#{subject.number.to_s.rjust(2, '0')} #{subject.title}"
    epub_path = Rails.root.join('output', "#{file_name}.epub")

    book.generate_epub(epub_path)

    Kindlegen.run(epub_path.to_s, '-o', "#{file_name}.mobi")
  end
end
