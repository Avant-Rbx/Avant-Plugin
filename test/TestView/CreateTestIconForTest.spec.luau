--Tests CreateTestIconForTest.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvantRuntime = require(ReplicatedStorage.AvantPlugin.Packages.AvantRuntime)
local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local CreateTestIconForTest = require(ReplicatedStorage.AvantPlugin.TestView.CreateTestIconForTest)

local Test = AvantRuntime.Test
local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A TestIcon for a test", function()
        local TestScope, TestTest = nil, nil
        local TestValue = nil
        local TestTestIcon = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest = Test.new()
            TestValue = TestScope:Value(TestTest)

            TestTestIcon = CreateTestIconForTest(TestScope, TestValue)
        end)

        afterEach(function()
            TestScope:doCleanup()
            TestTest:Destroy()
        end)

        it("should have the correct state.", function()
            TestTest.CombinedState = "PASSED"
            task.wait()
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(0, 200, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(512, 0))
        end)

        it("should have the correct contents state.", function()
            local TestContentState = TestTestIcon:FindFirstChild("ContentState") :: Frame
            TestTest.ContentsState = "UPDATED"
            task.wait()
            expect(TestContentState.BackgroundColor3).to.equal(Color3.fromRGB(200, 160, 0))
            expect(TestContentState.Visible).to.equal(true)
        end)

        it("should show the output state.", function()
            local TestOutputState = TestTestIcon:FindFirstChild("OutputState") :: Frame
            TestTest.OutputAdded:Fire({} :: any)
            task.wait()
            expect(TestOutputState.Visible).to.equal(true)

            TestTest.OutputCleared:Fire()
            task.wait()
            expect(TestOutputState.Visible).to.equal(false)
        end)

        it("should update for new tests.", function()
            local NewTest = Test.new()
            NewTest.CombinedState = "FAILED"
            NewTest.ContentsState = "MISSING"
            NewTest.Output = {{} :: any}
            TestValue:set(NewTest)

            local TestContentState = TestTestIcon:FindFirstChild("ContentState") :: Frame
            local TestOutputState = TestTestIcon:FindFirstChild("OutputState") :: Frame
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(200, 0, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(768, 0))
            expect(TestContentState.BackgroundColor3).to.equal(Color3.fromRGB(200, 50, 0))
            expect(TestContentState.Visible).to.equal(true)
            expect(TestOutputState.Visible).to.equal(true)
        end)
    end)
end