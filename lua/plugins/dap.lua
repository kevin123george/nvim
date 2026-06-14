return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,          desc = "Continue / Start" },
      { "<leader>ds", function() require("dap").step_over() end,         desc = "Step Over" },
      { "<leader>di", function() require("dap").step_into() end,         desc = "Step Into" },
      { "<leader>do", function() require("dap").step_out() end,          desc = "Step Out" },
      { "<leader>dt", function() require("dap").terminate() end,         desc = "Terminate" },
      { "<leader>dr", function() require("dap").repl.open() end,         desc = "Open REPL" },
      { "<leader>dB", function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end, desc = "Conditional Breakpoint" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", function() require("dapui").eval() end,   desc = "Evaluate Expression", mode = { "n", "v" } },
    },
  },
  -- remove the noice binding that conflicts with <leader>d
  {
    "folke/noice.nvim",
    keys = {
      { "<leader>db", false },
    },
  },
}
