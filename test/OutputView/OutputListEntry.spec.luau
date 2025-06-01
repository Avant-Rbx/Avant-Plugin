--Tests OutputListEntry.
--!strict


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local OutputListEntry = require(ReplicatedStorage.AvantPlugin.OutputView.OutputListEntry)

local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A OutputListEntry", function()
        local TestScope = nil
        local TestOutputListEntry = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
            TestOutputListEntry = OutputListEntry.new(TestScope, {
                MessageType = Enum.MessageType.MessageWarning,
                Text = "Test message",
            })
        end)

        afterEach(function()
            TestOutputListEntry:Destroy()
            TestScope:doCleanup()
        end)

        it("should display messages.", function()
            local TextLabel = TestOutputListEntry.GuiInstance:FindFirstChildOfClass("TextLabel") :: TextLabel
            expect(TextLabel.TextColor3).to.equal((settings().Studio.Theme :: StudioTheme):GetColor(Enum.StudioStyleGuideColor.WarningText))
            expect(TextLabel.Text).to.equal("Test message")
            expect(TextLabel.Font).to.equal(Enum.Font.SourceSans)
        end)

        it("should change messages.", function()
            local TextLabel = TestOutputListEntry.GuiInstance:FindFirstChildOfClass("TextLabel") :: TextLabel
            TestOutputListEntry:Update(1, {
                MessageType = Enum.MessageType.MessageError,
                Text = "New message",
            })
            expect(TextLabel.TextColor3).to.equal((settings().Studio.Theme :: StudioTheme):GetColor(Enum.StudioStyleGuideColor.ErrorText))
            expect(TextLabel.Text).to.equal("New message")
            expect(TextLabel.Font).to.equal(Enum.Font.SourceSans)
        end)

        it("should display internal messages.", function()
            local TextLabel = TestOutputListEntry.GuiInstance:FindFirstChildOfClass("TextLabel") :: TextLabel
            TestOutputListEntry:Update(1, {
                Text = "New message",
            })
            expect(TextLabel.TextColor3).to.equal((settings().Studio.Theme :: StudioTheme):GetColor(Enum.StudioStyleGuideColor.MainText))
            expect(TextLabel.Text).to.equal("New message")
            expect(TextLabel.Font).to.equal(Enum.Font.SourceSansItalic)
        end)
    end)
end