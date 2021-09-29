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

# Install command line tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${shell_profile}
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Rosetta
sudo softwareupdate --install-rosetta

# Also install MacOS Applications included in the tap: homebrew/cask-drivers
brew tap homebrew/cask-drivers

# Install MacOS Applications included in the tap: homebrew/core
brew install --cask bartender                   # https://macbartender.com/
brew install --cask istat-menus                 # https://bjango.com/mac/istatmenus/

# Install Office applications
brew install --cask microsoft-office            # https://products.office.com/mac/microsoft-office-for-mac/
brew install --cask synology-drive              # https://www.synology.com/en-us/releaseNote/SynologyDriveClient
brew install --cask devonthink                  # https://devontechnologies.com/apps/devonthink/
brew install --cask microsoft-teams             # https://teams.microsoft.com/downloads


# Install Developer applications
brew install --cask github                      # https://desktop.github.com/
brew install --cask macdown                     # https://macdown.uranusjr.com/
brew install --cask arduino                     # https://www.arduino.cc/
brew install --cask wch-ch34x-usb-serial-driver # CH34 driver for ESP
brew install --cask paragon-extfs               # https://www.paragon-software.com/ufsdhome/extfs-mac/

brew install --cask visual-studio-code          # https://code.visualstudio.com/

# Installs extensions for VS Code
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-vscode.cpptools
code --install-extension samuelcolvin.jinjahtml
code --install-extension WyattFerguson.jinja2-snippet-kit
code --install-extension TabNine.tabnine-vscode # AI auto-completion
# code --install-extension vsciot-vscode.vscode-arduino

brew install --cask sensei                      # https://sensei.app/
brew install --cask wireshare                   # https://www.wireshark.org
brew install --cask cyberduck                   # https://cyberduck.io/
brew install --cask blender                     # https://www.blender.org/
brew install --cask adobe-creative-cloud        # https://www.adobe.com/creativecloud.html
brew install --cask mactex-no-gui               # https://www.tug.org/mactex/
brew install --cask latexit                     # https://www.chachatelier.fr/latexit/
brew install --cask unity-hub                   # https://unity3d.com/get-unity/download

brew install --cask firefox                     # https://mozilla.org/firefox/
brew install --cask skype                       # https://www.skype.com/
brew install --cask google-drive                # https://www.google.com/drive/

brew install --cask vlc                         # https://videolan.org/vlc/
brew install --cask spotify                     # https://spotify.com/
brew install --cask handbrake
brew install --cask insta360-studio
brew install --cask audio-hijack                # https://rogueamoeba.com/audiohijack/
brew install --cask fission                     # https://rogueamoeba.com/fission/
brew install --cask minecraft

# For making
brew install --cask eagle
brew install --cask pronterface
brew install --cask ultimaker-cura

brew install --cask fujitsu-scansnap-home
brew install --cask displaylink

# Now install pyenv for development
brew install pyenv
echo -e 'export PYENV_ROOT="$HOME/.pyenv"' >> ${shell_profile}
echo -e 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${shell_profile}
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then' >> ${shell_profile}
echo -e '    eval "$(pyenv init --path)"' >> ${shell_profile}
echo -e 'fi' >> ${shell_profile}

# Python 3.9.7 is the latest (currently)
pyenv install 3.9.7
pyenv local 3.9.7
python_version=$(python -V 2>&1)
if [ "${python_version}" = "Python 3.9.7" ]; then
    pip install virtualenv
else
    echo "Error innstalling Python 3.9.7"
fi

# Python 3.9.1 should work also work with RPi
pyenv install 3.9.1
pyenv local 3.9.1
python_version=$(python -V 2>&1)
if [ "${python_version}" = "Python 3.9.1" ]; then
    pip install virtualenv
else
    echo "Error innstalling Python 3.9.1"
fi

# Some files cannot be automatically downloaded, here I open the relevant website for manual download:
open https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html

