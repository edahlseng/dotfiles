# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Run ./set-defaults.sh and you'll be good to go.

# Use AirDrop over every interface. srsly this should be a default
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Set the Finder prefs for showing hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# Hide Safari's bookmark bar
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Set up Safari for development
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Set up Terminal
terminalUpdated="false"
if [[ $(defaults read com.apple.Terminal "Default Window Settings") != "Man Page" ]]; then
	defaults write com.apple.Terminal "Default Window Settings" "Man Page"
	terminalUpdated="true"
fi
if [[ $(defaults read com.apple.Terminal "Startup Window Settings") != "Man Page" ]]; then
	defaults write com.apple.Terminal "Startup Window Settings" "Man Page"
	terminalUpdated="true"
fi

if [[ "${terminalUpdated}" == "true" ]]; then
	echo "Terminal must be restarted for setting changes to be applied"
fi

# Set up global domain
defaults write -globalDomain com.apple.mouse.scaling 3
defaults write -globalDomain com.apple.scrollwheel.scaling 1
defaults write -globalDomain com.apple.trackpad.forceClick 1
defaults write -globalDomain com.apple.trackpad.scaling 2.5
