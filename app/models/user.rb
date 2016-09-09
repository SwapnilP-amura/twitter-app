class User < ActiveRecord::Base
  attr_accessor :remember_token,:activation_token,:reset_token

  #because activate_token generation process is must for every creation of user.
  before_create :create_activation_digest


  before_save do
    self.email=email.downcase
  end
  #downcase email before saving.


  validates(:name,{:presence=>true,:length=>{:maximum=>50}})

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates(:email,{presence: true,length: {maximum: 250},format: {with: VALID_EMAIL_REGEX},uniqueness: {case_sensitive: false}})

  has_secure_password

  validates :password, presence: true, length: { minimum: 6 },allow_nil: true

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

  def activate
   update_attribute(:activated,    true)
   update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
   UserMailer.account_activation(self).deliver_now
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    #this digest is fetched from database row.
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
    #updates remember digest => nil
  end


  #reset digest is called only when user click forget password.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end


  private
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
    #digest have databse column but we are in before create ,so db entry doesnt exist yet.
    #so storing in instance var.
  end

end
