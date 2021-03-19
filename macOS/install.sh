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

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${shell_profile}
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install MacOS Applications included in the tap: homebrew/core
brew install --cask bartender                   # https://macbartender.com/
brew install --cask istat-menus                 # https://bjango.com/mac/istatmenus/

brew install --cask visual-studio-code          # https://code.visualstudio.com/
brew install --cask sensei                      # https://sensei.app/
brew install --cask github                      # https://desktop.github.com/
brew install --cask wireshare
brew install --cask macdown

brew install --cask firefox                     # https://mozilla.org/firefox/
# brew install --cask openoffice                  # https://openoffice.org/
brew install --cask devonthink                  # https://devontechnologies.com/apps/devonthink/
brew install --cask microsoft-teams             # https://teams.microsoft.com/downloads
brew install --cask teamdrive                   # https://teamdrive.com/
brew install --cask fujitsu-scansnap-home       # https://www.scansnapit.com/de/scansnap-software/scansnap-home/

brew install --cask vlc                         # https://videolan.org/vlc/
brew install --cask spotify                     # https://spotify.com/
brew install --cask audio-hijack                # https://rogueamoeba.com/audiohijack/
brew install --cask fission                     # https://rogueamoeba.com/fission/
brew install --cask minecraft

# Install MacOS Applications included in the tap: homebrew/cask-drivers
brew tap homebrew/cask-drivers

brew install --cask synology-drive          # https://www.synology.com/en-us/releaseNote/SynologyDriveClient
brew install --cask fujitsu-scansnap-home
brew install --cask displaylink

# Now install pyenv for development
brew install pyenv
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then' >> ${shell_profile}
echo -e '    eval "$(pyenv init -)"' >> ${shell_profile}
echo -e 'fi' >> ${shell_profile}

# Python 3.9.1 should work (also on Macs with M1 chip)
pyenv install 3.9.1
pyenv global 3.9.1

# Some files cannot be automatically downloaded, here I open the relevant website for manual download:
open https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html

