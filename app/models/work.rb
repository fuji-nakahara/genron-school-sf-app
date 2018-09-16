class Work < ApplicationRecord
  include Submitted

  def synopsis
    Synopsis.of(original_id)
  end

  def to_xhtml(style_path: nil)
    html = <<~HTML
      <html>
      <head>
        <link rel="stylesheet" href="#{style_path}" type="text/css">
      </head>
      <body>
        <h2>#{title_and_student_name}</h2>
        #{body}
      </body>
      </html>
    HTML
    Nokogiri::HTML(html).tap { |doc| doc.css('img, iframe').remove }.to_xhtml
  end
end
