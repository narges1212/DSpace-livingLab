#!/bin/bash

if [ $# -ne 2 ]; then
cat << EOF
usage: $0 [FILE]... [DBNAME]...
Extracts a single database from a sql file dumped with pg_dumpall and outputs
its content to stdout.
EOF
    exit 14
fi
 
db_file="$1"
db_name="$2"
 
if [ ! -f "$db_file" -o ! -r "$db_file" ]; then
    echo "error: $db_file not found or not readable" >&2
    exit 14
fi
 
while read line; do
    bytes=$(echo $line | cut -d: -f1)
 
    if [ -z "$start_point" ]; then
        start_point=$bytes
    else
        end_point=$bytes
    fi
done < <(grep -b '^\\\connect' "$db_file" | grep -m 1 -A 1 "$db_name$")

if [ -n "$start_point" -a -z "$end_point" ]; then
    end_point=`wc -c < $db_file`
fi

if [ -z "$start_point" -o -z "$end_point" ]; then
    echo "error: start or end not found" >&2
    exit 14
fi

db_length=$(($end_point - $start_point))
tail -c +$start_point $db_file | head -c $db_length | tail -n +3 \
     | grep -v "OWNER TO $db_name" | grep -v -E "^(REVOKE|GRANT|--)"