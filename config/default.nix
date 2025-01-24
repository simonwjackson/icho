{
  # Import all your configuration modules here
  imports = [
    ./ai

    ./markview.nix
    ./bufferline.nix
    ./dadbod.nix
    ./which-key.nix
    ./toggleterm.nix
    ./telescope.nix
  ];

  colorschemes.catppuccin = {
    enable = true;
    autoLoad = true;
    settings = {
      flavour = "frappe";
    };
  };
}
