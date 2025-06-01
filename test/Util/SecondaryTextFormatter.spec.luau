--Tests SecondaryTextFormatter.
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NexusPluginComponents = require(ReplicatedStorage.AvantPlugin.Packages.NexusPluginComponents)
local SecondaryTextFormatter = require(ReplicatedStorage.AvantPlugin.Util.SecondaryTextFormatter)

local CreateFusionScope = NexusPluginComponents.CreateFusionScope

return function()
    describe("A SecondaryTextFormatter", function()
        local TestScope = nil
        beforeEach(function()
            TestScope = CreateFusionScope()
        end)

        afterEach(function()
            TestScope:doCleanup()
        end)

        it("should format primary and secondary text.", function()
            local SubTextColor = (settings().Studio.Theme :: StudioTheme):GetColor(Enum.StudioStyleGuideColor.SubText)
            local SubTextColorText = `{math.floor(255 * SubTextColor.R)},{math.floor(255 * SubTextColor.G)},{math.floor(255 * SubTextColor.B)}`

            local Text = TestScope.peek(SecondaryTextFormatter(TestScope, "PrimaryText", "SecondaryText"))
            expect(Text).to.equal(`PrimaryText <i><font color=\"rgb({SubTextColorText})\">(SecondaryText)</font></i>`)
        end)

        it("should format primary and nil secondary text.", function()
            local Text = TestScope.peek(SecondaryTextFormatter(TestScope, "PrimaryText", nil))
            expect(Text).to.equal("PrimaryText")
        end)

        it("should format primary and empty secondary text.", function()
            local Text = TestScope.peek(SecondaryTextFormatter(TestScope, "PrimaryText", ""))
            expect(Text).to.equal("PrimaryText")
        end)
    end)
end