-- @description RS5k_manager_GUI
-- @author MPL
-- @website http://forum.cockos.com/member.php?u=70694
-- @noindex

  ---------------------------------------------------
  function rect(x,y,w,h)
    gfx.x,gfx.y = x,y
    gfx.lineto(x,y+h)
    gfx.x,gfx.y = x+1,y+h
    gfx.lineto(x+w,y+h)
    gfx.x,gfx.y = x+w,y+h-1
    gfx.lineto(x+w,y)
    gfx.x,gfx.y = x+w-1,y
    gfx.lineto(x+1,y)
  end
  ---------------------------------------------------
  function col(obj, col_str, a) 
    gfx.set( table.unpack(obj.GUIcol[col_str])) 
    if a then gfx.a = a end  
  end
  ---------------------------------------------------
  function GUI_DrawWF_edges(obj, data)   
    local w = obj.WF_w
    local h = obj.kn_h 
    local cur_note = obj.current_WFkey
    if cur_note and data[cur_note] and data[cur_note][1] and not ( data[cur_note][1].offset_end == 1 and data[cur_note][1].offset_start ==0) then
      
      local x_sel = w*data[cur_note][1].offset_start+obj.keycntrlarea_w
      local y_sel =  0
      local w_sel = w*data[cur_note][1].offset_end - w*data[cur_note][1].offset_start
      local h_sel = 2--h-1
      --gfx.muladdrect(x_sel,y_sel,w_sel,h_sel,1,1,1,2.5,0,0,0,0 )
      gfx.set(1,1,1,0.6)
      gfx.rect(x_sel,y_sel,w_sel,h_sel,1)
    end
  end
  ---------------------------------------------------
  function GUI_DrawWF(obj, data)    
    local w = obj.WF_w
    local h = obj.kn_h
    -- WF
      if obj.current_WFkey and data[obj.current_WFkey] and data[obj.current_WFkey][1] and data[obj.current_WFkey][1].src_track_col then
        --col(obj, data[obj.current_WFkey][1].src_track_col)
        local int_col = data[obj.current_WFkey][1].src_track_col
        local r, g, b = ColorFromNative( int_col )
                  if GetOS():match('Win') then gfx.set(r/255,g/255,b/255, 0.2)
                   else gfx.set(b/255,g/255,r/255,  0.2)     end
       else
        col(obj, 'green', 0.15)
      end
      gfx.x, gfx.y = 0, h
      step = (obj.WF_w / #data.current_spl_peaks)*10
      local last_x, cnt = nil, #data.current_spl_peaks
      for i = 1, cnt, step do 
        val = math.abs(data.current_spl_peaks[math.floor(i)])
        x = math.floor(w*i / cnt )
        y = h/2 --h-h*val 
        h0 =  h*val
        gfx.rect(x,y,math.ceil(w/#data.current_spl_peaks),h0, 1)  
        gfx.rect(x,h/2-h*val+1,math.ceil(w/#data.current_spl_peaks),h0, 1)
      end 
  end
  ---------------------------------------------------
  function Menu(mouse, t)
    local str, check ,hidden= '', '',''
    for i = 1, #t do
      if t[i].state then check = '!' else check ='' end
      if t[i].hidden then hidden = '#' else hidden ='' end
      local add_str = hidden..check..t[i].str 
      str = str..add_str
      str = str..'|'
    end
    gfx.x = mouse.x
    gfx.y = mouse.y
    local ret = gfx.showmenu(str)
    local incr = 0
    if ret > 0 then 
      for i = 1, ret do 
        if t[i+incr].menu_decr == true then incr = incr - 1 end
        if t[i+incr].str:match('>')  then incr = incr + 1 end
      end
      if t[ret+incr] and t[ret+incr].func then t[ret+incr].func() end 
    end
  end  
  ---------------------------------------------------
  function Menu_FormBrowser(conf,refresh)    
    for i = 1, conf.fav_path_cnt  do if not conf['smpl_browser_fav_path'..i] then conf['smpl_browser_fav_path'..i] = '' end end
    local browser_t =
                                  {
                                    {str = 'Browse for file/path',
                                    func = function()
                                              local ret, fn = GetUserFileNameForRead('', 'Browse for file/path', '.wav' )
                                              if ret then
                                                local par_fold = GetParentFolder(fn)
                                                if par_fold then 
                                                  conf.cur_smpl_browser_dir = par_fold 
                                                  refresh.conf = true
                                                  refresh.GUI = true
                                                  refresh.data = true                                             
                                                end
                                              end
                                            end
                                    },                                
                                    {str = '|>Save as favourite'},
                                    {str = '1 - '..conf.smpl_browser_fav_path1,
                                    func = function()
                                              conf.smpl_browser_fav_path1 = conf.cur_smpl_browser_dir
                                              refresh.conf = true 
                                              refresh.GUI = true
                                                                                            refresh.data = true
                                            end,
                                    }
                                  }
    -- save favourite 
    for i = 2, conf.fav_path_cnt  do
      if conf['smpl_browser_fav_path'..i] then 
        if i == conf.fav_path_cnt or not conf['smpl_browser_fav_path'..i+1] then close = '<' else close = '' end
        browser_t[#browser_t+1] = { str = close..i..' - '..conf['smpl_browser_fav_path'..i],
                                    func = function()
                                      conf['smpl_browser_fav_path'..i] = conf.cur_smpl_browser_dir
                                      refresh.conf = true
                                      refresh.GUI = true
                                                                                    refresh.data = true 
                                    end
                                }
      end
    end 
    -- load favourite
    for i = 1, conf.fav_path_cnt  do
      if conf['smpl_browser_fav_path'..i] then
        browser_t[#browser_t+1] = { str = 'Fav'..i..' - '..conf['smpl_browser_fav_path'..i],
                                  func = function()
                                    conf.cur_smpl_browser_dir = conf['smpl_browser_fav_path'..i]
                                    refresh.conf = true
                                    refresh.GUI = true
                                                                                  refresh.data = true
                                  end
                                }    
      end
    end
    return  browser_t
  end
  
  ---------------------------------------------------
  function GUI_knob(obj, b)
    local x,y,w,h,val =b.x,b.y,b.w,b.h, b.val
    local arc_r = math.floor(w/2 * 0.8)
    if b.reduce_knob then arc_r = arc_r*b.reduce_knob end
    y = y - arc_r/2 + 1
    local ang_gr = 120
    local ang_val = math.rad(-ang_gr+ang_gr*2*val)
    local ang = math.rad(ang_gr)
  
    col(obj, b.col, 0.08)
    if b.knob_as_point then 
      local y = y - 5
      local arc_r = arc_r*0.75
      for i = 0, 1, 0.5 do
        gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-180),math.rad(-90),    1)
        gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),math.rad(0),    1)
        gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
        gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),math.rad(180),    1)
      end
      gfx.a = 0.02
      gfx.circle(x+w/2,y+h/2,arc_r, 1)
      return 
    end
    
    
    -- arc back      
    col(obj, b.col, 0.2)
    for i = 0, 3, 0.5 do
      gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),math.rad(-90),    1)
      gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),math.rad(0),    1)
      gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
      gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),math.rad(ang_gr),    1)
    end
    
    
    
    local knob_a = 0.6
    if b.knob_a then knob_a = b.knob_a end
    col(obj, b.col, knob_a)      
    if not b.is_centered_knob then 
      -- val       
      local ang_val = math.rad(-ang_gr+ang_gr*2*val)
      for i = 0, 3, 0.5 do
        if ang_val < math.rad(-90) then 
          gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),ang_val, 1)
         else
          if ang_val < math.rad(0) then 
            gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),math.rad(-90), 1)
            gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),ang_val,    1)
           else
            if ang_val < math.rad(90) then 
              gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),math.rad(-90), 1)
              gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),math.rad(0),    1)
              gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),ang_val,    1)
             else
              if ang_val < math.rad(ang_gr) then 
                gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),math.rad(-90), 1)
                gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),math.rad(0),    1)
                gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
                gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),ang_val,    1)
               else
                gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-ang_gr),math.rad(-90),    1)
                gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(-90),math.rad(0),    1)
                gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
                gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),math.rad(ang_gr),    1)                  
              end
            end
          end                
        end
      end
      
     else -- if centered
      local ang_val = math.rad(-ang_gr+ang_gr*2*val)
      for i = 0, 3, 0.5 do
        if ang_val < math.rad(-90) then 
          gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(0),math.rad(-90),    1)
          gfx.arc(x+w/2-1,y+h/2,arc_r-i,    math.rad(-90),ang_val,    1)
         else
          if ang_val < math.rad(0) then 
            gfx.arc(x+w/2-1,y+h/2-1,arc_r-i,    math.rad(0),ang_val,    1)
           else
            if ang_val < math.rad(90) then 
              gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),ang_val,    1)
             else
              if ang_val < math.rad(ang_gr) then 
  
                gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
                gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),ang_val,    1)
               else
  
                gfx.arc(x+w/2,y+h/2-1,arc_r-i,    math.rad(0),math.rad(90),    1)
                gfx.arc(x+w/2,y+h/2,arc_r-i,    math.rad(90),math.rad(ang_gr),    1)                  
              end
            end
          end                
        end
      end    
          
    end 
  end
  ---------------------------------------------------
  function GUI_DrawObj(obj, o) 
    if not o then return end
    local x,y,w,h, txt = o.x, o.y, o.w, o.h, o.txt
    --[[
    gfx.set(1,1,1,1)
    gfx.setfont()
    gfx.x, gfx.y = x+20,y
    gfx.drawstr(x)]]
    
    if not x or not y or not w or not h then return end
    gfx.a = o.alpha_back or 0.2
    local blit_h, blit_w = obj.grad_sz,obj.grad_sz
    if o.is_step then 
      gfx.blit( 5, 1, 0, -- grad back
              0,0,  blit_w,blit_h,
              x,y,w,h, 0,0)      
     else
      gfx.blit( 2, 1, 0, -- grad back
              0,0,  blit_w,blit_h,
              x,y,w,h, 0,0)
    end
    
    ------------------ fill back
      local x_sl = x      
      local w_sl = w 
      local y_sl = y      
      local h_sl = h 
      if o.is_slider and o.steps and (not o.axis or o.axis == 'x') then 
        x_sl = x + w/o.steps*o.val
        w_sl = w/o.steps
       elseif o.is_slider  and o.steps and o.axis == 'y' then 
        y_sl = y + h/o.steps*o.val
        h_sl = h - h/o.steps
       elseif o.is_slider and o.axis == 'x_cent' then 
        if o.val < 0.5 then
          x_sl = x + w*o.val
          w_sl = w*(0.5-o.val)
         else
          x_sl = x + w*0.5
          w_sl = w*(o.val-0.5)          
        end
      end  
      if not (o.state and o.alpha_back2) then 
        if o.colint then
  
          local r, g, b = ColorFromNative( o.colint )
          if GetOS():match('Win') then gfx.set(r/255,g/255,b/255, o.alpha_back or 0.2)
           else gfx.set(b/255,g/255,r/255, o.alpha_back or 0.2)     end
                     
         else
          col(obj, o.col, o.alpha_back or 0.2)
        end
        gfx.rect(x_sl,y_sl,w_sl,h_sl,1)
       else
        if o.colint then
        
          local r, g, b = ColorFromNative( o.colint )
          if GetOS():match('Win') then gfx.set(r/255,g/255,b/255, o.alpha_back or 0.2)
           else gfx.set(b/255,g/255,r/255, o.alpha_back or 0.2)     end
           
         else
          col(obj, o.col, o.alpha_back or 0.2)
        end
        gfx.rect(x_sl,y_sl,w_sl,h_sl,1)
      end 
             
    ------------------ check
      if o.check and o.check == 1 then
        gfx.a = 0.5
        gfx.rect(x+w-h+2,y+2,h-3,h-3,1)
        rect(x+w-h,y,h,h,0)
       elseif o.check and o.check == 0 then
        gfx.a = 0.5
        rect(x+w-h,y,h,h,0)
      end
      
    ------------------ step
      if o.is_step and o.val then
        if tonumber(o.val) then
          local val = o.val/127
          local x_sl = x      
          local w_sl = w 
          local y_sl = y + h-math.ceil(h *val)  
          local h_sl = math.ceil(h *val)
          col(obj, o.col, 0.5)
          if o.colint then
          
            local r, g, b = ColorFromNative( o.colint )
            if GetOS():match('Win') then gfx.set(r/255,g/255,b/255) else gfx.set(b/255,g/255,r/255)     end
            gfx.a = 0.7
            
           else
            col(obj, o.col, 0.5)
          end
          
          gfx.rect(x_sl,y_sl,w_sl-1,h_sl,1)      
        end
      end
    
    ------------------ tab
      if o.is_tab then
        col(obj, o.col, 0.6)
        local tab_cnt = o.is_tab >> 7
        local cur_tab = o.is_tab & 127
        gfx.line( x+cur_tab*w/tab_cnt,y,
                  x+w/tab_cnt*(1+cur_tab),y)
        gfx.line( x+cur_tab*w/tab_cnt,y+h,
                  x+w/tab_cnt*(1+cur_tab),y+h)                  
      end
    
    ------------------ knob
      if o.is_knob then GUI_knob(obj, o) end
  
    ------------------ txt
      if o.txt and w > 5 then 
        local w0 = w -2
        local txt = tostring(o.txt)
        if o.txt_col then 
          col(obj, o.txt_col, o.alpha_txt or 0.8)
         else
          col(obj, 'white', o.alpha_txt or 0.8)
        end
        local f_sz = obj.GUI_fontsz
        gfx.setfont(1, obj.GUI_font,o.fontsz or obj.GUI_fontsz )
        local y_shift = -1
        for line in txt:gmatch('[^\r\n]+') do
          if gfx.measurestr(line:sub(2)) > w0 -2 and w0 > 20 then 
            repeat line = line:sub(2) until gfx.measurestr(line..'...')< w0 -2
            line = '...'..line
          end
          if o.txt2 then line = o.txt2..' '..line end
          gfx.x = x+ math.ceil((w-gfx.measurestr(line))/2)
          gfx.y = y+ (h-gfx.texth)/2 + y_shift 
          if o.aligh_txt then
            if o.aligh_txt&1==1 then gfx.x = x  end -- align left
            if o.aligh_txt>>2&1==1 then gfx.y = y + y_shift end -- align top
            if o.aligh_txt>>4&1==1 then gfx.y = h - gfx.texth end -- align bot
          end
          if o.bot_al_txt then 
            gfx.y = y+ h-gfx.texth-3 +y_shift
          end
          gfx.drawstr(line)
          y_shift = y_shift + gfx.texth
        end
      end
      
    ------------------ key txt
      if o.vertical_txt then
        gfx.dest = 10
        gfx.setimgdim(10, -1, -1)  
        gfx.setimgdim(10, h,h) 
        gfx.setfont(1, obj.GUI_font,o.fontsz or obj.GUI_fontsz )
        gfx.x,gfx.y = 0,h-gfx.texth
        col(obj, 'white', 0.8)
        gfx.drawstr(o.vertical_txt) 
        gfx.dest = o.blit or 1
        local offs = 0
        gfx.blit(10,1,math.rad(-90),
                  0,0,h,h,
                  x,y,h,h,-5,h-w+5)
      end
    
    ------------------ line
      if o.a_line then  -- low frame
        col(obj, o.col, o.a_frame or 0.2)
        gfx.x,gfx.y = x+1,y+h
        gfx.lineto(x+w,y+h)
      end
      
    ------------------ frame
      if o.a_frame then  -- low frame
        col(obj, o.col, o.a_frame or 0.2)
        gfx.rect(x,y,w,h,0)
        gfx.x,gfx.y = x,y
        gfx.lineto(x,y+h)
        gfx.x,gfx.y = x+1,y+h
        --gfx.lineto(x+w,y+h)
        gfx.x,gfx.y = x+w,y+h-1
        --gfx.lineto(x+w,y)
        gfx.x,gfx.y = x+w-1,y
        gfx.lineto(x+1,y)
      end    
      
    return true
  end
  ---------------------------------------------------
  function GUI_draw(conf, obj, data, refresh, mouse, pat)
    gfx.mode = 0
    
    -- 1 back
    -- 2 gradient
    -- 3 smpl browser blit
    -- 4 stepseq 
    -- 5 gradient steps
    -- 6 WaveForm
    -- 10 sample keys
    
    --  init
      if refresh.GUI_onStart then
        -- com grad
        gfx.dest = 2
        gfx.setimgdim(2, -1, -1)  
        gfx.setimgdim(2, obj.grad_sz,obj.grad_sz)  
        local r,g,b,a = 1,1,1,0.72
        gfx.x, gfx.y = 0,0
        local c = 0.8
        local drdx = c*0.00001
        local drdy = c*0.00001
        local dgdx = c*0.00008
        local dgdy = c*0.0001    
        local dbdx = c*0.00008
        local dbdy = c*0.00001
        local dadx = c*0.0001
        local dady = c*0.0001       
        gfx.gradrect(0,0, obj.grad_sz,obj.grad_sz, 
                        r,g,b,a, 
                        drdx, dgdx, dbdx, dadx, 
                        drdy, dgdy, dbdy, dady) 
        -- steps grad
        gfx.dest = 5
        gfx.setimgdim(5, -1, -1)  
        gfx.setimgdim(5, obj.grad_sz,obj.grad_sz)  
        local r,g,b,a = 1,1,1,0.5
        gfx.x, gfx.y = 0,0
        local c = 1
        local drdx = c*0.001
        local drdy = c*0.01
        local dgdx = c*0.001
        local dgdy = c*0.001    
        local dbdx = c*0.00008
        local dbdy = c*0.001
        local dadx = c*0.001
        local dady = c*0.001       
        gfx.gradrect(0,0, obj.grad_sz,obj.grad_sz, 
                        r,g,b,a, 
                        drdx, dgdx, dbdx, dadx, 
                        drdy, dgdy, dbdy, dady)     
        refresh.GUI_onStart = nil             
        refresh.GUI = true       
      end
      
    -- refresh
      if refresh.GUI then 
        -- refresh backgroung
          gfx.dest = 1
          gfx.setimgdim(1, -1, -1)  
          gfx.setimgdim(1, gfx.w, gfx.h) 
          gfx.blit( 2, 1, 0, -- grad back
                    0,0,  obj.grad_sz,obj.grad_sz/2,
                    0,0,  gfx.w,gfx.h, 0,0)
        -- refresh all buttons
          for key in spairs(obj) do 
            if type(obj[key]) == 'table' and obj[key].show and not obj[key].blit and key~= 'set_par_tr'  then 
              GUI_DrawObj(obj, obj[key]) 
            end  
          end  
        -- 
            GUI_DrawWF_edges(obj, data)    
        -- WF
          if refresh.GUI_WF then
            GetPeaks(data, obj.current_WFkey)
            gfx.setimgdim(6, -1, -1)  
            gfx.setimgdim(6, obj.WF_w,obj.WF_h) 
            if data.current_spl_peaks then 
              gfx.dest = 6
              gfx.a = 0.5
              gfx.setimgdim(6, -1, -1)  
              gfx.setimgdim(6, obj.WF_w,obj.WF_h) 
              GUI_DrawWF(obj, data)              
            end
            refresh.GUI_WF = nil
          end          
      end
    
 
      
    --  render    
      gfx.dest = -1   
      gfx.a = 1
      gfx.x,gfx.y = 0,0
    --  back
      gfx.blit(1, 1, 0, -- backgr
          0,0,gfx.w, gfx.h,
          0,0,gfx.w, gfx.h, 0,0)  
    --  WF
    if conf.tab == 0 then 
      gfx.a = 1
      gfx.mode = 0
        gfx.blit(6, 1, 0, -- backgr
            0,0,obj.WF_w, obj.WF_h-1,
            obj.keycntrlarea_w  ,
            0,--gfx.h-obj.WF_h-obj.key_h,
            gfx.w- obj.keycntrlarea_w  , 
            obj.WF_h-1 , 0,0) 
    end      
    
    refresh.GUI = nil
    gfx.update()
  end
