-- heeelllppp
queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/HubbyBlue/artox/refs/heads/main/layer2bot.lua"))
repeat wait() until game:IsLoaded()
wait(5)
local VIM = game:GetService("VirtualInputManager")

local function mb_1()
    VIM:SendMouseButtonEvent(game.Workspace.CurrentCamera.ViewportSize.X/2, game.Workspace.CurrentCamera.ViewportSize.Y/2, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(game.Workspace.CurrentCamera.ViewportSize.X/2, game.Workspace.CurrentCamera.ViewportSize.Y/2, 0, false, game, 1)
end

if game.PlaceId == 4111023553 then
    game.ReplicatedStorage.Requests.StartMenu.Start:FireServer(slot, {})
    wait(3)
elseif game.PlaceId == 8668476218 then 
    wait(7)
    mb_1()
    wait(25)
end


spawn(function()
    local start_time = os.clock()
    repeat wait() until os.clock() - start_time >= 300
    repeat
        wait(5)
        game.ReplicatedStorage.Requests.ReturnToMenu:FireServer(nil)
    until false
end)

--localized vars
local plr = game.Players.LocalPlayer
local chr = plr.Character
local galetrap = game.Players.LocalPlayer.Backpack:WaitForChild("Mantra:TrapWind{{Galetrap}}")
local requests = game.Players.LocalPlayer.Character.CharacterHandler:WaitForChild("Requests")
local cast_remote = requests:WaitForChild("ActivateMantra")

local positions = {
    Vector3.new(-4508.375, 465.4999694824219, -5937.01904296875), -- orb
    Vector3.new(-4995.33203125, 376.4448547363281, -5826.1708984375), -- door
    Vector3.new(-5341.36962890625, 354.25225830078125, -5802.22412109375),
    Vector3.new(-5493.36669921875, 383.2544250488281, -5819.6513671875),
    Vector3.new(-5698.533203125, 402.0506286621094, -6069.64013671875),
    Vector3.new(-5983.35693359375, 443.8338623046875, -6298.9658203125),
    Vector3.new(-5746.16064453125, 459.4011535644531, -6364.5498046875), -- bonekeeper
    Vector3.new(-5557.0380859375, 529.257568359375, -6477.33984375),-- generator
    Vector3.new(-5698.533203125, 402.0506286621094, -6069.64013671875),
    Vector3.new(-5452.01025390625, 353.6543884277344, -5654.0517578125),
    Vector3.new(-5460.83740234375, 425.9949951171875, -5136.78857421875), --firfire
    Vector3.new(-5408.3291015625, 279.205322265625, -4993.06640625),
    Vector3.new(-5365.28369140625, 277.34478759765625, -4763.12451171875),
    Vector3.new(-5232.18115234375, 203.39727783203125, -4642.83349609375),
    Vector3.new(-4804.396484375, 293.2510986328125, -4554.693359375),
    Vector3.new(-4653.1484375, 475.3758850097656, -4986.79833984375),
    Vector3.new(-4595.3955078125, 644.717529296875, -5156.9619140625) -- chaser
}





-- get an array of items
local function get_items_from_chest()
    local items = {}
    --path: PlayerGui/ChoicePrompt/ChoiceFrame/Options
    print("Chest debug:", unpack(plr.PlayerGui.ChoicePrompt.ChoiceFrame.Options:GetChildren()))
    for _, child in pairs(plr.PlayerGui.ChoicePrompt.ChoiceFrame.Options:GetChildren()) do
        print("checking child:", child)
        if type(child) ~= "number" and child:IsA("TextButton") then
            table.insert(items, child.Name)
        end
    end
    return items
end


--loot specified
local function loot_specific_item(item_name)
    local remote = game:GetService("Players").LocalPlayer.PlayerGui.ChoicePrompt.Choice
    for _, child in pairs(plr.PlayerGui.ChoicePrompt.ChoiceFrame.Options:GetChildren()) do
        if string.find(child.Name, item_name) then
            print("looting:", child.Name)
            remote:FireServer(child.Name)
            return
        end
    end
end


--noclip stuff
local connection
local function noclip(bool)
    local head, torso = chr:FindFirstChild("Head"), chr:FindFirstChild("Torso")
    if bool then
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            head.CanCollide = false
            torso.CanCollide = false 
        end)
    else 
        if connection then 
            connection:Disconnect()
        end
    end
