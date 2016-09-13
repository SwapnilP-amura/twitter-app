class User < ActiveRecord::Base
  has_many :microposts,dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                foreign_key: "follower_id",
                                dependent:   :destroy

  has_many :following, through: :active_relationships, source: :followed
  attr_accessor :remember_token,:activation_token,:reset_token

  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower


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
    self.reset_token = User.new_token           #plain test

    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end


  #Posts of user himself and people to whome he is following.
  # def feed
  #   Micropost.where("user_id = ?", id)
  #   #currently we are showing only posts of current user
  # end

  def feed
    #Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)


    #effiecient
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end  
  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  # Returns a user's status feed.


  private
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
    #digest have databse column but we are in before create ,so db entry doesnt exist yet.
    #so storing in instance var.
  end

end
