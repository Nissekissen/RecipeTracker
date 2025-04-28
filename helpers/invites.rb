module Invites
  # Validates an invite.
  #
  # @param user [User] The user to validate the invite for.
  # @param invite [Invite] The invite to validate.
  # @raise [Sinatra::Halt] If the invite is not found, the user is already in the group, the invite has expired, or the invite has no uses left.
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
      halt 403, 'Invite has expired'
    end

    # make sure invite has uses left
    if invite.uses_left <= 0
      halt 403, 'Invite has no uses left'
    end
  end
end