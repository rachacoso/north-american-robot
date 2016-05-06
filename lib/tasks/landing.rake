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

