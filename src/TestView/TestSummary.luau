--Stores totals for tests.
--!strict

local Test = require(script.Parent.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local CreateFusionScope = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))

local TestSummary = {}
TestSummary.__index = TestSummary

export type TestSummary = {
    RootTest: Test.Test,
    TotalTests: Fusion.Value<number>,
    PassedTests: Fusion.Value<number>,
    SkippedTests: Fusion.Value<number>,
    FailedTests: Fusion.Value<number>,
    ChildTests: {[Test.Test]: boolean},
} & typeof(setmetatable({}, TestSummary))



--[[
Creates a test summary.
--]]
function TestSummary.new(Scope: CreateFusionScope.FusionScope, RootTest: Test.Test): TestSummary
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
function TestSummary.InitializeTest(self: TestSummary, Test: Test.Test): ()
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
        self:InitializeTest(ChildTest :: Test.Test)
    end
    self:UpdateTotals()
end

--[[
Removes a test.
--]]
function TestSummary.RemoveTest(self: TestSummary, Test: Test.Test): ()
    self.ChildTests[Test] = nil
    for _, ChildTest in Test.ChildTests do
        self:RemoveTest(ChildTest :: Test.Test)
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