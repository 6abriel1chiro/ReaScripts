-- @description InfoTool_Widgets_Item
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @noindex


  -- Item wigets for mpl_InfoTool
  
  ---------------------------------------------------
  function Obj_UpdateItem(data, obj, mouse, widgets)
    obj.b.obj_name = { x = obj.menu_b_rect_side + obj.offs,
                        y = obj.offs *2 +obj.entry_h,
                        w = obj.entry_w,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt_a = obj.txt_a,
                        txt = data.it[1].name,
                        fontsz = obj.fontsz_entry,
                        func_DC = 
                          function ()
                            if data.it[1].name then
                              local retval0, retvals_csv = GetUserInputs( 'Rename', 1, 'New Name, extrawidth=220', data.it[1].name )
                              if not retval0 then return end
                              if      data.it[1].obj_type_int == 0  
                                  or  data.it[1].obj_type_int == 1 
                                  or  data.it[1].obj_type_int == 2 then
                                if data.it[1].ptr_take and ValidatePtr2(0, data.it[1].ptr_take,'MediaItem_Take*') then
                                  GetSetMediaItemTakeInfo_String( data.it[1].ptr_take, 'P_NAME', retvals_csv, true )
                                  redraw = 1
                                end
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
        if _G['Widgets_Item_'..key] then
            local ret = _G['Widgets_Item_'..key](data, obj, mouse, x_offs, widgets) 
            if ret then x_offs = x_offs + obj.offs + ret end
        end
      end  
    end
  end
  -------------------------------------------------------------- 







  --------------------------------------------------------------
  function Widgets_Item_position(data, obj, mouse, x_offs)    -- generate position controls 
    if not data.it then return end
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_pos = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Position'} 
    obj.b.obj_pos_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                        
                        
      local pos_str =  data.it[1].item_pos_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(pos_str),
                        table_key='position_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'item_pos',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_Pos,                         
                        mouse_scale= obj.mouse_scal_time})                         
    return obj.entry_w2
  end  
  function Apply_Item_Pos(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_POSITION', math.max(0,t_out_values[i] ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_pos( t_out_values[1], '', -1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- nudge values from first item
      local out_val = parse_timestr_pos(out_str_toparse,-1) 
      local diff = out_val - data.it[1].item_pos
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_POSITION', math.max(0,t_out_values[i] + diff ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_snap(data, obj, mouse, x_offs) -- generate snap_offs controls  
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_snap_offs = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Snap'} 
    obj.b.obj_snap_offs_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local snap_offs_str = data.it[1].snap_offs_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(snap_offs_str),
                        table_key='snap_offs_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'snap_offs',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_SnapOffs,                         
                        mouse_scale= obj.mouse_scal_time})                           
    return obj.entry_w2                         
  end
  
  function Apply_Item_SnapOffs(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_SNAPOFFSET', math.max(0,t_out_values[i] ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_len( t_out_values[1], '',0,-1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- directly set value from first item
      local out_val = parse_timestr_len(out_str_toparse,1,-1) 
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_SNAPOFFSET', math.max(0,out_val ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end   
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  -------------------------------------------------------------- 
  function Widgets_Item_pan(data, obj, mouse, x_offs) -- generate snap_offs controls  
    local pan_w = 60
    if x_offs + pan_w > obj.persist_margin then return x_offs end 
    obj.b.obj_it_pan = { x = x_offs,
                        y = obj.offs ,
                        w = pan_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Pan'} 
    obj.b.obj_it_pan_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = pan_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local it_pan_str = data.it[1].pan_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = {data.it[1].pan_format},
                        table_key='it_pan_ctrl',
                        x_offs= x_offs,  
                        w_com=pan_w,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'pan',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_Item_pan,                         
                        mouse_scale= obj.mouse_scal_pan,
                        use_mouse_drag_xAxis = true,
                        parse_pan_tags = true})                          
    return pan_w--obj.entry_w2                         
  end
  
  function Apply_Item_pan(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do        
        local out_val = math_q(t_out_values[i]*100)/100
        SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PAN', lim(out_val,-1,1) )
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      t_out_values[1] = lim(t_out_values[1], -1,1)
      local out_val = math_q(t_out_values[1]*100)/100
      local new_str = MPL_FormatPan(out_val)
      obj.b[butkey..1].txt = new_str
      redraw = 1
     else
      local out_val = 0
      if out_str_toparse:lower():match('r') then side = 1 
          elseif out_str_toparse:lower():match('l') then side = -1 
          elseif out_str_toparse:lower():match('c') then side = 0
          else side = 0
      end 
      local val = out_str_toparse:match('%d+')
      if not val then return end
      out_val = side * val/100
      --[[nudge
        local diff = data.it[1].pan - out_val
        for i = 1, #t_out_values do
          SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PAN', lim(t_out_values[i] - diff,-1,1) )
          UpdateItemInProject( data.it[i].ptr_item )                                
        end   ]]
      --set
        for i = 1, # data.it do
          local out_val = math_q(out_val*100)/100
          SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PAN', lim(out_val,-1,1) )
          UpdateItemInProject( data.it[i].ptr_item )                                
        end     
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_length(data, obj, mouse, x_offs) -- generate snap_offs controls  
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_len = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Length'} 
    obj.b.obj_len_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local len_str = data.it[1].item_len_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(len_str),
                        table_key='len_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'item_len',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_Length,                         
                        mouse_scale= obj.mouse_scal_time})                          
    return obj.entry_w2
  end
  
  function Apply_Item_Length(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        local out_len = math.max(0,t_out_values[i])
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_LENGTH', out_len )
        if data.it[i].isMIDI then
            local start_qn =  TimeMap2_timeToQN( 0, data.it[i].item_pos )
          local end_qn = TimeMap2_timeToQN(0, data.it[i].item_pos + out_len)
          MIDI_SetItemExtents(data.it[i].ptr_item, start_qn, end_qn)
        end
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_len( t_out_values[1],'', 1, -1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- nudge values from first item
      local out_val = parse_timestr_len(out_str_toparse,1,-1) 
      local diff = data.it[1].item_len - out_val
      for i = 1, #t_out_values do
        local out_len = math.max(0,t_out_values[i] - diff )
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_LENGTH', out_len)
        if data.it[i].isMIDI then
            local start_qn =  TimeMap2_timeToQN( 0, data.it[i].item_pos )
          local end_qn = TimeMap2_timeToQN(0, data.it[i].item_pos + out_len)
          MIDI_SetItemExtents(data.it[i].ptr_item, start_qn, end_qn)
        end        
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------
  function Widgets_Item_offset(data, obj, mouse, x_offs)    -- generate position controls 
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_start_offs = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Offset'} 
    obj.b.obj_start_offs_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                        
                        
      local start_offs_str = data.it[1].start_offs_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(start_offs_str),
                        table_key='start_offs_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'start_offs',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_Offset,                         
                        mouse_scale= obj.mouse_scal_time})                            
    return obj.entry_w2                         
  end  
  function Apply_Item_Offset(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_STARTOFFS', t_out_values[i] )
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_len( t_out_values[1], '',1, -1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- nudge values from first item
      local out_val = parse_timestr_len(out_str_toparse,1,-1) 
      local diff = data.it[1].start_offs - out_val
      for i = 1, #t_out_values do
        SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_STARTOFFS', t_out_values[i] - diff )
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      redraw = 2   
    end
  end    
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_fadein(data, obj, mouse, x_offs) -- generate snap_offs controls  
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_fadein = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'FadeIn'} 
    obj.b.obj_fadein_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local fadein_str = data.it[1].fadein_len_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(fadein_str),
                        table_key='fadein_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'fadein_len',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_fadein,                         
                        mouse_scale= obj.mouse_scal_time})                         
    return obj.entry_w2
  end
  
  function Apply_Item_fadein(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_FADEINLEN', math.max(0,t_out_values[i] ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_len( t_out_values[1], '', 0, -1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- directly set value from first item
      local out_val = parse_timestr_len(out_str_toparse,1,-1) 
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_FADEINLEN',math.max(0, out_val ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end   
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_fadeout(data, obj, mouse, x_offs) -- generate snap_offs controls  
    if x_offs + obj.entry_w2 > obj.persist_margin then return x_offs end 
    obj.b.obj_fadeout = { x = x_offs,
                        y = obj.offs ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'FadeOut'} 
    obj.b.obj_fadeout_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local fadeout_str = data.it[1].fadeout_len_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues(fadeout_str),
                        table_key='fadeout_ctrl',
                        x_offs= x_offs,  
                        w_com=obj.entry_w2,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'fadeout_len',
                        modify_func= MPL_ModifyTimeVal,
                        app_func= Apply_Item_fadeout,                         
                        mouse_scale= obj.mouse_scal_time})                          
    return obj.entry_w2
  end
  
  function Apply_Item_fadeout(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_FADEOUTLEN', math.max(0,t_out_values[i] ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = format_timestr_len( t_out_values[1], '', 0, -1 ) 
      local new_str_t = MPL_GetTableOfCtrlValues(new_str)
      for i = 1, #new_str_t do
        obj.b[butkey..i].txt = new_str_t[i]
      end
     else
      -- directly set value from first item
      local out_val = parse_timestr_len(out_str_toparse,1,-1) 
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_FADEOUTLEN',math.max(0, out_val ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end   
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_vol(data, obj, mouse, x_offs) -- generate snap_offs controls 
    local vol_w = 60 
    if x_offs + vol_w > obj.persist_margin then return x_offs end 
    obj.b.obj_vol = { x = x_offs,
                        y = obj.offs ,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Volume'} 
    obj.b.obj_vol_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = vol_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        fontsz = obj.fontsz_entry,
                        ignore_mouse = true}  
                
      local vol_str = data.it[1].vol_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues2(vol_str),
                        table_key='vol_ctrl',
                        x_offs= x_offs,  
                        w_com=vol_w,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'vol',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_Item_vol,                         
                        mouse_scale= obj.mouse_scal_vol,
                        ignore_fields = true})                           
    return vol_w--obj.entry_w2                         
  end
  
  function Apply_Item_vol(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_VOL', math.max(0,t_out_values[i] ))
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      if t_out_values[1] < 0 then return end
      local new_str = string.format("%.2f", t_out_values[1])
      local new_str_t = MPL_GetTableOfCtrlValues2(new_str)
      if new_str_t then 
        for i = 1, #new_str_t do
          if obj.b[butkey..i] then obj.b[butkey..i].txt = '' end--new_str_t[i]
        end
        obj.b.obj_vol_back.txt = dBFromReaperVal(t_out_values[1])..'dB'
      end
     else
      local out_val = tonumber(out_str_toparse) 
      out_val = ReaperValfromdB(out_val)
      out_val = math.max(0,out_val) 
      --[[nudge
        local diff = data.it[1].vol - out_val
        for i = 1, #t_out_values do
          SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_VOL', math.max(0,t_out_values[i] - diff ))
          UpdateItemInProject( data.it[i].ptr_item )                                
        end   ]]
      --set
        for i = 1, #t_out_values do
          SetMediaItemInfo_Value( data.it[i].ptr_item, 'D_VOL', math.max(0,out_val ))
          UpdateItemInProject( data.it[i].ptr_item )                                
        end     
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 







  --------------------------------------------------------------   
  function Widgets_Item_transpose(data, obj, mouse, x_offs)
    local pitch_w = 60
    if x_offs + pitch_w > obj.persist_margin then return x_offs end 
    obj.b.obj_pitch = { x = x_offs,
                        y = obj.offs ,
                        w = pitch_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_head,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_header,
                        txt = 'Pitch'} 
    obj.b.obj_pitch_back = { x =  x_offs,
                        y = obj.offs *2 +obj.entry_h ,
                        w = pitch_w,--obj.entry_w2,
                        h = obj.entry_h,
                        frame_a = obj.frame_a_entry,
                        txt = '',
                        ignore_mouse = true}  
                
      local pitch_str = data.it[1].pitch_format
      Obj_GenerateCtrl(  { data=data,obj=obj,  mouse=mouse,
                        t = MPL_GetTableOfCtrlValues2(pitch_str, 2),
                        table_key='pitch_ctrl',
                        x_offs= x_offs,  
                        w_com=pitch_w,--obj.entry_w2,
                        src_val=data.it,
                        src_val_key= 'pitch',
                        modify_func= MPL_ModifyFloatVal,
                        app_func= Apply_Item_transpose,                         
                        mouse_scale= obj.mouse_scal_pitch,
                        pow_tolerance = -2})                          
    return pitch_w--obj.entry_w2                         
  end
  
  function Apply_Item_transpose(data, obj, t_out_values, butkey, out_str_toparse)
    if not out_str_toparse then    
      for i = 1, #t_out_values do
        SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PITCH', t_out_values[i])
        UpdateItemInProject( data.it[i].ptr_item )                                
      end
      local new_str = tostring(t_out_values[1])
      local new_str_t = MPL_GetTableOfCtrlValues2(new_str)
      if new_str_t then 
        for i = 1, #new_str_t do
          obj.b[butkey..i].txt = new_str_t[i]
        end
      end
     else
      local out_val = tonumber(out_str_toparse) 
      local diff = data.it[1].pitch - out_val
      for i = 1, #t_out_values do
        SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'D_PITCH', t_out_values[i] - diff )
        UpdateItemInProject( data.it[i].ptr_item )                                
      end   
      redraw = 2   
    end
  end  
  -------------------------------------------------------------- 





  
  
  --------------------------------------------------------------  
  function Widgets_Item_buttons(data, obj, mouse, x_offs0, widgets)
    local frame_a, x_offs, y_offs
    if x_offs0 + obj.entry_w2*2 > obj.persist_margin then return x_offs0 end  -- reduce buttons when more than regular wx2
    local last_x1,last_x2 = x_offs0, x_offs0
    local tp_ID = data.obj_type_int
    local widg_key = widgets.types_t[tp_ID+1] -- get key of current mapped table
    if widgets[widg_key] and widgets[widg_key].buttons  then  
      for i = 1, #widgets[widg_key].buttons do 
        local key = widgets[widg_key].buttons[i]
        if _G['Widgets_Item_buttons_'..key] then  
          if i%2 == 1 then 
            x_offs = last_x1
            frame_a = obj.frame_a_head
            y_offs = 0
           elseif i%2 == 0 then   
            x_offs = last_x2 
            frame_a = obj.frame_a_entry
            y_offs = obj.entry_h
          end
          local next_w = _G['Widgets_Item_buttons_'..key](data, obj, mouse, x_offs, y_offs, frame_a)
          if i%2 == 1 then last_x1 = last_x1+next_w elseif i%2 == 0 then last_x2 = last_x2+next_w end
  
        end
        
      end
    end
    return math.max(last_x1,last_x2) - x_offs0
  end  
  -------------------------------------------------------------- 
  function Widgets_Item_buttons_lock(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 40*obj.entry_ratio
    obj.b.obj_itlock = {  x = x_offs,
                        y = y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_toolbar,
                        txt = 'Lock',
                        fontsz = obj.fontsz_entry,
                        state = data.it[1].lock==1,
                        state_col = 'red',
                        func =  function()
                                  for i = 1, #data.it do
                                    SetMediaItemInfo_Value( data.it[i].ptr_item, 'C_LOCK', math.abs(data.it[1].lock-1))
                                    UpdateItemInProject( data.it[i].ptr_item )                                
                                  end
                                  redraw = 1                              
                                end,
                        func_R =  function()
                                    Main_OnCommand(40277,0) --  Options: Show lock settings                        
                                  end,                                
                                
                                }
    return w
  end
  -------------------------------------------------------------- 
  function Widgets_Item_buttons_bwfsrc(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 40*obj.entry_ratio
    obj.b.obj_bwfsrc = {  x = x_offs,
                        y =y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_toolbar,
                        txt = 'BWF',
                        fontsz = obj.fontsz_entry,
                        func =  function()
                                  Main_OnCommand(40299,0) --Item: Move to source preferred position (used by BWF)                   
                                  end,                                
                                
                                }
    return w
  end
  --------------------------------------------------------------
  function Widgets_Item_buttons_loop(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 40*obj.entry_ratio
    obj.b.obj_loop = {  x = x_offs,
                        y = obj.offs+y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        fontsz = obj.fontsz_entry,
                        txt_col = obj.txt_col_toolbar,
                        txt = 'Loop',
                        state = data.it[1].loop==1,
                        state_col = 'green',
                        func =  function()
                                  for i = 1, #data.it do                                    
                                    SetMediaItemInfo_Value( data.it[i].ptr_item, 'B_LOOPSRC', math.abs(data.it[1].loop-1))
                                    UpdateItemInProject( data.it[i].ptr_item )                                
                                  end
                                  redraw = 1                              
                                end}
    return w
  end 
  --------------------------------------------------------------
  function Widgets_Item_buttons_preservepitch(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 90*obj.entry_ratio
    obj.b.obj_preservepitch = {  x = x_offs,
                        y = obj.offs+y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        fontsz = obj.fontsz_entry,
                        txt_col = obj.txt_col_toolbar,
                        txt = 'Preserve Pitch',
                        state = data.it[1].preservepitch==1,
                        state_col = 'green',
                        func =  function()
                                  for i = 1, #data.it do
                                    SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'B_PPITCH', math.abs(data.it[1].preservepitch-1))
                                    UpdateItemInProject( data.it[i].ptr_item )                                
                                  end
                                  redraw = 1                              
                                end}
    return w
  end  
  
  --------------------------------------------------------------
  function Widgets_Item_buttons_mute(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 40*obj.entry_ratio
    obj.b.obj_itmute = {  x = x_offs,
                        y = obj.offs+y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        txt_col = obj.txt_col_toolbar,
                        txt = 'Mute',
                        fontsz = obj.fontsz_entry,
                        state = data.it[1].mute==1,
                        state_col = 'red',
                        func =  function()
                                  for i = 1, #data.it do
                                    SetMediaItemInfo_Value( data.it[i].ptr_item, 'B_MUTE', math.abs(data.it[1].mute-1))
                                    UpdateItemInProject( data.it[i].ptr_item )                                
                                  end
                                  redraw = 1                              
                                end}
    return w
  end
  --------------------------------------------------------------
  function Widgets_Item_buttons_chanmode(data, obj, mouse, x_offs, y_offs, frame_a)
    local w = 100*obj.entry_ratio
    local txt = '-'
    if data.it[1].chanmode == 0 then 
      txt = 'ChMode: Norm'
     elseif data.it[1].chanmode == 1 then 
      txt = 'ChMode: Rev'     
     elseif data.it[1].chanmode == 2 then 
      txt = 'ChMode: L+R'
     elseif data.it[1].chanmode == 3 then 
      txt = 'ChMode: L'   
     elseif data.it[1].chanmode == 4 then 
      txt = 'ChMode: R'                     
    end
    obj.b.obj_itchanmode = {  x = x_offs,
                        y = obj.offs+y_offs ,
                        w = w,
                        h = obj.entry_h,
                        frame_a = frame_a,
                        txt_a = obj.txt_a,
                        fontsz = obj.fontsz_entry,
                        txt_col = obj.txt_col_toolbar,
                        txt = txt,
                        func =  function()
                                                    
                                  Menu(mouse, {
                                          {str = 'Channel mode: Normal',
                                          func = function() Apply_Item_ChanMode(data, 0) end},
                                          {str = 'Channel mode: Reverse',
                                          func = function() Apply_Item_ChanMode(data, 1) end},
                                          {str = 'Channel mode: Downmix',
                                          func = function() Apply_Item_ChanMode(data, 2) end},
                                          {str = 'Channel mode: Left',
                                          func = function() Apply_Item_ChanMode(data, 3) end},
                                          {str = 'Channel mode: Right',
                                          func = function() Apply_Item_ChanMode(data, 4) end},                                                                                                                                                                                                               
                                         
                                        })
                                                              
                                end
                          }
    return w
  end
  -------------------------------------------------------------- 
  function Apply_Item_ChanMode(data, app_val)
    for i = 1, #data.it do
      SetMediaItemTakeInfo_Value( data.it[i].ptr_take, 'I_CHANMODE', app_val)
      UpdateItemInProject( data.it[i].ptr_item )                                
    end
    redraw = 1 
  end