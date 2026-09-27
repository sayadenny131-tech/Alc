-- ============================================================================
-- SKUY SERVER AUTH + LICENSE KEY POPUP (STANDALONE EXTRACT)
-- Extracted from the working BRP/UI integration and decoupled from BRP features.
--
-- Usage:
--   local Auth = require("SKUY_SERVER_AUTH_EXTRACT")
--   Auth.Start(function(info)
--       print("AUTH OK", info.days_remaining, info.key_type)
--       -- Start your own systems here.
--   end)
--
-- Runtime dependencies expected from the game environment:
--   ModuleManager, CGame, slua_GameFrontendHUD, slua, UIContainers,
--   FLinearColor, FSlateColor, FAnchors, FVector2D, UEnums, import()
-- ============================================================================

local Auth = {}

Auth.URL = "https://luaserver.xxxxxxxxxxxx.workers.dev/api/auth?x=123"
Auth.KeyFileName = "KEY_SKUY.txt"
Auth.Contact = "@sayadeni131"
Auth.Pending = false
Auth.Ready = false

function Auth.GetPaths()
    return {
        "/storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/storage/emulated/0/Android/data/com.vng.pubgmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/storage/emulated/0/Android/data/com.rekoo.pubgm/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "/storage/emulated/0/Android/data/com.pubg.imobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/",
        "Documents/ShadowTrackerExtra/Saved/Paks/",
        "/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/com.tencent.ig/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/com.pubg.krmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/com.vng.pubgmobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/com.rekoo.pubgm/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/com.pubg.imobile/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Applications/UE4Game/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/private/var/mobile/Applications/UE4Game/Documents/ShadowTrackerExtra/Saved/Paks/",
        "/var/mobile/Containers/Data/Application/ShadowTrackerExtra/Documents/Saved/Paks/",
        "/private/var/mobile/Containers/Data/Application/ShadowTrackerExtra/Documents/Saved/Paks/",
        "ShadowTrackerExtra/Saved/Paks/",
        "../../ShadowTrackerExtra/Saved/Paks/",
        "../../../ShadowTrackerExtra/Saved/Paks/",
        "../../../../ShadowTrackerExtra/Saved/Paks/",
        "../../../../../ShadowTrackerExtra/Saved/Paks/"
    }
end

function Auth.NormalizeKey(value)
    if value == nil then return nil end
    value = tostring(value):gsub("%s+", "")
    if value == "" or value == "PASTE_YOUR_TIME_LIMITED_KEY_HERE" then
        return nil
    end
    return value
end

function Auth.WriteKey(path, value)
    local ok, f = pcall(function()
        return io.open(path, "w")
    end)
    if not ok or not f then return false end
    f:write(value)
    f:close()
    return true
end

function Auth.ReadKey()
    for _, path in ipairs(Auth.GetPaths()) do
        local f = io.open(path .. Auth.KeyFileName, "r")
        if f then
            local data = f:read("*a")
            f:close()
            data = Auth.NormalizeKey(data)
            if data then
                return data
            end
        end
    end
    return nil
end

function Auth.SaveKeyToFile(value)
    local key = Auth.NormalizeKey(value)
    if not key then return false end

    Auth.KeyCache = key
    _G._SKUY_KEY_CACHE = key

    for _, path in ipairs(Auth.GetPaths()) do
        if path and path ~= "" then
            if Auth.WriteKey(path .. Auth.KeyFileName, key) then
                return true
            end
        end
    end
    return false
end

function Auth.GetKeyFromFile()
    local key = Auth.NormalizeKey(Auth.KeyCache or _G._SKUY_KEY_CACHE)
    if key then return key end

    key = Auth.NormalizeKey(Auth.ReadKey())
    if key then
        Auth.KeyCache = key
        _G._SKUY_KEY_CACHE = key
    end
    return key
end

