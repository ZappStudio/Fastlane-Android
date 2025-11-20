module Fastlane
  module Actions
    module SharedValues
      ZAPPLI_CUSTOM_VALUE = :ZAPPLI_CUSTOM_VALUE
      ZAPPLI_BASEPATH = "https://api.zappli.app"
      ZAPPLI_ENDPOINT_INTEGRATION = "#{ZAPPLI_BASEPATH}/integration/releases"
      ZAPPLI_LOGO_URL = "#{ZAPPLI_BASEPATH}/api/public/{id}"
      DEFAULT_LOGO = "https://media.licdn.com/dms/image/v2/D4D0BAQEUKgr53vN9sg/company-logo_200_200/company-logo_200_200/0/1719812855696/zapp_studio_logo?e=2147483647&v=beta&t=zazdJQYym7vp7-HaU0tqTccHUy-G8GM3RsfYdlWAF9g"
    end

    class ZappliAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        api_token = params[:api_token]
        app = params[:app]
        groups = params[:groups]
        path = params[:path]

        UI.message("Auth by api token : #{api_token}")
        UI.message("Deploying to this app: #{app}")
        UI.message("Deploying to the next groups: #{groups}")
        UI.message("Deploying this artifact: #{path}")
        UI.message("Proceding to send Zappli 🚀")

        update_release(
          api_key:api_token,
          endpoint: SharedValues::ZAPPLI_ENDPOINT_INTEGRATION,
          app:app,
          path: path,
          groups: groups
        )
        # sh "shellcommand ./path"
        # Actions.lane_context[SharedValues::ZAPPLI_CUSTOM_VALUE] = "my_val"
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'A short description with <= 80 characters of what this action does'
      end

      def self.fetch_logo(id)
        url = SharedValues::ZAPPLI_LOGO_URL.gsub('{id}', id)
        uri = URI(url)
    
        begin
          response = Net::HTTP.get_response(uri)
          if response.is_a?(Net::HTTPSuccess)
            json_response = JSON.parse(response.body) rescue {}
            logo_url = json_response.dig("data", "logo") ||  SharedValues::DEFAULT_LOGO
          else
            logo_url = SharedValues::DEFAULT_LOGO
          end
        rescue => e
          puts "Error al obtener el logo: #{e.message}"
          logo_url =  SharedValues::DEFAULT_LOGO
        end
    
        return logo_url
      end



      # This method updates a release by sending a file to a specified endpoint.
      # It constructs a multipart payload with the file, app name, and groups.
      # The payload is then sent to the server using the `upload_to_server` method.
      #
      # Parameters:
      #   params (Hash): A hash containing the following keys:
      #     * :endpoint (String): The endpoint URL to send the request to.
      #     * :path (String): The file path to include in the payload.
      #     * :app (String): The app name to include in the payload.
      #     * :groups (String): The groups to include in the payload, separated by commas.
      def self.update_release(params)
        endpoint = params[:endpoint]
        api_key = params[:api_key]
        # Create a multipart payload with the file
        payload = {
          fileFormFieldName: "file",
          app: params[:app],
          groups: params[:groups].join(',')
        }

        # Upload the payload to the server
        response = other_action.upload_to_server(
            endPoint: endpoint,
            method: :post,
            multipartPayload: payload,
            file: params[:path],
            apk: "",
            headers: {
              "api-key" => "#{api_key}",
              "Content-Type" => "multipart/form-data"
            }
          )
        UI.message("Respuesta de Zappli:\n#{JSON.pretty_generate(response)}")
        
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        'You can use this action to do cool things...'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :api_token,
            env_name: 'FL_ZAPPLI_API_TOKEN',
            description: 'API Token for authentication with Zappli service',
            verify_block: proc do |value|
              unless value && !value.empty?
                UI.user_error!("No API token for ZappliAction given, pass using `api_token: 'token'`")
              end
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :app,
            env_name: 'FL_ZAPPLI_APP',
            description: 'Application identifier in Zappli',
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :groups,
            env_name: 'FL_ZAPPLI_GROUPS',
            description: 'Array of groups to deploy the application',
            type: Array,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :path,
            env_name: 'FL_ZAPPLI_PATH',
            description: 'Path to the artifact file to be uploaded',
            type: String,
            verify_block: proc do |value|
              UI.user_error!("File not found at path '#{value}'") unless File.exist?(value)
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :development,
            env_name: 'FL_ZAPPLI_DEVELOPMENT',
            description: 'Use development environment instead of production',
            is_string: false,
            default_value: false
          )
        ]
      
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['ZAPPLI_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ['@Zappli']
      end
      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #
        [:ios, :android].include?(platform)
      end
    end
  end
end