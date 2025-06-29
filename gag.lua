local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
warn("----------------------------------------------------")

function Player()
    return game:GetService("Players")
end

function LocalPlayer()
    return Player().LocalPlayer
end

function Character()
    return LocalPlayer().Character or LocalPlayer().CharacterAdded:Wait()
end

function Humanoid(Character)
    return Character:FindFirstChildOfClass("Humanoid")
end

function RootPart(Character)
    return Character:FindFirstChild("HumanoidRootPart")
end

function PlayerGui()
    return game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
end

local GET = {} ; GET.__index = GET
local BASE = {} ; BASE.__index = BASE

_G.Workspace = true

_G.MutationDefault = _G.MutationDefault or {} -- Mutation ที่ต้องการเทรด
_G.Pets = _G.Pets or {} -- สัตว์เลี้ยงที่ต้องการเทรด
_G.Mutation = _G.Mutation or {}

_G.Player = _G.Player or nil -- ผู้เล่น
_G.CountTrade = _G.CountTrade or false -- เปิดใช้งานการนับจำนวนการเทรด
_G.AutoTrade_Pets = _G.AutoTrade_Pets or false -- เทรดสัตว์เลี้ยง
_G.AutoTrade_Fruit = _G.AutoTrade_Fruit or false -- เทรดผลไม้
_G.AntiFavorite_Trade = _G.AntiFavorite_Trade or false -- ป้องกันเทรด item ที่ชอบ
_G.SelectPets = _G.SelectPets or false -- เลือกสัตว์เลี้ยง
_G.SelectMutation_Fruits = _G.SelectMutation_Fruits or false -- เปิดเลือกผลไม้ที่มี Mutation
_G.Weight_Configs_fruit = _G.Weight_Configs_fruit or 0.1 -- น้ำหนักผลไม้
_G.Count = _G.Count or 100 -- จำนวนการเทรดผลไม้


_G.__countfruit_log = 0
function BASE:clicked(ui)
    RunService.Heartbeat:Wait()
    if GuiService.SelectedObject == ui then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    elseif GuiService.SelectedObject ~= ui then
        GuiService.SelectedObject = ui
    end
end

function BASE:Equip_ITEM(item)
    if not item then return warn("Not Found Item") end
    local Backpack = LocalPlayer():FindFirstChild("Backpack")
    local Humanoid = LocalPlayer().Character and LocalPlayer().Character:FindFirstChildOfClass("Humanoid")

    Humanoid:UnequipTools()
    if Backpack then
        local tool = Backpack:FindFirstChild(item)
        if not tool then 
            local tool_char = LocalPlayer().Character:FindFirstChild(item)
            if tool_char then
                return
            end
        end

        if tool then
            if tool:IsA("Tool") then
                Humanoid:EquipTool(tool)
            end
        end
    end
end

