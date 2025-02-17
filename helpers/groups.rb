

module Groups

  def set_admin user, group, is_admin
    MyApp::DB.run("UPDATE groups_users SET is_admin = ? WHERE user_id = ? AND group_id = ?", [is_admin, user.id, group.id])
  end

  def is_admin user, group
    MyApp::DB.fetch("SELECT is_admin FROM groups_users WHERE user_id = ? AND group_id = ?", user.id, group.id).first[:is_admin]
  end
end