end

local function nofall()
    local oldfs 
    oldfs = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local args = {...}
        if not checkcaller() and getnamecallmethod() == "FireServer" and type(args[2]) == "number" and args[2] >= 10 and args[3] == false then
            return 
        else
            return oldfs(...)
        end
    end))

end



--
local function fly_to(goal, speed, look)
    local ts = game:GetService("TweenService")
    local distance = (goal-chr.HumanoidRootPart.Position).Magnitude
    local time = distance/speed
    local ts_config = TweenInfo.new(
        time, 
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    if look then goal = CFrame.new(goal, look) else goal = CFrame.new(goal) end
    local tween = ts:Create(chr.HumanoidRootPart, ts_config, {CFrame = goal})
    tween:Play()
    return tween
end

--delete chaser
local function delete_chaser()
    local chaser = game.Workspace.Live:FindFirstChild(".chaser")
    local torso = chaser.Torso
    local tween = fly_to(chaser.Torso.Position + Vector3.new(5,0,5), 100, chaser.Torso.Position)
    wait(tween.TweenInfo.Time)
    game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.Position, chaser.Torso.Position)
    wait(0.5)
    local mouse_pos = game.Workspace.CurrentCamera:WorldToViewportPoint(torso.Position)
    VIM:SendMouseMoveEvent(mouse_pos.X, mouse_pos.Y, game)
    wait(0.05)
    cast_remote:FireServer(galetrap)
    local trap
    repeat trap = game.Workspace.Thrown:FindFirstChild("WindTrap") wait() until trap
    repeat wait() until trap:FindFirstChild("Weld")
    repeat
        trap.Hitbox.CFrame = chr.HumanoidRootPart.CFrame
        chaser.HumanoidRootPart.CFrame = CFrame.new(0, -20000, 0)
        wait()
    until not trap
    wait(1)
    
end

--delete bonekeeper
local function delete_bonekeeper()
    local spear
    local boy
    repeat wait() boy = game.Workspace.Live:FindFirstChild(".boneboy21")  until boy
    local point1 = Vector3.new(-5724.9404296875, 459.401123046875, -6368.80224609375)
    local point2 = Vector3.new(-5880.5888671875, 459.4011535644531, -6312.36376953125)
    local point3 = Vector3.new(-5808.74853515625, 375.5366516113281, -6352.9912109375)

    spawn(function()
        repeat spear = game.Workspace.Thrown:FindFirstChild("BoneSpear") wait() until spear
        repeat
            boy.HumanoidRootPart.CFrame = CFrame.new(0, -20000, 0)
            spear.CFrame = chr.HumanoidRootPart
            wait()
        until not spear
    end)

    local cd = false
    game.Workspace.Thrown.ChildAdded:Connect(function(c)
        if c.Name == "Bone" and not cd then
            wait(0.2)
            VIM:SendKeyEvent(true, 32, false, game)
            wait(0.05)
            VIM:SendKeyEvent(false, 32, false, game)
            cd = true
            wait(2)
            cd = false
        end
    end)

    local switch = false
    while boy do
        wait()
        if (boy.HumanoidRootPart.Position - chr.HumanoidRootPart.Position).Magnitude <= 35 then
            fly_to(point3, 225)
            wait(2)
            if switch then
                fly_to(point1, 225)
                switch = false
            else
                fly_to(point2, 225)
                switch = true
            end
        end
    end
end


