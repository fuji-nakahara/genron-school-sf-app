class StudentsController < ApplicationController
  def index
    @year_to_students = Term.includes(:students).order(id: :desc).map { |term| [term.id, term.students] }.to_h
  end

  def show(id)
    @student = Student.includes(:terms, synopses: :subject, works: :subject).find(id)
  end
end
