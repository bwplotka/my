#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Import https://github.com/bwplotka/demo-nav bash library.
TYPE_SPEED=40
IMMEDIATE_REVEAL=false
NUMS=false
PREFIX="➜  "
curl https://raw.githubusercontent.com/bwplotka/demo-nav/master/demo-nav.sh -o ${DIR}/demo-nav.sh
. "${DIR}/demo-nav.sh"

rm -rf ${DIR}/tmp-demo
mkdir -p ${DIR}/tmp-demo
cd ${DIR}

function cat() {
    bat -p "$@"
}

clear

# `r` registers command to be invoked.
#
# First argument specifies what should be printed.
# Second argument specifies what will be actually executed.
#
# http://localhost:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=go_goroutines&g0.tab=0
# NOTE: Use `'` to quote strings inside command.
r "${RED}# Backfilling from CSV file to Prometheus? Why not! [Demo]"
r "${YELLOW}# Let's get our CSV file ready!"
r "${GREEN}xdg-open 'http://demo.robustperception.io:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=go_goroutines&g0.tab=0'" "xdg-open 'http://demo.robustperception.io:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=go_goroutines&g0.tab=0' &> /dev/null"
r "${YELLOW}# For demo purposes let's move some samples from demo.robustperception.io to local Prometheusi. \n   1. First let's export data to CSV file using following script:" "cat ./query-to-csv.sh"
r "${GREEN}bash query-to-csv.sh ./example.csv"
r "${GREEN}head ./example.csv && cat ./example.csv | wc -l"
r "${YELLOW}# 2. Let's install Prometheus TSDB CLI Tool:"
r "${GREEN}go get github.com/prometheus/prometheus/tsdb/cmd/tsdb@3ac96c7841ed2d81a9611bd3c158007a85559c98"
r "${GREEN}tsdb --help"
r "${YELLOW}# 3. Let's import CSV file into TSDB block using tsdb tool!"
r "${GREEN}cat example.csv | tsdb import csv --output=./tmp-demo"
r "${GREEN}ls -lR ./tmp-demo"
r "${YELLOW}# Great! Can Prometheus show our newly created block now?"
r "${GREEN}touch ./tmp-demo/config.yaml && prometheus --storage.tsdb.path=./tmp-demo/ --config.file=./tmp-demo/config.yaml &"
r "${GREEN}xdg-open 'http://localhost:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=up&g0.tab=0'" "xdg-open 'http://localhost:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=up&g0.tab=0' &> /dev/null"
r "${YELLOW}# The end (:" "xdg-open 'http://localhost:9090/graph?g0.range_input=1h&g0.end_input=2020-07-16%2011%3A26&g0.expr=go_goroutines&g0.tab=0' &> /dev/null"

# Last entry to run navigation mode.
navigate
