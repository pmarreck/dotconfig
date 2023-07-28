local wezterm = require 'wezterm';
local act = wezterm.action;

-- see color schemes with examples at https://wezfurlong.org/wezterm/colorschemes/index.html
local cobalt2 = wezterm.color.get_builtin_schemes()["Cobalt2"];
local embark, _metadata = wezterm.color.load_scheme(wezterm.config_dir .. "/colors/embark.toml");
local current_theme = embark;
-- overrides
current_theme.scrollbar_thumb = "#aaa";
-- overrode the theme text selection colors because they were not distinct enough:
current_theme.selection_fg = 'black';
current_theme.selection_bg = '#fffacd';
-- current_theme.selection_bg = '#ff9950';

-- now with darkmode support!
function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Cobalt Peter'
  else
    return 'Current'
  end
end

local config = {
  check_for_updates = false,
  font = wezterm.font("Berkeley Mono"),
  harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
  initial_rows = 40,
  initial_cols = 100,
  color_schemes = {
    ["Cobalt Peter"] = cobalt2,
    ["Embark"] = embark,
    ["Current"] = current_theme,
  },
  color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
  -- color_scheme = "Current", --"Cobalt Peter",
  font_size = 12.0,
  window_background_opacity = 0.85,
  use_fancy_tab_bar = true,
  hide_tab_bar_if_only_one_tab = true,
  enable_scroll_bar = true,
  scrollback_lines = 10000000,
  window_decorations = "RESIZE",
  use_resize_increments = true,
  visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 150,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 150,
  },
  colors = {
    visual_bell = '#202020',
  },
  -- https://wezfurlong.org/wezterm/config/lua/config/window_frame.html
  window_frame = {
    inactive_titlebar_bg = "#353535",
    active_titlebar_bg = "#2b2042",
    inactive_titlebar_fg = "#cccccc",
    active_titlebar_fg = "#ffffff",
    inactive_titlebar_border_bottom = "#2b2042",
    active_titlebar_border_bottom = "#2b2042",
    button_fg = "#cccccc",
    button_bg = "#2b2042",
    button_hover_fg = "#ffffff",
    button_hover_bg = "#3b3052",
  },
  -- https://wezfurlong.org/wezterm/config/lua/config/window_padding.html
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  -- https://wezfurlong.org/wezterm/config/lua/config/window_close_confirmation.html
  window_close_confirmation = "NeverPrompt",
  -- https://wezfurlong.org/wezterm/config/lua/config/window_decorations.html
  -- window_decorations = "RESIZE",
  -- https://github.com/wez/wezterm/discussions/2426 plus modifications by me
  keys = {
    {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
        local sel = window:get_selection_text_for_pane(pane)
        if (not sel or sel == '') then
          window:perform_action(act.SendKey{ key='c', mods='CTRL' }, pane)
        else
          window:perform_action(act{ CopyTo = 'ClipboardAndPrimarySelection' }, pane)
        end
      end),
    },
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
    { key = 'v', mods = 'SHIFT|CTRL', action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SendKey{ key='v', mods='CTRL' }, pane) end),
    },
    { key = 'V', mods = 'SHIFT|CTRL', action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SendKey{ key='v', mods='CTRL' }, pane) end),
    },
    { key = 'c', mods = 'ALT', action = act.CopyTo 'ClipboardAndPrimarySelection' },
    { key = 'v', mods = 'ALT', action = wezterm.action.PasteFrom 'Clipboard' },
    -- ctrl-backspace does what ctrl-u does, clears an entire input line
    { key = 'Backspace', mods = 'CTRL', action = wezterm.action.SendKey{ key='u', mods='CTRL' }},
    -- search for things that look like git hashes
    {
      key = 'h',
      mods = 'SHIFT|CTRL',
      action = act.Search { Regex = '[a-fA-F0-9]{6,}' },
    },
  },
  key_tables = {
    search_mode = {
      -- { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
      { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
      { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
      { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
      { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
      { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
      { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
      { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
      { key = 'Enter', mods = 'NONE', action = act.Multiple {
          { CopyTo = 'PrimarySelection' },
          { CopyMode = 'Close' },
          { PasteFrom = 'PrimarySelection' },
        },
      },
    }
  }
}

for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
  if gpu.backend == 'Vulkan' then -- and gpu.device_type == 'Integrated' then
    config.webgpu_preferred_adapter = gpu
    config.front_end = 'WebGpu'
    break
  end
end

return config
