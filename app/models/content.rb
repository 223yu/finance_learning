class Content < ApplicationRecord
  with_options presence: true do
    validates :title
    validates :body
  end

  validates :user_limited, inclusion: { in: [true, false] }

  has_many :learnings, dependent: :destroy
end
