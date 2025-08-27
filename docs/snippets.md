# Useful Commands and other Snippets

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [TAR archives](#tar-archives)
- [JSON](#json)

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
