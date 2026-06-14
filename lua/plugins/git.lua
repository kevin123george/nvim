return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "mgierada/lazydocker.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    keys = {
      { "<leader>gd", "<cmd>Lazydocker<cr>", desc = "LazyDocker" },
    },
    opts = {},
  },
}
