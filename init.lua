-- init grid
hs.grid.MARGINX 	= 0
hs.grid.MARGINY 	= 0
hs.grid.GRIDWIDTH  	= 5
hs.grid.GRIDHEIGHT 	= 2

-- disable animation
hs.window.animationDuration = 0
--hs.hints.style = "vimperator"

-- hotkey mash
local mash       = {"ctrl", "alt"}
local mash_app 	 = {"cmd", "alt", "ctrl"}
local mash_shift = {"ctrl", "alt", "shift"}
local mash_cmd	 = {"cmd", "cntrl", "shift"}	
local mash_vd    = {"cmd"}
local mash_vd_shift    = {"cmd", "shift"}

--------------------------------------------------------------------------------
workCuts = {
  t = 'iTerm2',
  s = 'Sublime Text',
  i = 'IntelliJ IDEA-EAP',
}

commCuts = {
  c = 'Slack',
  g = 'Google Chrome',
  o = 'Microsoft Outlook',
}

otherCuts = {
  f = 'Finder',
  a = 'Activity Monitor'
}

-- Launch applications
for key, app in pairs(workCuts) do
  hs.hotkey.bind(mash_app, key, function () hs.application.launchOrFocus(app) end)
end

-- global operations
hs.hotkey.bind(mash, ';', function() hs.grid.snap(hs.window.focusedWindow()) end)
hs.hotkey.bind(mash, "'", function() hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap) end)

-- adjust grid size
hs.hotkey.bind(mash, '=', function() hs.grid.adjustWidth( 1) end)
hs.hotkey.bind(mash, '-', function() hs.grid.adjustWidth(-1) end)
hs.hotkey.bind(mash, ']', function() hs.grid.adjustHeight( 1) end)
hs.hotkey.bind(mash, '[', function() hs.grid.adjustHeight(-1) end)

-- change focus
hs.hotkey.bind(mash_app, 'left', function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind(mash_app, 'right', function() hs.window.focusedWindow():focusWindowEast() end)
hs.hotkey.bind(mash_app, 'up', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(mash_app, 'down', function() hs.window.focusedWindow():focusWindowSouth() end)

hs.hotkey.bind(mash, '\\', hs.grid.maximizeWindow)

-- multi monitor
hs.hotkey.bind(mash, 'pagedown', hs.grid.pushWindowNextScreen)
hs.hotkey.bind(mash, 'pageup', hs.grid.pushWindowPrevScreen)

-- move windows
hs.hotkey.bind(mash, 'left', hs.grid.pushWindowLeft)
hs.hotkey.bind(mash, 'down', hs.grid.pushWindowDown)
hs.hotkey.bind(mash, 'up', hs.grid.pushWindowUp)
hs.hotkey.bind(mash, 'right', hs.grid.pushWindowRight)

-- resize windows
hs.hotkey.bind(mash_shift, 'left', hs.grid.resizeWindowThinner)
hs.hotkey.bind(mash_shift, 'up', hs.grid.resizeWindowShorter)
hs.hotkey.bind(mash_shift, 'down', hs.grid.resizeWindowTaller)
hs.hotkey.bind(mash_shift, 'right', hs.grid.resizeWindowWider)

-- Window Hints
hs.hotkey.bind(mash, '.', hs.hints.windowHints)

-- snap all newly launched windows
local function auto_tile(appName, event)
	if event == hs.application.watcher.launched then
		local app = hs.appfinder.appFromName(appName)
		-- protect against unexpected restarting windows
		if app == nil then
			return
		end
		hs.fnutils.map(app:allWindows(), hs.grid.snap)
	end
end

-- start app launch watcher
hs.application.watcher.new(auto_tile):start()

-- config auto-reload
hs.hotkey.bind(mash_app, 'r', hs.reload)
--hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config Re-loaded")


-- virtual desktops (contexts)
hs.window.switcher.ui.showSelectedThumbnail = false
hs.window.switcher.ui.showThumbnails = false

local switchers = {}

local function virt_win_switch(appMap)
  local appNames = {}
  local idx = 0
  for key, app in  pairs(appMap) do
    appNames[app] = app
    idx = idx + 1
  end
  
  local winFilter = hs.window.filter.new(function(w) 
    return w:title() ~= "" and appNames[w:application():title()] ~= nil 
  end)

  return { 
    switcher = hs.window.switcher.new(winFilter),
    appNames = appNames,
    winFilter = winFilter,
    actWindow = nil
  }  
end  

for idx, space in pairs{workCuts, commCuts, otherCuts} do
  -- create switcher
  switchers[idx] = virt_win_switch(space)
  -- add watcher to track active window per virtual desktop
  switchers[idx].winFilter:subscribe(hs.window.filter.windowFocused,
    function() switchers[idx].actWindow = hs.window:focusedWindow() end)
  -- make all "workspaced" windows to be maximized by default
  switchers[idx].winFilter:subscribe(hs.window.filter.windowCreated,
    hs.grid.maximizeWindow)
  -- bind forward window switch
  hs.hotkey.bind(mash_vd, 'F'..idx, nil, function()
    local win = hs.window.focusedWindow()
    if switchers[idx].actWindow == nil or (win and switchers[idx].appNames[win:application():title()]) then
      switchers[idx].switcher:next()
    else
      if switchers[idx].actWindow then switchers[idx].actWindow:focus() end
    end
  end)
  -- bind backward window switch
  hs.hotkey.bind(mash_vd_shift, 'F'..idx, nil, function() 
    switchers[idx].switcher:previous()
  end)
end