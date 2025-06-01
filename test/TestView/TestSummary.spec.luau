--Tests TestSummary.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvantRuntime = require(ReplicatedStorage.AvantPlugin.Packages.AvantRuntime)
local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local TestSummary = require(ReplicatedStorage.AvantPlugin.TestView.TestSummary)

local Test = AvantRuntime.Test
local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A TestSelectionListEntry", function()
        local TestScope, TestTest = nil, nil
        local TestTestSummary = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest = Test.new()
            TestTestSummary = TestSummary.new(TestScope, TestTest)
        end)

        afterEach(function()
            TestScope:doCleanup()
            TestTest:Destroy()
        end)

        it("should store empty values by default.", function()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(0)
        end)

        it("should store test results.", function()
            local ChildTest1 = TestTest:CreateChildTest()
            ChildTest1.State = "PASSED"
            local ChildTest2 = ChildTest1:CreateChildTest()
            ChildTest2.State = "PASSED"
            local ChildTest3 = ChildTest1:CreateChildTest()
            ChildTest3.State = "PASSED"

            task.wait()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(0)
            
            ChildTest1.State = "SKIPPED"
            task.wait()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(2)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(1)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(0)
            
            ChildTest1.State = "FAILED"
            task.wait()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(2)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(1)
        end)

        it("should remove test results.", function()
            local ChildTest1 = TestTest:CreateChildTest()
            ChildTest1.State = "PASSED"
            local ChildTest2 = ChildTest1:CreateChildTest()
            ChildTest2.State = "PASSED"
            local ChildTest3 = ChildTest2:CreateChildTest()
            ChildTest3.State = "PASSED"

            task.wait()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(3)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(0)
            
            ChildTest1:RemoveChildTest(ChildTest2)
            task.wait()
            expect(TestScope.peek(TestTestSummary.TotalTests)).to.equal(1)
            expect(TestScope.peek(TestTestSummary.PassedTests)).to.equal(1)
            expect(TestScope.peek(TestTestSummary.SkippedTests)).to.equal(0)
            expect(TestScope.peek(TestTestSummary.FailedTests)).to.equal(0)
        end)
    end)
end