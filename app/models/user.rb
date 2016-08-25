class User < ActiveRecord::Base
  attr_accessor :remember_token

  before_save do
    self.email=email.downcase
  end

  validates(:name,{:presence=>true,:length=>{:maximum=>50}})

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:email,{presence: true,length: {maximum: 250},format: {with: VALID_EMAIL_REGEX},uniqueness: {case_sensitive: false}})

  has_secure_password

  validates :password, presence: true, length: { minimum: 6 }

  #string to digest

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
    #randomly generating token
  end

  def remember
    self.remember_token=User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    #storing dogest of token in database
  end
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
    #varifying if remember_digest is enc of remember_token
    #if yes true
  end

end
