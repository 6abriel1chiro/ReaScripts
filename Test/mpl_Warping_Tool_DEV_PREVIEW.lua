  ------  Michael Pilyavskiy ------
  ---------- Warping tool ---------
  
  fontsize = 16
enable_display_graph = 1

-- warping if 2 or more items
  -- (check for rms matching (currently have no idea how to implement this))
  -- get rms envelope
  -- get fft rise envelope
  -- get stretch markers in selected items 
  -- quantize stretch markers of lower items to stretch markers of first item

-- tempo warp if one item
  -- get stretch markers in selected item (settings)
  -- calculate true beat markers
  -- average tempo
  -- delete wrong markers
  -- add approximately markers on every potential area  
  
-- actions
  -- add tempo envelope from bar/beat markers
  -- stretch beats to grid by markers index


  vrs = "0.11"
 
  ---------------------------------------------------------------------------------------------------------------              
  changelog =                              
[===[ Changelog:
12.10.2015  0.11
            area knob
11.10.2015  0.1
            gui, displays, get item data, get potential stretch markers
01.09.2015  0.01 
            alignment/warping/tempomatching tool idea 
    
 ]===]

 ---------------------------------------------------------------------------------------------------------------  
   function test(test)  
      if test ~= nil then  reaper.ShowConsoleMsg("") reaper.ShowConsoleMsg(test) end
   end

  ---------------------------------------------------------------------------------------------------------------    
  function limit(var,lim_min,lim_max)  
    if var < lim_min then var = lim_min end
    if var > lim_max then var = lim_max end
    return var
  end
  
  ---------------------------------------------------------------------------------------------------------------  
  function extract_table(table,color_set)
    if table ~= nil then
      a = table[1]
      b = table[2]
      c = table[3]
      d = table[4]
    end  
    if color_set then gfx.r,gfx.g,gfx.b = a,b,c end
    return a,b,c,d
  end  
 
 ---------------------------------------------------------------------------------------------------------------    
  function conv_val2norm(v,v_min,v_max,inv)
    if inv then
      v_ret = ((v-v_max)/math.abs(v_min-v_max))+1 
     else 
      v_ret = (v - v_min) / (v_max-v_min)
    end
    return v_ret
  end

 ---------------------------------------------------------------------------------------------------------------    
  function conv_norm2val(v_norm,v_min,v_max, inv)
    if inv then
      v = ((v_norm-1)*math.abs(v_min-v_max))+v_max
     else
      v = v_norm*(v_max-v_min)+v_min  
    end
    return v
  end
  
 ---------------------------------------------------------------------------------------------------------------    
  function DEFINE_default_variables()
    sel_items_t ={}
    cur_item = 1 
    
    window_time = 0.085 -- sec
    window_time_min = 0.02
    window_time_max = 0.4
        
    threshold = -55
    threshold_min = -80
    threshold_max = -10    
    
    s_area = 10
    s_area_min = 2
    s_area_max = 30
    
    mouse_res = 200 -- for knobs resolution
    
    
