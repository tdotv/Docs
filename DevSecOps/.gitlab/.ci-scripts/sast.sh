#!/bin/bash

vulnerability_count=$(cat $FILE_REPORT | jq --raw-output '.vulnerabilities | length')
if [ ${vulnerability_count} -gt 0 ];  then
  echo "|     severity     |     name     |     location     |     scanner     |"
  echo "|------------------|--------------|------------------|-----------------|"
  _jq() {
   echo ${row} | base64 --decode | jq -r ${1}
  }
  for row in $(cat $FILE_REPORT | jq -r '.vulnerabilities[] | @base64'); do
    vulnerability_name=$(_jq ".name")
    if [ "$vulnerability_name" == "null" ]; then vulnerability_name=$(_jq ".message"); fi
    echo '|' $(_jq ".severity") '|' $vulnerability_name '|' $(_jq ".location.file")':'$(_jq ".location.start_line") '|' $(_jq ".scanner.name") '|'
  done
fi

exit $vulnerability_count