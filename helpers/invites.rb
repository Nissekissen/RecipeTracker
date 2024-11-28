

module Invites
  def validate_invite(user, invite)
    if invite.nil?
      halt 404, 'Invite not found'
    end

    # make sure user is not already in group
    if invite.group.users.include?(user)
      halt 403, 'You are already a member of this group'
    end

    # make sure invite is not expired
    if invite.expires_at < Time.now
      p "Created at: #{invite.created_at}"
      p "Expires at: #{invite.expires_at}"
      halt 403, 'Invite has expired'
    end

    # make sure invite has uses left
    if invite.uses_left <= 0
      halt 403, 'Invite has no uses left'
    end

    # if invite.user_id is set, make sure user is the invitee
    if !invite.user_id.nil? && invite.user_id != user.id
      halt 403, 'You are not the invitee'
    end
  end
end