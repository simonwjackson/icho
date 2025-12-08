{
  plugins.gitsigns = {
    enable = true;
    settings = {
      signcolumn = true;
      signs = {
        add.text = "▎";
        change.text = "▎";
        delete.text = "▁";
        topdelete.text = "▔";
        changedelete.text = "▎";
        untracked.text = "▎";
      };
      signs_staged = {
        add.text = "▎";
        change.text = "▎";
        delete.text = "▁";
        topdelete.text = "▔";
        changedelete.text = "▎";
      };
      current_line_blame = false;
      current_line_blame_opts = {
        virt_text = true;
        virt_text_pos = "eol";
        delay = 300;
      };
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>";
    };
  };
}
