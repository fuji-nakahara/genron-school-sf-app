require 'genron_sf/client'

class ScoresController < ApplicationController
  def show(id)
    return redirect_to score_url(Term.last.id) if id == 'latest'

    @term = Term.find(id)

    @score_chart = Rails.cache.fetch("#{self.class.name.underscore}/#{id}", expires_in: 1.day) do
      logger.info "Fetching scores from the original site..."
      result   = GenronSf::Client.get_scores(id)
      labels   = result.head.take(result.body.values.map(&:size).max)
      datasets = result.body.map do |name, scores|
        sum = 0
        accumulated_scores = scores.map { |score| sum += score }
        { label: name, data: accumulated_scores }
      end
      { labels: labels, datasets: datasets }
    end
  end
end
