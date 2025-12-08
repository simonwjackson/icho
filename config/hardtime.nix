{
  plugins.hardtime = {
    enable = true;
    settings = {
      # Show hints for better motions
      hint = true;
      # Max count before key is disabled
      max_count = 3;
      # Disable hjkl spam
      disabled_keys = {
        "<Up>" = [ "n" "x" ];
        "<Down>" = [ "n" "x" ];
        "<Left>" = [ "n" "x" ];
        "<Right>" = [ "n" "x" ];
      };
      # Restrict these keys after repeated use
      restricted_keys = {
        "h" = [ "n" "x" ];
        "j" = [ "n" "x" ];
        "k" = [ "n" "x" ];
        "l" = [ "n" "x" ];
      };
    };
  };
}
