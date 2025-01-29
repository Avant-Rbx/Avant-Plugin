--Creates a list for the output of a test.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local NexusVirtualList = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("NexusVirtualList"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local OutputListEntry = require(script.Parent:WaitForChild("OutputListEntry"))
local TestOutput = require(script.Parent:WaitForChild("TestOutput"))

return function(Scope: CreateFusionScope.FusionScope, TestRunner: TestRunner.TestRunner): ScrollingFrame
    --Create the ScrollingFrame.
    local ScrollingFrame = Scope:Create("ScrollingFrame")({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -22),
        Position = UDim2.new(0, 0, 0, 22),
    }) :: ScrollingFrame

    --Create the expandbale list with the tests.
    local VirtualList = NexusVirtualList.CreateVirtualScrollList(ScrollingFrame, function(InitialIndex: number, InitialEntry: OutputListEntry.OutputData)
        return OutputListEntry.new(Scope, InitialEntry) :: any
    end)
    VirtualList:SetEntryHeight(17)

    --Create the test output state.
    local Output = TestOutput.new(Scope, TestRunner.FocusedOutputTest)
    Scope:Observer(Output.Output):onBind(function()
        VirtualList:SetData(Fusion.peek(Output.Output))
    end)

    --Return the frame.
    return ScrollingFrame
end