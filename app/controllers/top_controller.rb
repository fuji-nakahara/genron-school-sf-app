class TopController < ApplicationController
  def show
    @subjects = Subject.latest2
  end
end
