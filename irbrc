def me
  @me ||= User.find_by_username 'mgee'
end
