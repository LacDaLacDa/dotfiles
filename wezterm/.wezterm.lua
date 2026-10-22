local wezterm = require 'wezterm'
local mux = wezterm.mux
local action = wezterm.action

local config = wezterm.config_builder()

config.term = "xterm-256color"

config.window_background_opacity = 0.9
config.win32_system_backdrop = "Acrylic"
config.macos_window_background_blur = 30

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right"
}

local function split_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if pane:get_user_vars().IS_NVIM == "true" then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
			end
		end),
	}
end

config.font = wezterm.font('JetBrains Mono')
config.font_size = 10

config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = true

config.window_frame = {
	font_size = 13.0
}
config.window_padding = {
	top = 10,
	bottom = 10,
	left = 10,
	right = 10
}

-- open full size when startup
wezterm.on('gui-startup', function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- leader key
config.leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 }

config.keys = {
	-- split pane
	{
		key = "-",
		mods = "LEADER",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "=",
		mods = "LEADER",
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- resize pane
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = action.AdjustPaneSize({ "Up", 5 }),
	},
	-- toggle focus to pane
	{
		key = "m",
		mods = "LEADER",
		action = action.TogglePaneZoomState,
	},
	-- create new tab and travel through it
	{
		key = "c",
		mods = "LEADER",
		action = action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "p",
		mods = "LEADER",
		action = action.ActivateTabRelative(-1),
	},
	{
		key = "n",
		mods = "LEADER",
		action = action.ActivateTabRelative(1),
	},
	-- activate vi mode (allow copy)
	{
		key = "[",
		mods = "LEADER",
		action = action.ActivateCopyMode,
	},
	-- navigate between pane
	split_nav("h"),
	split_nav("j"),
	split_nav("k"),
	split_nav("l"),
}

-- setting pwsh as default shell
config.default_prog = { 'pwsh.exe', '-NoLogo' }

-- hot reload config
config.automatically_reload_config = true

-- Finally, return the configuration to wezterm:
return config
