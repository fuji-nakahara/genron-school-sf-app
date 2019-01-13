class ScoreChart
  attr_reader :term

  def initialize(term_id)
    @term = Term.includes(:subjects, :students).find(term_id)
  end

  def year
    term.id
  end

  def labels
    subjects.map(&:display_number)
  end

  def datasets
    number_to_score = subjects.map(&:number).map { |label| [label, 0] }.to_h
    term.students.map do |student|
      scores = number_to_score.merge(student.subject_number_to_score(year)).values
      accumulated_score = 0
      accumulated_scores = scores.map { |score| accumulated_score += score}
      puts ''
      {
        label: student.name,
        data:  accumulated_scores
      }
    end
  end

  private

  def subjects
    term.subjects.reject(&:no_synopsis?)
  end
end
