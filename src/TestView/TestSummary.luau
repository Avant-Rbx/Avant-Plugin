--Stores totals for tests.
--!strict

local AvantRuntime = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("AvantRuntime"))
local NexusPluginComponents = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))

local TestSummary = {}
TestSummary.__index = TestSummary

export type TestSummary = {
    RootTest: AvantRuntime.Test,
    TotalTests: NexusPluginComponents.Value<number>,
    PassedTests: NexusPluginComponents.Value<number>,
    SkippedTests: NexusPluginComponents.Value<number>,
    FailedTests: NexusPluginComponents.Value<number>,
    ChildTests: {[AvantRuntime.Test]: boolean},
} & typeof(setmetatable({}, TestSummary))



--[[
Creates a test summary.
--]]
function TestSummary.new(Scope: NexusPluginComponents.FusionScope, RootTest: AvantRuntime.Test): TestSummary
    --Create the object.
    local self = setmetatable({
        RootTest = RootTest,
        TotalTests = Scope:Value(0),
        PassedTests = Scope:Value(0),
        SkippedTests = Scope:Value(0),
        FailedTests = Scope:Value(0),
        ChildTests = {},
    }, TestSummary) :: TestSummary

    --Initialize the root test.
    self:InitializeTest(RootTest)

    --Return the object.
    return self
end

--[[
Initializes a test.
--]]
function TestSummary.InitializeTest(self: TestSummary, Test: AvantRuntime.Test): ()
    --Store the test.
    if self.ChildTests[Test] then return end
    self.ChildTests[Test] = true

    --Connect the test state changing.
    Test:GetPropertyChangedSignal("State"):Connect(function()
        self:UpdateTotals()
    end)

    --Connect tests being added or removed.
    Test.TestAdded:Connect(function(ChildTest)
        self:InitializeTest(ChildTest)
    end)
    Test.TestRemoved:Connect(function(ChildTest)
        self:RemoveTest(ChildTest)
        self:UpdateTotals()
    end)

    --Connect existing tests.
    for _, ChildTest in Test.ChildTests do
        self:InitializeTest(ChildTest :: AvantRuntime.Test)
    end
    self:UpdateTotals()
end

--[[
Removes a test.
--]]
function TestSummary.RemoveTest(self: TestSummary, Test: AvantRuntime.Test): ()
    self.ChildTests[Test] = nil
    for _, ChildTest in Test.ChildTests do
        self:RemoveTest(ChildTest :: AvantRuntime.Test)
    end
end

--[[
Updates the totals.
--]]
function TestSummary.UpdateTotals(self: TestSummary): ()
    --Get the totals.
    --The root test is ignored since it is a dummy test.
    local TotalTests = 0
    local PassedTests, SkippedTests, FailedTests = 0, 0, 0
    for Test, _ in self.ChildTests do
        if Test == self.RootTest then continue end
        TotalTests += 1
        
        if Test.State == "PASSED" then
            PassedTests += 1
        elseif Test.State == "SKIPPED" then
            SkippedTests += 1
        elseif Test.State == "FAILED" then
            FailedTests += 1
        end
    end

    --Set the new values.
    self.TotalTests:set(TotalTests)
    self.PassedTests:set(PassedTests)
    self.SkippedTests:set(SkippedTests)
    self.FailedTests:set(FailedTests)
end



return TestSummary