local RunService = game:GetService("RunService")

local UtilityModule = {}

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

return UtilityModule
