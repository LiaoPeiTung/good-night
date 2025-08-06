class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  # The Follow records where this user is the follower
  has_many :follows, foreign_key: :follower_id
  has_many :followees, through: :follows

  # The Follow records where this user is being followed
  has_many :reverse_follows, class_name: 'Follow', foreign_key: :followee_id
  has_many :followers, through: :reverse_follows, source: :follower
end
