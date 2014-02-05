# rsink

A backup utility for external hard drives that uses `rsync`.

Refer to the ["To Do" wiki page] [1] for ideas on how you can help contribute to rsink. Also, read the ["Testing" wiki page] [2] on how to test rsink without using your personal backup data.

## Installation

To download and install rsink, open a terminal window and run the command:

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
    -h <help>
    -p <pushover> (Fill in user key and app key in .rsink/tools/pushover.sh)
    -s <silent>
    -v <version>
```

You can also [automate] [3] rsink using `crontab`.

## Configuration

The `config` file provides instructions for `rsync` on the sources and destinations of your backups. Each line of the file is formatted like so:

```
profile source dest_drive dest_folder exclude1 exclude2 ...
```

* Destination folders can be `.` for root of drive.
* There can be 0 or more excludes.

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
* A `#` character indicates the start of a comment.

#### Included profiles

* `dump` Sends source's new files to the destination, where they stay.
* `sync` Source to destination sync. Files no longer on the source will be deleted from the destination.
* `backup` Versioned backup...

[1]: https://github.com/adamlazz/rsink/wiki/To-Do
[2]: https://github.com/adamlazz/rsink/wiki/Testing
[3]: https://github.com/adamlazz/rsink/wiki/Automation
[4]: https://github.com/adamlazz/rsink/releases
[5]: https://pushover.net
