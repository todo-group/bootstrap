#!/bin/bash

DOT_SSH=${HOME}/.ssh

read -p "GitHub ID: " GITHUB_ID

if [ -f "${DOT_SSH}/authorized_keys" ]; then
    echo "Info: ${DOT_SSH}/authorized_keys exists. Skip."
else
    mkdir -p ${DOT_SSH}
    chmod 755 ${DOT_SSH}
    curl "https://github.com/${GITHUB_ID}.keys" > "${DOT_SSH}/authorized_keys"
    chmod 644 ${DOT_SSH}/authorized_keys
fi

if [ -f "${DOT_SSH}/config" ]; then
    echo "Info: ${DOT_SSH}/config exists. Skip."
else
    cat > "${DOT_SSH}/config" << EOF
Host *github.com
  User ${GITHUB_ID}
  ForwardX11 no
  ForwardX11Trusted no
  StrictHostKeyChecking no
EOF
    chmod 644 "${DOT_SSH}/config"
fi
