require 'sinatra/namespace'
require 'json'

class MyApp < Sinatra::Application

  # @!group Routes

  # Displays a form for creating a new invite to a group.
  #
  # @route GET /invites/new
  # @param group_id [String] The ID of the group to invite users to.
  # @return [Haml] Rendered form for creating a new invite.
  get '/invites/new' do

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to create an invite'
    end

    group_id = params[:group_id]

    if group_id.nil?
      halt 404, 'Group not found'
    end

    @group = Group.where(id: group_id).first

    if @group.nil? || !@group.users.include?(@user)
      halt 404, 'Group not found'
    end

    haml :'invites/new'
  end

  # Creates a new invite to a group.
  #
  # @route POST /invites
  # @param group_id [String] The ID of the group to invite users to.
  # @param uses [Integer] The number of times the invite can be used.
  # @return [Haml] Rendered form for creating a new invite.
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
    @group = Group.where(id: params[:group_id]).first
    
    if @group.nil? || !@group.users.include?(@user)
      halt 404, 'Group not found'
    end

    # create invite
    @invite = Invite.create(group_id: @group.id, token: SecureRandom.hex(4), uses_left: params[:uses], expires_at: Time.now + 7 * 24 * 60 * 60, owner_id: @user.id)

    haml :'invites/new'
  end

  # Joins a group through an invite.
  #
  # @route GET /invite/:token
  # @param token [String] The invite token.
  # @return [Haml] Rendered page for accepting the invite.
  get '/invite/:token' do | token |
    # get invite

    # make sure user is logged in
    if @user.nil?
      halt 401, 'You must be logged in to accept an invite'
    end

    # get invite
    @invite = Invite.where(token: token).first

    if @invite.nil?
      halt 404, 'Invite not found'
    end

    @group = @invite.group
    @owner = User.where(id: @invite.owner_id).first


    validate_invite(@user, @invite)

    haml :'invites/show'
  end

  # Accepts an invite.
  #
  # @route GET /invite/:token/accept
  # @param token [String] The invite token.
  # @return [Haml] Redirects to the group page.
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

  namespace '/invite' do
    error 403 do
      # will be called when a 403 status is returned

      @error = true

      haml :'invites/show'

    end

    error 404 do

      @error = true

      haml :'invites/show'

    end 
  end

  namespace '/api/v1' do

    # Creates an invite. Requires group_id and uses.
    #
    # @route POST /api/v1/invites
    # @param group_id [String] The ID of the group to invite users to.
    # @param uses [Integer] The number of times the invite can be used.
    # @return [JSON] JSON representation of the created invite.
    post '/invites' do
      # create invite

      # make sure user is logged in
      if @user.nil?
        halt 401, 'You must be logged in to create an invite'
      end

      payload = JSON.parse(request.body.read)

      group_id = payload['group_id']
      uses = payload['uses']

      if group_id.nil? || uses.nil?
        halt 400, 'Group ID and uses are required'
      end

      # get group
      @group = Group.where(id: group_id).first

      if @group.nil? || !@group.users.include?(@user)
        halt 404, 'Group not found'
      end

      # create invite
      @invite = Invite.create(group_id: @group.id, token: SecureRandom.hex(4), uses_left: uses, expires_at: Time.now + 7 * 24 * 60 * 60, owner_id: @user.id)

      JSON.generate({ id: @invite.id, token: @invite.token, uses_left: @invite.uses_left, expires_at: @invite.expires_at, owner_id: @invite.owner_id, group_id: @invite.group_id })
    end

  end
  # @!endgroup
end