local function destroy_jars()
    local destructibles = game.Workspace.Destructibles:GetChildren()
    for _, jar in pairs(destructibles) do
        if jar.Name == "BloodJar" and jar:FindFirstChild("AttachmentPart"):FindFirstChild("Attachment") and jar:FindFirstChild("AttachmentPart"):FindFirstChild("Attachment"):FindFirstChild("JarLight") then
            local look = Vector3.new(jar.Part.Position.X, chr.HumanoidRootPart.Position.Y, jar.Part.Position.Z)
            local next = false
            spawn(function()
                while not next do
                    local tween = fly_to(jar.Part.Position + Vector3.new(7,0,7), 200, look)
                    wait(tween.TweenInfo.Time)
                end
            end)
            local connection = jar.ChildRemoved:Connect(function()
                next = true
            end)
            repeat mb_1() wait(0.05) until next 
            connection:Disconnect()
            print("finished breaking jar")
        end
    end
end

--main product
local function layer2bot()
    repeat wait() until game:IsLoaded()   
    if game.PlaceId == 8668476218 then
        mb_1()
        wait(15)
        noclip(true)
        nofall()
        chr.HumanoidRootPart.Anchored = true
        for _, point in pairs(positions) do
            repeat 
                local tween = fly_to(point, 250)
                wait(tween.TweenInfo.Time)
                if (chr.HumanoidRootPart.Position - point).Magnitude <= 5 then
                    wait(1.5)
                end
            until (chr.HumanoidRootPart.Position - point).Magnitude <= 5 
            if _ == 1 or _ == 2 or _ == 11  then
                if _ == 2 then 
                    game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.Position, Vector3.new(-5002.71533203125, 376.4448547363281, -5825.50927734375))
                end
                wait(1)
                VIM:SendKeyEvent(true, 101, false, game)
                wait(0.05)
                VIM:SendKeyEvent(false, 101, false, game)
                wait(0.5)
                VIM:SendKeyEvent(true, 49, false, game)
                wait(0.05)
                VIM:SendKeyEvent(false, 49, false, game)

            elseif _ == 8 then
                wait(1)
                VIM:SendKeyEvent(true, 101, false, game)
                wait(0.05)
                VIM:SendKeyEvent(false, 101, false, game)
                wait(0.5)
                VIM:SendKeyEvent(true, 49, false, game)
                wait(0.05)
                VIM:SendKeyEvent(false, 49, false, game)
                wait(0.5)
                VIM:SendKeyEvent(true, 49, false, game)
                wait(0.05)
                VIM:SendKeyEvent(false, 49, false, game)
            elseif _ == 7 then
                wait(1) 
                delete_bonekeeper()
            elseif _ == 15 then 
                wait(6)
            end
        end
        local chaser = game.Workspace.Live:FindFirstChild(".chaser")
        chr.HumanoidRootPart.CFrame = CFrame.new(chr.HumanoidRootPart.Position, chaser.HumanoidRootPart.Position)
        wait(1.5)
        VIM:SendKeyEvent(true, 49, false, game)
        wait(0.05)
        VIM:SendKeyEvent(false, 49, false, game)
        wait(0.5)
        VIM:SendKeyEvent(true, 101, false, game)
        wait(0.05)
        VIM:SendKeyEvent(false, 101, false, game)
        wait(0.5)
        VIM:SendKeyEvent(true, 49, false, game)
        wait(0.05)
        VIM:SendKeyEvent(false, 49, false, game)
        wait(0.6)
        mb_1()
        chr.HumanoidRootPart.Anchored = false
        repeat wait() until chaser.Torso.Position.Y >= 655
        wait(1)
        destroy_jars()
        repeat wait() until chaser.Torso.Position.Y <= 645
        delete_chaser()
        local tween = fly_to(Vector3.new(-4593.341796875, 644.6943359375, -5185.8837890625), 225)
        wait(tween.TweenInfo.Time)
        wait(2)
        VIM:SendKeyEvent(true, 101, false, game)
        wait(0.05)
        VIM:SendKeyEvent(false, 101, false, game)
        wait(2)
        local chest_loot = get_items_from_chest()
        print("Chest loot:", chest_loot)
        for _, item in pairs(chest_loot) do
            for i, wl_item in pairs(items) do 
                if string.find(item, wl_item) then
                    print("trying to loot:", item)
                    loot_specific_item(item)
                    wait(1)
                end
            end
        end
        repeat
            wait(5)
            game.ReplicatedStorage.Requests.ReturnToMenu:FireServer(nil)
        until false
    end
end

layer2bot()
