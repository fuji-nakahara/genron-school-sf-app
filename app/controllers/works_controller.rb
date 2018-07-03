class WorksController < ApplicationController
  def show(id)
    @work = Work.find(id)
    redirect_to @work.original_url if !authenticated? && !@work.student.available
  end
end
