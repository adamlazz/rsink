# rsink.sh

A backup utility for external hard drives that uses rsync.

In order to run `rsink.sh` you must set up your `.rsink/` directory. Inside this directory, there are two files: `config` and `prefs`.

## Installation

To install `rsink.sh`, open a terminal window in your home directory and run the command: `git clone ______` Then, `cd rsink; chmod +x install.sh; ./install.sh`

## config file

The `config` file provides instructions for `rsync` on the source and destinations of your backups. Each line of the file is formatted like so:

```
source desintation exclude1 exclude2 ...

```

* There can be 0 or more excludes.
* There must be a new line at the end of the `config` file.
* There are space characters between the tokens in each line.

## prefs file

The `prefs` file is a list of the options that rsync uses.

```
a
E
ignore-existing
delete-excluded

```

# crontab

The crontab schedules jobs to be run automatically. To add `rsink.sh` to crontab, run `crontab -e` in a terminal. Add this line to the file:

```
1 2 3 4 5 ~/.rsink/rsink.sh
```

Where:
* 1: Minute (0-59)
* 2: Hour (0-23)
* 3: Day (0-31)
* 4: Month (0-12) (December is 12)
* 5: Day of the week (0-7) (Sunday is 0 or 7)

Read more about crontab here: http://unixhelp.ed.ac.uk/CGI/man-cgi?crontab+5