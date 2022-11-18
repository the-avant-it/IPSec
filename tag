#!/bin/bash

echo "Script version: 2.0.4:5"
# Based on https://gist.github.com/dtiemann83/cfa16ade69a3ea451ad760d4118a9351

CURTAG=$(git describe --tags `git rev-list --tags --max-count=1` | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+");
CURTAG="${CURTAG/v/}"

IFS='.' read -a vers <<< "$CURTAG"

MAJ=${vers[0]}
MIN=${vers[1]}
BUG=${vers[2]}
echo "Latest tag: $MAJ.$MIN.$BUG"

for cmd in "$@"
do
	case $cmd in
		"--major")
			# $((MAJ+1))
			((MAJ+=1))
			MIN=0
			BUG=0
			echo "Incrementing major version"
            NEWTAG="$MAJ.$MIN.$BUG"
			;;
		"--minor")
			((MIN+=1))
			BUG=0
			echo "Incrementing minor version"
            NEWTAG="$MAJ.$MIN.$BUG"
			;;
		"--patch")
			((BUG+=1))
			echo "Incrementing patch version"
            NEWTAG="$MAJ.$MIN.$BUG"
			;;
        "--custom")
            echo "Using entered custom tag '$2'"
            NEWTAG="$2"
            ;;   
	esac
done

echo "Adding Tag: $NEWTAG";
if git tag | grep $NEWTAG > /dev/null; then
    echo "Tag $NEWTAG already exist =("
else
    git tag $NEWTAG
    git push origin $NEWTAG
    echo "Tag $NEWTAG has been pushed!"
fi