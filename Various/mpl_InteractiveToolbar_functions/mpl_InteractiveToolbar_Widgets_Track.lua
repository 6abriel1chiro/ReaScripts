-- @description InteractiveToolbar_Widgets_Track
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @noindex


  -- track wigets for mpl_InteractiveToolbar
  
  ---------------------------------------------------
  function Obj_UpdateTrack(data, obj, mouse, widgets)
    obj.b.obj_name = { x = obj.menu_b_rect_side + obj.offs,
                        y = obj.offs *2 +obj.entry_h,
                        w = obj.entry_w,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt_a = obj.txt_a,
                        txt = data.tr[1].name,
                        fontsz = obj.fontsz_entry,
                        func_DC = 
                          function ()
                            if data.tr[1].name_proj then
                              local retval0, retvals_csv = GetUserInputs( 'Rename', 1, 'New Name, extrawidth=220', data.tr[1].name_proj )
                              if not retval0 then return end
                              if data.tr[1].ptr and ValidatePtr2(0, data.tr[1].ptr,'MediaTrack*') then
                                  GetSetMediaTrackInfo_String( data.tr[1].ptr, 'P_NAME', retvals_csv, true )
                                  redraw = 1
                              end
                            end
                          end} 
    local x_offs = obj.menu_b_rect_side + obj.offs + obj.entry_w 
    
    
    
  --------------------------------------------------------------  
    local tp_ID = data.obj_type_int
    local widg_key = widgets.types_t[tp_ID+1] -- get key of current mapped table
    if widgets[widg_key] then      
      for i = 1, #widgets[widg_key] do
        local key = widgets[widg_key][i]
        if _G['Widgets_Track_'..key] then
            local ret = _G['Widgets_Track_'..key](data, obj, mouse, x_offs, widgets) 
            if ret then x_offs = x_offs + obj.offs + ret end
        end
      end  
    end
  end
  -------------------------------------------------------------- 








  -------------------------------------------------------------- 
  function Widgets_Track_pan(data, obj, mouse, x_offs)
    local pan_w = 60
    if x_offs + pan_w > obj.persist_margin then return x_offs end 
    obj.b.obj_tr_pan = { x = x_offs,
                        y = obj.offs ,
                        w = pan_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Pan'} 
    obj.b.obj_tr_pan_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = pan_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  

      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = {data.tr[1].pan_format},
                        table_key='tr_pan_ctrl',
                        x_offs= x_offs,  
                        w_com=pan_w,--obj.entry_w2,
                        src_val=data.tr,
                        src_val_key= 'pan',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_Track_pan,                    
                        mouse_scale= obj.mouse_scal_pan,               -- mouse scaling
                        use_mouse_drag_xAxis= true,
                        parse_pan_tags = true,
                        default_val = 0})                         
    return pan_w--obj.entry_w2                         
  end
  
  function Apply_Track_pan(data, obj, t_out_values, butkey, out_str_toparse, mouse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do        
        local out_val = math_q(t_out_values[i]*100)/100
        SetMediaTrackInfo_Value( data.tr[i].ptr, 'D_PAN', lim(out_val,-1,1) )   
      end
      t_out_values[1] = lim(t_out_values[1], -1,1)
      local out_val = math_q(t_out_values[1]*100)/100
      local new_str = MPL_FormatPan(out_val)
      obj.b[butkey..1].txt = new_str
      redraw = 1
     else
      local out_val = MPL_ParsePanVal(out_str_toparse)
      --[[nudge
        local diff = data.it[1].pan - out_val
        for i = 1, #t_out_values do
          SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PAN', lim(t_out_values[i] - diff,-1,1) )
          UpdateItemInProject( data.it[i].ptr_item )                                
        end   ]]
      --set
        for i = 1, #data.tr do
          local out_val = math_q(out_val*100)/100
          SetMediaTrackInfo_Value( data.tr[i].ptr, 'D_PAN', lim(out_val,-1,1) )    
        end     
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 






  --------------------------------------------------------------   
  function Widgets_Track_vol(data, obj, mouse, x_offs) -- generate snap_offs controls 
    local vol_w = 60 
    if x_offs + vol_w > obj.persist_margin then return x_offs end 
    obj.b.obj_trvol = { x = x_offs,
                        y = obj.offs ,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Volume'} 
    obj.b.obj_trvol_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt ='',
                        fontsz = obj.fontsz_entry,
                        ignore_mouse = true}  
                
      local vol_str = data.tr[1].vol_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = {data.tr[1].vol_format},
                        table_key='trvol_ctrl',
                        x_offs= x_offs,  
                        w_com=vol_w,--obj.entry_w2,
                        src_val=data.tr,
                        src_val_key= 'vol',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_Track_vol,                    
                        mouse_scale= obj.mouse_scal_vol,               -- mouse scaling
                        use_mouse_drag_xAxis= nil, -- x
                        --ignore_fields= true, -- same tolerance change
                        y_offs= nil,
                        dont_draw_val = nil,
                        default_val = 1,
                        modify_wholestr = true})
    return vol_w--obj.entry_w2                         
  end
  
  function Apply_Track_vol(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then 
      for i = 1, #t_out_values do
        SetMediaTrackInfo_Value( data.tr[i].ptr, 'D_VOL', math.max(0,t_out_values[i] ))
      end
      
      local new_str = string.format("%.2f", t_out_values[1])
      local new_str_t = MPL_GetTableOfCtrlValues2(new_str)
      if new_str_t then 
        for i = 1, #new_str_t do
          if obj.b[butkey..i] then obj.b[butkey..i].txt = '' end--new_str_t[i]
        end
        obj.b.obj_trvol_back.txt = dBFromReaperVal(t_out_values[1])..'dB'
      end
      
     else
      local out_val = tonumber(out_str_toparse) 
      out_val = ReaperValfromdB(out_val)
      --[[nudge
        local diff = data.it[1].vol - out_val
        for i = 1, #t_out_values do
          SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_VOL', math.max(0,t_out_values[i] - diff ))
          UpdateItemInProject( data.it[i].ptr_item )                                
        end   ]]
      --set
        for i = 1, #t_out_values do
          SetMediaTrackInfo_Value( data.tr[i].ptr, 'D_VOL', math.max(0,out_val )) 
        end     
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Track_fxlist(data, obj, mouse, x_offs)
    if not data.tr[1].fx_names or #data.tr[1].fx_names < 1 then return end
    local fxlist_w = 130 
    local fxlist_state = 20
    if x_offs + fxlist_w > obj.persist_margin then return x_offs end 
    local fxid = lim(math.modf(data.curent_trFXID),1, #data.tr[1].fx_names)
    obj.b.obj_fxlist_back1 = { x = x_offs,
                        y = obj.offs ,
                        w = fxlist_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = '',
                        func_wheel =  function() Apply_TrackFXListChange(data, mouse.wheel_trig) end}
                            --    func = function () Apply_TrackFXListChange_floatFX(data, mouse, data.tr[1].fx_names[fxid].is_enabled) end     
    obj.b.obj_fxlist_back2 = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = fxlist_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt ='',
                        fontsz = obj.fontsz_entry,
                        func_wheel =  function() Apply_TrackFXListChange(data, mouse.wheel_trig) end} 
                          --      func = function () Apply_TrackFXListChange_floatFX(data, mouse, data.tr[1].fx_names[fxid].is_enabled) end  }                           
    
    local h_entr= obj.fontsz_entry
    for i = 1, #data.tr[1].fx_names do
      local txt_a = 0.2
      if data.curent_trFXID and i == lim(math.modf(data.curent_trFXID),1, #data.tr[1].fx_names) then txt_a = obj.txt_a end
      local i_shift if data.curent_trFXID then i_shift = lim(math.modf(data.curent_trFXID),1, #data.tr[1].fx_names)-1 else  i_shift= 0 end
      local txt_col = obj.txt_col_header
      if not data.tr[1].fx_names[i].is_enabled then txt_col = 'red'end
      obj.b['obj_fxlist_val'..i] = { x =  x_offs+fxlist_state,
                                y = obj.offs *2 + obj.entry_h/2 + h_entr*(i-i_shift-1) ,
                                w = fxlist_w-fxlist_state,--obj.entry_w2,
                                h = h_entr,
                                frame_a = 0,
                                txt_a = txt_a,
                                txt_col = txt_col,
                                aligh_txt = 8,
                                txt =data.tr[1].fx_names[i].name,
                                fontsz = obj.fontsz_entry,
                                func_wheel =  function() Apply_TrackFXListChange(data, mouse.wheel_trig) end, 
                                func = function () Apply_TrackFXListChange_floatFX(data, mouse, data.tr[1].fx_names[i].is_enabled) end              }   
      local txt,txt_col
      if not data.tr[1].fx_names[i].is_enabled then 
        txt ='X' 
        txt_col = 'red'
       else 
        txt =i 
        txt_col = obj.txt_col_header
      end     
        obj.b['obj_fxlist_val'..i..'state'] = { x =  x_offs,
                                y = obj.offs *2 + obj.entry_h/2 + h_entr*(i-i_shift-1) ,
                                w = fxlist_state,--obj.entry_w2,
                                h = h_entr,
                                frame_a = 0,
                                txt_a = txt_a*0.7,
                                txt_col = txt_col,
                                txt =txt,
                                fontsz = obj.fontsz_entry,
                                func_wheel =  function() Apply_TrackFXListChange(data, mouse.wheel_trig) end, 
                                func = function () Apply_TrackFXListChange_floatFX(data, mouse, data.tr[1].fx_names[i].is_enabled) end              }           
    end
    return fxlist_w               
  end

  function Apply_TrackFXListChange(data, wheel_trig)
    local trig
    if wheel_trig > 0 then trig = 0.35 elseif wheel_trig <0 then trig = -0.35 else return  end                                                             
    data.curent_trFXID = lim( data.curent_trFXID -trig, 1 ,#data.tr[1].fx_names)
    redraw = 2  
  end
  function Apply_TrackFXListChange_floatFX(data, mouse, state)
    local fx_id = lim( math.modf(data.curent_trFXID), 1 ,#data.tr[1].fx_names) 
    if mouse.Shift then 
      TrackFX_SetEnabled( data.tr[1].ptr, fx_id-1, not state)
     else
      TrackFX_Show( data.tr[1].ptr, fx_id-1, 3 )
    end
  end
----------------------------------------------------------- 


  
  
  
-----------------------------------------------------------   
  function Widgets_Track_sendto(data, obj, mouse, x_offs)
    local send_but = 20
    local vol_w = 60 
    local send_w = send_but + vol_w 
    if x_offs + send_w > obj.persist_margin then return x_offs end 
    obj.b.obj_sendto_back1 = { x = x_offs,
                        y = obj.offs ,
                        w = send_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        ignore_mouse = true} 
    obj.b.obj_sendto_back2 = { x = x_offs,
                        y = obj.offs+obj.entry_h ,
                        w = send_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        ignore_mouse = true}  
    obj.b.obj_sendto_but = { x = x_offs+send_w-send_but,
                        y = obj.offs ,
                        w = send_but,--obj.entry_w2,
                        h = obj.entry_h*2,
                        frame_a = 0,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = '->',
                        func = function() SendTracksTo(data, mouse) end }     
    obj.b.obj_sendto_vol = { x = x_offs,
                        y = obj.offs ,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = 0,
                        frame_rect_a = 0.1,
                        fontsz = obj.fontsz_entry,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_entry,
                        txt = 'SendVol',
                        ignore_mouse=true,
                        val = data.defsendvol_slider,
                        is_slider = true,
                        sider_col = obj.txt_col_entry,
                        slider_a = 0.4}  
      local svol_str = data.defsendvol_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues2(svol_str),
                        table_key='svol_ctrl',
                        x_offs= x_offs,  
                        w_com=vol_w,--obj.entry_w2,
                        src_val=data.defsendvol,
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_STrack_vol,                         
                        mouse_scale= obj.mouse_scal_vol,               -- mouse scaling
                        use_mouse_drag_xAxis= true, -- x
                        ignore_fields= true, -- same tolerance change
                        y_offs= obj.offs,
                        dont_draw_val = true,
                        default_val = tonumber(({BR_Win32_GetPrivateProfileString( 'REAPER', 'defsendvol', '0',  get_ini_file() )})[2])})
    obj.b.obj_sendto_pan = { x = x_offs,
                        y = obj.offs +obj.entry_h,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = 0,
                        frame_rect_a = 0.1,
                        fontsz = obj.fontsz_entry,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_entry,
                        txt = 'SendPan',
                        ignore_mouse=true,
                        val = data.defsendpan_slider,
                        is_slider = true,
                        sider_col = obj.txt_col_entry,
                        slider_a = 0.4,
                        centered_slider = true}                         
      local span_str = data.defsendpan_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues2(span_str),
                        table_key='span_ctrl',
                        x_offs= x_offs,  
                        w_com=vol_w,--obj.entry_w2,
                        src_val=data.defsendpan,
                        --src_val_key= '',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_STrack_pan,                         
                        mouse_scale= obj.mouse_scal_pan,               -- mouse scaling
                        use_mouse_drag_xAxis= true, -- x
                        ignore_fields= true, -- same tolerance change
                        y_offs= obj.offs+obj.entry_h,
                        dont_draw_val = true,
                        default_val = 0})
    return send_w 
  end
  function Apply_STrack_vol(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then 
      data.defsendvol = lim(t_out_values,-1,1)
      local new_str = string.format("%.2f", t_out_values)
      local new_str_t = MPL_GetTableOfCtrlValues2(new_str)
      if new_str_t then 
        for i = 1, #new_str_t do
          obj.b[butkey..i].txt = ''--new_str_t[i]
        end
        obj.b.obj_sendto_vol.txt = dBFromReaperVal(t_out_values)..'dB'
      end
      
      local dBval = dBFromReaperVal(data.defsendvol)
      if not tonumber(dBval) then dBval = -math.huge end
      local real = reaper.DB2SLIDER(dBval )/1000
      data.defsendvol_slider = real
      obj.b.obj_sendto_vol.val = data.defsendvol_slider
      
      redraw =  2 
     else
      local out_val = tonumber(out_str_toparse) 
      out_val = ReaperValfromdB(out_val)
      out_val = math.max(0,out_val) 
      data.defsendvol =out_val  
      redraw = 2   
    end
  end  
  function Apply_STrack_pan(data, obj, t_out_values, butkey, out_str_toparse, mouse)
    if not out_str_toparse then    
      
      local out_val = lim(t_out_values,-1,1) 
      data.defsendpan =out_val
      local new_str = MPL_FormatPan(out_val)
      obj.b.obj_sendto_pan.txt = new_str
      data.defsendpan_format = MPL_FormatPan(data.defsendpan)
      data.defsendpan_slider = data.defsendpan
      obj.b.obj_sendto_pan.val = data.defsendpan_slider
      redraw = 2
     else
      local out_val = 0
      if out_str_toparse:lower():match('r') then side = 1 
          elseif out_str_toparse:lower():match('l') then side = -1 
          elseif out_str_toparse:lower():match('c') then side = 1
          else side = 0
      end 
      local val = out_str_toparse:match('%d+')
      if not val then return end
      local out_val = side * val/100
      out_val = lim(out_val,-1,1)
      data.defsendpan= out_val
      redraw = 2   
    end
  end  
  ---------------------------------------------------------
  function SendTracksTo(data,mouse) 
    local GUID  =GetTrackGUID( data.tr[1].ptr )
    local is_predefSend = data.PreDefinedSend_GUID[GUID] ~= nil
    local t = {
          {str = '#Send '..#data.tr..' selected track(s)'}  
        }  
        
    local unpack_prefed = ({table.unpack(SendTracksTo_CollectPreDef(data))})
    for i = 1, #unpack_prefed do table.insert(t, unpack_prefed[i]) end
    --[[local unpack_fold = ({table.unpack(SendTracksTo_CollectTopFold(data))})
    for i = 1, #unpack_fold do table.insert(t, unpack_fold[i]) end]]
    t[#t+1] ={str = '|Mark as predefined send bus',
             func = function ()
                      for i = 1, #data.tr do
                        local GUID  =GetTrackGUID( data.tr[i].ptr )
                        if not is_predefSend then 
                          data.PreDefinedSend_GUID[GUID] = 1
                          UpdatePreDefGUIDs(data)
                         else 
                          data.PreDefinedSend_GUID[GUID] = nil
                          UpdatePreDefGUIDs(data)
                        end
                      end
                    end,
             state = is_predefSend}
    Menu( mouse, t )
  end
  ---------------------------------------------------------
  function UpdatePreDefGUIDs(data)
    local str = ''
    for GUID in pairs(data.PreDefinedSend_GUID) do str = str..' '..GUID end
    SetProjExtState( 0, 'MPL_InfoTool', 'PreDefinedSend_GUID', str )
  end
  ---------------------------------------------------------
  function SendTracksTo_CollectTopFold(data)
    local out_t = {{str = '|#Top parent folders'}}
    for i = 1, CountTracks(0) do
      local tr = GetTrack(0,i-1)
      if GetTrackDepth( tr ) == 0 then
        out_t[#out_t+1] = { str =  ({GetTrackName( tr, '' )})[2],
                            func =  function() SendTracksTo_AddSend(data,tr) end}
      end
    end
    return out_t     
  end
  ---------------------------------------------------------
  function SendTracksTo_CollectPreDef(data)
    local out_t1 = {{str = '|#PreDefined sends list'}}
      for GUID in pairs(data.PreDefinedSend_GUID) do 
      local tr = BR_GetMediaTrackByGUID( 0, GUID )
      if tr then
        out_t1[#out_t1+1] = { str =  ({GetTrackName( tr, '' )})[2],
                            func =  function() SendTracksTo_AddSend(data, tr) end}
      end
    end
    return out_t1   
  end
  ---------------------------------------------------------
  function SendTracksTo_AddSend(data, dest_tr_ptr)
      if not dest_tr_ptr then return end
      local chan_id = 1
      for i = 1, #data.tr do
        local src_tr =  data.tr[i].ptr
        local ch_src = GetMediaTrackInfo_Value( src_tr, 'I_NCHAN')
        local ch_dest = GetMediaTrackInfo_Value( dest_tr_ptr, 'I_NCHAN')
        if ch_dest < ch_src then SetMediaTrackInfo_Value( dest_tr_ptr, 'I_NCHAN', ch_src) end
        
        local new_id = CreateTrackSend( src_tr, dest_tr_ptr )
        SetTrackSendInfo_Value( src_tr, 0, new_id, 'D_VOL', data.defsendvol)
        SetTrackSendInfo_Value( src_tr, 0, new_id, 'D_PAN', data.defsendpan) 
        SetTrackSendInfo_Value( src_tr, 0, new_id, 'I_SENDMODE', data.defsendflag)
           
        SetTrackSendInfo_Value( src_tr, 0, new_id, 'I_SRCCHAN', 0)
        --SetTrackSendInfo_Value( src_tr, 0, new_id, 'I_DSTCHAN',5)
      end
  end
  
  
