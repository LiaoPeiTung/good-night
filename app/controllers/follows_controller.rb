class FollowsController < ApplicationController
  # POST /users/:user_id/follow/:followee_id
  def create
    follower = User.find(params[:user_id])
    followee = User.find(params[:followee_id])

    if follower == followee
      render json: { error: "You cannot follow yourself." }, status: :bad_request
      return
    end

    if Follow.exists?(follower: follower, followee: followee)
      render json: { error: "Already following this user" }, status: :bad_request
      return
    end

    follow = Follow.new(follower: follower, followee: followee)

    if follow.save
      render json: { message: "Followed successfully." }
    else
      render json: { error: follow.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/unfollow/:followee_id
  def destroy
    follower = User.find(params[:user_id])
    followee = User.find(params[:followee_id])

    follow = Follow.find_by(follower: follower, followee: followee)

    if follow
      follow.destroy
      render json: { message: "Unfollowed successfully." }
    else
      render json: { error: "Follow relation not found." }, status: :not_found
    end
  end
end
