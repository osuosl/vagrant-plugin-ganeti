module VagrantPlugins
  module GANETI
    module Util
	class GanetiClient
		attr_accessor :cluster, :rapi_user, :rapi_pass, :version,:info
		
		def initialize(cluster, rapi_user, rapi_pass)
		    self.cluster = cluster
		    self.rapi_user = rapi_user
		    self.rapi_pass = rapi_pass
		    self.version = self.version_get
		end

		def set_config(info)
		    self.info = info
		end
	
		def instance_create( dry_run = 0)
		    url = get_url("instances")
		    body = info.to_json
		    response_body = send_request("POST", url, body)
		    return response_body
		end

		def instance_terminate(dry_run = 0)
		    url = get_url("instances/#{info['instance_name']}")
		    body = info.to_json
		    response_body = send_request("DELETE", url)
		    return response_body
		end


		def is_job_ready(jobno)
		    url = get_url("jobs/#{jobno}")
		    response_body = send_request("GET", url)
		    if response_body["status"] =="error"
            		if response_body["opresult"][0][1][1] == "already_exists"
				return "already_exists"
			else
				return "error"
			end
		    else
			response_body["status"]
		    end
		end

		def set_default_iallocator()
		    url = get_url("info")
		    response_body = send_request("GET", url)
		    return  response_body["default_iallocator"]
		end

		def start_instance()
		    url = get_url("instances/#{info['instance_name']}/startup")
		    response_body = send_request("PUT", url)
		    
		    return response_body
		end

		def version_get
		    url = get_url("version")
		    response_body = send_request("GET", url)
		    
		    return response_body
		end
	
		def authenticate(rapi_user, rapi_pass)
		    basic = Base64.encode64("#{rapi_user}:#{rapi_pass}").strip
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
		   uri = URI.parse(cluster)

		   http = Net::HTTP.new(uri.host, uri.port)
		   http.use_ssl = true
		   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		   headers['User-Agent'] = 'Ruby Ganeti RAPI Client'
		   headers['Content-Type'] = 'application/json'
		   headers['Authorization']= authenticate(self.rapi_user, self.rapi_pass)
		  
		   begin
		       response = http.send_request(method, url, body, headers)
		      # response = http.send_request("GET",url)
		   rescue => e
		        puts "Error sending request"
	#		puts "#{e.message}"
			       
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
		               puts "#{response.error!}"
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
  end
end
