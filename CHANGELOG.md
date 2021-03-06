# Changelog

## v0.2+dev
* Bugfix: Use `#!/bin/bash` shebang line
* Bugfix: Use `local` for local function variables
* Bugfix: Look for exact match when detecting volume
* Feature: `\n`-delimited `config` file
* Feature: Options stored in array, not in a string
* Feature: Skip destinations that are not mounted
* Feature: Use `rsync --dry-run` during `rsink --dry-run`
* Feature: `<dest>` placeholder for `rsync link-dest` option in backup profiles and similar options where paths are required. Allows for reuse of backup profiles among multiple destinations.
* Feature: `<source>` placeholder for `rsync exclude-from` option and similar options where paths are required.
* Feature: `config` and `profile` absolute paths. No need to `cd` into your rsink folder. Call rsink from anywhere.
* Removal: `install.sh` file and `.rsink` folder. Keep rsink folder wherever you want, along with `LICENSE.md` and `README.md`.
* Removal: `constants.sh` file
* Removal: Pushover support. Easy to implement on your own.

## v0.2 (February 8, 2014)
* Bugfix: Multiple single character options print together
* Bugfix: Exit on Ctrl+C
* Feature: Check for unknown option and free space errors
* Feature: Comment lines and empty lines allowed in profiles
* Feature: Pushover support in `.rsink/tools`
* Feature: Single character options system
* Feature: [Pushover](https://pushover.net/) option (`-p` or `--pushover`)
* Feature: Dry-run (`-d` or `--dry-run`) option
* Feature: Help (`-h` or `--help`) option
* Feature: Silent (`-s` or `--silent`) option
* Feature: Version (`-v` or `--version`) option
* Feature: [Versioned backup](http://blog.interlinked.org/tutorials/rsync_time_machine.html) profile using `rsync --link-dest`
* Feature: Constants stored in `.rsink/constants.sh`

## v0.1 (December 12, 2013)
* Initial release
* Automatic install
* `rsink.sh` with config and profiles
* OS X, Linux support
