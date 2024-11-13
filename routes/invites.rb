

class MyApp < Sinatra::Application

  get '/invites/new' do
    haml :'invites/new'
  end

  post '/invites' do
    # create invite

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to create an invite'
    end

    if params[:group_id].nil?
      halt 400, 'Group ID is required'
    end

    # get group
    group = Group.where(id: params[:group_id]).first
    
    if group.nil? || !group.users.include?(@user)
      halt 404, 'Group not found'
    end

    # create invite
    @invite = Invite.create(group_id: group.id, token: SecureRandom.hex(4), uses_left: params[:uses], expires_at: Time.now + 7 * 24 * 60 * 60)

    haml :'invites/created'
  end

  get '/invite/:token' do | token |
    # get invite

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to accept an invite'
    end

    # get invite
    @invite = Invite.where(token: token).first
    @group = @invite.group

    validate_invite(@user, @invite)

    haml :'invites/show'
  end

  get '/invite/:token/accept' do | token |
    # accept invite

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to accept an invite'
    end
    
    # get invite
    @invite = Invite.where(token: token).first

    validate_invite(@user, @invite)

    # add user to group
    @user.add_group(@invite.group)

    # decrement invite uses_left
    @invite.update(uses_left: @invite.uses_left - 1)

    redirect "/groups/#{@invite.group.id}"
  end

end