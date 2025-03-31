fastlane_require 'semantic'
fastlane_require 'safe_yaml'

default_platform(:android)

config_json = read_json(
  json_path: "./buildsystem/config.json"
)

zappli_api_token = config_json[:zappli_api_key]

platform :android do
  desc "Building generic by json configuration"
  lane :generic do |values|
    flavor_parameter = values[:id]
    flavors = config_json[:flavors]

    if flavor_parameter == "all"
      UI.message "Compiling all flavors"
      flavors.each do |child|
        buildWithJson(child)
      end
    else
      flavors.each do |child|
        if child[:id] == flavor_parameter
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
    module_name = options[:module_name]

    gradle(
      task: "#{module_name}:assemble",
      flavor: flavor_name.capitalize(),
      build_type: sign_conf.capitalize()
    )

    gradle_path = "#{lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]}"

    distributeApp(options: options, gradle_path: gradle_path)
  end

  desc "Distribute app"
  lane :distributeApp do |values|
    options = values[:options]
    teams_web_hook = options[:teams_web_hook]
    module_name = options[:module_name]
    zappli_info = options[:zappli]
    gradle_path = values[:gradle_path]
    flavor_name = options[:flavor_name]

    if zappli_info.nil? == false
      begin
        app = zappli_info[:app]
        groups = zappli_info[:groups]
        zappli(
           api_token: zappli_api_token,
           app: app,
           path: lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
           groups: groups
         )
        if teams_web_hook.nil? == false
          UI.message("Proceeding to send teams info, founded webhook #{teams_web_hook} 🚀")
          teams_info(
            group: groups[0],
            teams_webhook: teams_web_hook,
            flavor_name: flavor_name
          )
        end
      rescue => ex
        UI.error("Failed to upload to server: #{ex}")
        raise ex
      end
    end
  end

  desc "Inform teams"
  lane :teams_info do |options| 
    puts "Sending information to Microsoft Teams"
    group = options[:group]
    teams_webhook = options[:teams_webhook]
    flavor_name = options[:flavor_name]
    retrieve_logo =  Fastlane::Actions::ZappliAction.fetch_logo(group)

    begin
      teams_bot(
        teams_url: teams_webhook,
        title: "New Release Available",
        text: "Variante #{flavor_name}",
        activity_title: "",
        activity_image: retrieve_logo, # This is correctly using the logo URL
        facts: [
          { "name" => "Public Page", "value" => "[Ver](#{public_page})" }
        ],
        use_markdown: true # Allows using Markdown in the message
      )
    rescue => e
      puts "Error sending message to Teams: #{e.full_message(highlight: true, order: :top)}"
    end
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
       package_name: package_name,
       json_key: json_key_file,
       skip_upload_apk: true
     )
  end

  desc "Generate specific flavor to build, by security can't make all flavors, because some of them are pointing to develop"
  lane :buildAab do |values|
    flavor_parameter = values[:id]
    flavors = config_json[:flavors]
    UI.message "TESTTT"
    flavors.each do |child|
      if child[:id] == flavor_parameter
        UI.message "Found it specific flavor flavor to build"
        flavor_name = child[:flavor_name]
        sign_conf = child[:sign_conf]
        gradle(
          task: "bundle",
          flavor: flavor_name.capitalize(),
          build_type: sign_conf.capitalize()
        )
        gradle(
           task: "#{module_name}:assemble",
           flavor: flavor_name.capitalize(),
           build_type: sign_conf.capitalize()
        )

        gradle_path = "#{lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]}"
        apk_output_path = "#{lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]}"
        distributeApp(options: child, gradle_path: gradle_path)
      end
    end
  end

  desc "Generate specific flavor to build, by security can't make all flavors, because some of them are pointing to develop"
  lane :distributeAab do |values|
    flavor_parameter = values[:id]
    flavors = config_json[:flavors]
    flavors.each do |child|
      if child[:id] == flavor_parameter
        UI.message "Found it specific flavor flavor to build"
        flavor_name = child[:flavor_name]
        sign_conf = child[:sign_conf]
        json_key_file = child[:json_key_file]
        if json_key_file == nil
            raise "Error: No se ha encontrado la configuracion de google play"
        end
        buildWithJson(child)
        gradle(
          task: "bundle",
          flavor: flavor_name.capitalize(),
          build_type: sign_conf.capitalize()
        )

        bundle_path = "#{lane_context[SharedValues::GRADLE_AAB_OUTPUT_PATH]}"
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
    conf_file = values[:conf_file]

    if conf_file == nil
      conf_file = './buildsystem/localise.json'
    end

    simple_loco(conf_file_path: conf_file)
  end
