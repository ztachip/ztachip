#!/bin/sh
# Rebuild the styled HTML documentation from the Markdown sources.
#
#   sh tools/docs/build.sh          (run from the repository root)
#
# Output: Documentation/html/index.html and one page per document.
set -e
python3 tools/docs/mdhtml.py Documentation/html \
    Documentation/index.md:../ \
    Documentation/Overview.md:../ \
    Documentation/HardwareDesign.md:../ \
    Documentation/ztachip_programmer_guide.md:../ \
    Documentation/visionai_programmer_guide.md:../ \
    micropython/MicropythonUserGuide.md:../../micropython/
