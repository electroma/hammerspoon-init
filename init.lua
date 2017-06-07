-- init grid
hs.grid.MARGINX 	= 0
hs.grid.MARGINY 	= 0
hs.grid.GRIDWIDTH  	= 5
hs.grid.GRIDHEIGHT 	= 2

-- disable animation
hs.window.animationDuration = 0
--hs.hints.style = "vimperator"

-- logger
local log = hs.logger.new('romans','debug')

-- hotkey mash
local mash       = {"ctrl", "alt"}
local mash_app 	 = {"cmd", "alt", "ctrl"}
local mash_shift = {"ctrl", "alt", "shift"}
local mash_cmd	 = {"cmd", "cntrl", "shift"}	
local mash_vd    = {"cmd", "alt"}
local mash_vd_shift    = {"cmd", "shift"}
local mash_win_sw = {"cmd"}

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

externals = {workCuts['i'], commCuts['g']}

-- TAB switch
-- for i=1,6 do
--   hs.hotkey.bind(mash_win_sw, 'F'..i, function()
--     local app = hs.application.frontmostApplication()
--     log.i('Switching to '..i..' of '..app:name())
--     hs.tabs.focusTab(app,i)
--   end)
-- end

-- Launch applications
for key, app in pairs(workCuts) do
  hs.hotkey.bind(mash_app, key, function () hs.application.launchOrFocus(app) end)
end

for key, app in pairs(commCuts) do
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

hs.hotkey.bind(mash, '\\', function(w) hs.grid.maximizeWindow(w) end)

-- multi monitor
hs.hotkey.bind(mash, 'pagedown', function(w) hs.grid.pushWindowNextScreen(); hs.grid.maximizeWindow(w) end)
hs.hotkey.bind(mash, 'pageup', function(w) hs.grid.pushWindowPrevScreen(); hs.grid.maximizeWindow(w) end)

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
    hs.tabs.enableForApp(app)
		hs.fnutils.map(app.allWindows(), hs.grid.snap)
	end
end

-- dubug 
function list_apps() 
  local apps = hs.application.runningApplications()
  for k,app in ipairs(apps) do
    log.i(app)
  end 
end  

--move all work stuff to the external 
function move_all_out(appName)  
  local scr = hs.screen.allScreens()[2]
  if scr == nil then
    log.i('no external screen')
    return  
  end
  local app = hs.application.get(appName)
  if app == nil then
    log.i('no app', appName)
    return  
  end
  log.i(app)
  log.i(app.visibleWindows())
  for i,w in ipairs(app.allWindows()) do 
    log.i(w)
    --w.moveToScreen(scr)
  end  
end

function move_all_externals() 
  log.i('moving all to external')  
  for i,a in pairs(externals) do     
    move_all_out(a) 
  end 
end

hs.hotkey.bind(mash_app, 'z', move_all_externals)

hs.hotkey.bind(mash_app, 'a', list_apps)

-- start app launch watcher
hs.application.watcher.new(auto_tile):start()

-- config auto-reload
hs.hotkey.bind(mash_app, 'r', hs.reload)
--hs.pathwatcher.new(hs.configdir, hs.reload):start()
hs.alert.show("Config Re-loaded")


-- virtual desktops (contexts)
hs.window.switcher.ui.showSelectedThumbnail = false
hs.window.switcher.ui.showThumbnails = false

-- local switchers = {}

-- local function virt_win_switch(appMap)
--   local appNames = {}
--   local idx = 0
--   for key, app in  pairs(appMap) do
--     appNames[app] = app
--     idx = idx + 1
--   end
  
--   local winFilter = hs.window.filter.new(function(w) 
--     return w:title() ~= "" and appNames[w:application():title()] ~= nil 
--   end)

--   return { 
--     switcher = hs.window.switcher.new(winFilter),
--     appNames = appNames,
--     winFilter = winFilter,
--     actWindow = nil
--   }  
-- end  

-- for idx, space in pairs{workCuts, commCuts, otherCuts} do
--   -- create switcher
--   switchers[idx] = virt_win_switch(space)
--   -- add watcher to track active window per virtual desktop
--   switchers[idx].winFilter:subscribe(hs.window.filter.windowFocused,
--     function() switchers[idx].actWindow = hs.window:focusedWindow() end)
--   -- make all "workspaced" windows to be maximized by default
--   --switchers[idx].winFilter:subscribe(hs.window.filter.windowCreated,
--   --  hs.grid.maximizeWindow)
  
--   -- bind forward window switch
--   hs.hotkey.bind(mash_vd, 'F'..idx, nil, function()
--     local win = hs.window.focusedWindow()
--     if switchers[idx].actWindow == nil or (win and switchers[idx].appNames[win:application():title()]) then
--       switchers[idx].switcher:next()
--     else
--       if switchers[idx].actWindow then switchers[idx].actWindow:focus() end
--     end
--   end)
--   -- bind backward window switch
--   hs.hotkey.bind(mash_vd_shift, 'F'..idx, nil, function() 
--     switchers[idx].switcher:previous()
--   end)
-- end
