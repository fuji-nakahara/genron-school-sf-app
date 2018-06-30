class SubjectsController < ApplicationController
  def index
    @subjects = Subject.ordered
  end

  def show(id)
    @subject = Subject.includes(synopses: %i[student subject], works: %i[student subject]).find(id)
  end
end
