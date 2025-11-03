-- # ── Base ──────────────────────────────────────────────────────────────
local wezterm = require("wezterm")
local is_windows = wezterm.target_triple:find("windows")

config = wezterm.config_builder()
config.automatically_reload_config = true

if is_windows then
	config.default_prog = { "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-NoLogo" }
end

-- # ── Window frame configuration ────────────────────────────────────────
config.window_padding = {
	left = 0,
	right = 0,
    top = 0,
	bottom = 0,
}

if not is_windows then
	config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
end

config.window_close_confirmation = "NeverPrompt"

config.initial_rows = 40
config.initial_cols = 120

-- # ── Style and color ────────────────────────────────────────────────────
config.color_scheme = "GitHub Dark"

local schemes = wezterm.color.get_builtin_schemes()
local scheme = schemes[config.color_scheme]

-- # ── Font configuration ─────────────────────────────────────────────────
config.font = is_windows and wezterm.font("Fira Code", {
	weight = "Bold",
}) or wezterm.font("FiraCode Nerd font", {
	weight = "Bold",
})

config.font_size = is_windows and 12 or 14

-- # ── Tab bar configuration ──────────────────────────────────────────────
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.tab_and_split_indices_are_zero_based = true

local base_color = wezterm.color.parse(scheme.background)
local tabbar_background = base_color:lighten(0.08)
local active_tab_background = base_color:lighten(0.3)
local inactive_tab_background = base_color:lighten(0.1)

config.colors = {
	tab_bar = {
		background = tabbar_background,

		active_tab = {
			bg_color = active_tab_background,
			fg_color = scheme.foreground,
			intensity = "Bold",
			italic = true,
		},

		inactive_tab = {
			bg_color = inactive_tab_background,
			fg_color = scheme.foreground,
		},

		new_tab = {
			bg_color = tabbar_background,
			fg_color = scheme.foreground,
		},
	},
}

-- # ── Status bar configuration ───────────────────────────────────────────
local function active_tab_label(window)
	local tab = window:active_tab()
	if not tab then
		return ""
	end

	local idx = tab:tab_id()
	local pane = tab:active_pane()
	local title = pane and pane:get_title() or ""

	if title == "" and pane then
		local proc = pane:get_foreground_process_name()
		if proc and proc ~= "" then
			title = wezterm.basename(proc)
		end
		if (not title or title == "") and pane:get_current_working_dir() then
			title = tostring(pane:get_current_working_dir()):gsub("^.+/", "")
		end
	end

	return string.format("%d: %s", idx, title)
end

local function segments_for_right_status(window)
	return { active_tab_label(window), wezterm.strftime("%a %b %-d %H:%M"), wezterm.hostname() }
end

wezterm.on("update-status", function(window, _)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local segments = segments_for_right_status(window)

	local bg = wezterm.color.parse(scheme.background)
	local fg = scheme.foreground

	local gradient_to = bg
	local gradient_from = gradient_to:lighten(0.2)

	local gradient = wezterm.color.gradient({
		orientation = "Horizontal",
		colors = { gradient_from, gradient_to },
	}, #segments)

	local elements = {}
	for i, seg in ipairs(segments) do
		local is_first = i == 1

		if is_first then
			table.insert(elements, {
				Background = {
					Color = tabbar_background,
				},
			})
		end
		table.insert(elements, {
			Foreground = {
				Color = gradient[i],
			},
		})
		table.insert(elements, {
			Text = SOLID_LEFT_ARROW,
		})

		table.insert(elements, {
			Foreground = {
				Color = fg,
			},
		})
		table.insert(elements, {
			Background = {
				Color = gradient[i],
			},
		})
		table.insert(elements, {
			Text = " " .. seg .. " ",
		})
	end

	window:set_right_status(wezterm.format(elements))
end)

-- # ── Key bindings ───────────────────────────────────────────────────────
local mod_window = is_windows and "ALT" or "CMD"
local mod = is_windows and "CTRL" or "CMD"

config.keys = {
	{
		mods = mod,
		key = ".",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		mods = mod,
		key = "-",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		mods = mod_window,
		key = "LeftArrow",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = mod_window,
		key = "DownArrow",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = mod_window,
		key = "UpArrow",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = mod_window,
		key = "RightArrow",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "w",
		mods = mod,
		action = wezterm.action_callback(function(window, pane)
			local mw = window:mux_window()
			local tabs = mw:tabs()

			if #tabs == 1 then
				mw:spawn_tab({})
				window:perform_action(wezterm.action.ActivateTab(0), pane)
			end

			window:perform_action(
				wezterm.action.CloseCurrentTab({
					confirm = false,
				}),
				pane
			)
		end),
	},
}

if is_windows then
	table.insert(config.keys, {
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	})

	table.insert(config.keys, {
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SendKey({
			key = "RightArrow",
			mods = "CTRL|SHIFT",
		}),
	})

	table.insert(config.keys, {
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SendKey({
			key = "LeftArrow",
			mods = "CTRL|SHIFT",
		}),
	})
else
	table.insert(config.keys, {
		key = "a",
		mods = "CMD",
		action = wezterm.action.SendString("\x1b[999;7~"),
	})

	table.insert(config.keys, {
		key = "r",
		mods = "CMD",
		action = wezterm.action.SendString("\x12"), -- For Command+R
	})

	table.insert(config.keys, {
		key = "c",
		mods = "CMD",
		action = wezterm.action_callback(function(window, pane)
			local sel = window:get_selection_text_for_pane(pane)
			wezterm.log_error(sel)

			if sel and #sel > 0 then
				window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
			else
				window:perform_action(wezterm.action.SendString("\x1b[999;5~"), pane)
			end
		end),
	})
end

for i = 0, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = mod,
		action = wezterm.action.ActivateTab(i),
	})
end

return config
