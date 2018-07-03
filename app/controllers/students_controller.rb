class StudentsController < ApplicationController
  def index
    @year_to_students = Term.year_to_students
  end

  def show(id)
    @student = Student.includes(:terms, synopses: :subject, works: :subject).find(id)
  end
end
