--Wrapper for SelectionListEntry for storing a test.
--!strict

local AvantRuntime = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("AvantRuntime"))
local NexusPluginComponents = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))

local Fusion = NexusPluginComponents.Fusion
local SelectionListEntry = NexusPluginComponents.List.SelectionListEntry

local TestSelectionListEntry = {}
TestSelectionListEntry.__index = TestSelectionListEntry

export type SortMethod = "Name" | "SortIndex"
export type TestSelectionListEntry = {
    Scope: NexusPluginComponents.FusionScope,
    Configuration: AvantRuntime.AvantConfiguration,
    Test: AvantRuntime.Test,
    SortMethod: SortMethod,
    Entry: NexusPluginComponents.SelectionListEntry<AvantRuntime.Test>,
    ChildEntries: {[AvantRuntime.Test]: TestSelectionListEntry},
    EventConnections: {RBXScriptConnection},
} & typeof(setmetatable({}, TestSelectionListEntry))



--[[
Creates a SelectionListEntry for a test.
--]]
function TestSelectionListEntry.new(Scope: NexusPluginComponents.FusionScope, Configuration: AvantRuntime.AvantConfiguration, Test: AvantRuntime.Test, SortMethod: SortMethod?): TestSelectionListEntry
    --Create the entry.
    local self = setmetatable({
        Scope = Scope,
        Configuration = Configuration,
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
    table.insert(self.EventConnections, Configuration.ConfigurationChanged:Connect(function()
        self:UpdateChildTests()
    end) :: any)
    self:UpdateChildTests()

    --Return the entry.
    return self
end

--[[
Updates the stored child tests.
--]]
function TestSelectionListEntry.UpdateChildTests(self: TestSelectionListEntry): ()
    --Re-add the child tests.
    for _, ChildTest in self.Test.ChildTests do
        self:AddChildTest(ChildTest :: AvantRuntime.Test)
    end

    --Remove the child tests that are ignored.
    for _, ChildTest in self.Test.ChildTests do
        if not ChildTest.ModuleScript then continue end
        if not self.Configuration:IsIgnored(ChildTest.ModuleScript:GetFullName()) then continue end
        self:RemoveChildTest(ChildTest :: AvantRuntime.Test)
    end
end

--[[
Adds an entry for a child test.
--]]
function TestSelectionListEntry.AddChildTest(self: TestSelectionListEntry, Test: AvantRuntime.Test): ()
    if self.ChildEntries[Test] then return end
    if Test.ModuleScript and self.Configuration:IsIgnored(Test.ModuleScript:GetFullName()) then return end

    --Create the entry.
    local NewEntry = TestSelectionListEntry.new(self.Scope, self.Configuration, Test, "SortIndex")
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
function TestSelectionListEntry.RemoveChildTest(self: TestSelectionListEntry, Test: AvantRuntime.Test): ()
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