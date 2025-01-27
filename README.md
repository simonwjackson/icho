<h3 align="center">
    <img src="./.github/assets/icho.jpg" width="300px"/>
</h3>
<h1 align="center">
    icho | A bespoke neovim workspace. Powered by <a href="https://neovim.io/doc/user/lua.html">lua</a> and <a href="https://nixos.org">nix</a>.
</h1>

<div align="center">
    <img alt="Static Badge" src="https://img.shields.io/badge/nixpkgs-unstable-d2a8ff?style=for-the-badge&logo=NixOS&logoColor=cba6f7&labelColor=161B22">
    <img alt="Static Badge" src="https://img.shields.io/badge/State-Forever_WIP-ff7b72?style=for-the-badge&logo=fireship&logoColor=ff7b72&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/pulse">
      <img alt="Last commit" src="https://img.shields.io/github/last-commit/simonwjackson/icho?style=for-the-badge&logo=github&logoColor=D9E0EE&labelColor=302D41&color=9fdf9f"/>
    </a>
    <img alt="Static Badge" src="https://img.shields.io/badge/Powered_by-Endless_nights-79c0ff?style=for-the-badge&logo=nuke&logoColor=79c0ff&labelColor=161B22">
    <a href="https://github.com/simonwjackson/icho/tree/main/LICENSE">
      <img alt="License" src="https://img.shields.io/badge/License-MIT-907385605422448742?style=for-the-badge&logo=agpl&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41">
    </a>
    <a href="https://www.buymeacoffee.com/simonwjackson">
      <img alt="Buy me a coffee" src="https://img.shields.io/badge/Buy%20me%20a%20coffee-grey?style=for-the-badge&logo=buymeacoffee&logoColor=D9E0EE&label=Sponsor&labelColor=302D41&color=ffff99" />
    </a>
</div>

## Features

* 🌿 ...
* 🦥 ...
* 🏃 ...
*   ...

Welcome to my Neovim configuration crafted for Nix.
Feel free to use it as is or extract pieces to help construct your own unique setup.

> [!IMPORTANT]
> This repo is provided as-is and is primarily developed for my own workflows. As such, I offer no guarantees of regular updates or support. Bug fixes and feature enhancements will be implemented at my discretion, and only if they align with my personal use-cases. Feel free to fork the project and customize it to your needs, but please understand my involvement in further development will be intermittent.

## Usage

```{nix}
{
    inputs.icho.url = "github:simonwjackson/icho";
}
```

To utilize this configuration, clone the repo and run the following command from the directory:

```
nix run .#
```

or

```
nix run github:simonwjackson/icho
```

## Plugins

This configuration includes a variety of plugins.

<!-- TODO: Add all plugins -->

## Plugin Updates

#### all

```shell
nix flake update
```

## Repository Structure

<!-- TODO: Add repo structure -->

## Language Support

## License

> The files and scripts in this repository are licensed under the MIT License, which is a very
> permissive license allowing you to use, modify, copy, distribute, sell, give away, etc. the software.
> In other words, do what you want with it. The only requirement with the MIT License is that the license
> and copyright notice must be provided with the software.
