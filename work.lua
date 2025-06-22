_G.W = true
while _G.W do task.wait(0.1)
    local h = game.Players.LocalPlayer.Character.Humanoid

h:UnequipTools()

h:EquipTool(game.Players.LocalPlayer.Backpack:GetChildren()[7])
end
