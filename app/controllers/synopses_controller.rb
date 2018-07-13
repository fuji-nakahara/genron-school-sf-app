class SynopsesController < ApplicationController
  def show(id)
    @synopsis = Synopsis.find(id)
  end
end
