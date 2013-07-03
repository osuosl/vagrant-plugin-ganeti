require 'rubygems'
require 'uri'
require 'net/http'
require 'net/https'
require 'base64'
require 'json'
require 'log4r'

module VagrantPlugins
  module GANETI
    module Action
      # This action connects to Ganeti, verifies credentials start the instance.
      class ConnectGANETI
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_ganeti::action::connect_ganeti")
        end

        def call(env)
            config     = env[:machine].provider_config.get_config()

            @logger.info("Connecting to GANETI...")
            #Call  ganeti_client ruby wrapper
	    client = GanetiClient.new(config.host,config.username,config.password)
	    #client = GanetiClient.new("https://10.1.0.135:5080" ,"gsoc","v0fdYnVs")

	    info = {
	    '__version__'    => 1    , 
	    'os_type' => config.os_name,              
	    'disk_template' => config.disk_template,
	    'disks' => config.disks,
	    'instance_name' => config.instance_name,
	    'mode' => config.mode,        
	    'nics'   => config.nics,
	    'pnode' => config.pnode
	     }

            # Launch!
            env[:ui].info(I18n.t("vagrant_ganeti.launching_instance"))
            env[:ui].info(" -- Username: #{config.username}")
            env[:ui].info(" -- OS NAME: #{config.os_name}")
            env[:ui].info(" -- Instance NAME: #{config.instance_name}")
            env[:ui].info(" -- Host: #{config.host}")
            env[:ui].info(" -- Primary Noode #{config.pnode}") 
            env[:ui].info(" -- Disk Template: #{config.disk_template}")
            env[:ui].info(" -- Disks #{config.disks}") 
            env[:ui].info(" -- Network Configurations: #{config.nics}") 
            env[:ui].info(" -- Version : #{config.version }") if config.version 


            createjob = client.instance_create(info)
	    puts createjob
	    env[:ui].info( "This might take few minutes.....")
	    while true
		if  client.is_job_ready(createjob) == "error"
			env[:ui].info("Error Creating instance")
			break
		elsif client.is_job_ready(createjob) == "running"
			sleep(15)
		elsif client.is_job_ready(createjob) == "success"
	    		env[:ui].info( "VM sucessfully Created.Booting up the VM ")
            		createjob = client.start_instance(info)
			env[:machine].id = info['nics'][0]['ip']
                        puts env[:machine].id
			break
		end
            end
	    @app.call(env)
        end
      end
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


		def is_job_ready(jobno)
		    url = get_url("jobs/#{jobno}")
		    puts url
		    response_body = send_request("GET", url)
		    
		    return response_body["status"]
		end

		def start_instance(info)
		    url = get_url("instances/#{info['instance_name']}/startup")
		    puts url
		    response_body = send_request("PUT", url)
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
		   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		   headers['User-Agent'] = 'Ruby Ganeti RAPI Client'
		   headers['Content-Type'] = 'application/json'
		   headers['Authorization']= authenticate(self.username, self.password)
		  
		   begin
		       response = http.send_request(method, url, body, headers)
		      # response = http.send_request("GET",url)
		       puts body
		       puts response
		       puts response.body
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
      end #Action
  end #ganeti
end #VagrantPlugin
