#!/bin/bash

# default versions
MDBOOK_VERSION='0.4.32';

# install mdBook
echo "Installing mdBook $MDBOOK_VERSION..."
DOWNLOAD_URL="https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-musl.tar.gz"
echo "Downloading from $DOWNLOAD_URL"
curl -Lo mdbook.tar.gz $DOWNLOAD_URL
tar -xvzf mdbook.tar.gz


./mdbook build
echo "mdBook build completed."
