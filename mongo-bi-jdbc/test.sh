#! /bin/bash
if [[ -f env ]]; then
    source env
fi

echo $bi_uri
gradle run --args="$bi_uri $bi_user $bi_password"