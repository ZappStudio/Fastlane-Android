fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android generic

```sh
[bundle exec] fastlane android generic
```

Building generic by json configuration

### android buildWithJson

```sh
[bundle exec] fastlane android buildWithJson
```

Build flavor with json config

### android distributeApp

```sh
[bundle exec] fastlane android distributeApp
```

Distribute app

### android teamsNotification

```sh
[bundle exec] fastlane android teamsNotification
```

Teams message to teams_web_hook

### android uploadGooglePlay

```sh
[bundle exec] fastlane android uploadGooglePlay
```

Upload aab to google play

### android buildAab

```sh
[bundle exec] fastlane android buildAab
```

Generate specific flavor to build, by security can't make all flavors, because some of them are pointing to develop

### android distributeAab

```sh
[bundle exec] fastlane android distributeAab
```

Generate specific flavor to build, by security can't make all flavors, because some of them are pointing to develop

### android importLoco

```sh
[bundle exec] fastlane android importLoco
```


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
    docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project; fastlane importLoco'
```

También es recomendable crearse un Makefile para mas comodidad.
Contenido del Makefile:

```makefile
    import-loco:
    docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project; fastlane importLoco'
```
Se puede indicar la configuración que se quiere utilizar, por ejemplo:
```sh
   docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mdm.json'
```

De esta forma podemos tener varios modulos con diferentes configuraciones de localización. Importándolas todas desde un solo comando. Ejemplo:

```makefile
    import-loco: import-mycardio import-mdm
    import-mycardio:
      docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mycardio.json'

    import-mdm:
      docker run --rm -v `pwd`:/project mingc/android-build-box bash -c 'cd /project; fastlane importLoco conf_file:./buildsystem/localise-mdm.json'
```
Esto es extensible infinitamente.


----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
