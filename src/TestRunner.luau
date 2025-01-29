--Runs tests in Avant.
--!strict

local RunModuleScript = require(script.Parent:WaitForChild("AvantRuntime"):WaitForChild("Runner"):WaitForChild("RunModuleScript"))
local Test = require(script.Parent:WaitForChild("AvantRuntime"):WaitForChild("State"):WaitForChild("Test"):WaitForChild("Test"))
local CreateFusionScope = require(script.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("CreateFusionScope"))
local Fusion = require(script.Parent:WaitForChild("NexusPluginComponents"):WaitForChild("Fusion"))
local TestSelectionListEntry = require(script.Parent:WaitForChild("TestView"):WaitForChild("TestSelectionListEntry"))

local TestRunner = {}
TestRunner.__index = TestRunner

export type TestGroup = "ALL" | "FAILED" | "SELECTED"
export type TestRunner = {
    ListEntry: TestSelectionListEntry.TestSelectionListEntry,
    LastTestRunTime: Fusion.Value<DateTime?>,
    FocusedOutputTest: Fusion.Value<Test.Test?>,
} & typeof(setmetatable({}, TestRunner))



--[[
Returns if a test failed or a child test failed.
--]]
local function TestFailed(Test: Test.Test): boolean
    if Test.State == "FAILED" then
        return true
    end
    for _, ChildTest in Test.ChildTests do
        if not TestFailed(ChildTest :: Test.Test) then continue end
        return true
    end
    return false
end

--[[
Creates a test runner.
--]]
function TestRunner.new(Scope: CreateFusionScope.FusionScope, ListEntry: TestSelectionListEntry.TestSelectionListEntry): TestRunner
    return setmetatable({
        ListEntry = ListEntry,
        LastTestRunTime = Scope:Value(nil :: DateTime?),
        FocusedOutputTest = Scope:Value(nil :: Test.Test?),
    }, TestRunner) :: TestRunner
end

--[[
Runs a set of tests.
--]]
function TestRunner.RunTests(self: TestRunner, Tests: {Test.Test}): ()
    --Set the start time as now.
    self.LastTestRunTime:set(DateTime.now())

    --Run the tests.
    local RootTest = self.ListEntry.Test
    for _, Test in Tests do
        if Test.ModuleScript then
            --Run the test.
            RunModuleScript(Test :: Test.Test)
        else
            --Remove the test since the source no longer exists.
            RootTest:RemoveChildTest(Test :: Test.Test)
        end
    end
end

--[[
Returns the tests for a group.
--]]
function TestRunner.GetTestsForGroup(self: TestRunner, Group: TestGroup): {Test.Test}
    local Tests = {}
    for _, ChildEntry in Fusion.peek(self.ListEntry.Entry.Children) do
        --Determine if the condition matches.
        local ChildTest = Fusion.peek(ChildEntry.Data) :: Test.Test
        local TestMatches = false
        if Group == "ALL" then
            TestMatches = true
        elseif Group == "FAILED" then
            TestMatches = TestFailed(ChildTest)
        elseif Group == "SELECTED" then
            for _, DescendantEntry in Fusion.peek(ChildEntry.Descendants) do
                if not Fusion.peek(DescendantEntry.Selected) then continue end
                TestMatches = true
                break
            end
        end

        --Add the test.
        if TestMatches then
            table.insert(Tests, ChildTest)
        end
    end
    return Tests
end

--[[
Runs tests using a group.
--]]
function TestRunner.RunTestsForGroup(self: TestRunner, Group: TestGroup): ()
    --Get the tests to run.
    local TestsToRun = self:GetTestsForGroup(Group)

    --Run all the tests if no tests were ground in the group.
    if Group ~= "ALL" and #TestsToRun == 0 then
        TestsToRun = self:GetTestsForGroup("ALL")
    end

    --Run the tests.
    self:RunTests(TestsToRun)
end

--[[
Focues the output of a test.
--]]
function TestRunner.FocusOutput(self: TestRunner, Test: Test.Test): ()
    self.FocusedOutputTest:set(Test)
end



return TestRunner