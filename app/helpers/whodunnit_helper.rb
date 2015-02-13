module WhodunnitHelper
  def link_to_whodunnit(whodunnit)
    return nil unless whodunnit
    if whodunnit.include?('-ApiUser')
      user = ApiUser.find(whodunnit)
      return link_to(user.username, admin_epp_user_path(user))
    end
    user = AdminUser.find(whodunnit)
    return link_to(user.username, admin_user_path(user))
  rescue ActiveRecord::RecordNotFound
    return nil
  end

  def whodunnit_with_protocol(whodunnit)
    return nil unless whodunnit
    if whodunnit.include?('-ApiUser')
      user = ApiUser.find(whodunnit)
      return "#{user.username} (EPP)"
    end
    user = AdminUser.find(whodunnit)
    return user.username
  rescue ActiveRecord::RecordNotFound
    return nil
  end
end
