class TopController < ApplicationController
  def show(password = nil)
    remember(password) if password.present?

    @subjects = Subject.latest3
  end
end
