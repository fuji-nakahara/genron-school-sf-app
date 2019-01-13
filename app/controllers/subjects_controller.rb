class SubjectsController < ApplicationController
  def index
    @subjects = Subject.ordered
  end

  def show(id)
    @subject = Subject.includes(synopses: [:student, :subject], works: [:student, :subject]).find(id)
  end
end
