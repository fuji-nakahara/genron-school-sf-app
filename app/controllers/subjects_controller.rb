class SubjectsController < ApplicationController
  def index
    @subjects = Subject.ordered
  end

  def show(id)
    @subject = Subject.includes(synopses: :student, works: :student).find(id)
  end
end
