{...}: {
  plugins = {
    neo-tree = {
      enable = true;
      settings = {
        log_to_file = false;
        log_level = "error";
        filesystem = {
          hijack_netrw_behavior = "disabled";
        };
      };
    };
  };
}
