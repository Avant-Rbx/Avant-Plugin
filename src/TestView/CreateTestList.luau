--Creates a list of tests.
--!strict

local NexusPluginComponents = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateTestEntry = require(script.Parent:WaitForChild("CreateTestEntry"))
local TestSelectionListEntry = require(script.Parent:WaitForChild("TestSelectionListEntry"))

local Fusion = NexusPluginComponents.Fusion

return function(Scope: NexusPluginComponents.FusionScope, ListEntry: TestSelectionListEntry.TestSelectionListEntry, TestRunner: TestRunner.TestRunner): ScrollingFrame
    --Create the ScrollingFrame.
    local ScrollingFrame = Scope:Create("ScrollingFrame")({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -29, 1, -29),
        Position = UDim2.new(0, 29, 0, 0),
    }) :: ScrollingFrame

    --Create the expandbale list with the tests.
    local VirtualList = NexusPluginComponents.List.CreateExpandableList(Scope, ScrollingFrame, ListEntry.Entry, function(Scope, Entry, DoubleClicked)
        --Set up focusing the output of the test.
        DoubleClicked:Connect(function()
            TestRunner:FocusOutput(Fusion.peek(Fusion.peek(Entry).Data))
        end)

        --Create the list entry frames.
        return CreateTestEntry(Scope, Scope:Computed(function(use)
            return use(use(Entry).Data)
        end))
    end)
    VirtualList:SetEntryHeight(20)

    --Return the frame.
    return ScrollingFrame
end