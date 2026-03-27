{ ... }:
{
  programs.nixvim.keymaps = [
    # ── Insert mode ──────────────────────────────────────────────
    {
      mode = "i";
      key = "jk";
      action = "<Esc>";
      options.desc = "Exit Insert Mode";
    }

    # ── Save / Quit ──────────────────────────────────────────────
    {
      mode = [
        "i"
        "x"
        "n"
        "s"
      ];
      key = "<C-s>";
      action = "<cmd>w<cr><Esc>";
      options.desc = "Save file";
    }
    {
      mode = "n";
      key = "<leader>w";
      action = "<C-w>";
      options = {
        desc = "Windows";
        remap = true;
      };
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa<cr>";
      options.desc = "Quit all";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>qa!<cr>";
      options.desc = "Force quit all";
    }
    {
      mode = "n";
      key = "<leader>fn";
      action = "<cmd>enew<cr>";
      options.desc = "New file";
    }

    # ── Better up/down (respects word wrap) ──────────────────────
    {
      mode = [
        "n"
        "x"
      ];
      key = "j";
      action = "v:count == 0 ? 'gj' : 'j'";
      options = {
        desc = "Down";
        expr = true;
        silent = true;
      };
    }
    {
      mode = [
        "n"
        "x"
      ];
      key = "k";
      action = "v:count == 0 ? 'gk' : 'k'";
      options = {
        desc = "Up";
        expr = true;
        silent = true;
      };
    }

    # ── Window navigation ────────────────────────────────────────
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Go to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Go to lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Go to upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Go to right window";
    }

    # ── Window splits ────────────────────────────────────────────
    {
      mode = "n";
      key = "<leader>-";
      action = "<cmd>split<cr>";
      options.desc = "Split below";
    }
    {
      mode = "n";
      key = "<leader>|";
      action = "<cmd>vsplit<cr>";
      options.desc = "Split right";
    }

    # ── Resize windows ───────────────────────────────────────────
    {
      mode = "n";
      key = "<C-Up>";
      action = "<cmd>resize +2<cr>";
      options.desc = "Increase window height";
    }
    {
      mode = "n";
      key = "<C-Down>";
      action = "<cmd>resize -2<cr>";
      options.desc = "Decrease window height";
    }
    {
      mode = "n";
      key = "<C-Left>";
      action = "<cmd>vertical resize -2<cr>";
      options.desc = "Decrease window width";
    }
    {
      mode = "n";
      key = "<C-Right>";
      action = "<cmd>vertical resize +2<cr>";
      options.desc = "Increase window width";
    }

    # ── Buffer navigation ────────────────────────────────────────
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<cr>";
      options.desc = "Prev buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "<leader>bb";
      action = "<cmd>e #<cr>";
      options.desc = "Switch to other buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>bdelete<cr>";
      options.desc = "Delete buffer";
    }
    {
      mode = "n";
      key = "<leader>bD";
      action = "<cmd>%bdelete<cr>";
      options.desc = "Delete all buffers";
    }

    # ── Tab navigation ───────────────────────────────────────────
    {
      mode = "n";
      key = "<leader><tab>l";
      action = "<cmd>tablast<cr>";
      options.desc = "Last tab";
    }
    {
      mode = "n";
      key = "<leader><tab>f";
      action = "<cmd>tabfirst<cr>";
      options.desc = "First tab";
    }
    {
      mode = "n";
      key = "<leader><tab><tab>";
      action = "<cmd>tabnew<cr>";
      options.desc = "New tab";
    }
    {
      mode = "n";
      key = "<leader><tab>]";
      action = "<cmd>tabnext<cr>";
      options.desc = "Next tab";
    }
    {
      mode = "n";
      key = "<leader><tab>d";
      action = "<cmd>tabclose<cr>";
      options.desc = "Close tab";
    }
    {
      mode = "n";
      key = "<leader><tab>[";
      action = "<cmd>tabprevious<cr>";
      options.desc = "Previous tab";
    }

    # ── Move lines ───────────────────────────────────────────────
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>m .+1<cr>==";
      options.desc = "Move line down";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>m .-2<cr>==";
      options.desc = "Move line up";
    }
    {
      mode = "i";
      key = "<A-j>";
      action = "<Esc><cmd>m .+1<cr>==gi";
      options.desc = "Move line down";
    }
    {
      mode = "i";
      key = "<A-k>";
      action = "<Esc><cmd>m .-2<cr>==gi";
      options.desc = "Move line up";
    }
    {
      mode = "v";
      key = "<A-j>";
      action = ":m '>+1<cr>gv=gv";
      options.desc = "Move selection down";
    }
    {
      mode = "v";
      key = "<A-k>";
      action = ":m '<-2<cr>gv=gv";
      options.desc = "Move selection up";
    }

    # ── Better indenting (stay in visual mode) ───────────────────
    {
      mode = "v";
      key = "<";
      action = "<gv";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
    }

    # ── Better paste (don't yank replaced text) ──────────────────
    {
      mode = "v";
      key = "p";
      action = ''"_dP'';
      options.desc = "Paste without yanking";
    }

    # ── Clear search ─────────────────────────────────────────────
    {
      mode = [
        "i"
        "n"
      ];
      key = "<Esc>";
      action = "<cmd>noh<cr><Esc>";
      options.desc = "Escape and clear hlsearch";
    }

    # ── Terminal ─────────────────────────────────────────────────
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }
    {
      mode = "t";
      key = "<C-h>";
      action = "<cmd>wincmd h<cr>";
      options.desc = "Go to left window";
    }
    {
      mode = "t";
      key = "<C-j>";
      action = "<cmd>wincmd j<cr>";
      options.desc = "Go to lower window";
    }
    {
      mode = "t";
      key = "<C-k>";
      action = "<cmd>wincmd k<cr>";
      options.desc = "Go to upper window";
    }
    {
      mode = "t";
      key = "<C-l>";
      action = "<cmd>wincmd l<cr>";
      options.desc = "Go to right window";
    }

    # ── Toggles ──────────────────────────────────────────────────
    {
      mode = "n";
      key = "<leader>uw";
      action = "<cmd>set wrap!<cr>";
      options.desc = "Toggle word wrap";
    }
    {
      mode = "n";
      key = "<leader>ul";
      action = "<cmd>set relativenumber!<cr>";
      options.desc = "Toggle relative line numbers";
    }
    {
      mode = "n";
      key = "<leader>us";
      action = "<cmd>set spell!<cr>";
      options.desc = "Toggle spelling";
    }

    # ── Code (formatting handled by conform, LSP keymaps in lsp.nix)
    {
      mode = [
        "n"
        "v"
      ];
      key = "<leader>cf";
      action.__raw = ''function() require("conform").format({ async = true }) end'';
      options.desc = "Format";
    }

    # ── Quickfix navigation ──────────────────────────────────────
    {
      mode = "n";
      key = "[q";
      action = "<cmd>cprev<cr>";
      options.desc = "Prev quickfix";
    }
    {
      mode = "n";
      key = "]q";
      action = "<cmd>cnext<cr>";
      options.desc = "Next quickfix";
    }

    # ── Add blank lines ──────────────────────────────────────────
    {
      mode = "n";
      key = "]<space>";
      action = "o<Esc>k";
      options.desc = "Add blank line below";
    }
    {
      mode = "n";
      key = "[<space>";
      action = "O<Esc>j";
      options.desc = "Add blank line above";
    }

    # ── Select all ───────────────────────────────────────────────
    {
      mode = "n";
      key = "<C-a>";
      action = "ggVG";
      options.desc = "Select all";
    }

    # ── Better search centering ──────────────────────────────────
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Next search result (centered)";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Prev search result (centered)";
    }
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options.desc = "Scroll down (centered)";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Scroll up (centered)";
    }

    # ── Join lines without moving cursor ─────────────────────────
    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options.desc = "Join lines (keep cursor)";
    }
  ];
}
