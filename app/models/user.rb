class User < ActiveRecord::Base
  attr_accessor :login
  has_and_belongs_to_many :games
  has_many :pieces, :through => :game

  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]

  def self.find_for_database_authentication(warden_conditions)
   conditions = warden_conditions.dup
   if login = conditions.delete(:login)
     where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
   else
     where(conditions.to_hash).first
   end
  end

  validates :username,
   :presence => true,
   :uniqueness => {
     :case_sensitive => false
    }

  # Only allow letter, number, underscore and punctuation.
  validate :validate_username

  def validate_username
   if User.where(email: username).exists?
     errors.add(:username, :invalid)
   end
  end

  def enrolled_in?(course)
   return enrolled_courses.include?(course)
  end
end
