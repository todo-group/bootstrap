#!/bin/bash

read -r -p "Username: " USERNAME
test -n "$USERNAME" || { echo "Error: Invalid username. Exit."; exit 127; }

NEW_HOME=/home-local/${USERNAME}
test ! -d "$NEW_HOME" || { echo "Error: $NEW_HOME exists. Exit."; exit 127; }

ID_EXISTS=$(id "$USERNAME" > /dev/null 2>&1; echo $?)
test "$ID_EXISTS" = 1 || { echo "Error: user $USERNAME exists. Exit."; exit 127; }

# create user
set -x
useradd -d "$NEW_HOME" -m -s /bin/bash -U "$USERNAME"
{ set +x; } 2>/dev/null
passwd "$USERNAME"
set -x
usermod -aG sudo "$USERNAME"
{ set +x; } 2>/dev/null

read -r -p "GitHub ID: " GITHUB_ID
test -n "$GITHUB_ID" || { echo "Info: skipping SSH key installation"; exit 0; }

# setup ssh keys
DOT_SSH="$NEW_HOME"/.ssh
set -x
mkdir -p "$DOT_SSH"
chmod 755 "$DOT_SSH"
curl https://github.com/"$GITHUB_ID".keys > "$DOT_SSH"/authorized_keys
chmod 644 "$DOT_SSH"/authorized_keys
{ set +x; } 2>/dev/null
echo "Info: generating ssh config"
cat > "$DOT_SSH"/config << EOF
Host *github.com
    User ${GITHUB_ID}
    ForwardX11 no
    ForwardX11Trusted no
    StrictHostKeyChecking no
EOF
set -x
chmod 644 "$DOT_SSH"/config
chown -R "$USERNAME":"$USERNAME" "$DOT_SSH"
{ set +x; } 2>/dev/null
