-- Python configuration for LazyVim
-- Auto-detect Python interpreter from virtual environment

local function get_python_path(workspace)
  -- Check for virtual environment in workspace
  local venv_paths = {
    workspace .. "/.venv/bin/python",
    workspace .. "/venv/bin/python",
    workspace .. "/.env/bin/python",
    workspace .. "/env/bin/python",
  }

  for _, path in ipairs(venv_paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Check VIRTUAL_ENV environment variable
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    local venv_python = venv .. "/bin/python"
    if vim.fn.executable(venv_python) == 1 then
      return venv_python
    end
  end

  -- Fall back to system Python
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return {
  -- Configure Pyright to use detected Python interpreter
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          before_init = function(_, config)
            local workspace = config.root_dir
            if workspace then
              config.settings.python.pythonPath = get_python_path(workspace)
            end
          end,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },
      },
    },
  },

  -- Mason: ensure Python tools are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",
        "ruff",
        "black",
        "debugpy",
      })
    end,
  },

  -- venv-selector: select Python interpreter
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    branch = "regexp",
    cmd = "VenvSelect",
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
    },
  },
}
