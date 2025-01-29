--Creates a list of tests.
--!strict

local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local CreateExpandableList = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("List"):WaitForChild("CreateExpandableList"))
local TestRunner = require(script.Parent.Parent:WaitForChild("TestRunner"))
local CreateTestEntry = require(script.Parent:WaitForChild("CreateTestEntry"))
local TestSelectionListEntry = require(script.Parent:WaitForChild("TestSelectionListEntry"))

return function(Scope: CreateFusionScope.FusionScope, ListEntry: TestSelectionListEntry.TestSelectionListEntry, TestRunner: TestRunner.TestRunner): ScrollingFrame
    --Create the ScrollingFrame.
    local ScrollingFrame = Scope:Create("ScrollingFrame")({
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -29, 1, -29),
        Position = UDim2.new(0, 29, 0, 0),
    }) :: ScrollingFrame

    --Create the expandbale list with the tests.
    local VirtualList = CreateExpandableList(Scope, ScrollingFrame, ListEntry.Entry, function(Scope, Entry, DoubleClicked)
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