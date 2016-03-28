module UsersHelper

	def parse_errors(errors)
		if errors.any? # If there are errors, do something
			errstring = ""
			errors.each do |attribute, message|
				if message.include? "reCAPTCHA"
					errstring.concat("Please let us know you're not a robot!<br>")
				else
					errstring.concat("#{attribute} #{message}<br>")
				end
			end
		  return "<div class='errornotice error-on'>#{errstring}</div>".html_safe
		end
	end

end
