--Tests TestOutput.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Test = require(ReplicatedStorage.AvantPlugin.AvantRuntime.State.Test.Test)
local CreateFusionScope = require(ReplicatedStorage.AvantPlugin.NexusPluginComponents.CreateFusionScope)
local TestOutput = require(ReplicatedStorage.AvantPlugin.OutputView.TestOutput)

return function()
    describe("A TestOutput", function()
        local TestScope, TestTest = nil, nil
        local TestValue = nil
        local TestTestOutput = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest = Test.new()
            TestValue = TestScope:Value(nil :: Test.Test?)
            
            TestTestOutput = TestOutput.new(TestScope, TestValue)
        end)

        afterEach(function()
            TestScope:doCleanup()
            TestTest:Destroy()
            TestTestOutput:Destroy()
        end)

        it("should start with no output.", function()
            TestValue:set(TestTest)

            local Output = TestScope.peek(TestTestOutput.Output)
            expect(#Output).to.equal(1)
            expect(Output[1].MessageType).to.equal(nil)
            expect(Output[1].Text).to.equal("No output.")
        end)

        it("should add new output.", function()
            TestValue:set(TestTest)
            TestTest:AddOutput(Enum.MessageType.MessageOutput, "Test message 1", "Test message 2")
            TestTest:AddOutput(Enum.MessageType.MessageWarning, "Test message 3\nTest message 4")
            task.wait()

            local Output = TestScope.peek(TestTestOutput.Output)
            expect(#Output).to.equal(3)
            expect(Output[1].MessageType).to.equal(Enum.MessageType.MessageOutput)
            expect(Output[1].Text).to.equal("Test message 1 Test message 2")
            expect(Output[2].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[2].Text).to.equal("Test message 3")
            expect(Output[3].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[3].Text).to.equal("Test message 4")
        end)

        it("should clear the output.", function()
            TestValue:set(TestTest)
            TestTest:AddOutput(Enum.MessageType.MessageOutput, "Test message 1", "Test message 2")
            TestTest:AddOutput(Enum.MessageType.MessageWarning, "Test message 3\nTest message 4")
            task.wait()
            TestTest:ClearOutput()
            task.wait()

            local Output = TestScope.peek(TestTestOutput.Output)
            expect(#Output).to.equal(1)
            expect(Output[1].MessageType).to.equal(nil)
            expect(Output[1].Text).to.equal("No output.")
        end)

        it("should start with output.", function()
            TestTest:AddOutput(Enum.MessageType.MessageOutput, "Test message 1", "Test message 2")
            TestTest:AddOutput(Enum.MessageType.MessageWarning, "Test message 3\nTest message 4")
            task.wait()
            TestValue:set(TestTest)

            local Output = TestScope.peek(TestTestOutput.Output)
            expect(#Output).to.equal(3)
            expect(Output[1].MessageType).to.equal(Enum.MessageType.MessageOutput)
            expect(Output[1].Text).to.equal("Test message 1 Test message 2")
            expect(Output[2].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[2].Text).to.equal("Test message 3")
            expect(Output[3].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[3].Text).to.equal("Test message 4")
        end)

        it("should change tests.", function()
            TestValue:set(TestTest)
            local NewTest = Test.new()
            NewTest:AddOutput(Enum.MessageType.MessageOutput, "Test message 1", "Test message 2")
            NewTest:AddOutput(Enum.MessageType.MessageWarning, "Test message 3\nTest message 4")
            task.wait()
            TestValue:set(NewTest)

            local Output = TestScope.peek(TestTestOutput.Output)
            expect(#Output).to.equal(3)
            expect(Output[1].MessageType).to.equal(Enum.MessageType.MessageOutput)
            expect(Output[1].Text).to.equal("Test message 1 Test message 2")
            expect(Output[2].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[2].Text).to.equal("Test message 3")
            expect(Output[3].MessageType).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[3].Text).to.equal("Test message 4")
        end)
    end)
end