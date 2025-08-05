class User < ApplicationRecord
  has_many :sleep_records

  has_many :follows, foreign_key: :follower_id
  has_many :followees, through: :follows

  has_many :reverse_follows, class_name: 'Follow', foreign_key: :followee_id
  has_many :followers, through: :reverse_follows, source: :follower
end
