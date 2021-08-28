class Learning < ApplicationRecord
  with_options presence: true do
    validates :user_id
    validates :content_id
  end

  validates_uniqueness_of :content_id, scope: :user_id

  belongs_to :user
  belongs_to :content
end
