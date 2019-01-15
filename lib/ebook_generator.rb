class EbookGenerator < GEPUB::Book
  STYLE_FILE_NAME = 'ebook.css'
  INVALID_TAGS    = %w[iframe]

  attr_reader :renderer, :tag_builder, :layout, :parser

  def initialize(renderer: ApplicationController.renderer.new, tag_builder: ApplicationController.helpers.tag, parser: Nokogiri::HTML, layout: 'ebook', style_src: 'ebook.css')
    super()
    @renderer        = renderer
    @tag_builder     = tag_builder
    @layout          = layout
    @parser          = parser
    @style_file_name = STYLE_FILE_NAME

    style_path = Rails.root.join('app/assets/stylesheets', style_src)
    add_item(@style_file_name, content: File.open(style_path))

    language('ja')
  end

  def generate(file_path, ext: '.epub')
    full_path = Rails.root.join('output', file_path + ext)
    FileUtils.mkdir_p(File.dirname(full_path))
    generate_epub(full_path)
    Kindlegen.run(full_path.to_s, '-o', "#{File.basename(full_path, ext)}.mobi")
  end

  def add_chapter_title(title, file_name:)
    html = renderer.render(html: tag_builder.h1(title), layout: layout, assigns: { css_path: @style_file_name })
    add_ordered_item("#{file_name}.xhtml", content: StringIO.new(process(html)), toc_text: title)
  end

  def add_submitted(submitted, file_path:)
    html = renderer.render('ebooks/submitted', layout: 'ebook', assigns: { submitted: submitted, css_path: relative_path_to_css(file_path) })
    add_ordered_item("#{file_path}.xhtml", content: StringIO.new(process(html)))
  end

  private

  def process(html)
    doc = parser.parse(html)
    doc.css(INVALID_TAGS.join(',')).remove
    doc.to_xhtml
  end

  def relative_path_to_css(from_path)
    from_dir = Pathname.new(from_path).dirname
    Pathname.new(@style_file_name).relative_path_from(from_dir).to_s
  end
end
