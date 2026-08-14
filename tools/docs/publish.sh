#!/bin/sh
# Build the documentation and copy it into the ztachip.github.io working copy.
#
#   sh tools/docs/publish.sh [path-to-ztachip.github.io]
#
# Default destination is ../ztachip.github.io. Everything in that working copy
# except .git and .nojekyll is replaced: the site is generated, nothing there is
# edited by hand. Review, then commit and push from that repository.
set -e

SITE=${1:-../ztachip.github.io}

if [ ! -d "$SITE/.git" ]; then
    echo "Not a git working copy: $SITE" >&2
    echo "Usage: sh tools/docs/publish.sh [path-to-ztachip.github.io]" >&2
    exit 1
fi

sh tools/docs/build.sh

find "$SITE" -mindepth 1 -maxdepth 1 ! -name .git ! -name .nojekyll -exec rm -rf {} +
cp -r Documentation/html/. "$SITE"/

echo
echo "Published into $SITE"
echo "Next:  cd $SITE && git add -A && git commit -m 'Update documentation' && git push"
