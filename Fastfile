default_platform(:android)
config_json = read_json(
  json_path: "./buildsystem/config.json"
)

platform :android do

  desc "Building generic by json configuration"
    lane :generic do |values|
      flavor_parameter  = values[:flavor]
      flavors = config_json[:flavors]

       if flavor_parameter === "all"
          UI.message "Compiling all flavors"
          flavors.each do |child|
              buildWithJson(child)
          end
       else
           flavors.each do |child|
               if child[:id] === flavor_parameter
                 UI.message "Found flavor to build"
                 buildWithJson(child)
               end
              end
       end

    end

  desc "Build flavor with json config"
  lane :buildWithJson do |options|
    flavor_name = options[:flavor_name]
    sign_conf = options[:sign_conf]
    appcenter_api_key = options[:appcenter_api_key]
    appcenter_user = options[:appcenter_user]
    appcenter_app_name = options[:appcenter_app_name]
    appcenter_group = options[:appcenter_group]
    appcenter_url_release = options[:appcenter_url_release]
    teams_web_hook = options[:teams_web_hook]
    module_name = options[:module_name]

    gradle(task: "#{module_name}:assemble",flavor: flavor_name.then { |s| s[0].upcase + s[1..-1] },build_type: sign_conf.capitalize())
    
    appcenter_upload(
         api_token: appcenter_api_key,
         owner_name: appcenter_user,
         owner_type: "user", # Default is user - set to organization for appcenter organizations
         destinations: appcenter_group,
         app_name: appcenter_app_name,
         file: "#{lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]}" ,
         app_os: "Android",
         app_display_name: appcenter_app_name,
         notify_testers: true
      )

      if teams_web_hook.nil? == false
         teamsNotification(
           teams_web_hook:teams_web_hook,
           teams_message:"Nueva version distribuida en appcenter #{appcenter_app_name} #{appcenter_group} disponible",
           activity_title: "Link [Aquí](#{appcenter_url_release})"
         )
      end
  end


  desc "Teams message to teams_web_hook"
  lane :teamsNotification do |options|
    teams_web_hook = options[:teams_web_hook]
    teams_message = options[:teams_message]
    activity_title = options[:activity_title]
    teams_bot(
        teams_url: teams_web_hook,
        title: options[:teams_message],
        text: "",
        activity_title: options[:activity_title],
        activity_image: "https://graffica.info/wp-content/uploads/2017/07/logo-Android-Andy-1200x900.jpg"
    )
  end

   desc "Upload aab to google play"
    lane :uploadGooglePlay do |options|
       json_key_file = options[:json_key_file]
       package_name = options[:package_name]
       teams_web_hook = options[:teams_web_hook]
       flavor_name = options[:flavor_name]
       sign_conf = options[:sign_conf]

       validate_play_store_json_key(
         json_key: json_key_file
       )

       gradle(task: "bundle", flavor: flavor_name.capitalize(), build_type: sign_conf.capitalize())
       upload_to_play_store(
        track: 'alpha',
        package_name:package_name,
        json_key: json_key_file,
        skip_upload_apk:true
       )

       teamsNotification(
              teams_web_hook:teams_web_hook,
              teams_message:"Nueva version distribuida a google play alpha disponible",
              activity_title: "Link [Aquí](https://play.google.com/console/about/)"
       )
    end


   desc "Generate specific flavor to build, by security can't make all flavors, because some of them are pointing to develop"
    lane :buildAab do |values|
      flavor_parameter  = values[:flavor]
      flavors = config_json[:flavors]
      UI.message "TESTTT"
      flavors.each do |child|
          if child[:id] === flavor_parameter
            UI.message "Found it specific flavor flavor to build"
            uploadGooglePlay(child)
          end
      end
    end
end