local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local UtilityModule = {}
local ActiveMoveToken = 0

function UtilityModule.SafeDestroy(Object)
    if Object and Object.Destroy then
        Object:Destroy()
    end
end

function UtilityModule.SafeCleanup(Connection)
    if Connection and Connection.Disconnect then
        Connection:Disconnect()
    end
end

function UtilityModule.Wait()
    RunService.PostSimulation:Wait()
end

function UtilityModule.MoveToPoint(Method, Target, Time, ShouldYieldTillFinished)
    local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")

    if not HumanoidRootPart then
        return
    end

    if Method == "Tween" then
        Time = Time or 1

        local TweenInfoData = TweenInfo.new(Time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local TweenGoal = {CFrame = Target + Vector3.new(0, 3, 0)}

        HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        HumanoidRootPart.Velocity = Vector3.zero

        local Tween = TweenService:Create(HumanoidRootPart, TweenInfoData, TweenGoal)
        Tween:Play()

        if ShouldYieldTillFinished then
            local Completed = false

            Tween.Completed:Once(function()
                Completed = true
            end)

            while not Completed do
                UtilityModule.Wait()
            end
        end

        task.wait()
    end

    if Method == "Move" and Humanoid then
        ActiveMoveToken += 1

        local ThisMove = ActiveMoveToken
        local Finished = false

        local Connection

        Humanoid:MoveTo(Target)

        Connection = RunService.PostSimulation:Connect(function()
            if ThisMove ~= ActiveMoveToken then
                UtilityModule.SafeCleanup(Connection)
                Finished = true
                return
            end

            local Distance = (HumanoidRootPart.Position - Target).Magnitude

            if Distance <= 2 then
                UtilityModule.SafeCleanup(Connection)
                Finished = true
                return
            end

            if Humanoid.MoveDirection.Magnitude == 0 and Distance > 3 then
                Humanoid:MoveTo(Target)
            end
        end)

        Humanoid.MoveToFinished:Once(function()
            if ThisMove == ActiveMoveToken then
                UtilityModule.SafeCleanup(Connection)
                Finished = true
            end
        end)

        if ShouldYieldTillFinished then
            repeat
                UtilityModule.Wait()
            until Finished
        end

        task.wait()
    end
end

function UtilityModule.SortByNumberInName(Table, Order)
    if not Table then
        return
    end

    table.sort(Table, function(A, B)
        local NameA = tostring(A.Name or "")
        local NameB = tostring(B.Name or "")

        local NumberA = tonumber(NameA:match("%d+")) or 0
        local NumberB = tonumber(NameB:match("%d+")) or 0

        if Order == "Ascending" then
            return NumberA < NumberB
        else
            return NumberA > NumberB
        end
    end)
end

return UtilityModule
