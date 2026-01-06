#!/bin/bash

vulnerability_count=$(eval "$GET_VULNERABILITY_COUNT")
if [ ${vulnerability_count} -gt 0 ];  then
 echo "|     name     |     severity     |     file     |     commit     |"
 _jq() {
  echo ${row} | base64 --decode | jq -r ${1}
 }
 for row in $(cat gl-secret-detection-report.json | jq -r '.vulnerabilities[] | @base64'); do
   echo '|' $(_jq ".name") '|' $(_jq ".severity") '|' $(_jq ".location.file") '|' $(_jq ".location.commit.sha") '|'
 done
fi