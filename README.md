
# vim-pkgsync

The minimalist plugin manager for Vim/ Neovim using `+packages` feature.
vim-pkgsync provides installing and updating plugins only.
This plugin does not provide any event trigger of those.

## Usage

1. Clone this plugin and add it to runtimepath.
2. Create `~/pkgsync.json` that is a setting file in this plugin.
The following is an example:

```
{
    "packpath" : "~/vim",
    "plugins" : {
        "start" : {
            "bluz71" : ["vim-moonfly-colors"],
            "cocopon" : ["vaffle.vim"],
        },
        "opt" : {
             "rbtnn" : [
                "vim-pkgsync",
                "vim-ambiwidth",
             }
        }
    }
}
```

* The `packpath` key is at where plugins are installed and updated.
* The `plugins/start/{username}` key is {username}'s plugins that you want to install and update as a start plugin of `+packages` feature.
* The `plugins/opt/{username}` key is {username}'s plugins that you want to install and update as a opt plugin of `+packages` feature.

3. Execute `:PkgSync` in your Vim/Neovim. And then will install and update plugins at the `packpath` in `~/pkgsync.json`.
