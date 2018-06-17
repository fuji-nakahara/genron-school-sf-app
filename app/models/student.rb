class Student < ApplicationRecord
  has_and_belongs_to_many :terms

  def add_term(year)
    return true if terms.pluck(:id).include?(year)
    terms << Term.find(year)
    save
  end
end