--[[    fft_size0 = 512              -- fft size
    fft_start_index = 1          -- =highpass
    fft_end_index = 512 -- = lowpass]]
    
  end  

  ---------------------------------------------------------------------------------------------------------------    
  function DEFINE_default_variables_GUI()
    main_w = 440
    main_h = 355
    x_offset = 5
    y_offset = 5
    offset = 5
    knob_w = 55
    knob_h = 65
    knob_r = knob_w/2-2
    nav_button_w = 50
    displ_h = 55
    
    frame = 0.15
    frame_knob = 0.02
    frame_knob_outarc = 0.7
    fontsize2 = fontsize+1
    fontsize3 = fontsize -2
    
  
    --coordinates
      -- top window
        --get1 button
        window1_xywh_t = {x_offset-1, y_offset, main_w-x_offset*2, displ_h*2+offset}
        --1st item display
        window0_xywh_t = {x_offset, y_offset, main_w-nav_button_w-x_offset*3, displ_h}
        --2nd item display
        window2_xywh_t = {x_offset, y_offset+displ_h+offset, main_w-nav_button_w-x_offset*3, displ_h}
        text1_xywh_t = {x_offset, y_offset+40, main_w-nav_button_w-x_offset*3, 20}
        text2_xywh_t = {x_offset, y_offset+100, main_w-nav_button_w-x_offset*3, 20}        
        nav_button2_xywh_t = {window0_xywh_t[1]+window0_xywh_t[3]+x_offset,
                              window1_xywh_t[2],
                              nav_button_w,
                              window1_xywh_t[4]/3-offset/2}
        nav_button3_xywh_t = {window0_xywh_t[1]+window0_xywh_t[3]+x_offset,
                              window1_xywh_t[2]+window1_xywh_t[4]/3+offset/2,
                              nav_button_w,
                              window1_xywh_t[4]/3-offset/2}                                
        nav_button4_xywh_t = {window0_xywh_t[1]+window0_xywh_t[3]+x_offset,
                              window1_xywh_t[2]+window1_xywh_t[4]/3*2+offset-1,
                              nav_button_w,
                              window1_xywh_t[4]/3-offset/2} 
      -- middle window
        --detection params
        window_m2_xywh_t = {window1_xywh_t[1], window1_xywh_t[2]+window1_xywh_t[4]+offset,
          window0_xywh_t[3],window1_xywh_t[4]-20}
          -- window size knob
            w2_knob1_xywh_t = {window_m2_xywh_t[1] + offset,
                               window_m2_xywh_t[2] + offset,
                               knob_w, knob_h}
          -- threshold knob
            w2_knob2_xywh_t = {window_m2_xywh_t[1] + offset*2 + knob_w,
                               window_m2_xywh_t[2] + offset,
                               knob_w, knob_h}
          -- search area knob
            w2_knob3_xywh_t = {window_m2_xywh_t[1] + offset*3 + knob_w*2,
                               window_m2_xywh_t[2] + offset,
                               knob_w, knob_h}
                                                              
        --get2 button
        window_m1_xywh_t = {window0_xywh_t [1]+window0_xywh_t [3]+offset, window1_xywh_t[2]+window1_xywh_t[4]+offset, 
          nav_button_w, window_m2_xywh_t[4]}                  
                                
    -- colors
      color5_t = {0.2, 0.2, 0.2} -- back1
      color6_t = {0.2, 0.22, 0.22} -- back2
      
      color1_t = {0.4, 1, 0.4} -- green
      color2_t = {0.5, 0.8, 1} -- blue      
      color3_t = {1, 1, 1}-- white
      color4_t = {0.8, 0.5, 0.2} -- red

      rms_color_t = {0.9, 0.3, 0.0}
  end

  ---------------------------------------------------------------------------------------------------------------       

  function DEFINE_dynamic_variables_GUI()
    -- one or two displays on top
    if #sel_items_t <2 then 
      window1_xywh_t = {x_offset-1, y_offset, main_w-x_offset*2, displ_h*2+offset}
      window0_xywh_t = {x_offset, y_offset, main_w-x_offset*2, displ_h*2 + offset}
      text1_xywh_t = {x_offset, y_offset+100, main_w-nav_button_w-x_offset*3, 20}
     else
      window1_xywh_t = {x_offset-1, y_offset, main_w-x_offset*3-nav_button_w, displ_h*2+offset}
      window0_xywh_t = {x_offset, y_offset, main_w-nav_button_w-x_offset*3, displ_h}
      text1_xywh_t = {x_offset, y_offset+40, main_w-nav_button_w-x_offset*3, 20}
    end 
    
    if show_get_button == true then get_button_name = '[ Store selected items ]' else get_button_name = 'Store selected items' end
    if show_get_button2 == true then get_button_name2 = '[ Add ]' else get_button_name2 = 'Add' end
    
    
  end
  
  ---------------------------------------------------------------------------------------------------------------       
  function ENGINE1_get_items()
    sel_items_t = {}
    item_data_t = {}
    count_items = reaper.CountSelectedMediaItems()
    if count_items ~= nil then 
      ref_item = reaper.GetSelectedMediaItem(0, 0)
      if ref_item ~= nil then
        ref_item_pos = reaper.GetMediaItemInfo_Value(ref_item,"D_POSITION")
        ref_item_len = reaper.GetMediaItemInfo_Value(ref_item,"D_LENGTH")
      end  
      for i =1, count_items do 
        item = reaper.GetSelectedMediaItem(0, i-1)
        if item ~= nil then
          take = reaper.GetActiveTake(item)
          if not reaper.TakeIsMIDI(take) then
            item_guid = reaper.BR_GetMediaItemGUID(item)
            table.insert(sel_items_t, item_guid)
          end
        end    
      end        
    end    
  end
  
  ---------------------------------------------------------------------------------------------------------------         
  function ENGINE1_get_item_data(item_id)
    if #sel_items_t > 0 then
      item = reaper.BR_GetMediaItemByGUID(0, sel_items_t[item_id])
      if item ~= nil then
        item_pos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
        item_len = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
        take = reaper.GetActiveTake(item) 
        track = reaper.GetMediaItem_Track(item)
        retval, trackname = reaper.GetSetMediaTrackInfo_String(track, 'P_NAME','', false)
        if not reaper.TakeIsMIDI(take) then
          displayed_item_name = trackname..'   /   '..reaper.GetTakeName(take)
          displayed_item_name2 = 'Item '..math.floor(item_id)..' of '..#sel_items_t
          if item_id == 1 then displayed_item_name2 = displayed_item_name2..' (reference item)' end
                    
          --get accesor samples values+rms
          rms_val_t = {}
          audio_accessor = reaper.CreateTakeAudioAccessor(take)
            src = reaper.GetMediaItemTake_Source(take)
            src_num_ch = 1--reaper.GetMediaSourceNumChannels(src)
            src_rate = reaper.GetMediaSourceSampleRate(src)              
            window_samples = math.floor(src_rate * window_time)
            
            --fill from left
            item_rel_offset1 = item_pos - ref_item_pos
            if item_rel_offset1 > 0 then 
              for i = 0, item_rel_offset1-window_time, window_time do
                table.insert(rms_val_t, 0) end
            end
            
            --loop through windows
            for read_pos = 0, item_len, window_time do              
              if read_pos+item_pos > ref_item_pos and read_pos+item_pos < ref_item_pos+ref_item_len then
                audio_accessor_buffer = reaper.new_array(window_samples)
                reaper.GetAudioAccessorSamples(audio_accessor,src_rate,src_num_ch,read_pos,window_samples,audio_accessor_buffer)
                -- read window rms
                  rms = 0
                  audio_accessor_buffer_t = audio_accessor_buffer.table(1, window_samples)
                  for i = 1, window_samples do
                    sample_value = audio_accessor_buffer_t[i]
                    sample_value_abs = math.abs(sample_value)
                    rms = rms + sample_value_abs
                  end
                  rms = rms / window_samples
                  table.insert(rms_val_t, rms)             
                audio_accessor_buffer_t = {}
                audio_accessor_buffer.clear()                              
              end -- check if inside ref_item  
            end -- loop every window
            
            --fill from right
            item_rel_offset2 = ref_item_pos+ref_item_len - (item_pos+item_len)
            if item_rel_offset2 > 0 then 
              for i = 0, item_rel_offset2, window_time do
                table.insert(rms_val_t, 0) end
            end
                    
          reaper.DestroyAudioAccessor(audio_accessor)     
        end -- if not midi  
      end -- if item ~= nil
      
      
      com_val_t={}
      if rms_val_t ~= nil then data_table_size = #rms_val_t end
