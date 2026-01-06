#!/bin/bash

# Function to perform rsync
perform_rsync_dry() {
  rsync -e "ssh -p 1722" -r -i -c --delete --update \
    --exclude 'files' \
    --exclude 'smd' \
    --exclude 'node_modules' \
    --exclude '.env' \
    --exclude '.git' \
    --exclude 'public/vendor' \
    --exclude 'copy' \
    --dry-run . jjnes@docnode.by:~/app
}

perform_rsync() {
  rsync -e "ssh -p 1722" -r -i -c --delete --update \
    --exclude 'files' \
    --exclude 'smd' \
    --exclude 'node_modules' \
    --exclude '.env' \
    --exclude '.git' \
    --exclude 'public/vendor' \
    --exclude 'copy' \
    . jjnes@docnode.by:~/app
}

# Perform a dry run to preview changes
perform_rsync_dry

echo "Are you sure you want to continue? (Type 'Y' to proceed, 'n' to exit)"
read confirmation

if [ "$confirmation" == "Y" ]; then
  echo "Continuing with the script..."
  # Actual synchronization
  perform_rsync
else
  echo "You canceled the script execution."
  exit 1
fi
