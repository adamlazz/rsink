# rsink

A backup utility for external volumes using `rsync`.

Refer to the ["To Do" wiki page] [1] for ideas on how you can help contribute to rsink. Also, read the ["Testing" wiki page] [2] on how to test rsink without using your personal backup data.

## Usage

Clone rsink using `git clone https://github.com/adamlazz/rsink.git`, or download a release from the [releases] [4] page. You can move the `rsink` directory wherever you want.

In order to run `rsink.sh` you must set up your `rsink` directory. Inside this directory, there is a `config` file where your sources and destinations are listed. There is also a `profiles` directory, where you can manage settings for different backup schemes. Set up your config file and profiles (below) and then run rsink.

```
./rsink.sh <options>
    -d or --dry-run     # Dry run (Don't run rsync)
    -h or --help        # Display help
    -s or --silent      # Silent output
    -v or --version     # Displays version
```

You can also [automate] [3] rsink runs using `cron`.

## Configuration

The `config` file provides instructions for `rsync` on the sources and destinations for your backups. Each entry of the file is formatted like so:

```
profile name (required)
source path (required)
destination path (required)
destination folder (required and must exist)
exclude
...
<empty line>
```

* A `#` at the beginning of a line indicates a comment.
* There should not be a `/` character at the end of the destination volume or at the beginning of the destination folder.
* Destinations that are not mounted will be skipped.
* Destination folders can be `.` for root of drive. Otherwise, the folders must exist.
* There can be 0 or more excludes.
* An new line character `\n` indicates the end of a backup configuration.

## Profiles

The `profiles` directory contains files that create different sets of options for `rsync` to use. The profile's name is the name of the file. For example, the `dump` profile uses the following options:

```
a   # archive
E   # preserve executability
progress
ignore-existing
```

* A `#` character indicates the start of a comment. Blank lines are also permitted.
* `<source>` and `<dest>` are available as placeholders, so that profiles are not tied to specific sources or destinations.

#### Included profiles

* `dump` Copies source's new or changed files to the destination. Deleted files on the source will not be deleted from the destination.
* `sync` Source to destination sync. Files no longer on the source will be deleted from the destination if they exist.
* `backup` Versioned backup using `rsync --link-dest=PATH`. `PATH` is the location of the symbolic link to the most recent backup. You may use `<dest>` as a placeholder for the destination volume. A destination folder must be assigned in the `config` file and this folder must exist. Date and time data will be added to this destination folder to identify backups.

[1]: https://github.com/adamlazz/rsink/wiki/To-Do
[2]: https://github.com/adamlazz/rsink/wiki/Testing
[3]: https://github.com/adamlazz/rsink/wiki/Automation
[4]: https://github.com/adamlazz/rsink/releases
