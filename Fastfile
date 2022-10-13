default_platform(:android)
config_json = read_json(
  json_path: "./buildsystem/config.json"
)

platform :android do

  desc "Building generic by json configuration"
    lane :generic do |values|
      flavor_parameter  = values[:id]
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

      gradle(task: "#{module_name}:assemble",flavor: flavor_name.then { |s| s[0].upcase + s[1..-1] },build_type: sign_conf.capitalize())

      gradle_path = "#{lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]}"

      distributeApp(options: options, gradle_path: gradle_path)
    end

  desc "Distribute app"
    lane :distributeApp do |values|
      options = values[:options]
      appcenter_api_key = options[:appcenter_api_key]
      appcenter_user = options[:appcenter_user]
      appcenter_app_name = options[:appcenter_app_name]
      appcenter_group = options[:appcenter_group]
      appcenter_url_release = options[:appcenter_url_release]
      teams_web_hook = options[:teams_web_hook]
      module_name = options[:module_name]
      upload_server = options[:upload_server]
      gradle_path = values[:gradle_path]

      appcenter_upload(
        api_token: appcenter_api_key,
        owner_name: appcenter_user,
        owner_type: "user", # Default is user - set to organization for appcenter organizations
        destinations: appcenter_group,
        app_name: appcenter_app_name,
        file: gradle_path,
        app_os: "Android",
        app_display_name: appcenter_app_name,
        notify_testers: true
      )

      if upload_server.nil? == false
        upload_to_server(
          endPoint: upload_server[:endpoint],
          method: :post,
          multipartPayload: {
            :fileFormFieldName => "#{upload_server[:param]}"
          },
          headers: {
            :"api_key" => "#{upload_server[:api_key]}"
          },
        )
      end


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

       validate_play_store_json_key(
         json_key: json_key_file
       )

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
      flavor_parameter  = values[:id]
      flavors = config_json[:flavors]
      UI.message "TESTTT"
      flavors.each do |child|
          if child[:id] === flavor_parameter
            UI.message "Found it specific flavor flavor to build"
            flavor_name = child[:flavor_name]
            sign_conf = child[:sign_conf]
            gradle(task: "bundle", flavor: flavor_name.capitalize(), build_type: sign_conf.capitalize())
            gradle_path = "#{lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]}"
            distributeApp(options: child, gradle_path: gradle_path)
            uploadGooglePlay(child)
          end
      end
    end


    desc '
**Configuracion importLoco lane:**
La configuración usada para importar los archivos de Loco a Android debe estar en /buildsystem/localise.json, seguir este formato.

```json
              {
               "locales" : [ "es", "en", "fr" ],
               "directory" : "library/core/src/main/res",
               "format": ".xml",
               "platform" : "android",
               "key" : "ixjxISxkw_YD0MZIlPDK6g1Miils2JEK",
               "fallback" : "en"
               }
```
**Comando docker para ejecutar el script:**

```sh
    docker run --rm -v `pwd`:/project mingc/android-build-box bash -c \'cd /project; fastlane importLoco\'
```

También es recomendable crearse un Makefile para mas comodidad.
Contenido del Makefile:

```makefile
    import-loco:
    docker run --rm -v `pwd`:/project mingc/android-build-box bash -c \'cd /project; fastlane importLoco\'
```
Se puede indicar la configuración que se quiere utilizar, por ejemplo:
```sh
   docker run --rm -v `pwd`:/project mingc/android-build-box bash -c \'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mdm.json\'
```

De esta forma podemos tener varios modulos con diferentes configuraciones de localización. Importándolas todas desde un solo comando. Ejemplo:

```makefile
    import-loco: import-mycardio import-mdm
    import-mycardio:
      docker run --rm -v `pwd`:/project mingc/android-build-box bash -c \'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mycardio.json\'

    import-mdm:
      docker run --rm -v `pwd`:/project mingc/android-build-box bash -c \'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mdm.json\'
```
Esto es extensible infinitamente.
'
     lane :importLoco do |values|
       conf_file  = values[:conf_file]

       if conf_file == nil
         conf_file = './buildsystem/localise.json'
       end

       simple_loco(conf_file_path: conf_file)
     end
end

