--Tests CreateTestEntry.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvantRuntime = require(ReplicatedStorage.AvantPlugin.Packages.AvantRuntime)
local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local CreateTestEntry = require(ReplicatedStorage.AvantPlugin.TestView.CreateTestEntry)

local Test = AvantRuntime.Test
local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A TestEntry", function()
        local TestScope, TestTest = nil, nil
        local TestValue = nil
        local TestEntry = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestTest = Test.new()
            TestTest.Name = "TestName"
            TestValue = TestScope:Value(TestTest)

            TestEntry = CreateTestEntry(TestScope, TestValue)
        end)

        afterEach(function()
            TestScope:doCleanup()
            TestTest:Destroy()
        end)

        it("should show the test state.", function()
            local TestStateIcon = TestEntry[1] :: ImageLabel
            TestTest.CombinedState = "PASSED"
            task.wait()
            expect(TestStateIcon.ImageColor3).to.equal(Color3.fromRGB(0, 200, 0))
            expect(TestStateIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestStateIcon.ImageRectOffset).to.equal(Vector2.new(512, 0))
        end)

        it("should show the test name without a duration.", function()
            local TestName = TestEntry[2] :: TextLabel
            expect(TestName.Text).to.equal("TestName")
        end)

        it("should show the test name with a duration.", function()
            local TestName = TestEntry[2] :: TextLabel
            local SubTextColor = (settings().Studio.Theme :: StudioTheme):GetColor(Enum.StudioStyleGuideColor.SubText)
            local SubTextColorText = `{math.floor(255 * SubTextColor.R)},{math.floor(255 * SubTextColor.G)},{math.floor(255 * SubTextColor.B)}`

            TestTest.StartTime = 10
            task.wait()
            expect(TestName.Text).to.equal("TestName")

            TestTest.EndTime = 15
            task.wait()
            expect(TestName.Text).to.equal(`TestName <i><font color=\"rgb({SubTextColorText})\">(5.000 seconds)</font></i>`)

            TestTest.StartTime = nil
            task.wait()
            expect(TestName.Text).to.equal("TestName")
        end)

        it("should update for new tests.", function()
            local TestStateIcon = TestEntry[1] :: ImageLabel
            local TestName = TestEntry[2] :: TextLabel

            local NewTest = Test.new()
            NewTest.Name = "OtherTestName"
            NewTest.CombinedState = "FAILED"
            TestValue:set(NewTest)
        
            expect(TestStateIcon.ImageColor3).to.equal(Color3.fromRGB(200, 0, 0))
            expect(TestStateIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestStateIcon.ImageRectOffset).to.equal(Vector2.new(768, 0))
            expect(TestName.Text).to.equal("OtherTestName")
        end)
    end)
end