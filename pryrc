def model(table)
  Class.new(ActiveRecord::Base).tap {|m| m.table_name = table}
end

def me
  @me ||= User.find_by_username 'mgee'
end
