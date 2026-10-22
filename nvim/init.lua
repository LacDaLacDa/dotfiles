-- References: https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua

-- set <space> as the leader key
-- must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-------------------------------------------------------------------------------
--
-- preferences
--
-------------------------------------------------------------------------------
-- never ever folding
vim.opt.foldenable = false
vim.opt.foldmethod = "manual"
vim.opt.foldlevelstart = 99
-- keep more context on screen while scrolling
vim.opt.scrolloff = 2
-- never show me line breaks if they're not there
vim.opt.wrap = true
-- always draw sign column. prevents buffer moving when adding/deleting sign
vim.opt.signcolumn = "yes"
-- sweet sweet relative line numbers
vim.opt.relativenumber = true
-- and show the absolute line number for the current line
vim.opt.number = true
-- keep current content top + left when splitting
vim.opt.splitright = true
vim.opt.splitbelow = true
-- infinite undo!
-- NOTE: ends up in ~/.local/state/nvim/undo/
vim.opt.undofile = true
--" Decent wildmenu
-- in completion, when there is more than one match,
-- list all matches, and only complete to longest common match
vim.opt.wildmode = "list:longest"
-- when opening a file with a command (like :e),
-- don't suggest files like there:
vim.opt.wildignore = ".hg,.svn,*~,*.png,*.jpg,*.gif,*.min.js,*.swp,*.o,vendor,dist,_site"
-- tabs: go big or go home
vim.opt.shiftwidth = 8
vim.opt.softtabstop = 8
vim.opt.tabstop = 8
vim.opt.expandtab = false
-- case-insensitive search/replace
vim.opt.ignorecase = true
-- unless uppercase in search term
vim.opt.smartcase = true
-- never ever make my terminal beep
vim.opt.vb = true
-- more useful diffs (nvim -d)
--- by ignoring whitespace
vim.opt.diffopt:append("iwhite")
--- and using a smarter algorithm
--- https://vimways.org/2018/the-power-of-diff/
--- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
--- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.diffopt:append("indent-heuristic")
-- show a column at 80 characters as a guide for long lines
vim.opt.colorcolumn = "80"
-- show more hidden characters
-- also, show tabs nicer
vim.opt.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"
-- enable true color support
vim.opt.termguicolors = true
-- enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"
-- don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- sync clipboard between OS and Neovim
-- see `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"
-- enable break indent
vim.opt.breakindent = true
-- decrease update time
vim.opt.updatetime = 250
-- decrease mapped sequence wait time
-- displays which-key popup sooner
vim.opt.timeoutlen = 300
-- sets how neovim will display certain whitespace characters in the editor
-- See `:help 'list'`
-- and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", lead = "·", trail = "·", nbsp = "␣" }
-- preview substitutions live, as you type!
vim.opt.inccommand = "split"
-- show which line your cursor is on
vim.opt.cursorline = true
-- set highlight on search, but clear on pression <Esc> in normal mode
vim.opt.hlsearch = true

-------------------------------------------------------------------------------
--
-- hotkeys
--
-------------------------------------------------------------------------------
-- clear search highlights with <Esc>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-------------------------------------------------------------------------------
--
-- configuring diagnostics
--
-------------------------------------------------------------------------------
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = true, -- show inline diagnostics
	virtual_lines = false,
})

-------------------------------------------------------------------------------
--
-- autocommands
--
-------------------------------------------------------------------------------
-- highlight trailing whitespace
vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "LightRed" })
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	command = [[
		syntax clear TrailingWhitespace |
		syntax match TrailingWhitespace "\_s\+$"
	]],
})
-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = "silent! lua vim.highlight.on_yank({ timeout = 500 })",
})
-- shorter columns in text because it reads better that way
local text = vim.api.nvim_create_augroup("text", { clear = true })
for _, pat in ipairs({ "text", "markdown", "mail", "gitcommit" }) do
	vim.api.nvim_create_autocmd("Filetype", {
		pattern = pat,
		group = text,
		command = "setlocal spell tw=72 colorcolumn=73",
	})
end

-------------------------------------------------------------------------------
--
-- plugin configuration
--
-------------------------------------------------------------------------------
-- first, grab the manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- then, setup!
require("lazy").setup({
	-- main color scheme
	{
		"wincent/base16-nvim",
		lazy = false, -- load at start
		priority = 1000, -- load first
		config = function()
			vim.cmd([[colorscheme gruvbox-dark-hard]])
			vim.o.background = "dark"
			vim.cmd([[hi Normal ctermbg=NONE]])
			-- Less visible window separator
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = 1250067 })
			-- Make comments more prominent -- they are important.
			local bools = vim.api.nvim_get_hl(0, { name = "Boolean" })
			vim.api.nvim_set_hl(0, "Comment", bools)
			-- Make it clearly visible which argument we're at.
			local marked = vim.api.nvim_get_hl(0, { name = "PMenu" })
			vim.api.nvim_set_hl(
				0,
				"LspSignatureActiveParameter",
				{ fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true }
			)
			-- XXX
			-- Would be nice to customize the highlighting of warnings and the like to make
			-- them less glaring. But alas
			-- https://github.com/nvim-lua/lsp_extensions.nvim/issues/21
			-- call Base16hi("CocHintSign", g:base16_gui03, "", g:base16_cterm03, "", "", "")
		end,
	},
	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			-- stylua: ignore start
			local languages = {
				"bash", "c", "lua", "go", "python", "c_sharp", "hcl",
				"rust", "typescript", "javascript", "json", "yaml"
			}
			-- stylua: ignore end

			require("nvim-treesitter").install(languages)

			-- treesitter features for installed languages must be enabled manually
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "*" },
				callback = function()
					local filetype = vim.bo.filetype
					if filetype and filetype ~= "" then
						local success = pcall(function()
							vim.treesitter.start()
						end)
						if not success then
							return
						end
					end
				end,
			})
		end,
	},
	-- nice bar at the bottom
	{
		"itchyny/lightline.vim",
		lazy = false, -- also load at start since it's UI
		config = function()
			-- no need to also show mode in cmd line when we have bar
			vim.o.showmode = false
			vim.g.lightline = {
				active = {
					left = {
						{ "mode", "paste" },
						{ "readonly", "filename", "modified" },
					},
					right = {
						{ "lineinfo" },
						{ "percent" },
						{ "fileencoding", "filetype" },
					},
				},
				component_function = {
					filename = "LightlineFilename",
				},
			}
			function LightlineFilenameInLua(opts)
				if vim.fn.expand("%:t") == "" then
					return "[No Name]"
				else
					return vim.fn.getreg("%")
				end
			end

			-- https://github.com/itchyny/lightline.vim/issues/657
			vim.api.nvim_exec(
				[[
				function! g:LightlineFilename()
					return v:lua.LightlineFilenameInLua()
				endfunction
				]],
				true
			)
		end,
	},
	-- better %
	{
		"andymass/vim-matchup",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	-- auto-cd to root of git project
	-- 'airblade/vim-rooter'
	{
		"notjedi/nvim-rooter.lua",
		config = function()
			require("nvim-rooter").setup()
		end,
	},
	-- fzf support for ^p
	{
		"ibhagwan/fzf-lua",
		config = function()
			-- stop putting a giant window over my editor
			require("fzf-lua").setup({
				winopts = {
					split = "belowright 10new",
					preview = {
						hidden = true,
					},
				},
				files = {
					-- file icons are distracting
					file_icons = false,
					-- git icons are nice
					git_icons = true,
					-- but don't mess up my anchored search
					_fzf_nth_devicons = true,
				},
				buffers = {
					file_icons = false,
					git_icons = true,
					-- no nth_devicons as we'll do that
					-- manually since we also use
					-- with-nth
				},
				fzf_opts = {
					-- no reverse view
					["--layout"] = "default",
				},
			})
			-- when using <leader>ff for quick file open, pass the file list through
			--
			--   https://github.com/jonhoo/proximity-sort
			--
			-- to prefer files closer to the current file.
			vim.keymap.set("", "<leader>ff", function()
				local opts = {}
				opts.cmd = "fd --color=never --hidden --type f --type l --exclude .git"
				local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
				if base ~= "." then
					-- if there is no current file,
					-- proximity-sort can't do its thing
					-- stylua: ignore start
					opts.cmd = opts.cmd ..
					    (" | proximity-sort %s"):format(vim.fn.shellescape(vim.fn.expand("%")))
					-- stylua: ignore end
				end
				opts.fzf_opts = {
					["--scheme"] = "path",
					["--tiebreak"] = "index",
					["--layout"] = "default",
				}
				require("fzf-lua").files(opts)
			end, { desc = "Find Files" })
			-- use fzf to search buffers as well
			vim.keymap.set("n", "<leader>fb", function()
				require("fzf-lua").buffers({
					-- just include the paths in the fzf bits, and nothing else
					-- https://github.com/ibhagwan/fzf-lua/issues/2230#issuecomment-3164258823
					fzf_opts = {
						["--with-nth"] = "{-3..-2}",
						["--nth"] = "-1",
						["--delimiter"] = "[:\u{2002}]",
						["--header-lines"] = "false",
					},
					header = false,
				})
			end, { desc = "Find Buffers" })
			vim.keymap.set("n", "<leader>fg", function()
				require("fzf-lua").live_grep()
			end, { desc = "Grep Text" })
		end,
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Setup language servers.

			-- Lua
			if vim.fn.executable("lua-language-server") == 1 then
				vim.lsp.config("lua_ls", {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				})
				vim.lsp.enable("lua_ls")
			end

			-- csharp
			if vim.fn.executable("roslyn-language-server") == 1 then
				vim.lsp.enable("roslyn_ls")
			end

			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic Float" })
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to Previous Diagnostic" })
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to Next Diagnostic" })
			vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Send Diagnostics to Location List" })

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					-- stylua: ignore start
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration,
						{ buffer = ev.buf, desc = "Go to Declaration" })
					vim.keymap.set("n", "gd", vim.lsp.buf.definition,
						{ buffer = ev.buf, desc = "Go to Definition" })
					vim.keymap.set("n", "K", vim.lsp.buf.hover,
						{ buffer = ev.buf, desc = "Hover Documentation" })
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation,
						{ buffer = ev.buf, desc = "Go to Implementation" })
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help,
						{ buffer = ev.buf, desc = "Signature Help" })
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder,
						{ buffer = ev.buf, desc = "Add Workspace Folder" })
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder,
						{ buffer = ev.buf, desc = "Remove Workspace Folder" })
					vim.keymap.set("n", "<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, { buffer = ev.buf, desc = "List Workspace Folder" })
					--vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, { buffer = ev.buf, desc = "Go to Declaration" })
					vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename,
						{ buffer = ev.buf, desc = "Rename Symbol" })
					vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action,
						{ buffer = ev.buf, desc = "Code Action" })
					vim.keymap.set("n", "gr", vim.lsp.buf.references,
						{ buffer = ev.buf, desc = "Go to References" })
					-- stylua: ignore end

					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- TODO: find some way to make this only apply to the current line.
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
					end

					-- None of this semantics tokens business.
					-- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
					client.server_capabilities.semanticTokensProvider = nil
				end,
			})
		end,
	},
	-- code-completion
	{
		"saghen/blink.cmp",
		dependencies = {
			"saghen/blink.lib",
			-- optional: provides snippets for the snippet source
			"rafamadriz/friendly-snippets",
		},
		build = function()
			-- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
			-- you can use `gb` in `:Lazy` to rebuild the plugin as needed
			require("blink.cmp").build():pwait()
		end,
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = { preset = "default" },

			-- (Default) Only show the documentation popup when manually triggered
			completion = { documentation = { auto_show = false } },

			-- (Default) list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = { default = { "lsp", "path", "snippets", "buffer" } },

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"`
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "rust" },
		},
	},
	-- formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- formatter
			formatters_by_ft = {
				cs = { "csharpier" },
				json = { "biome" },
				javascript = { "biome" },
				typescript = { "biome" },
				go = { "gofmt" },
				lua = { "stylua" },
			},
			-- set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
		},
	},
	-- inline function signatures
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- Get signatures (and _only_ signatures) when in argument lists.
			require("lsp_signature").setup({
				doc_lines = 0,
				handler_opts = {
					border = "none",
				},
			})
		end,
	},
	{
		"hashivim/vim-terraform",
		ft = { "terraform" },
	},
	-- file pickers
	{
		"stevearc/oil.nvim",
		lazy = false,
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			columns = { "icon" },
			view_options = {
				show_hidden = true,
			},
		},
		keys = {
			{ "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
		},
	},
	-- help remeber the key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>f", group = "[F]ind" },
				{ "<leader>c", group = "[C]ode" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>s", group = "[S]earch", icon = { icon = "", color = "green" } },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	-- auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
})
