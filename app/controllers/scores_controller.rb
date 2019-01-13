class ScoresController < ApplicationController
  def show(id)
    return redirect_to score_url(Term.last.id) if id == 'latest'

    @score_chart = ScoreChart.new(id)
  end
end
