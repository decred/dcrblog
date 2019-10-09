#!/bin/bash -e
# Requires docker 17.05 or higher

echo ""
echo "================================="
echo "  Building dcrblog docker image  "
echo "================================="
echo ""

docker build -t decred/dcrblog .

echo ""
echo "==================="
echo "  Build complete"
echo "==================="
echo ""
echo "You can now run dcrblog with the following command:"
echo "    docker run -d --rm -p <local port>:80 decred/dcrblog:latest"
echo ""