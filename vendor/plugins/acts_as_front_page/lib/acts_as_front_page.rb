#module ActiveRecord #:nodoc:
#	module Acts #:nodoc:
#		module FrontPage
#			CALLBACKS = [:set_any_two]
#			def self.included(base) # :nodoc:
#				base.extend ClassMethods
#			end
#
#			module ClassMethods
#				def acts_as_front_page(options = {})
#					# don't allow multiple calls
#					return if self.included_modules.include?(ActiveRecord::Acts::FrontPage::InstanceMethods)
#					#show_on_front_page.each do |s|
#					
#						#attr_accessor :show_on_front_page
#						def self.any_two
#							  all_marked_show_on_front_page
#                self.all(:conditions => [:ids => s], :limit => 2)
#						end
#					  options[:show] = any_two  
#						def self.all_marked_show_on_front_page
#								self.all(:conditions => [:ids => s])							
#						end
#						#
#						if options[:show]
#							validate :set_any_two	
#						end
#							
#						def set_any_two
#							collect = all_marked_show_on_front_page
#							if collect.size > 2
#								errors.add("Cant Select More Than Two For Front Page")
#								#collect[0].update_attribute(:show_on_front_page, false)
#							end
#						end
#					#end
#				end
#			 end	
#			 module InstanceMethods
#			 end						
#		end
#	end
#end
#ActiveRecord::Base.send :include, ActiveRecord::Acts::FrontPage