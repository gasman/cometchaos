unless ActiveRecord::Base.instance_methods.map(&:to_s).include?('write_attribute_with_dirty')
	ActiveRecord::Base.class_eval { include ActiveRecord::Dirty }
end
