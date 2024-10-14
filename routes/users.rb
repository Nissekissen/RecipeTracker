
class MyApp < Sinatra::Application

  get '/profile/:id' do | id |
    @profile = User.find(db, id)
    if !@profile
      halt 404, 'Profile not found'
    end

    if !@user.nil? && @profile.id == @user.id
      @is_owner = true
    end

    haml :'profile/show'
  end
end