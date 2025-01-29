--Wrapper for SelectionListEntry for storing a test.
--!strict

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local SelectionListEntry = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("List"):WaitForChild("SelectionListEntry"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local TestSelectionListEntry = {}
TestSelectionListEntry.__index = TestSelectionListEntry

export type SortMethod = "Name" | "SortIndex"
export type TestSelectionListEntry = {
    Scope: CreateFusionScope.FusionScope,
    Test: Test.Test,
    SortMethod: SortMethod,
    Entry: SelectionListEntry.SelectionListEntry<Test.Test>,
    ChildEntries: {[Test.Test]: TestSelectionListEntry},
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, TestSelectionListEntry))



--[[
Creates a SelectionListEntry for a test.
--]]
function TestSelectionListEntry.new(Scope: CreateFusionScope.FusionScope, Test: Test.Test, SortMethod: SortMethod?): TestSelectionListEntry
    --Create the entry.
    local self = setmetatable({
        Scope = Scope,
        Test = Test,
        SortMethod = SortMethod or "Name",
        Entry = SelectionListEntry.new(Scope, Test, function(a, b)
            local TestA, TestB = Fusion.peek(a.Data), Fusion.peek(b.Data)
            if SortMethod ~= "SortIndex" then
                return string.lower(TestA.Name) < string.lower(TestB.Name)
            end
            return TestA.SortIndex < TestB.SortIndex
        end),
        ChildEntries = {},
        EventConnections = {},
    }, TestSelectionListEntry) :: TestSelectionListEntry

    --Connect adding and removing child tests.
    table.insert(self.EventConnections, Test.TestAdded:Connect(function(ChildTest)
        self:AddChildTest(ChildTest)
    end) :: any)
    table.insert(self.EventConnections, Test.TestRemoved:Connect(function(ChildTest)
        self:RemoveChildTest(ChildTest)
    end) :: any)
    for _, ChildTest in Test.ChildTests do
        self:AddChildTest(ChildTest :: Test.Test)
    end

    --Return the entry.
    return self
end

--[[
Adds an entry for a child test.
--]]
function TestSelectionListEntry.AddChildTest(self: TestSelectionListEntry, Test: Test.Test): ()
    if self.ChildEntries[Test] then return end

    --Create the entry.
    local NewEntry = TestSelectionListEntry.new(self.Scope, Test, "SortIndex")
    self.ChildEntries[Test] = NewEntry
    self.Entry:AddChild(NewEntry.Entry)

    --Sort the child entries if the test name or sort index changes changes.
    --The event connection isn't stored since the test being removed will disconnect the event.
    Test:GetPropertyChangedSignal(self.SortMethod):Connect(function()
        --Ignore the re-order if the index went above 1,000,000.
        --This is done by TestRunContext to prepare for a new run.
        --New tests or re-run tests will call a re-sort soon after.
        if Test.SortIndex >= 1000000 then return end

        --Sort the children.
        self.Entry:SortChildren()
    end)
end

--[[
Removes an entry for a child test.
--]]
function TestSelectionListEntry.RemoveChildTest(self: TestSelectionListEntry, Test: Test.Test): ()
    if not self.ChildEntries[Test] then return end
    self.Entry:RemoveChild(self.ChildEntries[Test].Entry)
    self.ChildEntries[Test]:Destroy()
    self.ChildEntries[Test] = nil
end

--[[
Destroys the entry.
--]]
function TestSelectionListEntry.Destroy(self: TestSelectionListEntry): ()
    for _, EventConnection in self.EventConnections do
        EventConnection:Disconnect()
    end
    self.EventConnections = {}
end



return TestSelectionListEntry