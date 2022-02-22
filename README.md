
# vim-pkgsync

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

The minimalist plugin manager for Vim/ Neovim using `+packages` feature.
vim-pkgsync provides only installing and updating plugins. Other features will be not improved.

## Usage

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

3. Create `~/pkgsync.json` that is a setting file of this plugin.
The following is an example:
```
{
    "packpath" : "~/vim",
    "plugins" : {
        "start" : {
            "bluz71" : ["vim-moonfly-colors"],
            "cocopon" : ["vaffle.vim"]
        },
        "opt" : {
             "rbtnn" : [
                "vim-pkgsync",
                "vim-ambiwidth"
             }
        }
    }
}
```

* The `packpath` is specified at where plugins are installed. `&packpath` needs to contain it.
* The `plugins/start/{username}` is specified {username}'s plugins that you want to install as a start plugin of `+packages` feature.
* The `plugins/opt/{username}` is specified {username}'s plugins that you want to install as a opt plugin of `+packages` feature.

4. Execute `:PkgSync` in your Vim/Neovim. And then will install and update the plugins at the `packpath` in `~/pkgsync.json`.
If you execute `:PkgSync!`, unmanaged plugins in the `packpath` will be deleted.

![](https://raw.githubusercontent.com/rbtnn/vim-pkgsync/master/pkgsync.gif)

