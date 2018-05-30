# The Brewfile handles Homebrew-based app and library installs, but there may
# still be updates and installables in the Mac App Store. There's a nifty
# command line interface to it that we can use to just install everything (like
# OS and iTunes updates), so yeah, let's do that.

echo "› softwareupdate -i -a"
softwareupdate -i -a
