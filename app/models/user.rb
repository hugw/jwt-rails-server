class User < ActiveRecord::Base
  STATUS = {
    active: 'active',
    inactive: 'inactive'
  }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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
end
