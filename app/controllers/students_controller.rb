class StudentsController < ApplicationController
  def index
    @year_to_students = Term.year_to_students
  end

  def show(id)
    @student = Student.includes(:terms, synopses: [:student, :subject], works: [:student, :subject]).find(id)
  end
end
