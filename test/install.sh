#!/urs/bin/env bash

# Define the correct dotfile
case "$SHELL" in
  */bash*)
    if [[ -r "$HOME/.bash_profile" ]]; then
      shell_profile="$HOME/.bash_profile"
    else
      shell_profile="$HOME/.profile"
    fi
    ;;
  */zsh*)
    shell_profile="$HOME/.zprofile"
    ;;
  *)
    shell_profile="$HOME/.profile"
    ;;
esac

echo "Running a test for ${shell_profile}"


# Opening a browser window for manual download
open https://google.com/

