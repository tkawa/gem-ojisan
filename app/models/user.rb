class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable
  has_many :oauth_authentications, dependent: :destroy
  validates :name, presence: true, uniqueness: true

  include Omniauthable
end
