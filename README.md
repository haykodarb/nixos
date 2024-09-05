# Steps to reproduce Operating System.

- Install NixOS using the installer from their website.

- Clone this repository somewhere inside the home directory.

- Remove all contents of the /etc/nixos directory.

- Create a symlink between the two directories
  
  ```
  cd /etc/nixos
  sudo ln -s ~/nixos/configuration.nix
  ```

- Run ``sudo nixos-rebuild switch`` to rebuild with our new configuration. Use ``--show-trace`` if something goes wrong.

- To add applications go into home.nix and add them to the packages array. In case they are needed as system wide packages, do the same in configuration.nix.



### Developing with Flutter

- With the OS installed, follow these steps to enter a Flutter shell.
  
  ```
  cd ~/nixos/shells/flutter
  devenv shell
  flutter doctor -v
  ```

- Check that everything is OK by running ``flutter doctor -v`` and perhaps by creating a demo app and compiling in all platforms (Android, Linux and Chrome)

```
flutter create example
cd example
flutter run -d linux
flutter run -d chrome
flutter build apk
```
