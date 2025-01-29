--Creates an entry for a test.
--!strict

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local SecondaryTextFormatter = require(script.Parent.Parent:WaitForChild("Util"):WaitForChild("SecondaryTextFormatter"))
local CreateTestIconForTest = require(script.Parent:WaitForChild("CreateTestIconForTest"))

return function(Scope: CreateFusionScope.FusionScope, Test: Fusion.UsedAs<Test.Test>): {Instance}
    --Set up the duration calculation.
    local StartTime = Scope:ValueFromProperty(Test, "StartTime")
    local EndTime = Scope:ValueFromProperty(Test, "EndTime")
    local Duration = Scope:Computed(function(use): number?
        local CurrentStartTime = use(StartTime) :: number
        local CurrentEndTime = use(EndTime) :: number
        if not CurrentStartTime or not CurrentEndTime then return nil end
        return CurrentEndTime - CurrentStartTime
    end)

    --Create the instances.
    return {
        --Test status icon.
        Scope:Hydrate(CreateTestIconForTest(Scope, Test))({
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0, 2),
        }),

        --Test name + duration.
        Scope:Create("TextLabel")({
            Size = UDim2.new(1, -24, 0, 16),
            Position = UDim2.new(0, 22, 0, 1),
            Text = SecondaryTextFormatter(Scope, Scope:ValueFromProperty(Test, "Name") :: any, Scope:Computed(function(use)
                local CurrentDuration = use(Duration)
                return CurrentDuration and `{string.format("%.3f", CurrentDuration)} seconds`
            end)),
            RichText = true,
        }),
    }
end