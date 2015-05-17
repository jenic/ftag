# ftag
_File tagging because reasons_

    Syntax: tag [ -t <tag1,tag2,...> | -f <file1,file2,...> ] | [-v] [-d <file>]
    If -t and -f are found in same runtime it is assumed you are tagging a file.
    -t tag, comma separated
    -f files, comma separated
    -d  Do not save. Dry run.

Examples
--------
* Tag a file:
 * tag -f funny.gif -t funny,gif,lol

* Show tags for file:
 * tag -f funny.gif

* Show files for tags:
 * tag -t funny

* Show all tags:
 * tag -t

* Show all files and tags:
 * tag -f

* Show all tags with a count of files for each tag:
 * tag
