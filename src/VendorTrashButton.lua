-- create addon settings page
VendorTrashSettings = {}

local category = Settings.RegisterVerticalLayoutCategory("VendorTrashButton")

do
  local variable = "SafeMode"
  local name = "Safe Mode"
  local tooltip = "At most 12 items are sold per button click so that all items can still be bought back."
  local defaultValue = true

  local setting = Settings.RegisterProxySetting(category, variable, VendorTrashSettings, type(defaultValue), name, defaultValue)
  Settings.CreateCheckBox(category, setting, tooltip)
end

Settings.RegisterAddOnCategory(category)

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
    local GetContainerNumSlots = (C_Container.GetContainerNumSlots or GetContainerNumSlots)
    local GetContainerItemInfo = (C_Container.GetContainerItemInfo or GetContainerItemInfo)
    local UseContainerItem = (C_Container.UseContainerItem or UseContainerItem)
    local totalSellValue = 0
    local amountSold = 0
    for containerIndex=0, 5 do
        for slotIndex=1, GetContainerNumSlots(containerIndex) do
            _, itemStackCount, _, itemQuality, _, _, _, _, itemHasNoValue, itemID, _ = GetContainerItemInfo(containerIndex, slotIndex)
            if itemQuality == 0 and not itemHasNoValue then
                itemSellPrice = select(11, GetItemInfo(itemID)) * itemStackCount
                totalSellValue = totalSellValue + itemSellPrice
                UseContainerItem(containerIndex, slotIndex)
                amountSold = amountSold + 1
                if VendorTrashSettings["SafeMode"] and amountSold == 12 then
                    totalSellValue = GetCoinTextureString(totalSellValue)
                    print("[VendorTrashButton] Safe Mode is enabled, stopping after 12 items. Mode can be changed in settings.")
                    print("[VendorTrashButton] Sold " .. amountSold .. " uncommon items for " .. totalSellValue .. ".")
                    return
                end
            end
        end
    end
    totalSellValue = GetCoinTextureString(totalSellValue)
    print("[VendorTrashButton] Sold " .. amountSold .. " uncommon items for " .. totalSellValue .. ".")
end
