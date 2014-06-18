def model(table)
  Class.new(ActiveRecord::Base).tap {|m| m.table_name = table}
end

def me
  @me ||= User.find_by_email("mgee@covermymeds.com") || User.where("username = ? OR username = ?", "mgee", "mgee_internal").first
end

def pbcopy(str)
  IO.popen("pbcopy", "w") { |pb| pb.write str }
end

def pbpaste
  IO.popen("pbpaste", "r") { |pb| pb.read }
end
