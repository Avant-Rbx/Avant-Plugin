--Tests CreateTestIcon.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateFusionScope = require(ReplicatedStorage.AvantPlugin.NexusPluginComponents.CreateFusionScope)
local CreateTestIcon = require(ReplicatedStorage.AvantPlugin.TestView.CreateTestIcon)

return function()
    describe("A TestIcon", function()
        local TestScope = nil
        local TestStateValue, TestContentsStateValue, TestHasOutputValue = nil, nil, nil
        local TestTestIcon = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            
            TestStateValue = TestScope:Value("PASSED")
            TestContentsStateValue = TestScope:Value("NORMAL")
            TestHasOutputValue = TestScope:Value(false)

            TestTestIcon = CreateTestIcon(TestScope, TestStateValue :: any, TestContentsStateValue :: any, TestHasOutputValue)
        end)

        afterEach(function()
            TestScope:doCleanup()
        end)

        it("should show the correct icon.", function()
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(0, 200, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(512, 0))

            TestStateValue:set("NOT_RUN")
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(0, 170, 255))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(0, 0))

            TestStateValue:set("IN_PROGRESS")
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(255, 150, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(256, 0))

            TestStateValue:set("FAILED")
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(200, 0, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(768, 0))

            TestStateValue:set("SKIPPED")
            expect(TestTestIcon.Image).to.equal("rbxassetid://4595118527")
            expect(TestTestIcon.ImageColor3).to.equal(Color3.fromRGB(220, 220, 0))
            expect(TestTestIcon.ImageRectSize).to.equal(Vector2.new(256, 256))
            expect(TestTestIcon.ImageRectOffset).to.equal(Vector2.new(0, 256))
        end)

        it("should show the correct content state.", function()
            local TestContentState = TestTestIcon:FindFirstChild("ContentState") :: Frame
            expect(TestContentState.Visible).to.equal(false)

            TestContentsStateValue:set("UPDATED")
            expect(TestContentState.BackgroundColor3).to.equal(Color3.fromRGB(200, 160, 0))
            expect(TestContentState.Visible).to.equal(true)

            TestContentsStateValue:set("MISSING")
            expect(TestContentState.BackgroundColor3).to.equal(Color3.fromRGB(200, 50, 0))
            expect(TestContentState.Visible).to.equal(true)
        end)

        it("should show the correct output state.", function()
            local TestOutputState = TestTestIcon:FindFirstChild("OutputState") :: Frame
            expect(TestOutputState.Visible).to.equal(false)
        
            TestHasOutputValue:set(true)
            expect(TestOutputState.Visible).to.equal(true)
        end)
    end)

    describe("A TestIcon without HasOutput", function()
        local TestScope = nil
        local TestStateValue, TestContentsStateValue = nil, nil
        local TestTestIcon = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            
            TestStateValue = TestScope:Value("PASSED")
            TestContentsStateValue = TestScope:Value("NORMAL")

            TestTestIcon = CreateTestIcon(TestScope, TestStateValue :: any, TestContentsStateValue :: any)
        end)

        afterEach(function()
            TestScope:doCleanup()
        end)

        it("should show the correct output state.", function()
            local TestOutputState = TestTestIcon:FindFirstChild("OutputState") :: Frame
            expect(TestOutputState.Visible).to.equal(false)
        end)
    end)
end