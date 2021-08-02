class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  with_options presence: true do
    validates :name
    validates :year
  end
  
  has_many :learnings, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :journals, dependent: :destroy
  
end
