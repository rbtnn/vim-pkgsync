
# vim-pkgsync

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![](https://github.com/rbtnn/vim-pkgsync/workflows/ubuntu/badge.svg)](https://github.com/rbtnn/vim-pkgsync/actions/workflows/ubuntu.yml)
[![](https://github.com/rbtnn/vim-pkgsync/workflows/windows/badge.svg)](https://github.com/rbtnn/vim-pkgsync/actions/workflows/windows.yml)

The minimalist plugin manager for Vim/Neovim using `+packages` feature.
vim-pkgsync provides `:PkgSync` command for Vim and `vimpkgsync` command for Terminal that have the same interface.

![pkgsync](https://user-images.githubusercontent.com/1595779/165096296-44af0deb-e5bb-4ac6-817d-25e462fad376.gif)



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

### vimpkgsync init [{packpath}]
At first, you must run this command for initialization of this plugin manager.
If {packpath} is specified, this plugin manager initializes with {packpath} as the packpath.
If {packpath} is not specified, the default value of {packpath} is `~/vim`.

### vimpkgsync list
Show your managed Vim plugin list.

### vimpkgsync update
Update your Vim plugins.

### vimpkgsync install [opt] [branch={branch-name}] user/plugin
If `opt` is not specified, install `user/plugin` from GitHub as a start Vim plugin of the packages feature.
If `opt` is specified, install `user/plugin` from GitHub as an opt Vim plugin of the packages feature.
If `branch={branch-name}` is specified, install the {branch-name} branch of `user/plugin`.

### vimpkgsync uninstall [opt] user/plugin
If `opt` is not specified, uninstall `user/plugin` from start Vim plugins in the packpath.
If `opt` is specified, uninstall `user/plugin` from opt Vim plugins in the packpath.

### vimpkgsync clean
Uninstall unmanaged Vim plugins in the packpath.

### vimpkgsync [help]
Show the help.

