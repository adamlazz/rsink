# rsink.sh

A backup utility for external hard drives that uses rsync.

In order to run `rsink.sh` you must set up your `.rsink/` directory. Inside this directory, there are two files: `config` and `prefs`.

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

* The single letter options and the longer options must be grouped together.