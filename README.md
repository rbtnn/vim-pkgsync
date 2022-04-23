
# vim-pkgsync

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The minimalist plugin manager for Vim/ Neovim using `+packages` feature.
vim-pkgsync provides `:PkgSync` command for Vim and `vimpkgsync` command for Terminal.

## Setup

1. Clone this repository.
```
$git clone --depth 1 https://github.com/rbtnn/vim-pkgsync.git
```

2. Add it to `&runtimepath`. The following is a minimal example of .vimrc:

```
set packpath+=~/vim
set runtimepath+=~/vim-pkgsync
filetype plugin indent on
syntax enable
```

3. If you want to use `vimpkgsync` command in Terminal, Add `/path/to/vim-pkgsync/bin` to PATH environment.
And if you are using MacOS or Linux, execute `chmod 755 /path/to/vim-pkgsync/bin/vimpkgsync`.

## Usage

`:PkgSync` command in Vim and `vimpkgsync` command in Terminal have the same interface.

### vimpkgsync init
At first, you must run this command for initialization of this plugin manager.

### vimpkgsync list
Show your installing Vim plugin list.

### vimpkgsync update
Update your Vim plugins.

### vimpkgsync install user/plugin
Install `user/plugin` from GitHub as a start Vim plugin of the packages feature.

### vimpkgsync install opt user/plugin
Install `user/plugin` from GitHub as a opt Vim plugin of the packages feature.

### vimpkgsync uninstall user/plugin
Uninstall `user/plugin` from start Vim plugins in the packpath.

### vimpkgsync uninstall opt user/plugin
Uninstall `user/plugin` from opt Vim plugins in the packpath.

### vimpkgsync clean
Uninstall unmanaged Vim plugins in the packpath.

