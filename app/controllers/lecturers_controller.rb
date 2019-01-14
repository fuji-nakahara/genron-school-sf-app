class LecturersController < ApplicationController
  def index
    name_to_lecturers      = Lecturer.includes(:subject).exclude_main.order('subjects.term_id desc', 'subjects.number desc').group_by(&:name)
    @novelist_to_lecturers = name_to_lecturers.reject { |_, lecturers| lecturers.any? { |lecturer| lecturer.note.present? } }
    @editor_to_lecturers   = name_to_lecturers.select { |_, lecturers| lecturers.any? { |lecturer| lecturer.note.present? } }
  end
end
