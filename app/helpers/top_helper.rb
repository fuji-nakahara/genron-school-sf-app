module TopHelper
  SubjectLabel = Struct.new(:theme, :text)

  def subject_label(index, no_synopsis = false)
    index += 1 if no_synopsis && index < 2

    labels = [
      [:primary, '梗概提出'],
      [:success, '実作提出'],
      [:secondary, '終了'],
    ]
    theme, text = labels[index]

    content_tag(:span, text, class: "badge badge-#{theme}")
  end
end
