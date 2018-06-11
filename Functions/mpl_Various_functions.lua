-- @description Various_functions
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @about Functions for using with some MPL scripts. It is strongly recommended to have it installed for future updates.
-- @version 1.02
-- @changelog
--    + spairs
--    + ExtState_Load/Save (for {conf})
--    + Table: NormalizeT, ScaleT, SmoothT
--    + GetParentFolder
--    + GetShortSmplName
--    + GetNoteStr
--    + ExportSelItemsToRs5k_AddMIDI, ExportSelItemsToRs5k_FormMIDItake_data
--    + math_q, math_q_dec
--    + local table or REAPER functions
--    + FloatInstrument
--    + ApplyFunctionToTrackInTree

  for key in pairs(reaper) do _G[key]=reaper[key]  end 
  function msg(s) if not s then return end ShowConsoleMsg(s..'\n') end  
  ------------------------------------------------------------------------------------------------------
  function eugen27771_GetObjStateChunk(obj)
    if not obj then return end
    local fast_str, chunk
    fast_str = SNM_CreateFastString("")
    if SNM_GetSetObjectState(obj, fast_str, false, false) then chunk = SNM_GetFastString(fast_str) end
    SNM_DeleteFastString(fast_str)  
    return chunk
  end 
  ------------------------------------------------------------------------------------------------------
  function literalize(str) -- http://stackoverflow.com/questions/1745448/lua-plain-string-gsub
     if str then  return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end) end
  end  
  ------------------------------------------------------------------------------------------------------
  function lim(val, min,max) --local min,max 
    if not min or not max then min, max = 0,1 end 
    return math.max(min,  math.min(val, max) ) 
  end
  ---------------------------------------------------
  function CopyTable(orig)--http://lua-users.org/wiki/CopyTable
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
          copy = {}
          for orig_key, orig_value in next, orig, nil do
              copy[CopyTable(orig_key)] = CopyTable(orig_value)
          end
          setmetatable(copy, CopyTable(getmetatable(orig)))
      else -- number, string, boolean, etc
          copy = orig
      end
      return copy
  end 
  ------------------------------------------------------------------------------------------------------
  function WDL_DB2VAL(x) return math.exp((x)*0.11512925464970228420089957273422) end  --https://github.com/majek/wdl/blob/master/WDL/db2val.h
  ------------------------------------------------------------------------------------------------------
  function WDL_VAL2DB(x, reduce)   --https://github.com/majek/wdl/blob/master/WDL/db2val.h
    if not x or x < 0.0000000298023223876953125 then return -150.0 end
    local v=math.log(x)*8.6858896380650365530225783783321
    if v<-150.0 then return -150.0 else 
      if reduce then 
        return string.format('%.2f', v)
       else 
        return v 
      end
    end
  end
  ------------------------------------------------------------------------------------------------------
  function GetSpectralData(item)
    --[[
    {table}
      {takeID}
        {edits}
          {editID = 
            param = value}
    ]]
    if not item then return end
    local chunk = ({GetItemStateChunk( item, '', false )})[2]
    -- parse chunk
    local tk_cnt = 0
    local SE ={}
    for line in chunk:gmatch('[^\r\n]+') do 
    
      if line:match('<SOURCE') then 
        tk_cnt =  tk_cnt +1 
        SE[tk_cnt]= {}
      end 
        
      if line:match('SPECTRAL_CONFIG') then
        local sz = line:match('SPECTRAL_CONFIG ([%d]+)')
        if sz then sz = tonumber(sz) end
        SE[tk_cnt].FFT_sz = sz
      end
            
      if line:match('SPECTRAL_EDIT') then  
        if not SE[tk_cnt].edits then SE[tk_cnt].edits = {} end
        local tnum = {} 
        for num in line:gmatch('[^%s]+') do if tonumber(num) then tnum[#tnum+1] = tonumber(num) end end
        SE[tk_cnt].edits [#SE[tk_cnt].edits+1] =       {pos = tnum[1],
                       len = tnum[2],
                       gain = tnum[3],
                       fadeinout_horiz = tnum[4], -- knobleft/2 + knobright/2
                       fadeinout_vert = tnum[5], -- knoblower/2 + knobupper/2
                       freq_low = tnum[6],
                       freq_high = tnum[7],
                       chan = tnum[8], -- -1 all 0 L 1 R
                       bypass = tnum[9], -- bypass&1 solo&2
                       gate_threshold = tnum[10],
                       gate_floor = tnum[11],
                       compress_threshold = tnum[12],
                       compress_ratio = tnum[13],
                       unknown1 = tnum[14],
                       unknown2 = tnum[15],
                       fadeinout_horiz2 = tnum[16],  -- knobright - knobleft
                       fadeinout_vert2 = tnum[17],
                       chunk_str = line} -- knobupper - knoblower
      end
                       
    end
    return true, SE
  end
  ------------------------------------------------------------------------------------------------------
  function SetSpectralData(item, data, apply_chunk)
    --[[
    {table}
      {takeID}
        {edits}
          {editID = 
            param = value}
    ]]  
    if not item then return end
    local chunk = ({GetItemStateChunk( item, '', false )})[2]
    chunk = chunk:gsub('SPECTRAL_CONFIG.-\n', '')
    chunk = chunk:gsub('SPECTRAL_EDIT.-\n', '')
    local open
    local t = {} 
    for line in chunk:gmatch('[^\r\n]+') do t[#t+1] = line end
    local tk_cnt = 0 
    for i = 1, #t do
      if t[i]:match('<SOURCE') then 
        tk_cnt = tk_cnt + 1 
        open = true 
      end
      if open and t[i]:match('>') then
      
        local add_str = ''
        
        if data[tk_cnt] 
          and data[tk_cnt].edits 
          and GetTake( item, tk_cnt-1 )
          and not TakeIsMIDI(GetTake( item, tk_cnt-1 ))
          then
          for edit_id in pairs(data[tk_cnt].edits) do
            if not data[tk_cnt].FFT_sz then data[tk_cnt].FFT_sz = 1024 end
            
            if not apply_chunk then
              add_str = add_str..'SPECTRAL_EDIT '
                ..data[tk_cnt].edits[edit_id].pos..' '
                ..data[tk_cnt].edits[edit_id].len..' '
                ..data[tk_cnt].edits[edit_id].gain..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_horiz..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_vert..' '
                ..data[tk_cnt].edits[edit_id].freq_low..' '
                ..data[tk_cnt].edits[edit_id].freq_high..' '
                ..data[tk_cnt].edits[edit_id].chan..' '
                ..data[tk_cnt].edits[edit_id].bypass..' '
                ..data[tk_cnt].edits[edit_id].gate_threshold..' '
                ..data[tk_cnt].edits[edit_id].gate_floor..' '
                ..data[tk_cnt].edits[edit_id].compress_threshold..' '
                ..data[tk_cnt].edits[edit_id].compress_ratio..' '
                ..data[tk_cnt].edits[edit_id].unknown1..' '
                ..data[tk_cnt].edits[edit_id].unknown2..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_horiz2..' '
                ..data[tk_cnt].edits[edit_id].fadeinout_vert2..' '
                ..'\n'
              add_str = add_str..'SPECTRAL_CONFIG '..data[tk_cnt].FFT_sz ..'\n'
             else
              add_str = apply_chunk..'\nSPECTRAL_CONFIG '..data[tk_cnt].FFT_sz ..'\n'
            end
          end        
        end
        
        t[i] = t[i]..'\n'..add_str
        open = false
      end
    end   
    
    local out_chunk = table.concat(t, '\n')
    --ClearConsole()
    --msg(out_chunk)
    SetItemStateChunk( item, out_chunk, false )
    UpdateItemInProject( item )
  end
  ---------------------------------------------------
  function spairs(t, order) --http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then table.sort(keys, function(a,b) return order(t, a, b) end)  else  table.sort(keys) end
    local i = 0
    return function()
              i = i + 1
              if keys[i] then return keys[i], t[keys[i]] end
           end
  end
  ---------------------------------------------------
  function ExtState_Load(conf)
    local def = ExtState_Def()
    for key in pairs(def) do 
      local es_str = GetExtState(def.ES_key, key)
      if es_str == '' then conf[key] = def[key] else conf[key] = tonumber(es_str) or es_str end
    end    
  end  
  ---------------------------------------------------
  function ExtState_Save(conf)
    conf.dock , conf.wind_x, conf.wind_y, conf.wind_w, conf.wind_h= gfx.dock(-1, 0,0,0,0)
    for key in pairs(conf) do SetExtState(conf.ES_key, key, conf[key], true)  end
    --for k,v in spairs(conf, function(t,a,b) return b:lower() > a:lower() end) do SetExtState(conf.ES_key, k, conf[k], true) end  
  end
  ---------------------------------------------------------------------------------------------------------------------
  function NormalizeT(t)
    local m = 0 for i = 1, #t do m = math.max(math.abs(t[i]),m) end
  end 
  ---------------------------------------------------------------------------------------------------------------------
  function ScaleT(t, scaling)
    for i =1, #t do t[i]= t[i]^scaling end
  end   
  ---------------------------------------------------------------------------------------------------------------------
  function SmoothT(t, smooth)
    for i = 2, #t do t[i]= t[i] - (t[i] - t[i-1])*smooth   end
  end  
  ---------------------------------------------------------------------------------------------------------------------
  function GetParentFolder(dir) return dir:match('(.*)[%\\/]') end
  ---------------------------------------------------------------------------------------------------------------------
  function GetShortSmplName(path) 
    local fn = path
    fn = fn:gsub('%\\','/')
    if fn then fn = fn:reverse():match('(.-)/') end
    if fn then fn = fn:reverse() end
    return fn
  end  
  ---------------------------------------------------------------------------------------------------------------------   
    function GetNoteStr(conf, val, mode)  -- conf.key_names
      local oct_shift = -1
      if conf.oct_shift then oct_shift = conf.oct_shift end
      local int_mode
      if mode then int_mode = mode else int_mode = conf.key_names end
      if int_mode == 0 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end
       elseif int_mode == 1 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'D♭', 'D', 'E♭', 'E', 'F', 'G♭', 'G', 'A♭', 'A', 'B♭', 'B',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end  
       elseif int_mode == 2 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'Do', 'Do#', 'Re', 'Re#', 'Mi', 'Fa', 'Fa#', 'Sol', 'Sol#', 'La', 'La#', 'Si',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end      
       elseif int_mode == 3 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'Do', 'Re♭', 'Re', 'Mi♭', 'Mi', 'Fa', 'Sol♭', 'Sol', 'La♭', 'La', 'Si♭', 'Si',}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift end       
       elseif int_mode == 4 -- midi pitch
        then return val, 'MIDI pitch'
       elseif int_mode == 5 -- freq
        then return math.floor(440 * 2 ^ ( (val - 69) / 12))..'Hz'
       elseif int_mode == 6 -- empty
        then return '', 'Nothing'
       elseif int_mode == 7 then -- ru
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'До', 'До#', 'Ре', 'Ре#', 'Ми', 'Фа', 'Фа#', 'Соль', 'Соль#', 'Ля', 'Ля#', 'Си'}
        if note and oct and key_names[note+1] then return key_names[note+1]..oct+oct_shift..'\n'..val,
                                                          'keys (RU) + octave + MIDI pitch' end  
       elseif int_mode == 8 then
        if not val then return end
        local val = math.floor(val)
        local oct = math.floor(val / 12)
        local note = math.fmod(val,  12)
        local key_names = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',}
        if note and oct and key_names[note+1] then 
          return key_names[note+1]..oct+oct_shift..'\n'..val,
                  'keys + octave + MIDI pitch'
        end              
      end
    end
  ---------------------------------------------------------------------------------------------------------------------
    function math_q(num)  if math.abs(num - math.floor(num)) < math.abs(num - math.ceil(num)) then return math.floor(num) else return math.ceil(num) end end
  ---------------------------------------------------------------------------------------------------------------------
    function math_q_dec(num, pow) return math.floor(num * 10^pow) / 10^pow end
  -------------------------------------------------------------------------------   
  function ExportSelItemsToRs5k_FormMIDItake_data()
    local MIDI = {}
    -- check for same track/get items info
      local item = reaper.GetSelectedMediaItem(0,0)
      if not item then return end
      MIDI.it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
      MIDI.it_end_pos = MIDI.it_pos + 0.1
      local proceed_MIDI = true
      local it_tr0 = reaper.GetMediaItemTrack( item )
      for i = 1, reaper.CountSelectedMediaItems(0) do
        local item = reaper.GetSelectedMediaItem(0,i-1)
        local it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
        local it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
        MIDI[#MIDI+1] = {pos=it_pos, end_pos = it_pos+it_len}
        MIDI.it_end_pos = it_pos + it_len
        local it_tr = reaper.GetMediaItemTrack( item )
        if it_tr ~= it_tr0 then proceed_MIDI = false break end
      end
      
    return proceed_MIDI, MIDI
  end
  -------------------------------------------------------------------------------    
  function ExportSelItemsToRs5k_AddMIDI(track, MIDI, base_pitch)    
    if not MIDI then return end
      local new_it = reaper.CreateNewMIDIItemInProj( track, MIDI.it_pos, MIDI.it_end_pos )
      local new_tk = reaper.GetActiveTake( new_it )
      for i = 1, #MIDI do
        local startppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].pos )
        local endppqpos =  reaper.MIDI_GetPPQPosFromProjTime( new_tk, MIDI[i].end_pos )
        local ret = reaper.MIDI_InsertNote( new_tk, 
            false, --selected, 
            false, --muted, 
            startppqpos, 
            endppqpos, 
            0, 
            base_pitch+i-1, 
            100, 
            true)--noSortInOptional )
          --if ret then reaper.ShowConsoleMsg('done') end
      end
      reaper.MIDI_Sort( new_tk )
      reaper.GetSetMediaItemTakeInfo_String( new_tk, 'P_NAME', 'sliced loop', 1 )
      reaper.UpdateArrange()    
  end
  -------------------------------------------------------------------------------     
  function FloatInstrument(track)
    local vsti_id = TrackFX_GetInstrument(track)
    if vsti_id and vsti_id >= 0 then 
      TrackFX_Show(track, vsti_id, 3) -- float
      return true
    end
  end
  ---------------------------------------------------------------------
    function ApplyFunctionToTrackInTree(track, func) -- function return true stop search
      -- search tree
        local parent_track, ret2, ret3
        local track2 = track
        repeat
          parent_track = reaper.GetParentTrack(track2)
          if parent_track ~= nil then
            ret2 = func(parent_track )
            if ret2 then return end
            track2 = parent_track
          end
        until parent_track == nil    
        
      -- search sends
        local cnt_sends = GetTrackNumSends( track, 0)
        for sendidx = 1,  cnt_sends do
          dest_tr = BR_GetMediaTrackSendInfo_Track( track, 0, sendidx-1, 1 )
          ret3 = func(dest_tr )
          if ret3 then return  end
        end
    end
