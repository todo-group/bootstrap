#!/bin/bash

[ "$USER" = "root" ] || { echo "Error: Not running as root. Exit."; exit 127; }
[ -n "$BASH_VERSION" ] || { echo "Info: Not running in bash. Re-executing with bash..."; exec bash "$0" "$@"; }

read -r -p "Username: " USERNAME
test -n "$USERNAME" || { echo "Error: Invalid username. Exit."; exit 127; }

ID_EXISTS=$(id "$USERNAME" > /dev/null 2>&1; echo $?)
if test "$ID_EXISTS" = 0; then
  echo "Info: user $USERNAME exists. Skipping user creation."
  NEW_HOME=$(eval echo ~"$USERNAME")
  test -d "$NEW_HOME" || { echo "Error: $NEW_HOME not found. Exit."; exit 127; }
else 
  read -r -p "Home Directory: 1) /home/${USERNAME}, 2) /admin/${USERNAME}: " HOME_CHOICE
  case "$HOME_CHOICE" in
    1) NEW_HOME="/home/${USERNAME}"; SET_SUDO=0 ;;
    2) NEW_HOME="/admin/${USERNAME}"; SET_SUDO=1 ;;
    *) echo "Error: Invalid choice. Exit."; exit 127 ;;
  esac
  test ! -d "$NEW_HOME" || { echo "Error: $NEW_HOME exists. Exit."; exit 127; }

  # create user
  set -x
  mkdir -p "$(dirname "$NEW_HOME")"
  useradd -d "$NEW_HOME" -m -s /bin/bash -U "$USERNAME"
  { set +x; } 2>/dev/null
  passwd "$USERNAME"
  if test "$SET_SUDO" = 1; then
    echo "Info: adding $USERNAME to sudo group"
    usermod -aG sudo "$USERNAME"
  fi
fi
GROUPNAME=$(groups "$USERNAME" | cut -d' ' -f 3)

read -r -p "GitHub ID: " GITHUB_ID
test -n "$GITHUB_ID" || { echo "Info: skipping SSH key installation"; exit 0; }

# setup ssh keys
DOT_SSH="$NEW_HOME"/.ssh
if test -f "$DOT_SSH"/authorized_keys; then
  echo "Info: $DOT_SSH/authorized_keys already exists. Skipping SSH key installation."
else
  set -x
  mkdir -p "$DOT_SSH"
  chmod 755 "$DOT_SSH"
  curl https://github.com/"$GITHUB_ID".keys > "$DOT_SSH"/authorized_keys
  chmod 644 "$DOT_SSH"/authorized_keys
  chown -R "$USERNAME":"$GROUPNAME" "$DOT_SSH"
  { set +x; } 2>/dev/null
fi

# generate ssh config
if test -f "$DOT_SSH"/config; then
  echo "Info: $DOT_SSH/config already exists. Skipping SSH config generation."
else
  echo "Info: generating ssh config: $DOT_SSH/config"
  cat > "$DOT_SSH"/config << EOF
Host *github.com
  User ${GITHUB_ID}
  ForwardX11 no
  ForwardX11Trusted no
Host *
  ForwardAgent yes
  StrictHostKeyChecking no
EOF
  set -x
  chmod 644 "$DOT_SSH"/config
  chown -R "$USERNAME":"$GROUPNAME" "$DOT_SSH"/config
  { set +x; } 2>/dev/null
fi
