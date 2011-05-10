module Fog
  module Ninefold
    class Compute < Fog::Service

      API_URL = "http://api.ninefold.com/compute/v1.0/"

      requires :ninefold_compute_key, :ninefold_compute_secret
      #recognizes :brightbox_auth_url, :brightbox_api_url
      recognizes :provider # remove post deprecation

      model_path 'fog/compute/models/ninefold'
      #collection  :servers
      #model       :server
      #collection  :flavors
      #model       :flavor
      #collection  :images
      #model       :image
      #collection  :load_balancers
      #model       :load_balancer
      #collection  :zones
      #model       :zone
      #collection  :cloud_ips
      #model       :cloud_ip
      #collection  :users
      #model       :user

      request_path 'fog/compute/requests/ninefold'
      # General list-only stuff
      request :list_accounts
      request :list_events
      request :list_service_offerings
      request :list_disk_offerings
      request :list_capabilities
      request :list_hypervisors
      request :list_zones
      request :list_network_offerings
      request :list_resource_limits
      # Templates
      request :list_templates
      # Virtual Machines
      request :deploy_virtual_machine
      request :destroy_virtual_machine
      request :list_virtual_machines
      request :reboot_virtual_machine
      request :stop_virtual_machine
      request :start_virtual_machine
      request :change_service_for_virtual_machine
      request :reset_password_for_virtual_machine
      request :update_virtual_machine
      # Jobs
      request :list_async_jobs
      request :query_async_job_result
      # Networks
      request :list_networks

      class Mock

        def initialize(options)
          unless options.delete(:provider)
            location = caller.first
            warning = "[yellow][WARN] Fog::Ninefold::Compute.new is deprecated, use Fog::Compute.new(:provider => 'Ninefold') instead[/]"
            warning << " [light_black](" << location << ")[/] "
            Formatador.display_line(warning)
          end

          @brightbox_client_id = options[:brightbox_client_id] || Fog.credentials[:brightbox_client_id]
          @brightbox_secret = options[:brightbox_secret] || Fog.credentials[:brightbox_secret]
        end

        def request(options)
          raise "Not implemented"
        end
      end

      class Real

        def initialize(options)
          unless options.delete(:provider)
            location = caller.first
            warning = "[yellow][WARN] Fog::Ninefold::Compute.new is deprecated, use Fog::Compute.new(:provider => 'Ninefold') instead[/]"
            warning << " [light_black](" << location << ")[/] "
            Formatador.display_line(warning)
          end

          require "json"

          @api_url = options[:ninefold_api_url] || Fog.credentials[:ninefold_api_url] || API_URL
          @ninefold_compute_key = options[:ninefold_compute_key] || Fog.credentials[:ninefold_compute_key]
          @ninefold_compute_secret = options[:ninefold_compute_secret] || Fog.credentials[:ninefold_compute_secret]
          @connection = Fog::Connection.new(@api_url)
        end

        def request(command, params, options)
          params['response'] = "json"
          req = "apiKey=#{@ninefold_compute_key}&command=#{command}&"
          # convert params to strings for sort
          req += URI.escape(params.sort_by{|k,v| k.to_s }.collect{|e| "#{e[0].to_s}=#{e[1].to_s}"}.join('&'))
          encoded_signature = url_escape(encode_signature(req))

          options = {
            :expects => 200,
            :method => 'GET',
            :query => "#{req}&signature=#{encoded_signature}"
          }.merge(options)

          begin
            response = @connection.request(options)
          end
          unless response.body.empty?
            # Because the response is some weird xml-json thing, we need to try and mung
            # the values out with a prefix, and if there is an empty data entry return an
            # empty version of the expected type (if provided)
            response = JSON.parse(response.body)
            if options.has_key? :response_prefix
              keys = options[:response_prefix].split('/')
              keys.each do |k|
                if response[k]
                  response = response[k]
                elsif options[:response_type]
                  response = options[:response_type].new
                  break
                else
                end
              end
              response
            else
              response
            end
          end
        end

      private
        def url_escape(string)
          string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
            '%' + $1.unpack('H2' * $1.size).join('%').upcase
          end.tr(' ', '+')
        end

        def encode_signature(data)
          Base64.encode64(OpenSSL::HMAC.digest('sha1', @ninefold_compute_secret, URI.encode(data.downcase).gsub('+', '%20'))).chomp
        end
      end
    end
  end
end
