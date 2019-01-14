class Lecturer < ApplicationRecord
  belongs_to :subject, touch: true

  scope :has_role, ->(role) { where('? = any (roles)', role) }
  scope :proposers, -> { has_role(ROLE_NAME_PROPOSER) }
  scope :exclude_main, -> { where.not(name: '大森望') }

  ROLE_NAME_PROPOSER = '課題提示'

  def name_with_note
    if note.present?
      "#{name}（#{note}）"
    else
      name
    end
  end
end
