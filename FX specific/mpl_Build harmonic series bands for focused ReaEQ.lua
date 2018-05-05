-- @description Build harmonic series bands for focused ReaEQ
-- @version 1.0
-- @author MPL
-- @website http://forum.cockos.com/showthread.php?t=188335
  
  
  
  -- NOT reaper NOT gfx
  for key in pairs(reaper) do _G[key]=reaper[key]  end 
  function msg(s) if s then ShowConsoleMsg(s..'\n') end end
  -----------------------------------------------------------------------------
   function lim(val, min,max) --local min,max 
     if not min or not max then min, max = 0,1 end 
     return math.max(min,  math.min(val, max) ) 
   end
  -----------------------------------------------------------------------------
  function MPL_BuildEQReduce(freq, gain)
    local startQdenom = 20
    local  retval, tracknumber, itemnumber, fx = GetFocusedFX()
    if not (retval ==1 and fx >= 0) then return end
    local tr = CSurf_TrackFromID( tracknumber, false )
    local isReaEQ = TrackFX_GetEQParam( tr, fx, 0 )
    if not isReaEQ then return end
    local num_params = TrackFX_GetNumParams( tr, fx )
    for param = 1, num_params - 2, 3 do
      local band_id = math.floor(param/3)
      TrackFX_SetNamedConfigParm( tr, fx, 'BANDTYPE'..band_id, 2 )
      TrackFX_SetParamNormalized( tr, fx, param, gain) -- -2.0dB gain
      TrackFX_SetParamNormalized( tr, fx, param+1, lim(1/(startQdenom* (band_id+1)), 0.01, 1)) -- 0.5 Q
      local ConvertedF = F2ReaEQVal(freq * (band_id+1) )
      TrackFX_SetParamNormalized( tr, fx, param-1, lim(ConvertedF, 0.01, 1)) -- freq
    end
  end
  ----------------------------------------------------------------------------- 
  function ReaEQVal2F(x) 
    local curve = (math.exp(math.log(401)*x) - 1) * 0.0025
    local freq = (24000 - 20) * curve + 20
    return freq
  end
  function WDL_DB2VAL(x) return math.exp((x)*0.11512925464970228420089957273422) end  --https://github.com/majek/wdl/blob/master/WDL/db2val.h
  ----------------------------------------------------------------------------- 
  function ParseDbVol(out_str_toparse)
    if not out_str_toparse or not out_str_toparse:match('%d') then return 0 end
    if out_str_toparse:find('1.#JdB') then return 0 end
    out_str_toparse = out_str_toparse:lower():gsub('db', '')
    local out_val = tonumber(out_str_toparse)
    if not out_val then return end
    out_val = lim(out_val, -150, 12)
    out_val = WDL_DB2VAL(out_val)
    if out_val <= 1 then out_val = out_val / 2 else out_val = 0.5 + out_val / 8 end
    
    return out_val
  end
  ----------------------------------------------------------------------------- 
  function F2ReaEQVal(F) 
    local curve =  (F - 20) / (24000 - 20)
    local x = (math.log((curve +0.0025) / 0.0025,math.exp(1) ))/math.log(401)
    return x
  end
  ----------------------------------------------------------------------------- 
  local retval, str = GetUserInputs('Build harmonic bands', 2, 'Base frequency(Hz),Gain Reduction(dB)', '50,-inf')
  if retval then 
    local t, freq, gain = {}, _, 0
    for val in str:gmatch('[^,]+') do  t[#t+1] = val end
    if t[1] then freq = t[1] else return end
    if t[2] then gain = ParseDbVol(t[2]) end
    MPL_BuildEQReduce(freq, lim(gain, 0, 0.5))
  end