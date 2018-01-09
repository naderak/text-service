class User < ApplicationRecord

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable
  devise :cas_authenticatable,  :rememberable, :registerable

  def to_s
    fullname
  end

  def cas_extra_attributes=(extra_attributes)
    unless self.persisted?
      self.fullname = "#{extra_attributes['gn']} #{extra_attributes['sn']}"
    end
  end

end
