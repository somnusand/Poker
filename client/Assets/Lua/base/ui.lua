
local Class = {uis = {}}
Class.__index = Class


-- global functions

function Class.create(mod,hide)

    GameAPI.UnloadRes()


    Time.timeScale = 1
    print("------",mod)
    local xxx = require("ui."..mod)

    GameAPI.Clear3D()
    --setmetatable(obj,Class)

    local obj = {}

    for k,v in pairs(Class) do
        if type(v) == "function" then
            obj[k] = v
        end
    end

    for k,v in pairs(xxx) do
        obj[k] = v
    end

    print("------",obj.res)
    obj.node = UIAPI.CreateUI(obj.res)
    obj.cur_node = obj.node
    obj.push_nodes = {}

    obj.now = Time.realtimeSinceStartup
    obj.dt  = 0
    obj.delay_funs = {}

    if obj.init then
        obj:init()
    end

    if hide then
        obj.node.gameObject.SetActive(false)
    else
        obj:show()
    end

    print("Add", obj.base_update,obj)
    UpdateBeat:Add(obj.base_update,obj)

    return obj
end


function Class.close_all()
    for _,ui in pairs(Class.uis) do
        ui:close(true)
    end
    Class.uis = {}

    UIAPI.CloseAll()
end


-- member functions

function Class:base_update()

    if self.is_closed then
        print("is_closed",self)
        return
    end

    local cur_time = Time.realtimeSinceStartup
    self.dt = cur_time - self.now
    self.now = cur_time

    if self.update then
        self:update()
    end

    local now = self.now

    local i = 1

    --print(self.delay_funs[1],self.delay_funs[2])
    while self.delay_funs[i] do
        local f = self.delay_funs[i]
        if f.time < now then
            f.fun()
            table.remove(self.delay_funs,i)
        else
            i = i + 1
        end
    end
end

function Class:close(not_pop)
    if self.destroy then
        self:destroy()
    end

    self.is_closed = true

    print("remove", self.base_update,self)
    UpdateBeat:Remove(self.base_update,self)

    UnityEngine.GameObject.Destroy(self.node.gameObject)

    if not not_pop then
        self:pop_top()
    end
end

function Class:show()
    self:push_top()
    self.node.gameObject:SetActive(true)
    if self.on_show then
        self:on_show()
    end
end

function Class:hide()
    self.node.gameObject:SetActive(false)
    if self.on_hide then
        self:on_hide()
    end
end


function Class:push_top()
    self:pop_top()
    table.insert(Class.uis,self)
end

function Class:pop_top()
    for i,v in pairs(Class.uis) do
        if v == self then
            table.remove(Class.uis,i)
        end
    end
end

function Class:push_node(node)
    table.insert(self.push_nodes,self.cur_node)
    self.cur_node = node
end

function Class:pop_node()
    self.cur_node = table.remove(self.push_nodes)
end

function Class:push_child(child,node)
    if node == nil then
        node = self.cur_node
    end

    table.insert(self.push_nodes,self.cur_node)

    if type(child) == "string" then
        local child_obj = node:FindChild(child)
        if child_obj == nil then
            print("can't found:",child)
        end
        self.cur_node = child_obj
    elseif type(child) == "number" then
        local child_obj = node:GetChild(child)
        self.cur_node = child_obj
    else
        self.cur_node = child
    end
end

function Class:pop_child()
    self.cur_node = table.remove(self.push_nodes)
end

function Class:text(txt,node)
    if node == nil then
        node = self.cur_node
    end
    UIAPI.SetText(node,tostring(txt))
end

function Class:text_child(txt,path,node)

    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetText(child,tostring(txt))
    end
end

function Class:toggle(v,node)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetToggle(node,v)
end

function Class:toggle_child(v,path,node)
    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetToggle(child,v)
    end
end


function Class:button(fun)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetOnClick(node,fun)

end

function Class:button_child(fun,path,node)
    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetOnClick(child,fun)
    end
end


function Class:image(name,node)

    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetImage(node,name)

end

function Class:image_child(name,path,node)
    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetImage(child,name)
    end
end


function Class:text_color(color,node)

    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetTextColor(node,color[1],color[2],color[3])

end

