{lib, ...}: {
  plugins.fidget = {
    enable = true;
    settings = {
      notification = {
        window = {
          winblend = 0;
        };
      };
      progress = {
        display = {
          done_icon = "";
          done_ttl = 7;
          format_message = lib.nixvim.mkRaw "function(msg)\n  if string.find(msg.title, \"Indexing\") then\n    return nil -- Ignore \"Indexing...\" progress messages\n  end\n  if msg.message then\n    return msg.message\n  else\n    return msg.done and \"Completed\" or \"In progress...\"\n  end\nend\n";
        };
      };
      text = {
        spinner = "dots";
      };
    };
  };
  plugins.flash.enable = true;

  keymaps = [
    {
      key = "s";
      mode = [
        "n"
        "x"
        "o"
      ];
      action = lib.nixvim.mkRaw ''function() require("flash").jump() end'';
      options.desc = "Flash";
    }
  ];
}
