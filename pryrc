def model(table)
  Class.new(ActiveRecord::Base).tap {|m| m.table_name = table}
end
