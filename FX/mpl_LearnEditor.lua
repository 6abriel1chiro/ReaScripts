-- @description LearnEditor
-- @version 1.01
-- @author MPL
-- @website https://forum.cockos.com/showthread.php?t=188335
-- @about Script for handling FX parameter bindings data
-- @provides
--    mpl_LearnEditor_functions/mpl_LearnEditor_GUI.lua
--    mpl_LearnEditor_functions/mpl_LearnEditor_MOUSE.lua
--    mpl_LearnEditor_functions/mpl_LearnEditor_data.lua
--    mpl_LearnEditor_functions/mpl_LearnEditor_obj.lua
-- @changelog
--    # rebuild GUI draw, improve GUI performance
--    + allow to filter list of Learn or/and param modulation
--    + highlight last touched track

  local vrs = 'v1.01'
  --NOT gfx NOT reaper
  --Delete all MIDI OSC learn from focused FX
  --Delete all MIDI OSC learn from selected track
  --List all MIDI OSC learn for current project
  --List all MIDI OSC learn for focused FX
  

 --  INIT -------------------------------------------------
  local conf = {}  
  local refresh = { GUI_onStart = true, 
                    GUI = false, 
                    GUI_minor = false,
                    data = false,
                    data_proj = false, 
                    conf = false}
  local mouse = {}
  data = {}
  local obj = {}
  ---------------------------------------------------  
  
  function Main_RefreshExternalLibs()     -- lua example by Heda -- http://github.com/ReaTeam/ReaScripts-Templates/blob/master/Files/Require%20external%20files%20for%20the%20script.lua
    local info = debug.getinfo(1,'S');
    local script_path = info.source:match([[^@?(.*[\/])[^\/]-$]]) 
    dofile(script_path .. "mpl_LearnEditor_functions/mpl_LearnEditor_GUI.lua")
    dofile(script_path .. "mpl_LearnEditor_functions/mpl_LearnEditor_MOUSE.lua")  
    dofile(script_path .. "mpl_LearnEditor_functions/mpl_LearnEditor_obj.lua")  
    dofile(script_path .. "mpl_LearnEditor_functions/mpl_LearnEditor_data.lua")  
  end  

  ---------------------------------------------------
  function ExtState_Def()  
    local t= {
            -- globals
            mb_title = 'LearnEditor', 
            ES_key = 'MPL_LearnEditor',
            wind_x =  50,
            wind_y =  50,
            wind_w =  600,
            wind_h =  200,
            dock =    0,
            
            -- mouse
            mouse_wheel_res = 960,
            showflag = 1,
                      --[[&1 learn
                        &2 param mod
                      ]]
            }
    return t
  end  
  
  
  ---------------------------------------------------    
  function run()
    obj.clock = os.clock()
    
    MOUSE(conf, obj, data, refresh, mouse)
    CheckUpdates(obj, conf, refresh)
    if refresh.data == true then 
      refresh.data = nil 
      --refresh.GUI = true
      --if conf.refresh_on_psc ==1 then 
      DataReadProject(conf, obj, data, refresh, mouse) 
      --end
      --msg(1)
    end  
    if refresh.conf == true then 
      ExtState_Save(conf)
      refresh.conf = nil end
    if refresh.GUI == true or refresh.GUI_onStart == true then   
      Data_HandleTouchedObjects(conf, obj, data, refresh, mouse) 
      OBJ_Update (conf, obj, data, refresh, mouse) 
    end  
    if refresh.GUI_minor == true then refresh.GUI = true end
    GUI_draw (conf, obj, data, refresh, mouse)    
                                               
 
    ShortCuts(conf, obj, data, refresh, mouse)
    if mouse.char >= 0 and mouse.char ~= 27 
      then defer(run) else atexit(gfx.quit) end
  end
  ---------------------------------------------------------------------
  function RunInit(conf, obj, data, refresh, mouse) 
    DataReadProject(conf, obj, data, refresh, mouse) 
    Data_HandleTouchedObjects(conf, obj, data, refresh, mouse, true) 
  end
---------------------------------------------------------------------
  function CheckFunctions(str_func) local SEfunc_path = reaper.GetResourcePath()..'/Scripts/MPL Scripts/Functions/mpl_Various_functions.lua' local f = io.open(SEfunc_path, 'r')  if f then f:close() dofile(SEfunc_path) if not _G[str_func] then  reaper.MB('Update '..SEfunc_path:gsub('%\\', '/')..' to newer version', '', 0) else return true end  else reaper.MB(SEfunc_path:gsub('%\\', '/')..' missing', '', 0) end   end
--------------------------------------------------------------------
  function main()
        conf.dev_mode = 0
        conf.vrs = vrs
        Main_RefreshExternalLibs()
        ExtState_Load(conf)
        --conf.tableentries = 15
        gfx.init('MPL '..conf.mb_title..' '..conf.vrs,
                    conf.wind_w, 
                    conf.wind_h, 
                    conf.dock, conf.wind_x, conf.wind_y)
        OBJ_init(conf, obj, data, refresh, mouse)
        OBJ_Update(conf, obj, data, refresh, mouse) 
        RunInit(conf, obj, data, refresh, mouse) 
        run()  
  end
  --------------------------------------------------------------------  
  local ret = CheckFunctions('VF_CalibrateFont') 
  if ret then
    local ret2 = VF_CheckReaperVrs(5.95,true)    
    if ret and ret2 then main() end
  end
