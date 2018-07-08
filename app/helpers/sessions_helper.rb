module SessionsHelper
  def log_in
    session[:logged_in?] = true
  end

  def log_out
    forget
    session.delete(:logged_in?)
  end

  def logged_in?
    if session[:logged_in?]
      true
    elsif cookies.has_key?(:remember_token) && cookies[:remember_token] == Rails.cache.read(cookies.signed[:browser_id], namespace: :remember_token)
      log_in
    end
  end

  def remember
    browser_id     = SecureRandom.uuid
    remember_token = SecureRandom.urlsafe_base64

    Rails.cache.write(browser_id, remember_token, namespace: :remember_token)

    cookies.permanent.signed[:browser_id] = browser_id
    cookies.permanent[:remember_token]    = remember_token
  end

  def forget
    Rails.cache.delete(cookies.signed[:browser_id], namespace: :remember_token)

    cookies.delete(:browser_id)
    cookies.delete(:remember_token)
  end
end
