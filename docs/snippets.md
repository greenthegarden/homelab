# Useful Commands and other Snippets

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [TAR archives](#tar-archives)
- [JSON](#json)
- [stat command](#stat-command)
- [Creating a new json file](#creating-a-new-json-file)
- [Viewing Logs](#viewing-logs)
- [Contents of directory structure](#contents-of-directory-structure)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## TAR archives

To inspect contents of a tar file, `foo.tar.gz`, use

```bash
tar -t -f ./foo.gz
```

Where

- `-t` is used to list, but not extract the contents of the file.

To extract the content of a file, `bar.json`,  within a tar file,  `foo.tar.gz`, to screen, use

```bash
tar -x -O -f ./foo.tar.gz bar.json
```

Where

- `-x` to extract tar file
- `-O` to extract file to screen, rather than disk

## JSON

To work with `json` files on the command line [`jq` is a lightweight and flexible command-line JSON processor program](https://jqlang.org/).

For example, to prettyprint a json file `bar.json`, located inside a tar file, `foo.tar.gz`, use

```bash
tar -x -O -f ./foo.tar.gz bar.json | jq .
```

## stat command

The `stat` command provides more information about a file than using ``ls`.

To get the status of the file `~/.bashrc`, use

```bash
stat ~/.bashrc
```

In addition, `stat` can be used to get information about the file system a file is located on.

To get the status of the file system that the file `~/.bashrc` is lcoated on use

```bash
stat -f ~/.bashrc
```

## Creating a new json file

To quickly create a new json file, `test.json`, use, for example

```bash
sh -c 'echo "{\n\t\"debug\": true\n}" > test.json'
```

## Viewing Logs

To view logs use `journalctl`.

To view only the logs from a process, `docker`, use

```bash
journalctl -f -x -u docker
```

Where

- `-f` show only the most recent journal entries, and continuously print new entries as they are appended to the journal
- `-u` shous only messages for the specified systemd unit
- `-x` augments log lines with explanation texts from the message catalog

DigitalOceen offers a good [guide to journctl](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs).

## Contents of directory structure

Use the command `tree` to see the contents of multiple layers of direecotries.

```bash
tree ~/
```
