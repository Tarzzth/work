
-- -- ใช้ hookfunction เพื่อจับฟังก์ชันที่โดนเรียก
-- local mt = getrawmetatable(game)
-- setreadonly(mt, false)

-- local oldNamecall = mt.__namecall

-- mt.__namecall = newcclosure(function(self, ...)
--     local args = {...}
--     local method = getnamecallmethod()

--     -- ตรวจจับถ้าเป็นการเตะผู้เล่น
--     if method == "Kick" and self == game.Players.LocalPlayer then
--         warn("ถูกพยายาม Kick: ", unpack(args))
--         return -- บล็อกไม่ให้เตะ
--     end

--     return oldNamecall(self, unpack(args))
-- end)


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



_G.Player = "himlayas14"
_G.SelectMutation_Fruits = false
_G.Weight_Configs_fruit = 0.1
_G.AntiFavorite_Trade = false
_G.SelectPets = true
_G.Count = 1000000000000

_G.CountLog = 0
_G.CountTrade = true
_G.AutoTrade_Pets = false
_G.AutoTrade_Fruit = false
_G.Pets = {
    "Deer",
}
_G.Mutation = {
    "Wet",
    "Frozen",
}

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
    local Backpack = LocalPlayer():FindFirstChild("Backpack")
    local Humanoid = LocalPlayer().Character and LocalPlayer().Character:FindFirstChildOfClass("Humanoid")
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

    print("Hello Fruit")
    local Backpack = LocalPlayer():FindFirstChild("Backpack")
    for i, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") and item:GetAttribute("f") then
            table.insert(fruit, item)
        end
    end
    return fruit
end

-- function GET:Pets()
--     local __Pets = {}

    
--     local Backpack = LocalPlayer():FindFirstChild("Backpack")
--     for i, item in pairs(Backpack:GetChildren()) do
--         if item:IsA("Tool") and item:GetAttribute("ItemType") == "Pet" then
--             table.insert(__Pets, item)
--         end
--     end
--     return __Pets
-- end

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

    task.wait(2)
    Humanoid:UnequipTools()
    print("Unequip")
    if not item then return end

    local target_player = Player():FindFirstChild(player)
    if not target_player then return warn("Not Found Player : ".. player) end
    RootPart.CFrame = target_player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 0)
 
    task.wait(2)
    BASE:Equip_ITEM(item)

    warn("Equipped item:", item)
    local RootPart_Target = target_player.Character:FindFirstChild("HumanoidRootPart")
    if RootPart_Target then
        -- workspace.polatak13.HumanoidRootPart.ProximityPrompt
        local promt = RootPart_Target:FindFirstChild("ProximityPrompt")
        if not promt then return end

        if promt then
            task.wait(2)
            promt.Enabled = true
            promt.HoldDuration = 0
            fireproximityprompt(promt , 0)
            print("Fire Proximity Prompt")
            warn("Trading item:", item, "to player:", player)
        end
    end
end

function Trade_Fruit()
    local fruit = GET:Fruit()
    local __item = nil

    task.wait(2)
    for i, item in pairs(fruit) do task.wait(0.1)

        if _G.CountTrade and _G.__countfruit_log >= _G.Count then
            warn("Trade limit reached for fruits.")
            return
        end
        local item_weight = item:FindFirstChild("Weight")
        -- if tonumber(item_weight.Value) >= _G.Weight_Configs_fruit then
            if _G.SelectMutation_Fruits then
                for i, keyword in pairs(_G.Mutation) do
                    if item:GetAttribute(tostring(keyword)) == true then
                        __item = item
                        break
                    end
                end
            else

                __item = item
            end
        -- else
            -- return
        -- end

        if __item then
            if _G.AntiFavorite_Trade then
                if __item:GetAttribute("d") == true then
                    return
                end
            end

            task.wait(2)
            print("trade")
            Trade(__item.Name, _G.Player)
            _G.__countfruit_log += 1
            task.wait(0.1)
        end
    end
end

-- function Trade_Pets()
--     local Pets = GET:Pets()
--     local __item = nil

--     for i, item in pairs(Pets) do task.wait(0.1)

--         if _G.CountTrade and _G.__countfruit_log >= _G.Count then
--             warn("Trade limit reached for fruits.")
--             return
--         end


--         if _G.SelectPets then
--             for i, keyword in pairs(_G.Pets) do
--                 if item.Name:lower():find(tostring(keyword:lower())) then
--                     __item = item
--                     break
--                 end
--             end
--         else
--             __item = item

--         end
--     end

--     if __item then
--         if _G.AntiFavorite_Trade then
--             if __item:GetAttribute("d") == true then
--                 warn("Trading pets is not allowed for favorite items. : " , __item.Name)
--                 return
--             else
--                 warn("error favorite: " , __item.Name)
--             end
--         end

--         Trade(__item.Name, _G.Player)
--         _G.__countfruit_log += 1
--         task.wait(0.1)
--     end
-- end


Trade_Fruit()
