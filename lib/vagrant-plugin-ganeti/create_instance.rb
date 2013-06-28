require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'

module Ganeticlient
	class GanetiClient
		attr_accessor :host, :username, :password, :version
		
		def initialize(host, username, password)
		    self.host = host
		    self.username = username
		    self.password = password
		    self.version = self.version_get
		    puts self.version
		end

	
		def instance_create(info, dry_run = 0)
		    
		    
		    url = get_url("instances")
		    body = info.to_json
		    response_body = send_request("POST", url, body)
		
		    return response_body
		end

		def version_get
		    url = get_url("version")
		    response_body = send_request("GET", url)
		    
		    return response_body
		end
	
		def authenticate(username, password)
		    basic = Base64.encode64("#{username}:#{password}").strip
		    return "Basic #{basic}"
		end
	    
	
		def get_url(path, params = nil)
		    param_string = ""

		    if params
		        params.each do |key, value|
		            if value.kind_of?(Array)
		                value.each do |svalue|
		                    param_string += "#{key}=#{svalue}&"
		                end
		            else
		                param_string += "#{key}=#{value}&"
		            end
		        end
		    end

		     url =  (self.version)? "/#{self.version}/#{path}?#{param_string}" : "/#{path}?#{param_string}"
	  
		    return url.chop
		end

	
		def send_request(method, url, body = nil, headers = {}) 
		   uri = URI.parse(host)

		   http = Net::HTTP.new(uri.host, uri.port)
		   http.use_ssl = true
	           puts uri
		   puts url
	           puts body
		   headers['User-Agent'] = 'Ruby Ganeti RAPI Client'
		   headers['Content-Type'] = 'application/json'
		   headers['Authorization']= authenticate(self.username, self.password)

		   begin
		        response = http.send_request(method, url, body.to_json, headers)
		   rescue => e
		        puts "Error sending request"
		        puts e.message
			       
		    else
		        case response
		        when Net::HTTPSuccess
		            parse_response(response.body.strip)
		        else
		            response.instance_eval { class << self; attr_accessor :body_parsed; end }
		            begin 
		                response.body_parsed = parse_response(response.body) 
		            rescue
		                # raises  exception corresponding to http error Net::XXX
		                puts response.error! 
		            end
		        end
		    end
		end


		def parse_response(response_body)
		    # adding workaround becouse Google seems to operate on 'non-strict' JSON format
		    # http://code.google.com/p/ganeti/issues/detail?id=117
		    begin
		        response_body = JSON.parse(response_body)
		    rescue
		        response_body = JSON.parse('['+response_body+']').first
		    end

		    return response_body
		end
	end #Class GanetiClient
end
