#!/bin/sh
# Build the styled HTML documentation.
#
#   sh tools/docs/build.sh            (run from the repository root)
#
# Writes a self-contained site to Documentation/html: open index.html from disk,
# or publish the directory as-is. Images are copied in; links to repository
# files point at github.com.
set -e
rm -rf Documentation/html
python3 tools/docs/mdhtml.py Documentation/html \
    Documentation/index.md \
    Documentation/Overview.md \
    Documentation/HardwareDesign.md \
    Documentation/ztachip_programmer_guide.md \
    Documentation/visionai_programmer_guide.md \
    micropython/MicropythonUserGuide.md
