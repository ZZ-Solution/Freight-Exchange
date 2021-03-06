class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :role
  has_many :trucks
  has_many :loads
  has_many :subscriptions
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  validates :first_name,:presence => true
  validates :last_name,:presence => true
  validates :mobile_number,   :presence => {:message => 'Mobile number with 10 digit!'},
                     :numericality => true,
                     :length => { :minimum => 10, :maximum => 11}
  validates :address_pin_code,   :presence => {:message => 'Pin number with 6 digit!'},
	:numericality => true,
	:length => {:maximum => 6} 
  validates :address_line1,:presence => true
  validates :address_line2,:presence => true
  validates :address_pin_code,:presence => true
  validates :address_country,:presence => true
  validates :address_state,:presence => true
  validates :address_city,:presence => true
  validates :company_type,:presence => true
  validates :company_pan_no,:presence => true
  validates :role_id,:presence => true
  has_attached_file :aadhaar_no_image, :default_url => ":style/rails1.jpg", validate_media_type: false
  validates_attachment_content_type :aadhaar_no_image, content_type: /\Aimage\/.*\z/
  before_create do
    self.subscription_date = Time.now
    self.confirmed_at = Time.now 
  end
  after_create :create_razor_customer

  def create_razor_customer
    if self.email.present? and self.mobile_number.present?
      customer = Razorpay::Customer.create email: self.email, contact: self.mobile_number
      self.update_attribute(:customer_id, customer.id) if self.present?
    end
  end

  # Validate content type
  # validates_attachment_content_type :aadhaar_no_image, content_type: /\Aimage\/.*\z/
  # validates :other_detail_aadhaar_no, :presence => {:message => 'Aadhaar card number should be 12 digit!'}, :numericality => true,
  # :length => {:maximum => 12, :minimum=> 12}
  validates :email, :password, presence: true
  def full_name
    "#{first_name} #{last_name}"
  end
end