{pkgs, ...}: {
  plugins = {
    avante = {
      enable = true;
      autoLoad = true;
    };
  };

  extraPlugins = with pkgs; [
  ];

  extraConfigLua = ''
  '';
}
