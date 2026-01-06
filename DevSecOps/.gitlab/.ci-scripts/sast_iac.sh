#!/bin/bash

vulnerability_count=$(cat $FILE_REPORT | jq --raw-output '.vulnerabilities | length')
if [ ${vulnerability_count} -gt 0 ];  then
  echo "|     severity     |     name     |     location     |"
  echo "|------------------|--------------|------------------|"
  _jq() {
   echo ${row} | base64 --decode | jq -r ${1}
  }
  for row in $(cat $FILE_REPORT | jq -r '.vulnerabilities[] | @base64'); do
    echo '|' $(_jq ".severity") '|' $(_jq ".identifiers[0].name") '|' $(_jq ".location.file")':'$(_jq ".location.start_line") '|'
  done
fi

exit $vulnerability_count