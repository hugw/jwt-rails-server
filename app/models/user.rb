class User < ActiveRecord::Base
  STATUS = {
    active: 'active',
    inactive: 'inactive'
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  cattr_accessor :callback_url

  validates :name, presence: true, length: { minimum: 5 }
  validates :status, inclusion: { in: STATUS.values }

  def active_for_authentication?
    super && self.status?
  end

  def status?(code = :active)
    self.status == STATUS[code]
  end

  def status!(code = :active)
    self.status = STATUS[code]
  end

  def token(raw = nil, ping = 10.minutes.from_now.to_i)
    # Define what to store
    # on the token generated
    user = { id: self.id, ping: ping }
    token = AuthToken.encode({ user: user })
    raw.nil? ? { token: token } : token
  end
end
