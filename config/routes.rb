Rails.application.routes.draw do
  root 'top#show'
  resources :subjects, only: %i[index show]
  resources :students, only: %i[index show]
  resources :scores, only: :show

  direct :original_root do
    'https://school.genron.co.jp/works/sf/'
  end

  direct :original_students do |year|
    "http://school.genron.co.jp/works/sf/#{year.presence || 2018}/students/"
  end

  direct :original_student do |student, year|
    "http://school.genron.co.jp/works/sf/#{year || student.terms.last.id}/students/#{student.original_id}/"
  end

  direct :original_subjects do |year|
    "http://school.genron.co.jp/works/sf/#{year.presence || 2018}/"
  end

  direct :original_subject do |subject|
    "http://school.genron.co.jp/works/sf/#{subject.term_id}/subjects/#{subject.number}/"
  end

  direct :original_work do |work|
    "http://school.genron.co.jp/works/sf/#{work.subject.term_id}/students/#{work.student.original_id}/#{work.original_id}/"
  end

  direct :twitter_user do |screen_name|
    "https://twitter.com/#{screen_name}"
  end
end
