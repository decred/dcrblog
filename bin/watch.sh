#!/usr/bin/env bash

set -e

# Remove old hugo output before building
rm -rf public resources

# Serve site
#   --buildFuture          include content with publishdate in the future
#   --buildDrafts          include content marked as draft
#   --disableFastRender    enables full re-renders on changes
#   --baseURL              hostname (and path) to the root
hugo server \
    --buildFuture \
    --buildDrafts \
    --disableFastRender \
    --baseURL http://localhost:1313/