function GET:Fruit()
    local fruit = {}

    local fruit_item = LocalPlayer():FindFirstChild("Backpack")
    for i, item in pairs(fruit_item:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("f") then
            if item:GetAttribute("Seed") then
                continue
            end

            if _G.AntiFavorite_Trade then
                if item:GetAttribute("d") == true then
                    continue
                end
            end

            if item:GetAttribute("b") ~= "j" then
                continue
            end

            table.insert(fruit, item)
        end
    end

    local fruit_item = LocalPlayer().Character
    for i, item in pairs(fruit_item:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("f") then
            if item:GetAttribute("Seed") then
                continue
            end

            if _G.AntiFavorite_Trade then
                if item:GetAttribute("d") == true then
                    continue
                end
            end

            table.insert(fruit, item)
        end
    end

    return fruit
end

function GET:Pets()
    local __Pets = {}

    local pet_item = LocalPlayer():FindFirstChild("Backpack")
    for i, item in pairs(pet_item:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("ItemType") == "Pet" then
            if _G.AntiFavorite_Trade then
                if item:GetAttribute("d") == true then
                    continue
                end
            end

            table.insert(__Pets, item)
        end
    end

    local pet_item = LocalPlayer().Character
    for i, item in pairs(pet_item:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("ItemType") == "Pet" then
            if _G.AntiFavorite_Trade then
                if item:GetAttribute("d") == true then
                    continue
                end
            end

            table.insert(__Pets, item)
        end
    end 
    return __Pets
end

function Accept_Trade()
    local suss , err = pcall(function()
        local PlayerGui = PlayerGui()
        local Gift_Notification = PlayerGui:FindFirstChild("Gift_Notification")
        local Frame = Gift_Notification:FindFirstChild("Frame")
        if Frame then
            local Holder = Frame:FindFirstChild("Gift_Notification"):FindFirstChild("Holder")
            if Holder then
                local Frame2 = Holder:FindFirstChild("Frame")
                if Frame2 then
                    local Accept = Frame2:FindFirstChild("Accept")
                    if Accept then
                        BASE:clicked(Accept)
                    end
                end    
            end
        end
    end)
end

function Trade(item , player)
    local Humanoid = Humanoid(Character())
    local RootPart = RootPart(Character()) 

    if not item then return print("Not Found Item") end

    local target_player = Player():FindFirstChild(player)
    if not target_player then return warn("Not Found Player : ".. player) end
    RootPart.CFrame = target_player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
 
    BASE:Equip_ITEM(item)

    local RootPart_Target = target_player.Character:FindFirstChild("HumanoidRootPart")
    if RootPart_Target then
        local promt = RootPart_Target:FindFirstChild("ProximityPrompt")
        if not promt then return end

        if promt then
            promt.Enabled = true
            promt.HoldDuration = 0
            -- ส่วนที่มีปัญหา 
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            warn("Trading item:", item, "to player:", player)
        end
    end
end

function Trade_Fruit()
    local suss , err = pcall(function()
        local fruit = GET:Fruit()
        local __item = nil
        local Humanoid = Humanoid(Character())

        
        for i, item in pairs(fruit) do task.wait(0.1)

            print("Trading item: ", item.Name)
            if not _G.AutoTrade_Fruit then
                break
            end

            if _G.CountTrade and _G.__countfruit_log >= _G.Count then
                warn("Trade limit reached for fruits.")

                return
            end

            -- game:GetService("Players").LocalPlayer.Backpack["Pepper [6.77kg]"].Weight
            local item_weight = item["Weight"]
            if item_weight and tonumber(item_weight.Value) >= _G.Weight_Configs_fruit then
                if _G.SelectMutation_Fruits then
                    for i, keyword in ipairs(_G.Mutation) do
                        if item:GetAttribute(tostring(keyword)) == true then
                            __item = item
                        end
                    end
                else
                    __item = item
                end
            else
                return
            end

            if __item then

                Trade(__item.Name, _G.Player)
                _G.__countfruit_log += 1
                task.wait(0.1)
            end
        end
    end)
    if not suss then
        warn("Error in Trade_Fruit: ", err)
    end
end

function Trade_Pets()
    local suss , err = pcall(function()
        local Pets = GET:Pets()
        local __item = nil
        local Humanoid = Humanoid(Character())


        for i, item in pairs(Pets) do task.wait(0.1)

            

            if not _G.AutoTrade_Pets then
                break
            end

            if _G.CountTrade and _G.__countfruit_log >= _G.Count then
                warn("Trade limit reached for fruits.")
                return
            end


            if _G.SelectPets then
                for i, keyword in pairs(_G.Pets) do
                    local keyword_str = tostring(keyword:lower())
                    if item.Name:find(keyword_str) then
                        __item = item
                    end
                end
            else
                __item = item
                
            end
        
        
        end

        if __item then
            if _G.AntiFavorite_Trade then
                if __item:GetAttribute("d") == true then
                    warn("Trading pets is not allowed for favorite items. : " , __item.Name)
                    return
                else
                    warn("error favorite: " , __item.Name)
                end
            end

            Trade(__item.Name, _G.Player)
            _G.__countfruit_log += 1
            task.wait(0.1)
        end
    end)
    if not suss then
        warn("Error in Trade_Pets: ", err)
    end
end

_G.__MutationList = {}
_G.PlayerList = {}
_G.__PetsList = {}

local MutationHandler = require(game.ReplicatedStorage.Modules.MutationHandler)
local mutations = MutationHandler:GetMutations()

local PetsList_Module = require(game:GetService("ReplicatedStorage").Data.PetRegistry.PetList)


for pets, data in pairs(PetsList_Module) do
    table.insert(_G.__PetsList, pets)
end

for key, data in pairs(mutations) do
    table.insert(_G.__MutationList , key)
end

for _, Player in pairs(game:GetService("Players"):GetChildren()) do
    table.insert(_G.PlayerList , Player.Name)
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Grow a Graden : Trade item",
    SubTitle = "by ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
}

local section = {
    Main = Tabs.Main:AddSection("Player"),
    Trade = Tabs.Main:AddSection("Trade"),
    setting = Tabs.Main:AddSection("Setting"),
}

-- Player

local Player = section.Main:AddParagraph({
    Title = "เลือกผู้เล่นที่จะ เทรดไปหา",
    Content = ""
})

local PlayerDropDown = section.Main:AddDropdown("Dropdown", {
    Title = "Select Player",
    Values = _G.PlayerList or {},
    Multi = false,
    Default =  _G.Player or 2,
})
print("A")

PlayerDropDown:OnChanged(function(Value)
    _G.Player = Value
end)

print("H")

local Player_refresh = section.Main:AddButton({
    Title = "Update Players List",
    Description = "",
    Callback = function()
        _G.PlayerList = {}
        for _, Player in pairs(game:GetService("Players"):GetChildren()) do
            table.insert(_G.PlayerList, Player.Name)
        end

        PlayerDropDown:SetValues(_G.PlayerList)
    end
})

-- trade

local AutoTrade = section.Trade:AddToggle("AutoTrade", {
    Title = "Enable Auto Trade Fruits -- สำหรับตัวเทรดผล",
    Default = _G.AutoTrade_Fruit or false,
})

AutoTrade:OnChanged(function(Value)
    _G.__countfruit_log = 0
    _G.AutoTrade_Fruit = Value
end)

local AutoTrade = section.Trade:AddToggle("AutoTrade", {
    Title = "Enable Auto Trade Pets -- สำหรับตัวเทรดสัตว์เลี้ยง",
    Default = _G.AutoTrade_Pets or false,
})

AutoTrade:OnChanged(function(Value)
    _G.__countfruit_log = 0
    _G.AutoTrade_Pets = Value
end)

local AutoAccept = section.Trade:AddToggle("AutoAccept", {
    Title = "Enable Auto Accept Trade -- สำหรับตัวรับเทรด",
    Default = _G.AutoAccept or false,
})

AutoAccept:OnChanged(function(Value)
    _G.AutoAccept = Value
end)

-- Setting

local InputCount = section.setting:AddInput("Input", {
    Title = "จำนวนการเทรดผลไม้",
    Default = _G.Count or 100,
    Placeholder = "Input Count",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.Count = tonumber(Value) or 100
    end
})


local InputWeight = section.setting:AddInput("Input", {
    Title = "จำนวนน้ำหนักผลไม้",
    Default = _G.Weight_Configs_fruit or 0,
    Placeholder = "Input Count",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.Weight_Configs_fruit = tonumber(Value) or 0
    end
})

local __TradeCount = section.setting:AddToggle("trade count", {
    Title = "Enable Trade Count -- เปิดใช้งานการนับจำนวนการเทรด", 
    Default = _G.CountTrade or false
})

__TradeCount:OnChanged(function(Value)
    _G.CountTrade = Value
end)

local MutationDropDown = section.setting:AddDropdown("Dropdown", {
    Title = "Select Mutation",
    Values = _G.__MutationList or {},
    Multi = true,
    Default = _G.Mutation,
})

MutationDropDown:OnChanged(function(Value)
    _G.Mutation = {}

    for i, v in pairs(Value) do
        table.insert(_G.Mutation, i)
    end
end)

local MutationSelect = section.setting:AddToggle("Trade mutation", {
    Title = "Enable Trade Mutation Fruit",
    Default = _G.SelectMutation_Fruits or false,
})

MutationSelect:OnChanged(function(Value)
    _G.SelectMutation_Fruits = Value
end)

local PetsDropDown = section.setting:AddDropdown("Dropdown", {
    Title = "Select Pets",
    Values = _G.__PetsList or {},
    Multi = true,
    Default = _G.Pets,
})

PetsDropDown:OnChanged(function(Value)
    _G.Pets = {}

    for i, v in pairs(Value) do
        table.insert(_G.Pets, i)
    end
end)

local PetsSelect = section.setting:AddToggle("Trade mutation", {
    Title = "Enable Trade Pets Select",
    Default = _G.SelectPets or false,
})

PetsSelect:OnChanged(function(Value)
    _G.SelectPets = Value
end)

local ANTI_Trade_favorite = section.setting:AddToggle("Anti", {
    Title = "Enable Anti Favorite Trade -- ป้องกันเทรด item ที่ชอบ",
    Default = _G.AntiFavorite_Trade or false,
})

ANTI_Trade_favorite:OnChanged(function(Value)
    _G.AntiFavorite_Trade = Value
end)

Window:SelectTab(Tabs.Main)

-- Workspace

-- Loop สำหรับ Auto Trade Fruits
task.spawn(function()
    while _G.Workspace do task.wait(0.1)
        if _G.AutoTrade_Fruit then
            Trade_Fruit()
        end
    end
end)

-- Loop สำหรับ Auto Trade Pets
task.spawn(function()
    while _G.Workspace do task.wait(0.1)
        if _G.AutoTrade_Pets then
            Trade_Pets()
        end
    end
end)

-- Loop สำหรับ Auto Accept Trade
task.spawn(function()
    while _G.Workspace do task.wait(0.1)
        if _G.AutoAccept then
            Accept_Trade()
        end
    end
end)

warn("-- Loaded Grow a Graden : Trade item --")

task.spawn(function()
    while _G.Workspace do task.wait(0.1)
        local playerGui = PlayerGui()
        local Gui = playerGui:FindFirstChild("ON/OFF")
        if Gui then return end

        if not Gui then
            playerGui = LocalPlayer():WaitForChild("PlayerGui")
        
            -- GUI
            local gui = Instance.new("ScreenGui")
            gui.Name = "ON/OFF"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = false
            gui.Parent = playerGui
        
            local button = Instance.new("TextButton")
            button.Name = "ProButton"
            button.AnchorPoint = Vector2.new(0, 0)
            button.Position = UDim2.new(0, 20, 0, 20)
            button.Size = UDim2.new(0, 180, 0, 55)
            button.BackgroundColor3 = Color3.fromRGB(123, 31, 162)
            button.Text = "Script by "
            button.TextColor3 = Color3.new(1, 1, 1)
            button.TextSize = 22
            button.Font = Enum.Font.GothamMedium
            button.AutoButtonColor = false
            button.Parent = gui
        
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 14)
            corner.Parent = button
        
            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 92, 231)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 61, 172)),
            })
            gradient.Rotation = 45
            gradient.Parent = button
        
        
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(186, 104, 200)
            stroke.Thickness = 1.5
            stroke.Transparency = 0.2
            stroke.Parent = button
        
        
            button.MouseEnter:Connect(function()
                button:TweenSize(UDim2.new(0, 190, 0, 60), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
                stroke.Transparency = 0
            end)
        
            button.MouseLeave:Connect(function()
                button:TweenSize(UDim2.new(0, 180, 0, 55), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
                stroke.Transparency = 0.2
            end)
        
        
            button.MouseButton1Click:Connect(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
            end) 
        end
    end
end)

