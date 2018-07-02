module TopHelper
  SubjectLabel = Struct.new(:theme, :text)

  def subject_state_label(subject)
    theme, text = case
                  when subject.comment_date&.>(Time.zone.today)
                    %w[primary 梗概提出]
                  when subject.work_comment_date > Time.zone.today
                    %w[success 実作提出]
                  else
                    %w[secondary 終了]
                  end
    content_tag(:span, text, class: "badge badge-#{theme}")
  end
end
