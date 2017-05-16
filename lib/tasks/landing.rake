task :set_brand_subscriber_account_numbers => :environment do
	brands = Brand.all
	brands.each do |b|
		b.set_subscriber_account_number
		b.save
		puts "#{b.company_name} #{b.active} #{b.subscriber_account_number}"
	end
end

task :set_auth_tokens => :environment do
	users = User.where(:auth_token => nil)
	puts users.count
	users.each do |u|
		begin
			u.auth_token = SecureRandom.urlsafe_base64
		end while User.where(:auth_token => u.auth_token).exists?
		puts "User: #{u.email} token: #{u.auth_token}"
	end
end

task :set_distributor_ratings => :environment do
	distros_rating = Distributor.where(:rating => nil)
	puts distros_rating.count
	distros_rating.each do |d|
		d.rating = 0
		d.save
	end
	distros_completeness = Distributor.all
	puts distros_completeness.count
	distros_completeness.each do |d|
		d.update_completeness
		d.save
		puts d.completeness
	end	
end

task :set_brand_completeness => :environment do
	brand_completeness = Brand.all
	puts brand_completeness.count
	brand_completeness.each do |b|
		b.update_completeness
		b.save
		puts b.completeness
	end	
end

task :set_all_tags_upcase => :environment do
	tags = Tag.all
	tags.each do |t|
		t.name = t.name.upcase
		t.save
	end
end

task :set_user_company => :environment do
	users = User.where(company: nil, administrator: nil)
	users.each do |u|
		puts u.email
		brd = u.brand || u.retailer || u.distributor
		if brd
			u.company = brd
			puts "#{brd.company_name} set!"
			u.save!
			puts "#{brd.company_name} saved!"
		else
			u.destroy # destroy if orphaned and not an admin
		end
	end
end


#reset all armor ids used for testing only
task :reset_armor_ids => :environment do
	users = User.with_armor_user_id
	brands = Brand.where(:armor_account_id.ne => nil)
	retailers = Retailer.where(:armor_account_id.ne => nil)
	distributors = Distributor.where(:armor_account_id.ne => nil)
	users.each do |u|
		puts u.email
		u.armor_user_id = nil
		u.armor_email = nil
		u.save!
	end
	brands.each do |b|
		puts b.company_name
		b.armor_account_id = nil
		b.save!
	end
	retailers.each do |r|
		puts r.company_name
		r.armor_account_id = nil
		r.save!
	end
	distributors.each do |d|
		puts d.company_name
		d.armor_account_id = nil
		d.save!
	end
end

# GENERATE COMMENTS FOR ALL OLD ORDERS SO DON'T BREAK

task :prep_legacy_orders => :environment do
	orders = Order.all
	puts "Begin: Setting Pending Date Array from Pending Date for #{orders.count} Orders"
	updated_count = 0
	orders.each do |o|
		next if o.pending_date.blank? || !o.pending_date_array.blank?
		o.push(pending_date_array: o.pending_date)
		updated_count +=1
	end
	puts "Completed: Setting Pending Date Array from Pending Date. Updated #{updated_count} Orders"
	c_orders = Order.current
	puts "Setting initial comments for #{c_orders.count} Open Orders"
	c_orders.each do |o|
		next if o.comments.present?
		o.comments.build(text: nil, author: o.orderer.class.to_s.downcase, order_status: "open")
		o.save
	end
	s_orders = Order.submitted
	puts "Setting initial comments for #{s_orders.count} Submitted Orders"
	s_orders.each do |o|
		next if o.comments.present?
		o.comments.build(text: nil, author: o.orderer.class.to_s.downcase, order_status: "open")
		o.comments.build(text: nil, author: "brand", order_status: "submitted")
		o.save
	end
	p_orders = Order.pending
	puts "Setting initial comments for #{p_orders.count} Pending Orders"
	p_orders.each do |o|
		next if o.comments.present?
		o.comments.build(text: nil, author: o.orderer.class.to_s.downcase, order_status: "open")
		o.comments.build(text: nil, author: "brand", order_status: "submitted")
		o.save
	end
end