--      if fft_val_t ~= nil then data_table_size = #fft_val_t end
      for i=1, data_table_size do
        rms_val_t_item = rms_val_t[i]
        table.insert(com_val_t, rms_val_t_item)  
      end
      
      -- normalize table
      local max_com = 0
      for i =1, #com_val_t do max_com = math.max(max_com, com_val_t[i]) end
      com_mult = 1/max_com      
      for i =1, #com_val_t do com_val_t[i]= com_val_t[i]*com_mult  end
      
      sm_t = ENGINE2_get_stretch_markers(com_val_t)
      
      data_t = {displayed_item_name, --1
                displayed_item_name2, --2
                item_pos, --3
                item_pos, --4
                read_pos0,
                com_val_t, --5
                sm_t}    
          
      return data_t    
    end -- sel_items_t ~= nil        
    
    
              --[[
              
              
            
        
              -- get peaks table          
              -- get rms table           
                item_peaks_t = {}
                rms_val_t = {}
                
                  
                  peaks_in_window = 1         
                  for i =1, peaks_in_window do
                    table.insert(item_peaks_t, audio_accessor_buffer_t[i])
                    if window_samples / peaks_in_window > 2 then
                      table.insert(item_peaks_t, audio_accessor_buffer_t[math.floor(window_samples/i)])
                    end
                  end            
                  
                end
                
              -- get fft sum table 
                fft_sum_t = {}    
                for read_pos = 0, item_len-window_time, window_time do
                  audio_accessor_buffer = reaper.new_array(window_samples*2)
                  reaper.GetAudioAccessorSamples(audio_accessor, src_rate, src_num_ch, read_pos, window_samples*2, audio_accessor_buffer)
                         fft_size = fft_size0*2
                  repeat fft_size = fft_size/2 until fft_size < window_samples             
                  audio_accessor_buffer.fft(fft_size, true, 1)
                  fft_sum = 0
                  audio_accessor_buffer_fft_t = audio_accessor_buffer.table(1, fft_size)                          
                  fft_end_index1 = fft_end_index / (fft_size0/fft_size)
                  for i = fft_start_index, fft_end_index1  do
                    value = audio_accessor_buffer_fft_t[i]
                    value_abs = math.abs(value)
                    fft_sum = fft_sum + value_abs
                  end
                  fft_sum = fft_sum / window_samples
                  table.insert(fft_sum_t, fft_sum)             
                  audio_accessor_buffer.clear()
                end        
              
            end
          end  
        end  
         
        -- generate com table   
          com_val_t = {}   
          for i = 1, math.ceil((item_len-window_time) / window_time) do
            table.insert(com_val_t, fft_sum_t[i]  +  rms_val_t[i] ) end
        ]]
