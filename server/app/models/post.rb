class Post < ApplicationRecord
  belongs_to :user
  scope :user_firebase_uid_is, -> uid {
    joins(:user).where("users.firebase_uid = ?", uid)
  }
end