function Class:text_color_child(color,path,node)
    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetTextColor(child,color[1],color[2],color[3])
    end
end

function Class:image_color(color,node)

    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetImageColor(node,color[1],color[2],color[3])

end

function Class:image_color_child(color,path,node)
    if node == nil then
        node = self.cur_node
    end

    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetImageColor(child,color[1],color[2],color[3])
    end
end



function Class:number_image(value,node)

    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetNumberImage(node,value)
end


function Class:art_number(value,node)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetArtNumber(node,value)
end

function Class:art_number_child(value,path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetArtNumber(child,value)
    end
end

function Class:art_number2(value,node)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SetArtNumber2(node,value)
end

function Class:art_number_child2(value,path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SetArtNumber2(child,value)
    end
end

function Class:slider(value,node)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SliderValue(node,value)
end

function Class:slider_child(value,path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SliderValue(child,value)
    end
end

function Class:slider_count(value,node)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.SliderCount(node,value)
end

function Class:slider_count_child(value,path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.SliderCount(child,value)
    end
end


function Class:gray(obj)
    if node == nil then
        node = self.cur_node
    end

    UIAPI.Gray(node,name)
end

function Class:gray_child(path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        UIAPI.Gray(child)
    end
end

function Class:enable(value,obj)
    if obj == nil then
        self.cur_node.gameObject:SetActive(value)
    else
        obj.gameObject:SetActive(value)
    end
end

function Class:enable_child(value,path,node)
    if node == nil then
        node = self.cur_node
    end
    local child
    if type(path) == "string" then
        child = node:FindChild(path)
    else
        child = node:GetChild(path)
    end

    if child then
        child.gameObject:SetActive(value)
    end
end

function Class:enable_all_child(value,node)
    if node == nil then
        node = self.cur_node
    end

    local count = node.childCount

    for i=0,count-1 do
        local child = node:GetChild(i)
        child.gameObject:SetActive(value)
    end
end


function Class:clear_input()
    UIAPI.ClearInput(self.cur_node)
end

function Class:clear_child_input(path)
    local child = self.cur_node:FindChild(path)

    if child then
        UIAPI.ClearInput(child)
    end
end

function Class:find_child(path,node)
    if not node then
        node = self.cur_node
    end
    return node:FindChild(path)
end


function Class:effect(name,node)
    if node == nil then
        node = self.cur_node
    end

    return UIAPI.ShowEffect(node,name)
end


function Class:effect_image(name,img,node)
    if node == nil then
        node = self.cur_node
    end

    return UIAPI.ShowImageEffect(node,name,img)
end

function Class:effect_image_color(name,img,node,color)
    if node == nil then
        node = self.cur_node
    end

    return UIAPI.ShowImageEffectColor(node,name,img,color[1],color[2],color[3])
end

function Class:clear_delay()
    self.delay_funs = {}
end

function Class:delay(time,fun)
    table.insert(self.delay_funs,{fun=fun,time=self.now+time})
end

-- global functions

function Class.show_watting()
    UIAPI.ShowOne("watting")
end

function Class.close_watting()
    UIAPI.CloseOne("watting")
end

function Class.msg_box(txt,fun_ok,fun_cancel)
    local node

    if fun_cancel == nil then
        node = Class.show_temp("MsgBox")
        if fun_ok then
            local btn = node:FindChild("Button")
            UIAPI.SetOnClick(btn,fun_ok)
        end
    else
        node = Class.show_temp("MsgBox_2")

        local btn = node:FindChild("Button_1")
        UIAPI.SetOnClick(btn,fun_ok)

        btn = node:FindChild("Button_2")
        UIAPI.SetOnClick(btn,fun_cancel)

        btn = node:FindChild("Button_3")
        UIAPI.SetOnClick(btn,fun_cancel)
    end

    local child = node:FindChild("Text")
    UIAPI.SetText(child,txt)
end


function Class.show_temp(res)
    --local len = #Class.uis
    return UIAPI.CreateUI(res)
end

function Class.destroy_temp(t)
    UnityEngine.GameObject.Destroy(t.gameObject)
end


function Class.show_text(text)
    --local len = #Class.uis
    local node = Class.show_temp("Text")

    Class:text(text,node)
end





return Class
