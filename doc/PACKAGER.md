# Packager info

## BigWigModes release.sh

- https://github.com/BigWigsMods/packager

> Show Help by running command

```shell
$ ./packager.sh -h

Usage: release.sh [options]
  -c               Skip copying files into the package directory.
  -d               Skip uploading.
  -e               Skip checkout of external repositories.
  -l               Skip @localization@ keyword replacement.
  -L               Only do @localization@ keyword replacement (skip upload to CurseForge).
  -o               Keep existing package directory, overwriting its contents.
  -s               Create a stripped-down "nolib" package.
  -S               Create a package supporting multiple game types from a single TOC file.
  -u               Use Unix line-endings.
  -z               Skip zip file creation.
  -t topdir        Set top-level directory of checkout.
  -r releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
  -p curse-id      Set the project id used on CurseForge for localization and uploading. (Use 0 to unset the TOC value)
  -w wowi-id       Set the addon id used on WoWInterface for uploading. (Use 0 to unset the TOC value)
  -a wago-id       Set the project id used on Wago Addons for uploading. (Use 0 to unset the TOC value)
  -g game-version  Set the game version to use for uploading.
  -m pkgmeta.yaml  Set the pkgmeta file to use.
  -n "{template}"  Set the package zip file name and upload label. Use "-n help" for more info.

```
### Notes

- The command $HOME/bin/release-wow-addon is linked to packager.sh in local dev env

### Common Commands

> Download Externals
```shell
$ release-wow-addon -coz
# writes to a .release folder
```