end


lane :change_version do |options|
  bump_type = options[:bump_type] || 'patch'
  gradle_files = Dir.glob("../**/*.gradle") + Dir.glob("../**/*.gradle.kts")
  puts "Bump type #{bump_type}"

  version_name = nil
  version_code = nil

  gradle_files.each do |file|
    content = File.read(file)

    version_name_match = content.match(/versionName\s*=\s*["']([\d.]+)["']/)
    version_code_match = content.match(/versionCode\s*=\s*(\d+)/)

    if version_name_match
      version_name = version_name_match[1]
    end
    if version_code_match
      version_code = version_code_match[1].to_i
    end

    break if version_name && version_code
  end

  if version_name && version_code
    puts "Current Version Name: #{version_name}, Version Code: #{version_code}"

       # Asegurarse de que la versión tenga tres partes (MAJOR.MINOR.PATCH)
    if version_name.split('.').length == 2
        version_name += '.0'  # Agregar .0 para completar el formato SemVer
        puts "Adjusted Version Name (with patch): #{version_name}"
    end
    version = Semantic::Version.new(version_name)
    new_version = case bump_type
        when 'major'
          version.increment!(:major)
        when 'minor'
          version.increment!(:minor)
        when 'patch'
          version.increment!(:patch)
        else
          puts "⚠️ Tipo de incremento no válido. Usa 'major', 'minor' o 'patch'."
          return
    end

    puts "New Version Name (after bumping #{bump_type}): #{new_version}"

    new_version_code = version_code + 1
    puts "New Version Code: #{new_version_code}"

    gradle_files.each do |file|
      content = File.read(file)
      new_content = content.gsub(/versionName\s*=\s*["'][\d.]+["']/, "versionName = \"#{new_version}\"")
      new_content = new_content.gsub(/versionCode\s*=\s*\d+/, "versionCode = #{new_version_code}")
      File.write(file, new_content)
    end
     File.open(ENV['GITHUB_OUTPUT'], 'a') do |file|
        file.puts("new_version=#{new_version}")
     end
  else
    puts "⚠️ No se encontró versionName o versionCode en el proyecto."
  end
end

lane :update_ci do |options|
    flavors = config_json[:flavors]
    ids = flavors.map do |item|
        item[:id]
    end
    ids_production = flavors.select do |obj|
        obj[:id].include?("production") || obj["production"] == true
    end
    ids_production = ids_production.map do |item|
        item[:id]
    end

    all_flavors_apk_directory = "../.github/workflows/all-flavors-apk.yml"
    all_flavors_apk = SafeYAML.load_file(all_flavors_apk_directory)
    all_flavors_apk["jobs"]["build"]["strategy"]["matrix"]["flavor"] = ids
    File.open(all_flavors_apk_directory, 'w') do |file|
        file.write(all_flavors_apk.to_yaml)
    end

    all_flavors_googleplay_directory = "../.github/workflows/all-flavors-googleplay.yml"
    all_flavors_googleplay = SafeYAML.load_file(all_flavors_googleplay_directory)
    all_flavors_googleplay["jobs"]["build"]["strategy"]["matrix"]["flavor"] = ids_production
    File.open(all_flavors_googleplay_directory, 'w') do |file|
        file.write(all_flavors_googleplay.to_yaml)
    end


    flavor_aab_google_play_directory = "../.github/workflows/flavor-aab-googleplay.yml"
    flavor_aab_google_play = SafeYAML.load_file(flavor_aab_google_play_directory)
    flavor_aab_google_play["on"]["workflow_dispatch"]["inputs"]["flavorId"]["options"] = ids_production
    File.open(flavor_aab_google_play_directory, 'w') do |file|
        file.write(flavor_aab_google_play.to_yaml)
    end


    flavor_apk_directory = "../.github/workflows/flavor-apk.yml"
    flavor_apk = SafeYAML.load_file(flavor_apk_directory)
    flavor_apk["on"]["workflow_dispatch"]["inputs"]["flavorId"]["options"] = ids
    File.open(flavor_apk_directory, 'w') do |file|
        file.write(flavor_apk.to_yaml)
    end

    update_strings_build_version_directory = "../.github/workflows/update-strings-build-version.yml"
    update_strings_build_version = SafeYAML.load_file(update_strings_build_version_directory)
    update_strings_build_version["on"]["workflow_dispatch"]["inputs"]["flavorId"]["options"] = ids
    File.open(update_strings_build_version_directory, 'w') do |file|
        file.write(update_strings_build_version.to_yaml)
    end

end

