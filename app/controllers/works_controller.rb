class WorksController < ApplicationController
  def show(id)
    @work = Work.find(id)
  end
end