end

  ---------------------------------------------------------------------------------------------------------------       
  function ENGINE2_get_stretch_markers(data_t)
    sm_data_t = {}
    -- 1 check couple of windows
      for i = 1, #data_t, s_area do
        if i+s_area-1 < #data_t then
          -- 2 search max point value in window
          local max_point = 0
          for j =0, s_area-1 do
            data_t_item = data_t[i+j]
            max_point = math.max(max_point, data_t_item)
          end                    
          --search max point around couple of windows
          for j =0, s_area-1 do
            data_t_item = data_t[i+j]
            -- check if max point around couple of windows more than thresold
            if data_t_item == max_point and 20*math.log(max_point) > threshold then
              table.insert(sm_data_t,1)
             else table.insert(sm_data_t,0)
            end
          end
            
        end
      end
    
    return sm_data_t
  end
        
  ---------------------------------------------------------------------------------------------------------------       
  function GUI_item_display(data_t, xywh_t0,show_name, color_t,text_xywh_t)
    -- 1 displayed_item_name
    -- 2 displayed_item_name2
    -- 3 item_pos
    -- 4 item_len
    -- 5 offset rel to ref item pos
    -- 6 com_val_t
    -- 7 sm table
    local X0,Y,W0,H0 = extract_table(xywh_t0)
    X=X0+1
    W = W0-1
    H = H0-20

    if data_t ~= nil then
      --draw display back
        gfx.gradrect(X,Y,W,H, 1,1,1,0.001, 0,0,0,0.0001, 0,0,0,0.001)    

      --draw take name
      if data_t[2] ~= nil then
        gfx.setfont(1, font, fontsize)
        measurestrname = gfx.measurestr(data_t[1])  
        x0 = X0 + (W0- measurestrname)/2
        y0 = Y + H + 2
        gfx.x, gfx.y = x0,y0
        extract_table(color_t,true)
        gfx.a = 1
        gfx.drawstr(data_t[1]) end 
          
      --draw rms envelope
      local com_val_t = data_t[6]
      if com_val_t ~= nil then
        gfx.x, gfx.y = X,Y
        extract_table(color_t,true)
        gfx.a = 0.9
        for i =2, #com_val_t do
          prev_com_peak = com_val_t[i-1]
          com_peak = com_val_t[i]
          y1 = Y+H-(prev_com_peak*H)
          y2 = Y+H-(com_peak*H)
          gfx.line( X+(W/#com_val_t) * (i-1)-(W/#com_val_t+1)+1, y1,
            X+(W/#com_val_t) * i -(W/#com_val_t+1)+1, y2,1) end --for loop
        gfx.line( X+(W/#com_val_t) * (#com_val_t)-(W/#com_val_t+1), y2,
          X+W-1, y2,0.5) end -- rms
      
      -- draw sm
        local sm_t = data_t[7]
        extract_table(color4_t,true)
        gfx.a = 0.9
        for i=1,#sm_t do
          sm_t_item = sm_t[i]
          if sm_t_item == 1 then
            gfx.line(X+W/#com_val_t*(i-1), Y+H-1,
                     X+W/#com_val_t*(i-1), Y+H-H*com_val_t[i], 1)
          end
        end--end draw sm
      
    end--if data~= nil
    
    -- frame -- 
      x,y,w,h = extract_table(xywh_t0)
      extract_table(color_t,true)
      gfx.a = frame
      gfx.roundrect(x-1,y,w,h,0.1, true)
  end
  
  ---------------------------------------------------------------------------------------------------------------     
  function GUI_button(xywh_t, name, frame_alpha, font_color, fsize)      
      x,y,w,h = extract_table(xywh_t)      
      gfx.x, gfx.y = x, y      
      --fill background
      extract_table(color6_t, true)
      gfx.a = 0.92
      gfx.rect(x,y,w,h)
           
      -- draw name -- 
      gfx.setfont(1, font, fsize)
      measurestrname = gfx.measurestr(name)  
      x0 = x + (w - measurestrname)/2
      y0 = y + (h - fontsize)/2
      gfx.x, gfx.y = x0,y0
      extract_table(font_color,true)
      gfx.a = 1
      gfx.drawstr(name)
      
      -- help frame -- 
      extract_table(color3_t, true)
      gfx.a = frame_alpha
      gfx.roundrect(x,y,w,h,0.1, true)
  end

  ---------------------------------------------------------------------------------------------------------------       
  function GUI_knob(xywh_t,val,knob_val,knob_name)
    local x,y,w,h = extract_table(xywh_t)
    
    -- frame -- 
      extract_table(color3_t, true)
      gfx.a = frame_knob
      gfx.roundrect(x,y,w,h,0.1, true)
    -- out arc
      extract_table(color3_t, true)
      gfx.a = frame_knob_outarc
      gfx.x,gfx.y = x,y
      gfx.arc(x+w/2,y+knob_r+offset,knob_r,math.rad(-130),math.rad(130),1)
    -- circ
      extract_table(color1_t, true)
      gfx.a = 1
      if val ~= nil then
        val_grad = val*240-30
        circ_x = x+w/2 - knob_r*math.cos(math.rad(val_grad))
        circ_y = y+knob_r+offset - knob_r*math.sin(math.rad(val_grad))
        gfx.circle(circ_x,circ_y,3,1,2)
      end 
    -- val
      gfx.setfont(1, font, fontsize3)
      local measurestrname = gfx.measurestr(knob_val)  
      gfx.x, gfx.y = x+w/2-measurestrname/2, y+knob_r-2
      extract_table(color3_t, true)
      gfx.a = 1
      gfx.drawstr(knob_val)
    -- name
      gfx.setfont(1, font, fontsize3)
      local measurestrname = gfx.measurestr(knob_name)  
      gfx.x, gfx.y = x+w/2-measurestrname/2, y+h-fontsize3
      extract_table(color3_t, true)
      gfx.a = 1
      gfx.drawstr(knob_name)
      
            
  end
   
  ---------------------------------------------------------------------------------------------------------------     
  function GUI_DRAW()
    -- background
      extract_table(color5_t, true)
      gfx.a = 1
      gfx.rect(0,0,main_w,main_h)
    
    -- top window            
      -- show item peaks
        if enable_display_graph == 1 then 
          GUI_item_display(ref_item_data_t,window0_xywh_t,true,color1_t,text1_xywh_t)
          if #sel_items_t > 1 then GUI_item_display(item_data_t,window2_xywh_t,true,color2_t,text2_xywh_t) end
         else
          if #sel_items_t > 0 then 
            x,y,w,h = extract_table(window1_xywh_t)
            gfx.setfont(1, font, fontsize)
            measurestrname = gfx.measurestr('Item RMS / FFT graphs are disabled')  
            gfx.x, gfx.y = x+(w-measurestrname)/2,y+offset
            extract_table(color3_t, true)
            gfx.a = 1
            gfx.drawstr('Item RMS / FFT graphs are disabled')
          end  
        end
      -- nav buttons                  
        if #sel_items_t > 1 then  
          GUI_button(nav_button3_xywh_t, '<', frame, color2_t, fontsize)
          GUI_button(nav_button4_xywh_t, '>', frame, color2_t, fontsize)
          GUI_button(nav_button2_xywh_t, math.floor(cur_item)..' / '..#sel_items_t, 0.1, color2_t,fontsize) end      
      -- get button
        if #sel_items_t == 0 then show_get_button=true end
        if show_get_button then 
          GUI_button(window1_xywh_t, get_button_name , 0.8, color3_t,fontsize2)  end     
           
    -- middle window
      -- get button
        if #sel_items_t > 0 then GUI_button(window_m1_xywh_t, get_button_name2, 0.8, color3_t,fontsize2) end
      -- detection settings 
        if #sel_items_t > 0 then 
          -- settings com frame -- 
          x,y,w,h = extract_table(window_m2_xywh_t)
          extract_table(color3_t, true)
          gfx.a = frame
          gfx.roundrect(x,y,w,h,0.1, true)
          -- settings gradrect
          gfx.gradrect(x,y,w,h-20, 1,1,1,0.0005, 0,0,0,0.00005, 0,0,0,0.00009) 
          -- name
          gfx.setfont(1, font, fontsize)
          measurestrname = gfx.measurestr('Stretch markers detection settings')  
          gfx.x, gfx.y = x+(w-measurestrname)/2,y+h-fontsize-2
          extract_table(color3_t, true)
          gfx.a = 1
          gfx.drawstr('Stretch markers detection settings')
          
          --knobs
          
          k1_val = math.floor(window_time*1000)..' ms'          
            GUI_knob(w2_knob1_xywh_t, k1_val_norm, k1_val, "Window")                   
          k2_val = math.floor(threshold)..' dB'
            GUI_knob(w2_knob2_xywh_t, k2_val_norm, k2_val, "Threshold")
          k3_val = math.floor(s_area*window_time*1000)..' ms'
            GUI_knob(w2_knob3_xywh_t, k3_val_norm, k3_val, "Area")            
          
        end -- if sel items table size > 0  
        
        
    char = gfx.getchar()
    gfx.update()    
  end
  
  ---------------------------------------------------------------------------------------------------------------  
  function MOUSE_gate(mb, b)
    local state    
    if MOUSE_match_xy(b) then       
     if mb == 1 then if LMB_state and not last_LMB_state then state = true else state = false end end
     if mb == 2 then if RMB_state and not last_RMB_state then state = true else state = false end end 
     if mb == 64 then if MMB_state and not last_MMB_state then state = true else state = false end end        
    end   
    return state
  end
  
  ---------------------------------------------------------------------------------------------------------------  
  function MOUSE_match_xy(b)
    if    mx > b[1] 
      and mx < b[1]+b[3]
      and my > b[2]
      and my < b[2]+b[4] then
     return true 
    end 
  end

  ---------------------------------------------------------------------------------------------------------------   
  function MOUSE_knob(xywh_t,last_mouse_obj_name,knob_val_norm0 , knob_val_norm)
    if MOUSE_gate(1, xywh_t) and not last_LMB_state then
      knob_val_norm0 = knob_val_norm
      last_mouse_obj = last_mouse_obj_name
    end
    
    if LMB_state and last_mouse_obj == last_mouse_obj_name and knob_val_norm0 ~= nil then
      knob_val_norm = my_rel/mouse_res + knob_val_norm0
      knob_val_norm = limit(knob_val_norm, 0, 1) 
    end
    
    return last_mouse_obj, knob_val_norm0, knob_val_norm
    --[[
      
    
      
      set = true 
     else
      set = false end
      
    , knob_val_norm_r, set, knob_val_norm0  ]]
    
      --[[
    if MOUSE_gate(2, xywh_t) then
      local knob_retval, knob_return_s = reaper.GetUserInputs(inputname1, 1, inputname2, "") 
      if knob_retval ~= nil then
        knob_return = tonumber(knob_return_s)
        if knob_return ~= nil then
          knob_user_return = limit(knob_return,lim1,lim2)
          last_mouse_obj = last_mouse_obj_name
          LMB_state = true
          return last_mouse_obj, knob_val_norm, knob_user_return
        end
      end
    end
    ]]
  
  end
  
  --------------------------------------------------------------------------------------------------------------- 
  function MOUSE_get()
    cur_time = os.clock()
    timer = 0.5
    LMB_state = gfx.mouse_cap&1 == 1 
    RMB_state = gfx.mouse_cap&2 == 2 
    MMB_state = gfx.mouse_cap&64 == 64         
    if LMB_state or RMB_state or MMB_state then MB_state = true else MB_state = false end
    if last_LMB_state or last_RMB_state or last_MMB_state then last_MB_state = true else last_MB_state = false end    
    mx, my = gfx.mouse_x, gfx.mouse_y
    if LMB_state and not last_LMB_state then mx0,my0 = mx,my else  end
    if mx0 ~= nil and my0 ~= nil then    mx_rel,my_rel = mx0-mx, my0-my end
    
    --release behaviour
      if last_LMB_state and not MB_state then
        if last_mouse_obj == 'k1_windowsize' or 
          last_mouse_obj == 'k2_threshold' or 
          last_mouse_obj == 'k3_search_area'then
          ref_item_data_t = ENGINE1_get_item_data(1)
          item_data_t = ENGINE1_get_item_data(cur_item)
        end
      end -- release actions    
  
    if not last_LMB_state then last_mouse_obj = nil end
    
        
    -- TOP
      -- display
        if MOUSE_match_xy(window1_xywh_t) and last_mouse_obj == nil then 
          show_get_button = true show_get_button_a2 = 0.5 
           else show_get_button_a = 0.0 show_get_button = false end    
        if MOUSE_gate(1, window1_xywh_t) then 
          ENGINE1_get_items()
          if #sel_items_t == 1 then cur_item = 1 elseif #sel_items_t > 1 then cur_item = 2 end
          ref_item_data_t = ENGINE1_get_item_data(1)
          item_data_t = ENGINE1_get_item_data(cur_item)
          get_but_state = 1
         else get_but_state = 0.5 end       
      -- navigation 
        if #sel_items_t > 0 then
          if MOUSE_gate(1, nav_button3_xywh_t) then 
            cur_item = cur_item-1 
            if cur_item <2 then cur_item = 2 end 
            item_data_t = ENGINE1_get_item_data(cur_item) end
          if MOUSE_gate(1, nav_button4_xywh_t) then 
            cur_item = cur_item+1 
            if cur_item > #sel_items_t then cur_item = #sel_items_t end 
            item_data_t = ENGINE1_get_item_data(cur_item) end
          if MOUSE_gate(1, nav_button2_xywh_t) then
            menustring = ""             
            for i = 1, #sel_items_t do 
              item = reaper.BR_GetMediaItemByGUID(0, sel_items_t[i])
              track = reaper.GetMediaItem_Track(item)
              retval, trackname = reaper.GetSetMediaTrackInfo_String(track, 'P_NAME','', false)
              take = reaper.GetActiveTake(item) 
              take_name = reaper.GetTakeName(take)
              menustring = menustring..trackname..' / '..take_name..'|' if i == 1 then menustring = menustring .."|" end end  
            gfx.x,gfx.y = mx,my  
            menu_ret = gfx.showmenu(menustring) 
            if menu_ret ~= 0 and menu_ret ~= 1 then cur_item = menu_ret end 
            item_data_t = ENGINE1_get_item_data(cur_item) end
        end -- end nav
    -- MID
      if #sel_items_t > 0 then
        -- add button
          if MOUSE_match_xy(window_m1_xywh_t) then 
            show_get_button2 = true 
          else show_get_button2 = false end
        -- knob1 window size
          k1_val_norm = conv_val2norm(window_time, window_time_min, window_time_max,false)
          last_mouse_obj, k1_val_norm0, k1_val_norm = 
            MOUSE_knob(w2_knob1_xywh_t, 'k1_windowsize',k1_val_norm0, k1_val_norm)
          window_time = conv_norm2val(k1_val_norm,window_time_min, window_time_max,false)
         
        -- knob2 threshold
          k2_val_norm = conv_val2norm(threshold,threshold_min,threshold_max, true)
          last_mouse_obj, k2_val_norm0, k2_val_norm = 
            MOUSE_knob(w2_knob2_xywh_t, 'k2_threshold', k2_val_norm0, k2_val_norm)
          threshold = conv_norm2val(k2_val_norm,threshold_min,threshold_max, true)
                  
        -- knob3 search area
          k3_val_norm = conv_val2norm(s_area,s_area_min,s_area_max, false)
          last_mouse_obj, k3_val_norm0, k3_val_norm = 
            MOUSE_knob(w2_knob3_xywh_t, 'k3_search_area', k3_val_norm0, k3_val_norm)
          s_area = math.floor(conv_norm2val(k3_val_norm,s_area_min,s_area_max, false))

           
         function JUMP() end
        
          
          
      end -- end MID window        
            
    last_LMB_state = LMB_state    
    last_RMB_state = RMB_state
    last_MMB_state = MMB_state
    
  end
         
  --------------------------------------------------------------------------------------------------------------- 
  function MAIN_exit() gfx.quit() end
  
  ---------------------------------------------------------------------------------------------------------------   
  function MAIN_run()
    DEFINE_dynamic_variables_GUI()
    GUI_DRAW()
    MOUSE_get()
    if char == 27 then MAIN_exit() end     
    if char ~= -1 then reaper.defer(MAIN_run) else MAIN_exit() end
  end 

  ---------------------------------------------------------------------------------------------------------------      
  DEFINE_default_variables_GUI()
  DEFINE_default_variables()
  gfx.init("mpl Warping tool // "..vrs..' DEVELOPER PREVIEW', main_w, main_h)
  reaper.atexit(MAIN_exit)  
  MAIN_run() 

