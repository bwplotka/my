#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT=$1
# Take 1h from 2020-07-16 11:26 for go_goroutines from RobustPerception demo server. 
# http://demo.robustperception.io:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=go_goroutines&g0.tab=0
QUERY="http://demo.robustperception.io:9090/api/v1/query_range?query=go_goroutines&start=1594895160&end=1594898760&step=14&_=1594898299554"
echo "label_name,label_value,label_name,label_value,label_name,label_value,timestamp_ms,value" > ${OUTPUT}
for row in $(curl ${QUERY} | jq -c '.data.result[]'); do
  prefix=""
  for labelName in $(echo ${row} | jq -cr '.metric | keys[]'); do
    value=$(echo ${row} | jq -r ".metric.${labelName}")
    prefix="${prefix}${labelName},${value},"
  done

  for sample in $(echo ${row} | jq -c '.values[]'); do
      ts_sec=$(echo ${sample} | jq -r ".[0]")
      ts_ms=$(( 1000*ts_sec ))

      value=$(echo ${sample} | jq -r ".[1]")

      # Write CSV line.
      echo "${prefix}${ts_ms},${value}" >> ${OUTPUT}
  done
done
