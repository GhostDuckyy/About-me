--// Env
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

getgenv().Setting = shared.Setting or {
    AutoFarm = true,
    AutoRestart = true,
}
--// Source
function AutoFarm()
    local function consolePrint(string)
        if string == nil then string = "\n" end
        string = tostring(string)
         local Print = rconsoleprint or consoleprint or function(input) warn("Missing 'rconsoleprint' / 'consoleprint' function") end
         Print(string)
     end

    local function CreateConsole()
        local create = rconsolecreate or consolecreate or false
        if not create then consolePrint("--> Made by Ghost-Ducky#7698 | Last Update: 11/27/2022 \n\n") return else create(); task.wait(.5); consolePrint("--> Made by Ghost-Ducky#7698 | Last Update: 11/27/2022 \n\n"); return end
    end

    local function ClearConsole()
        local clear = rconsoleclear or consoleclear
        clear()
    end

    local function Killaura()
        local function KillEnemy(mob)
            task.wait(.1)

            if mob:FindFirstChildOfClass("Humanoid") and Players:GetPlayerFromCharacter(mob) == nil and Character and Character:FindFirstChild("HumanoidRootPart") then
                consolePrint("Debug: Target = ".. tostring(mob.Name) .."\n")
                consolePrint("Debug: Set Target MaxHealth = 0 \n")
                mob:FindFirstChildOfClass("Humanoid").MaxHealth = 0
                consolePrint("Debug: Set Target Health = 0 \n")
                mob:FindFirstChildOfClass("Humanoid").Health = -1

                task.spawn(function()
                    task.wait(7.5)
                    if mob ~= nil and Character and Character:FindFirstChild("HumanoidRootPart") then
                        consolePrint("Debug: Detected a timeout \n")
                        local Panic = game:GetService("ReplicatedStorage").PANIC
                        Panic:FireServer()

                        workspace["InvisiblePart"].CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 20)
                        task.wait(.1)
                        Character.HumanoidRootPart.CFrame = workspace["InvisiblePart"].CFrame * CFrame.new(0, 1, 0)
                    end
                end)
            end
        end

        if workspace:FindFirstChild("Room") and workspace["Room"]:FindFirstChild("Enemies") then
            for i,v in ipairs(workspace["Room"]["Enemies"]:GetChildren()) do
                KillEnemy(v)
            end
        end
    end

    local function CollectCircuits()
        local function Collect(child)
            task.wait(1)
            if child:FindFirstChild("Pay") and child.Pay:IsA("IntValue") and Character and Character:FindFirstChild("HumanoidRootPart") then
                firetouchinterest(Character.HumanoidRootPart, child, 0)
                task.wait(.5)
                firetouchinterest(Character.HumanoidRootPart, child, 1)
            end
        end

        task.spawn(function()
            for _,v in ipairs(workspace:GetChildren()) do
                Collect(v)
            end

            workspace.ChildAdded:Connect(function(child)
                Collect(child)
            end)
        end)
    end

    local function GotoRoom()
        if workspace:FindFirstChild("Room") and Character and Character:FindFirstChild("HumanoidRootPart") then
            consolePrint("Debug: Teleport to room \n")
            local Floor = workspace["Room"].Floor
            workspace["InvisiblePart"].CFrame =CFrame.new(Floor.CFrame.X, Floor.CFrame.Y + 25, Floor.CFrame.Z + 30)
            Character.HumanoidRootPart.CFrame = workspace["InvisiblePart"].CFrame * CFrame.new(0, 1, 0)
        end
    end

    local function ActiveButton()
        local function Active(child)
            if child:FindFirstChildOfClass("ClickDetector") and Character and Character:FindFirstChild("HumanoidRootPart") then

                workspace["InvisiblePart"].CFrame = CFrame.new(child.CFrame.X, child.CFrame.Y + 2, child.CFrame.Z)
                Character.HumanoidRootPart.CFrame = workspace["InvisiblePart"].CFrame * CFrame.new(0, 1, 0)

                consolePrint("Debug: Active Button \n")

                fireclickdetector(child:FindFirstChildOfClass("ClickDetector"))

            elseif child:FindFirstChild("Box") then
                for x,y in ipairs(child.Parent:GetChildren()) do
                    if y:FindFirstChild("Base") and y:FindFirstChild("Activator") then
                        consolePrint("Debug: Move box to plate \n")
                        child["Box"].CFrame = CFrame.new(y["Activator"].CFrame.X, y["Activator"].CFrame.Y + 1.5, y["Activator"].CFrame.Z)
                    end
                end
            end
        end

        if workspace:FindFirstChild("Room") and workspace["Room"]:FindFirstChild("Enemies") then
            for i,v in ipairs(workspace["Room"]["Enemies"]:GetChildren()) do
                Active(v)
            end
        end
    end

    local function Restart()
        local GuiEvent = game:GetService("ReplicatedStorage").GuiEvent

        LocalPlayer.Character.Humanoid.Died:Connect(function()
            Setting.AutoFarm = false
            if not Setting.AutoRestart then return end
            consolePrint("--> Detected died, Restart in 0.5 second \n\n")
            task.wait(.5)
            GuiEvent:FireServer("Restart")
        end)

        local source = [=[
            task.wait(1)
            
        ]=]

        if Setting.AutoRestart then
            if syn then
                syn.queue_on_teleport(source)
            else
                local unc = queue_on_teleport or queueonteleport
                unc(source)
            end
        end
    end

    task.spawn(function()
        ClearConsole()
        if not Setting.AutoFarm or game.PlaceId ~= 6312903733 then return end

        CreateConsole()
        if not game:IsLoaded() then consolePrint("Debug: Waiting game loaded \n") end

        while true do if game:IsLoaded() then break; end task.wait(.1) end

        if Character == nil then consolePrint("Debug: Wait Character \n") LocalPlayer.CharacterAppearanceLoaded:Wait() end

        if not workspace:FindFirstChild("InvisiblePart") then local Part = Instance.new("Part", workspace); Part.Name = "InvisiblePart"; Part.Anchored = true; Part.Size = Vector3.new(10, 1, 10); Part.CFrame = CFrame.new(0, -100, 0);Part.Transparency = 0.5; end

        consolePrint("--> AutoFarm will start in 0.5 second \n")
        task.wait(.5)

        Restart()
        CollectCircuits()

        while Setting.AutoFarm do

            Killaura()

            task.wait(.5)

            ActiveButton()

            task.wait(.5)

            GotoRoom()

            task.wait(.5)
        end
    end)
end

AutoFarm()