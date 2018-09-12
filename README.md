dotfiles
========

Your dotfiles are how you personalize your system. These are mine. [Fork it](https://github.com/edahlseng/dotfiles/fork), remove what you don't use, and build on what you do use.

Setup
--------------------------------------------------------------------------------

Run this:

```sh
git clone https://github.com/edahlseng/dotfiles.git
cd dotfiles
./bin/dot
```

Everything is configured and tweaked within this repository. `bin/dot` will set defaults, symlink the appropriate files to your home directory, and install dependencies.

Whenever changing something within this repository, re-run `dot` to apply the changes. Run `dot` from time to time to keep your environment fresh and up-to-date.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`. `install.sh` is probably next to be tweaked, and is found in `system/`.

Components
-------------------------------------------------------------------------------

Everything's built around topic areas. If you're adding a new area to your forked dotfiles — say, "Java" — you can simply add a `java` directory and put files in there. Anything with an extension of `.zsh` will get automatically included into your shell. Anything with an extension of `.symlink` will get symlinked without extension into `$HOME` when you run `script/bootstrap`.

If you're interested in the philosophy behind why projects like these are awesome, you might want to read [Zach Holman's post on the subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

* **Brewfile**: This is a list of applications for [Homebrew Cask](https://caskroom.github.io) to install
* **bin/**: Anything in `bin/` will get added to your `$PATH` and be made available everywhere.
* **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your environment.
  * **topic/path.zsh**: Any file named `path.zsh` is loaded first and is expected to setup `$PATH` or similar.
  * **topic/completion.zsh**: Any file named `completion.zsh` is loaded last and is expected to setup autocomplete.
* **topic/install.sh**: Any file named `install.sh` is executed when you run `system/install` (which is also run by `dot`). To avoid being loaded automatically, it does not have a `.zsh` extension.
* **\*.symlink**: Any file ending in `*.symlink` gets symlinked into your `$HOME` with a `.` prefix. This is so you can keep all of these files versioned in your dotfiles but still keep those autoloaded files in your home directory. These files get symlinked when you run `system/bootstrap`.

Bugs
--------------------------------------------------------------------------------

I want this to work for everyone; that means when you clone it down it should work for you even though you are on your own system. That said, I do use this as *my* dotfiles, so there's a good chance I may break something if I forget to make a check for a dependency.

If you're brand-new to the project and run into any blockers, please [open an issue](https://github.com/edahlseng/dotfiles/issues) on this repository and I'd love to get it fixed for you!

Thanks
-------------------------------------------------------------------------------

This project was originally forked from [Zach Holman](https://github.com/holman/dotfiles).
