Rails.application.routes.draw do
  post '/clock_in', to: 'sleep_records#clock_in'
  patch '/clock_out', to: 'sleep_records#clock_out'

end
