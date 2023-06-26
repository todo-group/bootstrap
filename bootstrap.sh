#!/bin/bash

DOT_SSH=/tmp/dot.ssh

read -p "GitHub ID: " GITHUB_ID && echo

mkdir -p ${DOT_SSH}
wget https://github.com/${GITHUB_ID}.keys -O ${DOT_SSH}/authorized_keys
cat > ${DOT_SSH}/config << EOF
Host *github.com
  User ${GITHUB_ID}
  ForwardX11 no
  ForwardX11Trusted no
  StrictHostKeyChecking no
EOF
chmod 755 ${DOT_SSH}
chmod 644 ${DOT_SSH}/authorized_keys ${DOT_SSH}/config
