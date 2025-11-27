{...}: {
  plugins = {
    todo-comments.enable = true;
    typescript-tools.enable = true;
    # tailwind-tools is deprecated (upstream archived)
    scope.enable = true;
    refactoring = {
      enable = true;
      enableTelescope = true;
    };
    qmk = {
      enable = true;
      settings = {
        name = "zmk";
        layout = [
          "x x"
          "x^x"
        ];
      };
    };
  };
}
