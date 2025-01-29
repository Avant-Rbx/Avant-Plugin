--Creates an icon for a test with a specific test.
--!strict

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateTestIcon = require(script.Parent:WaitForChild("CreateTestIcon"))

return function(Scope: CreateFusionScope.FusionScope, Test: Fusion.UsedAs<Test.Test>): ImageLabel
    --Create a value for the test having an output.
    local HasOutput = Scope:Value(false)
    local TestEventConnections = {} :: {RBXScriptConnection}
    Scope:Observer(Test):onBind(function()
        for _, EventConnection in TestEventConnections do
            EventConnection:Disconnect()
        end
        TestEventConnections = {}

        local CurrentTest = Fusion.peek(Test) :: Test.Test
        table.insert(TestEventConnections, CurrentTest.OutputAdded:Connect(function()
            HasOutput:set(true)
        end) :: any)
        table.insert(TestEventConnections, CurrentTest.OutputCleared:Connect(function()
            HasOutput:set(false)
        end) :: any)
        HasOutput:set(#CurrentTest.Output > 0)
    end)

    --Create the other values and create the icon.
    local State = Scope:ValueFromProperty(Test, "CombinedState")
    local ContentsState = Scope:ValueFromProperty(Test, "ContentsState")
    return CreateTestIcon(Scope, State :: any, ContentsState :: any, HasOutput)
end