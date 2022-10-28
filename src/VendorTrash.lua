-- create addon settings page
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        if not VendorTrashSettings then
            VendorTrashSettings = {}
        end

        local category = Settings.RegisterVerticalLayoutCategory("VendorTrash")

        do
            local variable = "SafeMode"
            local name = "Safe Mode"
            local tooltip = "At most 12 items are sold per button click so that all items can still be bought back."
            local defaultValue = true

            local setting = Settings.RegisterProxySetting(category, variable, VendorTrashSettings, type(defaultValue), name, defaultValue)
            Settings.CreateCheckBox(category, setting, tooltip)
        end

        Settings.RegisterAddOnCategory(category)
    end
end)
f:RegisterEvent("PLAYER_LOGIN")

-- add vendor button to merchant window
local VendorButton
VendorButton = CreateFrame("Button", nil, MerchantFrame, "UIPanelButtonTemplate")
VendorButton:SetPoint("TOPLEFT", 60, -28)
VendorButton:SetSize(85, 30)
VendorButton:SetText("Sell Trash")
VendorButton:SetScript("OnClick", function() Vendor() end)

-- vendor button logic
function Vendor()
    local itemStackCount, itemQuality, itemHasNoValue, itemID, itemSellPrice
    local totalSellValue = 0
    local amountSold = 0
    for containerIndex=0, 5 do
        for slotIndex=1, GetContainerNumSlots(containerIndex) do
            _, itemStackCount, _, itemQuality, _, _, _, _, itemHasNoValue, itemID, _ = GetContainerItemInfo(containerIndex, slotIndex)
            if itemQuality == 0 and not itemHasNoValue then
                itemSellPrice = select(11, GetItemInfo(itemID)) * itemStackCount
                totalSellValue = totalSellValue + itemSellPrice
                PickupContainerItem(containerIndex, slotIndex)
                PickupMerchantItem()
                amountSold = amountSold + 1
                if VendorTrashSettings["SafeMode"] and amountSold == 12 then
                    totalSellValue = GetCoinTextureString(totalSellValue)
                    print("[VendorTrash] Safe Mode is enabled, stopping after 12 items. Mode can be changed in settings.")
                    print("[VendorTrash] Sold " .. amountSold .. " uncommon items for " .. totalSellValue .. ".")
                    return
                end
            end
        end
    end
    totalSellValue = GetCoinTextureString(totalSellValue)
    print("[VendorTrash] Sold " .. amountSold .. " uncommon items for " .. totalSellValue .. ".")
end