class TopController < ApplicationController
  def show
    @subjects = Subject.latest3
  end
end
