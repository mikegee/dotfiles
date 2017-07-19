IRB.conf[:PROMPT_MODE] = :SIMPLE

def me
  @me ||= User.find_by_username 'mgee'
end