function Auth.GetHWID()
    local hwid = nil
    pcall(function()
        local KismetSystemLibrary = import("KismetSystemLibrary")
        if KismetSystemLibrary and KismetSystemLibrary.GetDeviceId then
            hwid = KismetSystemLibrary:GetDeviceId()
        end
    end)

    hwid = tostring(hwid or "UNKNOWN_DEVICE")
    Auth.HWID = hwid
    _G._CURRENT_USER_HWID = hwid
    return hwid
end

function Auth.GenerateSign(key, hwid, timestamp, nonce)
    local raw = key .. "NOX" .. hwid .. "mod" .. tostring(timestamp) .. tostring(nonce)
    local hash = 5381
    for i = 1, #raw do
        hash = (hash * 33 + string.byte(raw, i)) % 4294967296
    end
    return tostring(math.floor(hash % 2147483647))
end

function Auth.ShowError(message)
    Auth.Message = tostring(message or "Unknown authentication error")
    _G._AuthMessage_ = Auth.Message

    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"]
            or require("client.slua.logic.common.logic_common_msg_box")

        if Msg and Msg.Show then
            Msg.Show(
                4,
                "ACCESS DENIED",
                Auth.Message .. "\nContact " .. tostring(Auth.Contact),
                nil,
                nil,
                "OK"
            )
        end
    end)
end

