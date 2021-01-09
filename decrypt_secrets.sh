#!/bin/bash

gpg \
  --quiet \
  --batch \
  --yes \
  --decrypt \
  --passphrase="$SSH_KEY_GPG_PASSPHRASE" \
  --output .secrets/activetravel-inverness \
  .secrets/activetravel-inverness.gpg

gpg \
  --quiet \
  --batch \
  --yes \
  --decrypt \
  --passphrase="$SSH_KEY_GPG_PASSPHRASE" \
  --output .secrets/activetravel-inverness.pub \
  .secrets/activetravel-inverness.pub.gpg