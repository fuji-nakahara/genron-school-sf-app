Rails.application.routes.draw do
  direct :original_students do |year|
    "http://school.genron.co.jp/works/sf/#{year.presence || 2018}/students/"
  end
end
