--Runs tests in Avant.
--!strict

local AvantRuntime = require(script.Parent:WaitForChild("Packages"):WaitForChild("AvantRuntime"))
local NexusPluginComponents = require(script.Parent:WaitForChild("Packages"):WaitForChild("NexusPluginComponents"))
local TestSelectionListEntry = require(script.Parent:WaitForChild("TestView"):WaitForChild("TestSelectionListEntry"))

local RunModuleScript = AvantRuntime.RunModuleScript
local Fusion = NexusPluginComponents.Fusion

local TestRunner = {}
TestRunner.__index = TestRunner

export type TestGroup = "ALL" | "FAILED" | "SELECTED"
export type TestRunner = {
    ListEntry: TestSelectionListEntry.TestSelectionListEntry,
    LastTestRunTime: NexusPluginComponents.Value<DateTime?>,
    FocusedOutputTest: NexusPluginComponents.Value<AvantRuntime.Test?>,
} & typeof(setmetatable({}, TestRunner))



--[[
Returns if a test failed or a child test failed.
--]]
local function TestFailed(Test: AvantRuntime.Test): boolean
    if Test.State == "FAILED" then
        return true
    end
    for _, ChildTest in Test.ChildTests do
        if not TestFailed(ChildTest :: AvantRuntime.Test) then continue end
        return true
    end
    return false
end

--[[
Creates a test runner.
--]]
function TestRunner.new(Scope: NexusPluginComponents.FusionScope, ListEntry: TestSelectionListEntry.TestSelectionListEntry): TestRunner
    return setmetatable({
        ListEntry = ListEntry,
        LastTestRunTime = Scope:Value(nil :: DateTime?),
        FocusedOutputTest = Scope:Value(nil :: AvantRuntime.Test?),
    }, TestRunner) :: TestRunner
end

--[[
Runs a set of tests.
--]]
function TestRunner.RunTests(self: TestRunner, Tests: {AvantRuntime.Test}): ()
    --Set the start time as now.
    self.LastTestRunTime:set(DateTime.now())

    --Reset the tests.
    local RootTest = self.ListEntry.Test
    local FilteredTests = {}
    for _, Test in Tests do
        if Test.ModuleScript then
            --Reset the test state.
            (Test :: AvantRuntime.Test):ResetTestState()
            table.insert(FilteredTests, Test)
        else
            --Remove the test since the source no longer exists.
            RootTest:RemoveChildTest(Test :: AvantRuntime.Test)
        end
    end

    --Run the tests.
    for _, Test in FilteredTests do
        RunModuleScript(Test :: AvantRuntime.Test)
    end
end

--[[
Returns the tests for a group.
--]]
function TestRunner.GetTestsForGroup(self: TestRunner, Group: TestGroup): {AvantRuntime.Test}
    local Tests = {}
    for _, ChildEntry in Fusion.peek(self.ListEntry.Entry.Children) do
        --Determine if the condition matches.
        local ChildTest = Fusion.peek(ChildEntry.Data) :: AvantRuntime.Test
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
function TestRunner.FocusOutput(self: TestRunner, Test: AvantRuntime.Test): ()
    self.FocusedOutputTest:set(Test)
end



return TestRunner