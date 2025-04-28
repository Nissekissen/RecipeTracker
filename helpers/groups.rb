module Groups

  # Sets the admin status for a user in a group.
  #
  # @param user [User] The user to set the admin status for.
  # @param group [Group] The group to set the admin status in.
  # @param is_admin [Boolean] True if the user should be an admin, false otherwise.
  def set_admin user, group, is_admin
    MyApp::DB.run("UPDATE groups_users SET is_admin = ? WHERE user_id = ? AND group_id = ?", [is_admin, user.id, group.id])
  end

  # Checks if a user is an admin in a group.
  #
  # @param user [User] The user to check.
  # @param group [Group] The group to check in.
  # @return [Boolean] True if the user is an admin, false otherwise.
  def is_admin user, group
    MyApp::DB.fetch("SELECT is_admin FROM groups_users WHERE user_id = ? AND group_id = ?", user.id, group.id).first[:is_admin]
  end
end