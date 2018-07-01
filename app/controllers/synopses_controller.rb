class SynopsesController < ApplicationController
  def show(id)
    @synopsis = Synopsis.find(id)
    redirect_to @synopsis.original_url if !authenticated? && !@synopsis.student.available
  end
end