function Auth.ShowKeyInputUI(callback)
    if Auth.KeyInputShown or _G._SKUY_KEY_INPUT_SHOWN == true then
        return false
    end

    Auth.KeyInputShown = true
    _G._SKUY_KEY_INPUT_SHOWN = true

    local existingKey = Auth.GetKeyFromFile() or ""
    local inputBox = nil
    local rootWidget = nil
    local closeWidget = nil

    local function finish(key)
        Auth.KeyInputShown = false
        _G._SKUY_KEY_INPUT_SHOWN = false

        if rootWidget and slua.isValid(rootWidget) then
            pcall(function()
                rootWidget:RemoveFromParent()
            end)
        end

        if closeWidget then
            closeWidget()
            closeWidget = nil
        end

        if callback then
            callback(key)
        end
    end

    local ok, err = pcall(function()
        local root = CGame:NewObjectFromPath(
            "/Script/UMG.CanvasPanel",
            slua_GameFrontendHUD:GetWorld()
        )

        if not root or not slua.isValid(root) then
            root = slua.loadUI(
                "/Game/UMG/UI_BP/Common/Common_Legal_01_UIBP.Common_Legal_01_UIBP"
            )
        end

        if not root or not slua.isValid(root) then
            return
        end

        local hud = require("game_frontend_hud")
        hud.AddToContainer(UIContainers.Top, root, 12000)

        if root.SetBrushColor then
            root:SetBrushColor(FLinearColor(0.05, 0.05, 0.15, 0.92))
        elseif root.Image_Background then
            root.Image_Background:SetColorAndOpacity(FLinearColor(0.05, 0.05, 0.15, 0.92))
        end

        pcall(function()
            if root.RichText_Content then
                root.RichText_Content:SetText("")
            end
            if root.UTRichText_Content then
                root.UTRichText_Content:SetText("")
            end
        end)

        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")

        local title = CGame:NewObjectFromPath(
            "/Script/UMG.TextBlock",
            slua_GameFrontendHUD:GetWorld()
        )

        if title and slua.isValid(title) then
            title:SetText("ENTER LICENSE KEY")
            title:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0.8, 1, 1)))
            pcall(function()
                local font = title.Font
                if font then
                    font.Size = 22
                    title:SetFont(font)
                end
            end)
            root:AddChild(title)
            local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(title)
            if slot then
                slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                slot:SetAlignment(FVector2D(0.5, 0))
                slot:SetPosition(FVector2D(20, 20))
                slot:SetSize(FVector2D(400, 40))
            end
        end

        inputBox = CGame:NewObjectFromPath(
            "/Script/UMG.EditableTextBox",
            slua_GameFrontendHUD:GetWorld()
        )

        if inputBox and slua.isValid(inputBox) then
            inputBox:SetHintText("Type or paste your key here...")
            if existingKey ~= "" and inputBox.SetText then
                inputBox:SetText(existingKey)
            end
            root:AddChild(inputBox)
            local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(inputBox)
            if slot then
                slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                slot:SetAlignment(FVector2D(0.5, 0))
                slot:SetPosition(FVector2D(20, 80))
                slot:SetSize(FVector2D(350, 40))
            end
        end

        local function submit()
            local text = ""
            if inputBox and slua.isValid(inputBox) then
                text = inputBox:GetText() or ""
            end

            local key = Auth.NormalizeKey(text)
            if key then
                Auth.SaveKeyToFile(key)
                finish(key)
            else
                Auth.ShowError("Key cannot be empty!")
                local pc = slua_GameFrontendHUD:GetPlayerController()
                if pc and slua.isValid(pc) and pc.DisplayGameTip then
                    pc:DisplayGameTip("Key cannot be empty!")
                end
            end
        end

        local okButton = slua.loadUI(
            "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
        )

        if okButton and slua.isValid(okButton) then
            if okButton.RichText_Content then
                okButton.RichText_Content:SetText("OK")
                pcall(function()
                    local font = okButton.RichText_Content.Font
                    if font then
                        font.Size = 16
                        okButton.RichText_Content:SetFont(font)
                    end
                end)
                okButton.RichText_Content:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0.8, 1, 1)))
            end

            if okButton.Button_Temp and okButton.Button_Temp.OnClicked then
                okButton.Button_Temp.OnClicked:Add(submit)
            end

            root:AddChild(okButton)
            local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(okButton)
            if slot then
                slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                slot:SetAlignment(FVector2D(0.5, 0))
                slot:SetPosition(FVector2D(-80, 150))
                slot:SetSize(FVector2D(100, 40))
            end
        end

        local cancelButton = slua.loadUI(
            "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
        )

        if cancelButton and slua.isValid(cancelButton) then
            if cancelButton.RichText_Content then
                cancelButton.RichText_Content:SetText("CANCEL")
                pcall(function()
                    local font = cancelButton.RichText_Content.Font
                    if font then
                        font.Size = 16
                        cancelButton.RichText_Content:SetFont(font)
                    end
                end)
                cancelButton.RichText_Content:SetColorAndOpacity(FSlateColor(FLinearColor(1, 0.3, 0.3, 1)))
            end

            if cancelButton.Button_Temp and cancelButton.Button_Temp.OnClicked then
                cancelButton.Button_Temp.OnClicked:Add(function()
                    finish(nil)
                end)
            end

            root:AddChild(cancelButton)
            local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(cancelButton)
            if slot then
                slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
                slot:SetAlignment(FVector2D(0.5, 0))
                slot:SetPosition(FVector2D(80, 150))
                slot:SetSize(FVector2D(100, 40))
            end
        end

        rootWidget = root
        root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)

        closeWidget = function()
            if rootWidget and slua.isValid(rootWidget) then
                pcall(function()
                    rootWidget:RemoveFromParent()
                end)
            end
            rootWidget = nil
            inputBox = nil
        end

        if inputBox and slua.isValid(inputBox) and inputBox.OnTextCommitted then
            inputBox.OnTextCommitted:Add(function(text, commitMethod)
                if commitMethod == UEnums.ETextCommit.OnEnter then
                    local key = Auth.NormalizeKey(text)
                    if key then
                        Auth.SaveKeyToFile(key)
                        finish(key)
                    else
                        Auth.ShowError("Key cannot be empty!")
                    end
                end
            end)
        end
    end)

    if not ok then
        Auth.KeyInputShown = false
        _G._SKUY_KEY_INPUT_SHOWN = false
        Auth.ShowError("Unable to open license-key UI: " .. tostring(err))
        return false
    end

    if not rootWidget then
        Auth.KeyInputShown = false
        _G._SKUY_KEY_INPUT_SHOWN = false
        Auth.ShowError("Unable to create license-key UI")
        return false
    end

    return true
end

function Auth.ShowKeyInputPrompt(callback)
    return Auth.ShowKeyInputUI(callback)
end

