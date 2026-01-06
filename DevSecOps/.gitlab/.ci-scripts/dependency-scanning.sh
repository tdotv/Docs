#!/bin/bash

vulnerability_count=$(cat $FILE_REPORT | jq --raw-output '.vulnerabilities | length')
if [ ${vulnerability_count} -gt 0 ];  then
  echo "|     severity     |     name     |     file     |     package     |"
  echo "|------------------|--------------|--------------|-----------------|"
  _jq() {
   echo ${row} | base64 --decode | jq -r ${1}
  }
  for row in $(cat $FILE_REPORT | jq -r '.vulnerabilities[] | @base64'); do
    echo '|' $(_jq ".severity") '|' $(_jq ".name") '|' $(_jq ".location.file") '|' $(_jq ".location.dependency.package.name") '|'
  done
fi

exit $vulnerability_count