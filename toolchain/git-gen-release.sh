#!/bin/bash

WDIR="$(dirname "$(realpath "$0")")"

function gitw()
{
	[ -n "$DRYRUN" ] && echo git $@ && return 0
	git $@
}

function die()
{
	echo $@
	exit 1
}

[ -z "$1" ] && die "-- Release type not specified"

RELEASE_NAME="$("$WDIR"/version.py "$1")"

gitw tag -a -m "Version $RELEASE_NAME" "$RELEASE_NAME"
gitw push --follow-tags
