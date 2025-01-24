{
  # Import all your configuration modules here
  imports = [
    # UI
    ./markview.nix
    ./bufferline.nix
    ./dadbod.nix

    ./supermaven.nix
    ./avante.nix
  ];

  colorschemes.catppuccin = {
    enable = true;
    autoLoad = true;
    settings = {
      flavour = "frappe";
    };
  };
}
