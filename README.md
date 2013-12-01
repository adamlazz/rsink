# rsink.sh

A backup utility for external hard drives that uses `rsync`.

In order to run `rsink.sh` you must set up your `.rsink/` directory. Inside this directory, there is a config file where your sources and destinations are listed. There is also a `profiles` directory, where you can manage settings for different backup schemes.

Refer to the To Do [wiki page] [1] for ideas on how you can help contribute to rsink.

## Installation

To install `rsink.sh`, open a terminal window and run the command: 

```
git clone https://github.com/adamlazz/rsink.git; cd rsink; chmod +x install.sh; ./install.sh`
```

## Configuration

The `config` file provides instructions for `rsync` on the source and destinations of your backups. Each line of the file is formatted like so:

```
profile source desintation_drive destination_folder exclude1 exclude2 ...

```

* If the source folder does not exist on the destination, it will be created.
* Don't include `/` characters at the end of tokens.
* Destination folders can be `.` for root of drive.
* There can be 0 or more excludes.
* There are space characters between the tokens in each line.
* There must be a new line at the end of the `config` file.

## Profiles

The `profiles` directory contains files that create different sets of options for rsync to use. The profile name is the name of the file. For example, the `sink` profile uses rsync archive mode (`-a`) and lists the following options:

```
progress:shows transfer progress
a:archive mode
ignore-existing
E:preserve executability

```

`rsink.sh` also comes with a `sync` profile for a source to destination sync. Files no longer on the source will be deleted from the destination. 

* For a full list of options run `man rsync`.
* You can name the profiles whatever you want.
* Only the first token of each line is read. You are able to add comments after the argument by separating the command and comment with a colon character as shown above.
* There must be a new line at the end of each profile file.

[1]: https://github.com/adamlazz/rsink/wiki/To-Do
