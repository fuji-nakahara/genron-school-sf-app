Rails.application.routes.draw do
  direct :original_students do |year|
    "http://school.genron.co.jp/works/sf/#{year.presence || 2018}/students/"
  end

  direct :original_student do |year, student|
    "http://school.genron.co.jp/works/sf/#{year || student.terms.last.id}/students/#{student.wp_id}"
  end

  direct :original_subjects do |year|
    "http://school.genron.co.jp/works/sf/#{year.presence || 2018}/"
  end
end
