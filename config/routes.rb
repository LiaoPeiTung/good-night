Rails.application.routes.draw do
  post '/clock_in', to: 'sleep_records#clock_in'
  patch '/clock_out', to: 'sleep_records#clock_out'
  get '/users/:user_id/friends_sleep_records', to: 'sleep_records#friends_sleep_records'

  post '/users/:user_id/follow/:followee_id', to: 'follows#create'
  delete '/users/:user_id/unfollow/:followee_id', to: 'follows#destroy'
end
