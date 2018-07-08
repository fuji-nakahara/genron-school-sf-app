class WorksController < ApplicationController
  def show(id)
    @work = Work.find(id)
    redirect_to @work.original_url if !logged_in? && !@work.student.available
  end
end
