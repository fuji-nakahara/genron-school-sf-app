class SessionsController < ApplicationController
  def new
    redirect_to root_url if logged_in?
  end

  def create(password, remember_me = nil)
    if password == Rails.application.credentials.password
      log_in
      remember_me == '1' ? remember : forget
      redirect_to root_url
    else
      render js: "alert('パスワードが異なります');"
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
