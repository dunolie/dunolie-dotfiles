#!/bin/sh

# sanitizes filenames in $PWD
SED=/bin/sed
LS=/bin/ls
LESS=/usr/bin/less
IFS=$'\t\n'

#1 anything that's !not alphanumeric, replace with underscore
#2 remove any underscores at the beginning of the line
#3 replace one or more underscores with just one underscore
for file in `$LS $PWD`; do
    echo "renaming $file to -->"
    NEWFN=` echo $file \
    | $SED 's/[^[:alnum:]\.-_]/_/g' \
    | $SED 's/^_//' \
    | $SED 's/\[//' \
    | $SED 's/\]//' \
    | $SED 's/\.\{1,\}/./' \
    | $SED 's/_\{1,\}/_/g' `
    echo $NEWFN
    /bin/mv $file $NEWFN 

done
#    | $SED 's/[:blank:]/_/g' \
