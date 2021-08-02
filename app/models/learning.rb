class Learning < ApplicationRecord

  with_options presence: true do
    validates :user_id
    validates :content_id
    validates :end_learning
  end

  belongs_to :user
  belongs_to :content

end
