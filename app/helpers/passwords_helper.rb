module PasswordsHelper
  def remember(password)
    cookies.permanent.signed[:password] = password
  end

  def authenticated?
    cookies.permanent.signed[:password] == Rails.application.credentials.password
  end
end
