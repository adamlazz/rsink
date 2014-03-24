# rsink

A backup utility for external volumes that uses `rsync`.

Refer to the ["To Do" wiki page] [1] for ideas on how you can help contribute to rsink. Also, read the ["Testing" wiki page] [2] on how to test rsink without using your personal backup data.

## Installation

To clone and install rsink, open a terminal window and run the command:

```
git clone https://github.com/adamlazz/rsink.git; cd rsink; chmod +x install.sh; ./install.sh
```

Or, if you downloaded rsink from the [releases] [4] page, unzip the file and run:

```
cd rsink-*.*; chmod +x install.sh; ./install.sh
```

## Usage

In order to run `rsink.sh` you must set up your `.rsink` directory. Inside this directory, there is a `config` file where your sources and destinations are listed. There is also a `profiles` directory, where you can manage settings for different backup schemes. Set up your config file and profiles (below) and then run rsink.

```
./rsink.sh <options>
    -d or --dry-run     # Dry run (Don't run rsync)
    -h or --help        # Display help
    -p or --pushover    # Send Pushover.net notification
    -s or --silent      # Silent output
    -v or --version     # Displays version
```

You can also [automate] [3] rsink runs using `crontab`.

## Configuration

The `config` file provides instructions for `rsync` on the sources and destinations of your backups. Each line of the file is formatted like so:

```
profile source dest_volume dest_folder exclude1 exclude2 ...
```

* There should not be a `/` character at the end of the destination volume or at the beginning of the destination folder.
* Destination folders can be `.` for root of drive. Otherwise, the folders must exist.
* There can be 0 or more excludes.
* Destinations that aren't mounted will be skipped.

## Profiles

The `profiles` directory contains files that create different sets of options for `rsync` to use. The profile's name is the name of the file. For example, the `dump` profile uses the following options:

```
a   # archive
E   # preserve executability
progress
ignore-existing
```

* For a full list of options run `man rsync`.
* You can name profiles whatever you want.
* A `#` character indicates the start of a comment. Blank lines are also permitted.

#### Included profiles

* `dump` Copies source's new or changed files to the destination. Deleted files on the source will not be deleted from the destination.
* `sync` Source to destination sync. Files no longer on the source will be deleted from the destination if they exist.
* `backup` Versioned backup using `rsync --link-dest=PATH`. PATH should be the location you to link the most recent backup to.

[1]: https://github.com/adamlazz/rsink/wiki/To-Do
[2]: https://github.com/adamlazz/rsink/wiki/Testing
[3]: https://github.com/adamlazz/rsink/wiki/Automation
[4]: https://github.com/adamlazz/rsink/releases
[5]: https://pushover.net
