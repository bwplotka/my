#!/usr/bin/env bash

FORK_MD2GSLIDES=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Using awesome https://github.com/gsuitedevs/md2googleslides
MD2GSLIDES="md2gslides"
if ! [ -z ${FORK_MD2GSLIDES} ]; then
  MD2GSLIDES="node ${FORK_MD2GSLIDES}/bin/md2gslides.js"
fi

# Regenerate all slides with proper titles.

# https://docs.google.com/presentation/d/1a9g9krgZwmA27Z-zAYeOH-nZZyrkHtybAUMhHzb41WA
${MD2GSLIDES} ${DIR}/17062020-optimizing-go-for-clouds-go-meetup.md -n --style=github --title="Optimizing Go for Clouds: Practical Intro" --append=1a9g9krgZwmA27Z-zAYeOH-nZZyrkHtybAUMhHzb41WA --erase