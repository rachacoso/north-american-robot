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