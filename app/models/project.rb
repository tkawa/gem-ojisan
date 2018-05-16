class Project < ApplicationRecord
  has_many :project_check_logs, dependent: :destroy, inverse_of: :project

  validates :slug, presence: :true
end
