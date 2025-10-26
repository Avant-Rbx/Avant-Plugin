--Tests TestRunner.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvantRuntime = require(ReplicatedStorage.AvantPlugin.Packages.AvantRuntime)
local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local TestSelectionListEntry = require(ReplicatedStorage.AvantPlugin.TestView.TestSelectionListEntry)
local TestRunner = require(ReplicatedStorage.AvantPlugin.TestRunner)

local Test = AvantRuntime.Test
local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A TestRunner", function()
        local TestScope, TestTest, TestTestSelectionListEntry = nil, nil, nil
        local TestTestRunner = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest = Test.new()
            TestTestSelectionListEntry = TestSelectionListEntry.new(TestScope, AvantRuntime.AvantConfiguration.new(), TestTest)

            TestTestRunner = TestRunner.new(TestScope, TestTestSelectionListEntry)
        end)

        afterEach(function()
            task.wait() --Hides error due to Scope being cleaned up before events are fired.
            TestScope:doCleanup()
            TestTest:Destroy()
        end)

        it("should run tests.", function()
            local ModuleScript = Instance.new("ModuleScript")
            ModuleScript.Source = "return true"

            local NewTest = TestTest:CreateChildTest()
            NewTest.ModuleScript = ModuleScript
        
            expect(#TestTest.ChildTests).to.equal(1)
            TestTestRunner:RunTests({NewTest})
            expect(#TestTest.ChildTests).to.equal(1)
            expect(NewTest.State).to.equal("PASSED")
        end)

        it("should remove stale tests on run.", function()
            local NewTest = TestTest:CreateChildTest()
        
            expect(#TestTest.ChildTests).to.equal(1)
            TestTestRunner:RunTests({NewTest})
            expect(#TestTest.ChildTests).to.equal(0)
            expect(NewTest.State).to.equal("NOT_RUN")
        end)

        it("should get all tests.", function()
            local NewTest1 = TestTest:CreateChildTest()
            local NewTest2 = TestTest:CreateChildTest()
            local NewTest3 = NewTest2:CreateChildTest()
            local NewTest4 = TestTest:CreateChildTest()
            task.wait()

            local Tests = TestTestRunner:GetTestsForGroup("ALL")
            expect(#Tests).to.equal(3)
            expect(Tests[1]).to.equal(NewTest1)
            expect(Tests[2]).to.equal(NewTest2)
            expect(Tests[3]).to.equal(NewTest4)
        end)

        it("should get failed tests.", function()
            local NewTest1 = TestTest:CreateChildTest()
            local NewTest2 = TestTest:CreateChildTest()
            local NewTest3 = NewTest2:CreateChildTest()
            local NewTest4 = TestTest:CreateChildTest()
            NewTest1.State = "FAILED"
            NewTest3.State = "FAILED"
            task.wait()

            local Tests = TestTestRunner:GetTestsForGroup("FAILED")
            expect(#Tests).to.equal(2)
            expect(Tests[1]).to.equal(NewTest1)
            expect(Tests[2]).to.equal(NewTest2)
        end)

        it("should get selected test.", function()
            local NewTest1 = TestTest:CreateChildTest()
            local NewTest2 = TestTest:CreateChildTest()
            local NewTest3 = NewTest2:CreateChildTest()
            local NewTest4 = TestTest:CreateChildTest()
            task.wait()
            TestTestSelectionListEntry.ChildEntries[NewTest1].Entry.Selected:set(true)
            TestTestSelectionListEntry.ChildEntries[NewTest2].ChildEntries[NewTest3].Entry.Selected:set(true)

            local Tests = TestTestRunner:GetTestsForGroup("SELECTED")
            expect(#Tests).to.equal(2)
            expect(Tests[1]).to.equal(NewTest1)
            expect(Tests[2]).to.equal(NewTest2)
        end)

        it("should run the given group.", function()
            local ModuleScript = Instance.new("ModuleScript")
            ModuleScript.Source = "return true"

            local NewTest1 = TestTest:CreateChildTest()
            local NewTest2 = TestTest:CreateChildTest()
            NewTest1.State = "FAILED"
            NewTest1.ModuleScript = ModuleScript
            NewTest2.ModuleScript = ModuleScript
            task.wait()

            TestTestRunner:RunTestsForGroup("FAILED")
            expect(NewTest1.State).to.equal("PASSED")
            expect(NewTest2.State).to.equal("NOT_RUN")
        end)

        it("should run all tests when the given group is empty.", function()
            local ModuleScript = Instance.new("ModuleScript")
            ModuleScript.Source = "return true"

            local NewTest1 = TestTest:CreateChildTest()
            local NewTest2 = TestTest:CreateChildTest()
            NewTest1.ModuleScript = ModuleScript
            NewTest2.ModuleScript = ModuleScript
            task.wait()

            TestTestRunner:RunTestsForGroup("FAILED")
            expect(NewTest1.State).to.equal("PASSED")
            expect(NewTest2.State).to.equal("PASSED")
        end)

        it("should focus the output of a test.", function()
            TestTestRunner:FocusOutput(TestTest)
            expect(TestScope.peek(TestTestRunner.FocusedOutputTest)).to.equal(TestTest)
        end)
    end)
end