function Auth.ResetKey()
    Auth.KeyCache = nil
    _G._SKUY_KEY_CACHE = nil
end

function Auth.GetHttpManager()
    if not ModuleManager or not ModuleManager.GetModule then
        return nil
    end
    if not ModuleManager.CommonModuleConfig then
        return nil
    end
    return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)
end

function Auth.Start(onSuccess, onFailure)
    if Auth.Pending then
        return false, "AUTH_PENDING"
    end

    if Auth.Ready or _G._Authenticated_ == true then
        Auth.Ready = true
        _G.SkuyAuthReady = true
        if onSuccess then
            onSuccess({
                days_remaining = tonumber(_G._DaysRemaining_) or 0,
                key_type = _G.VALID_KEY_TYPE or "VIP",
                expiry = _G._ExpireDateStr_ or "Online Approved",
                hwid = Auth.HWID or _G._CURRENT_USER_HWID
            })
        end
        return true
    end

    local key = Auth.GetKeyFromFile()
    if not key then
        _G._Authenticated_ = false
        local msg = Auth.KeyFileName .. " was not found or is empty!"
        Auth.ShowError(msg)

        Auth.ShowKeyInputPrompt(function(newKey)
            if newKey then
                Auth.Start(onSuccess, onFailure)
            elseif onFailure then
                onFailure("KEY_REQUIRED")
            end
        end)
        return false, "KEY_REQUIRED"
    end

    local httpManager = Auth.GetHttpManager()
    if not httpManager or type(httpManager.Post) ~= "function" then
        local msg = "HttpManager is unavailable!"
        Auth.ShowError(msg)
        if onFailure then onFailure(msg) end
        return false, "HTTP_UNAVAILABLE"
    end

    local timestamp = os.time()
    math.randomseed(timestamp)
    local nonce = math.random(100000, 999999)
    local hwid = Auth.GetHWID()
    local sign = Auth.GenerateSign(key, hwid, timestamp, nonce)

    local body = string.format(
        "user_key=%s&hwid=%s&timestamp=%d&nonce=%d&sign=%s",
        key,
        hwid,
        timestamp,
        nonce,
        sign
    )

    Auth.Pending = true
    _G.SkuyAuthPending = true

    httpManager:Post(
        Auth.URL,
        { ["Content-Type"] = "application/x-www-form-urlencoded" },
        body,
        nil,
        function(ok, response, _, httpCode)
            Auth.Pending = false
            _G.SkuyAuthPending = false

            if not ok then
                Auth.Ready = false
                _G._Authenticated_ = false
                local msg = "Server connection failed! HTTP Code: " .. tostring(httpCode)
                Auth.ShowError(msg)

                if onFailure then onFailure(msg) end
                Auth.ShowKeyInputPrompt(function(newKey)
                    if newKey then
                        Auth.Start(onSuccess, onFailure)
                    end
                end)
                return
            end

            local status, value = string.match(response or "", "^([^|]+)|(.*)")
            if status ~= "OK" then
                Auth.Ready = false
                _G._Authenticated_ = false
                local msg = "Server rejected the key: " .. tostring(value or response)
                Auth.ShowError(msg)

                if onFailure then onFailure(msg) end
                Auth.ShowKeyInputPrompt(function(newKey)
                    if newKey then
                        Auth.Start(onSuccess, onFailure)
                    end
                end)
                return
            end

            Auth.Ready = true
            _G._Authenticated_ = true
            _G._DaysRemaining_ = tonumber(value) or 0
            _G._ExpireDateStr_ = "Online Approved"
            _G.VALID_KEY_TYPE = "VIP"
            _G.USER_EXPIRY_TIME = _G._ExpireDateStr_
            _G.SkuyAuthReady = true

            if onSuccess then
                onSuccess({
                    days_remaining = _G._DaysRemaining_,
                    key_type = _G.VALID_KEY_TYPE,
                    expiry = _G._ExpireDateStr_,
                    hwid = hwid,
                    key = key
                })
            end
        end
    )

    return true
end

return Auth
