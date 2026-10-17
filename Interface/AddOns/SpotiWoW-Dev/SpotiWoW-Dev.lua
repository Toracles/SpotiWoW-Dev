-- SpotiWoW-Dev for Turtle WoW / WoW 1.12.1 (Lua 5.0 + SuperWoW)
-- Spotify bridge files live under the client's Imports folder.

local CHANNELS = { say="SAY", yell="YELL", party="PARTY", guild="GUILD", raid="RAID", emote="EMOTE" }
local CMD = { prev="prev", pause="pause", next="next", back="back", fwd="fwd", voldown="voldown", volup="volup", shuffle="shuffle", ["repeat"]="repeat" }
local Locale = SPOTIWOW_OCTO_L or {}
local UI_FALLBACK = {
    settings_title="Player Settings", settings_theme="Theme", settings_layout="Layout", settings_expand="Expand player", settings_compact="Use compact player",
    layout_compact="Compact", layout_square="Square", layout_expanded="Expanded", layout_help="Click options to cycle or toggle them. /spn help for commands.",
    settings_accent="Accent", settings_progress_color="Progress color", settings_custom_accent="Accent hex", settings_custom_progress="Progress hex", settings_apply="Apply", settings_glow="Glow", settings_border="Border", settings_buttons="Button accents", settings_controls="Controls", settings_metadata="Track details", settings_progress="Progress bar", settings_seek="Click to seek", settings_progress_style="Bar style", setting_on="ON", setting_off="OFF", color_default="Theme default",
    theme_obsidian="Obsidian", theme_azerite="Azerite", theme_fel="Fel", theme_bloodmoon="Bloodmoon",
    mode_shuffle="SHUFFLE", mode_repeat_all="REPEAT ALL", mode_repeat_track="REPEAT 1",
    help_1="/spn : show the current track locally", help_2="/spn say|yell|party|guild|raid|emote : announce the current track",
    help_3="/spn lyrics [on|off] : lyrics mode; /spn channel <channel> : lyrics channel",
    help_4="/spn ui : show/hide the mini-player; /spn settings : open settings",
    help_5="/spn prev|pause|next|back|fwd|voldown|volup : playback controls",
    settings_help="/spn mode compact|square|expanded; /spn expand toggles compact/expanded; /spn theme obsidian|azerite|fel|bloodmoon; /spn accent RRGGBB",
    settings_help2="/spn glow|border|buttons|controls|metadata|progress on|off; /spn progressstyle line|thick|segmented; /spn progresscolor RRGGBB; /spn seek on|off",
    theme_help="Themes: obsidian, azerite, fel, bloodmoon", color_help="Use RRGGBB (example: 1ED760), or reset.",
    progressstyle_help="Progress styles: line, thick, segmented", spotify_label="SPOTIFY", status_playing="PLAYING", status_paused="PAUSED", lyrics_toggle="Toggle lyrics",
}
local function T(key) return Locale[key] or UI_FALLBACK[key] or key end
local playing, volume, SendCommand = false, -1, nil
local ApplyStyle, RefreshUI, HexColor
local lastLyricsModeSeen = nil
local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage("|cff1ed760[Spotify]|r " .. msg) end
local function NowPlaying()
    if SpotifyNowDB and SpotifyNowDB.title and SpotifyNowDB.title ~= "" then return (SpotifyNowDB.artist or "") .. " - " .. SpotifyNowDB.title end
    return nil
end
local function Announce(channelKey)
    local np = NowPlaying(); if not np then Print(T("no_track")); return end
    local chan = CHANNELS[channelKey]
    if chan == "EMOTE" then SendChatMessage(T("announce_emote_prefix") .. np, "EMOTE") else SendChatMessage(T("announce_prefix") .. np .. " ~", chan) end
end
local function SingLine(text)
    if not SpotifyNowDB.lyrics or text == "" then return end
    local chan = CHANNELS[SpotifyNowDB.channel] or "SAY"
    if chan == "EMOTE" then SendChatMessage(T("sing_emote_prefix") .. text .. "\"", "EMOTE") else SendChatMessage("~ " .. text .. " ~", chan) end
end
local function PrintLyricsMode(on)
    if on then Print(T("lyrics_mode") .. "|cff00ff00ON|r") else Print(T("lyrics_mode") .. "|cffff0000OFF|r") end
end
local function SetLyrics(on, syncToCompanion)
    on = not not on; local changed = SpotifyNowDB.lyrics ~= on; SpotifyNowDB.lyrics = on; lastLyricsModeSeen = on
    if changed then PrintLyricsMode(on) end
    if syncToCompanion then SendCommand("lyrics", on and "1" or "0") end
end

local ui = CreateFrame("Frame", "SpotifyNowFrame", UIParent)
local currentPosMs,durationMs,stateTick=0,0,0
ui:SetWidth(300); ui:SetHeight(68); ui:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
ui:SetFrameStrata("MEDIUM"); ui:SetMovable(true); ui:EnableMouse(true); ui:SetClampedToScreen(true); ui:RegisterForDrag("LeftButton")
ui:SetBackdrop({ bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true, tileSize=32, edgeSize=32, insets={left=11,right=12,top=12,bottom=11} })
ui:SetScript("OnDragStart", function() this:StartMoving() end)
ui:SetScript("OnDragStop", function() this:StopMovingOrSizing(); local p,_,rp,x,y=this:GetPoint(); SpotifyNowDB.pos={p,rp,x,y} end)

local artFrame=CreateFrame("Frame",nil,ui)
artFrame:SetFrameLevel(ui:GetFrameLevel()+1)
artFrame:SetBackdrop({edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=8,insets={left=2,right=2,top=2,bottom=2}})
artFrame:SetBackdropColor(0,0,0,0)
local art = artFrame:CreateTexture("SpotifyNowArtwork", "ARTWORK")
art:SetWidth(34); art:SetHeight(34); art:SetPoint("TOPLEFT",artFrame,"TOPLEFT",3,-3); art:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
local titleText=ui:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",46,-8); titleText:SetWidth(128); titleText:SetJustifyH("LEFT")
local volText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
volText:SetWidth(40); volText:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-52,-8); volText:SetJustifyH("RIGHT")
local modeText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
modeText:SetPoint("TOPLEFT",ui,"TOPLEFT",46,-29); modeText:SetWidth(168); modeText:SetJustifyH("LEFT"); modeText:Hide()
local artistText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
artistText:SetPoint("TOPLEFT",ui,"TOPLEFT",96,-34); artistText:SetWidth(242); artistText:SetJustifyH("LEFT"); artistText:Hide()
local albumText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
albumText:SetPoint("TOPLEFT",ui,"TOPLEFT",96,-51); albumText:SetWidth(242); albumText:SetJustifyH("LEFT"); albumText:Hide()
local timeText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
timeText:SetPoint("BOTTOMRIGHT",ui,"BOTTOMRIGHT",-8,30); timeText:SetJustifyH("RIGHT"); timeText:Hide()
local sourceText=ui:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
sourceText:SetPoint("TOPLEFT",ui,"TOPLEFT",358,-30); sourceText:SetWidth(86); sourceText:SetJustifyH("LEFT"); sourceText:SetText(T("spotify_label")); sourceText:Hide()
local sourceStatus=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
sourceStatus:SetPoint("TOPLEFT",ui,"TOPLEFT",358,-48); sourceStatus:SetWidth(86); sourceStatus:SetJustifyH("LEFT"); sourceStatus:Hide()
local volumeLabelText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
volumeLabelText:SetPoint("TOPLEFT",ui,"TOPLEFT",358,-62); volumeLabelText:SetWidth(54); volumeLabelText:SetJustifyH("LEFT"); volumeLabelText:SetText(T("volume_label")); volumeLabelText:Hide()
local function SkinButton(button)
    button:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=8,edgeSize=8,insets={left=2,right=2,top=2,bottom=2}})
    button:SetBackdropColor(0.10,0.095,0.085,0.98); button:SetBackdropBorderColor(0.58,0.50,0.36,1)
    button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    local fs=button:CreateFontString(button:GetName() and (button:GetName().."Text") or nil,"OVERLAY","GameFontNormalSmall")
    fs:SetPoint("CENTER",button,"CENTER",0,0); fs:SetTextColor(1,0.82,0.28)
    return fs
end
local buttonLabels={}
local function SetButtonText(button,value) local fs=buttonLabels[button]; if fs then fs:SetText(value) end end
local SetLayout, CycleLayout, RefreshSettingsPanel
local expandButton=CreateFrame("Button","SpotifyNowExpandButton",ui)
expandButton:SetWidth(20); expandButton:SetHeight(17); expandButton:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-5,-4)
buttonLabels[expandButton]=SkinButton(expandButton); SetButtonText(expandButton,"+")
expandButton:SetScript("OnClick",function() if CycleLayout then CycleLayout() end end)
expandButton:SetScript("OnEnter",function() GameTooltip:SetOwner(this,"ANCHOR_TOP"); GameTooltip:SetText(T("layout_cycle_hint")); GameTooltip:Show() end)
expandButton:SetScript("OnLeave",function() GameTooltip:Hide() end)
local settingsButton=CreateFrame("Button","SpotifyNowSettingsButton",ui)
settingsButton:SetWidth(20); settingsButton:SetHeight(17); settingsButton:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-28,-4)
buttonLabels[settingsButton]=SkinButton(settingsButton); SetButtonText(settingsButton,"...")
local settingsPanel=CreateFrame("Frame","SpotifyNowSettingsPanel",UIParent)
settingsPanel:SetWidth(360); settingsPanel:SetHeight(390); settingsPanel:SetPoint("CENTER",UIParent,"CENTER",0,0)
settingsPanel:SetFrameStrata("DIALOG"); settingsPanel:SetMovable(true); settingsPanel:EnableMouse(true); settingsPanel:RegisterForDrag("LeftButton")
settingsPanel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=11,right=12,top=12,bottom=11}})
settingsPanel:SetBackdropColor(0.52,0.49,0.43,0.98)
local settingsHeader=settingsPanel:CreateTexture(nil,"ARTWORK")
settingsHeader:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
settingsHeader:SetWidth(210); settingsHeader:SetHeight(42); settingsHeader:SetPoint("TOP",settingsPanel,"TOP",0,14)
settingsPanel:SetScript("OnDragStart",function() this:StartMoving() end); settingsPanel:SetScript("OnDragStop",function() this:StopMovingOrSizing() end)
settingsPanel:Hide()
local settingsTitle=settingsPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
settingsTitle:SetPoint("TOP",settingsPanel,"TOP",0,-13); settingsTitle:SetText(T("settings_title"))
settingsTitle:SetTextColor(1,0.82,0.28)
local settingsClose=CreateFrame("Button",nil,settingsPanel)
settingsClose:SetWidth(20); settingsClose:SetHeight(20); settingsClose:SetPoint("TOPRIGHT",settingsPanel,"TOPRIGHT",-11,-9)
settingsClose:SetNormalTexture("Interface\\Buttons\\UI-Panel-CloseButton-Up")
settingsClose:SetPushedTexture("Interface\\Buttons\\UI-Panel-CloseButton-Down")
settingsClose:SetHighlightTexture("Interface\\Buttons\\UI-Panel-CloseButton-Highlight")
settingsClose:SetScript("OnClick",function() settingsPanel:Hide() end)
local function NewSettingsButton(width,height,anchor,relative,relativePoint,x,y)
    local button=CreateFrame("Button",nil,settingsPanel)
    button:SetWidth(width); button:SetHeight(height); button:SetPoint(anchor,relative,relativePoint,x,y)
    buttonLabels[button]=SkinButton(button)
    return button
end
local themeButton=NewSettingsButton(328,22,"TOP",settingsPanel,"TOP",0,-34)
local layoutButton=NewSettingsButton(296,22,"TOP",themeButton,"BOTTOM",0,-4)
layoutButton:SetWidth(328)
local accentButton=NewSettingsButton(328,22,"TOP",layoutButton,"BOTTOM",0,-4)
local progressColorButton=NewSettingsButton(328,22,"TOP",accentButton,"BOTTOM",0,-4)
local function NewColorEntry(key,anchor,relativePoint)
    local label=settingsPanel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    label:SetWidth(114); label:SetJustifyH("LEFT"); label:SetText(T(key))
    label:SetPoint("TOPLEFT",anchor,relativePoint,8,-6)
    local edit=CreateFrame("EditBox",nil,settingsPanel)
    edit:SetWidth(132); edit:SetHeight(20); edit:SetAutoFocus(false); edit:SetMaxLetters(7)
    edit:SetFontObject(GameFontHighlightSmall); edit:SetTextInsets(5,5,0,0); edit:SetJustifyH("LEFT")
    edit:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",tile=true,tileSize=8,edgeSize=8,insets={left=2,right=2,top=2,bottom=2}})
    edit:SetBackdropColor(0.06,0.06,0.06,1); edit:SetBackdropBorderColor(0.58,0.50,0.36,1)
    edit:SetPoint("LEFT",label,"RIGHT",6,0)
    local apply=NewSettingsButton(70,20,"LEFT",edit,"RIGHT",6,0)
    SetButtonText(apply,T("settings_apply"))
    return {label=label,edit=edit,apply=apply}
end
local accentEntry=NewColorEntry("settings_custom_accent",progressColorButton,"BOTTOMLEFT")
local progressEntry=NewColorEntry("settings_custom_progress",accentEntry.label,"BOTTOMLEFT")
local function ApplyEditedColor(field,edit)
    local value=string.gsub(edit:GetText() or "","[#%s]","")
    local r=HexColor(value)
    if not r then Print(T("color_help")); return end
    SpotifyNowDB.style[field]=string.upper(value)
    edit:ClearFocus(); ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
end
accentEntry.apply:SetScript("OnClick",function() ApplyEditedColor("accent",accentEntry.edit) end)
accentEntry.edit:SetScript("OnEnterPressed",function() ApplyEditedColor("accent",accentEntry.edit) end)
accentEntry.edit:SetScript("OnEscapePressed",function() this:ClearFocus(); RefreshSettingsPanel() end)
progressEntry.apply:SetScript("OnClick",function() ApplyEditedColor("progressColor",progressEntry.edit) end)
progressEntry.edit:SetScript("OnEnterPressed",function() ApplyEditedColor("progressColor",progressEntry.edit) end)
progressEntry.edit:SetScript("OnEscapePressed",function() this:ClearFocus(); RefreshSettingsPanel() end)
local settingsHint=settingsPanel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
settingsHint:SetPoint("BOTTOM",settingsPanel,"BOTTOM",0,10); settingsHint:SetWidth(320); settingsHint:SetJustifyH("CENTER"); settingsHint:SetText(T("layout_help"))
local settingsButtons={}
local function AddSettingButton(key,field,column,row)
    local button=NewSettingsButton(150,22,"TOPLEFT",settingsPanel,"TOPLEFT",18+(column-1)*172,-(212+(row-1)*25))
    settingsButtons[key]={button=button,field=field}
    button:SetScript("OnClick",function()
        local style=SpotifyNowDB.style
        if field=="progressStyle" then
            local order={"line","thick","segmented"}; local index=1
            for i,value in ipairs(order) do if value==style.progressStyle then index=(i%table.getn(order))+1; break end end
            style.progressStyle=order[index]
        else style[field]=not style[field] end
        ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
    end)
    return button
end
AddSettingButton("glow","glow",1,1)
AddSettingButton("border","border",2,1)
AddSettingButton("buttons","buttons",1,2)
AddSettingButton("controls","controls",2,2)
AddSettingButton("metadata","metadata",1,3)
AddSettingButton("progress","progress",2,3)
AddSettingButton("seek","progressSeek",1,4)
AddSettingButton("progressStyle","progressStyle",2,4)
local lyricsButton=NewSettingsButton(150,22,"TOPLEFT",settingsPanel,"TOPLEFT",18,-312)
local channelButton=NewSettingsButton(150,22,"TOPLEFT",settingsPanel,"TOPLEFT",190,-312)
lyricsButton:SetScript("OnClick",function() SetLyrics(not SpotifyNowDB.lyrics,true); RefreshSettingsPanel() end)
local CHANNEL_ORDER={"say","yell","party","guild","raid","emote"}
channelButton:SetScript("OnClick",function()
    local index=1
    for i,name in ipairs(CHANNEL_ORDER) do if name==SpotifyNowDB.channel then index=(i%table.getn(CHANNEL_ORDER))+1; break end end
    SpotifyNowDB.channel=CHANNEL_ORDER[index]; RefreshSettingsPanel()
end)
local function ColorLabel(value)
    if value and value~="" then return "#"..value end
    return T("color_default")
end
RefreshSettingsPanel=function()
    local style=SpotifyNowDB.style
    local names={obsidian=T("theme_obsidian"),azerite=T("theme_azerite"),fel=T("theme_fel"),bloodmoon=T("theme_bloodmoon")}
    SetButtonText(themeButton,T("settings_theme")..": "..(names[style.theme] or names.obsidian))
    local mode=style.layout or (style.expanded and "expanded" or "compact")
    local modes={compact=T("layout_compact"),square=T("layout_square"),expanded=T("layout_expanded")}
    SetButtonText(layoutButton,T("settings_layout")..": "..(modes[mode] or modes.compact))
    SetButtonText(accentButton,T("settings_accent")..": "..ColorLabel(style.accent))
    SetButtonText(progressColorButton,T("settings_progress_color")..": "..ColorLabel(style.progressColor))
    if not accentEntry.edit:HasFocus() then accentEntry.edit:SetText(style.accent or "") end
    if not progressEntry.edit:HasFocus() then progressEntry.edit:SetText(style.progressColor or "") end
    local labels={glow="settings_glow",border="settings_border",buttons="settings_buttons",controls="settings_controls",metadata="settings_metadata",progress="settings_progress",seek="settings_seek",progressStyle="settings_progress_style"}
    SetButtonText(lyricsButton,T("settings_lyrics")..": "..(SpotifyNowDB.lyrics and T("setting_on") or T("setting_off")))
    SetButtonText(channelButton,T("settings_lyrics_channel")..": "..strupper(SpotifyNowDB.channel or "say"))
    for key,item in pairs(settingsButtons) do
        local value=style[item.field]
        if item.field=="progressStyle" then
            value=value or "line"
        else value=value~=false end
        local shown=value
        if item.field=="progressStyle" then
            local pretty={line="line",thick="thick",segmented="segmented"}; shown=pretty[value] or pretty.line
        else shown=value and T("setting_on") or T("setting_off") end
        SetButtonText(item.button,T(labels[key])..": "..shown)
    end
end
settingsPanel:SetScript("OnShow",function() RefreshSettingsPanel() end)
settingsButton:SetScript("OnClick",function() if settingsPanel:IsShown() then settingsPanel:Hide() else RefreshSettingsPanel(); settingsPanel:Show() end end)
themeButton:SetScript("OnClick",function()
    local order={"obsidian","azerite","fel","bloodmoon"}; local current=SpotifyNowDB.style.theme or "obsidian"; local nextIndex=1
    for i,name in ipairs(order) do if name==current then nextIndex=(i%table.getn(order))+1; break end end
    SpotifyNowDB.style.theme=order[nextIndex]; SpotifyNowDB.style.accent=nil; SpotifyNowDB.style.progressColor=nil
    ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
end)
SetLayout=function(mode)
    if mode~="compact" and mode~="square" and mode~="expanded" then mode="compact" end
    SpotifyNowDB.style.layout=mode
    SpotifyNowDB.style.expanded=(mode=="expanded")
    ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
end
CycleLayout=function()
    local mode=SpotifyNowDB.style.layout or (SpotifyNowDB.style.expanded and "expanded" or "compact")
    if mode=="compact" then SetLayout("square") elseif mode=="square" then SetLayout("expanded") else SetLayout("compact") end
end
layoutButton:SetScript("OnClick",function() CycleLayout() end)
local COLOR_PRESETS={false,"1ED760","9B59FF","00D9FF","28F028","FF3348","FFFFFF","FFB020","FF4FD8"}
local function CycleColor(field)
    local current=SpotifyNowDB.style[field]; local index=1
    for i,value in ipairs(COLOR_PRESETS) do
        local normalized=value or nil
        if normalized==current then index=(i%table.getn(COLOR_PRESETS))+1; break end
    end
    SpotifyNowDB.style[field]=COLOR_PRESETS[index] or nil
    ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
end
accentButton:SetScript("OnClick",function() CycleColor("accent") end)
progressColorButton:SetScript("OnClick",function() CycleColor("progressColor") end)

local function MakeButton(name,label,tip,w,x,cmd)
    local b=CreateFrame("Button","SpotifyNowBtn"..name,ui)
    b:SetWidth(w); b:SetHeight(19); b:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",x,7)
    buttonLabels[b]=SkinButton(b); SetButtonText(b,label)
    b:SetScript("OnClick",function() SendCommand(cmd) end)
    b:SetScript("OnEnter",function() this:SetBackdropBorderColor(1,0.78,0.28,1); GameTooltip:SetOwner(this,"ANCHOR_TOP"); GameTooltip:SetText(tip); GameTooltip:Show() end)
    b:SetScript("OnLeave",function() this:SetBackdropBorderColor(0.58,0.50,0.36,1); GameTooltip:Hide() end)
    return b
end
local controls={}
controls.prev=MakeButton("Prev","<<",T("previous"),28,7,CMD.prev)
local playBtn=MakeButton("Play",">",T("play_pause"),28,39,CMD.pause); controls.pause=playBtn
controls.next=MakeButton("Next",">>",T("next"),28,71,CMD.next)
controls.back=MakeButton("Back","-10",T("back_10"),30,103,CMD.back)
controls.fwd=MakeButton("Fwd","+10",T("forward_10"),30,137,CMD.fwd)
controls.voldown=MakeButton("VolDown","V-",T("volume_down"),27,171,CMD.voldown)
controls.volup=MakeButton("VolUp","V+",T("volume_up"),27,203,CMD.volup)
controls.shuffle=MakeButton("Shuffle","S",T("shuffle"),44,238,"shuffle")
controls["repeat"]=MakeButton("Repeat","R",T("repeat"),44,286,"repeat")
controls.lyrics=MakeButton("Lyrics","L+",T("lyrics_toggle"),30,0,"lyrics")
controls.lyrics:SetScript("OnClick",function() SetLyrics(not SpotifyNowDB.lyrics,true); RefreshUI() end)

local progressBg=ui:CreateTexture(nil,"BORDER"); progressBg:SetTexture(0.08,0.09,0.11,1); progressBg:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",8,3); progressBg:SetWidth(234); progressBg:SetHeight(2)
local topAccent=ui:CreateTexture(nil,"ARTWORK"); topAccent:SetTexture("Interface\\Buttons\\WHITE8X8"); topAccent:SetPoint("TOPLEFT",ui,"TOPLEFT",18,-8); topAccent:SetHeight(1)
local sideDivider=ui:CreateTexture(nil,"ARTWORK"); sideDivider:SetTexture("Interface\\Buttons\\WHITE8X8")
local progressFill=ui:CreateTexture(nil,"ARTWORK"); progressFill:SetTexture(0.12,0.84,0.38,1); progressFill:SetPoint("BOTTOMLEFT",progressBg,"BOTTOMLEFT",0,0); progressFill:SetWidth(1); progressFill:SetHeight(2)
local progressHit=CreateFrame("Button",nil,ui); progressHit:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",8,1); progressHit:SetWidth(234); progressHit:SetHeight(7)
progressHit:SetScript("OnClick",function()
    if not SpotifyNowDB.style.progressSeek or durationMs <= 0 then return end
    local x=GetCursorPosition(); local scale=UIParent:GetEffectiveScale() or 1; x=x/scale
    local left=progressHit:GetLeft() or 0; local width=progressHit:GetWidth() or 234
    SendCommand("seek", tostring(floor(math.max(0,math.min(1,(x-left)/width))*durationMs)))
end)
local progressSegments={}
local progressSegmentCount=26
local titleVisibleChars=28
for i=1,38 do
    local segment=ui:CreateTexture(nil,"ARTWORK")
    segment:SetTexture("Interface\\Buttons\\WHITE8X8")
    segment:SetPoint("BOTTOMLEFT",progressBg,"BOTTOMLEFT",(i-1)*9,0)
    segment:SetWidth(8); segment:SetHeight(2); segment:Hide()
    progressSegments[i]=segment
end

local THEMES={
    obsidian={bg={0.025,0.027,0.035},accent={0.56,0.28,1.0}},
    azerite={bg={0.025,0.035,0.043},accent={0.08,0.78,0.92}},
    fel={bg={0.032,0.03,0.036},accent={0.24,0.95,0.28}},
    bloodmoon={bg={0.038,0.027,0.032},accent={0.92,0.17,0.20}},
}
HexColor=function(value)
    if not value then return nil end
    value=string.gsub(value,"#",""); if string.len(value)~=6 or string.find(value,"[^%x]") then return nil end
    return tonumber(string.sub(value,1,2),16)/255,tonumber(string.sub(value,3,4),16)/255,tonumber(string.sub(value,5,6),16)/255
end
ApplyStyle=function()
    local s=SpotifyNowDB.style or {}; local th=THEMES[s.theme] or THEMES.obsidian
    local r,g,b=HexColor(s.accent); if not r then r,g,b=th.accent[1],th.accent[2],th.accent[3] end
    ui:SetBackdropColor(th.bg[1],th.bg[2],th.bg[3],0.96)
    local mode=s.layout or (s.expanded and "expanded" or "compact")
    if mode~="compact" and mode~="square" and mode~="expanded" then mode="compact" end
    s.layout=mode; s.expanded=(mode=="expanded")
    local compact=mode=="compact"; local square=mode=="square"; local expanded=mode=="expanded"
    ui:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=compact and 16 or 24,insets={left=8,right=8,top=8,bottom=8}})
    ui:SetBackdropColor(0.72,0.69,0.62,0.98)
    ui:SetWidth(compact and 300 or (square and 236 or 460)); ui:SetHeight(compact and 68 or (square and 236 or 164))
    progressBg:SetWidth(ui:GetWidth()-16); progressHit:SetWidth(ui:GetWidth()-16)
    topAccent:SetWidth(ui:GetWidth()-36)
    progressSegmentCount=compact and 26 or 38
    local segmentSpace=(ui:GetWidth()-16)/progressSegmentCount
    for i,segment in pairs(progressSegments) do
        segment:ClearAllPoints(); segment:SetPoint("BOTTOMLEFT",progressBg,"BOTTOMLEFT",(i-1)*segmentSpace,0)
        segment:SetWidth(segmentSpace-1)
    end
    for _,item in pairs({{controls.prev,28,19},{playBtn,28,19},{controls.next,28,19},{controls.back,30,19},{controls.fwd,30,19},{controls.voldown,27,19},{controls.volup,27,19},{controls.shuffle,44,19},{controls["repeat"],44,19},{controls.lyrics,30,19}}) do item[1]:SetWidth(item[2]); item[1]:SetHeight(item[3]) end
    art:SetWidth(compact and 34 or (square and 68 or 96)); art:SetHeight(compact and 34 or (square and 68 or 96))
    artFrame:SetWidth(art:GetWidth()+6); artFrame:SetHeight(art:GetHeight()+6)
    if expanded then
        artFrame:ClearAllPoints(); artFrame:SetPoint("TOPLEFT",ui,"TOPLEFT",8,-8)
        titleText:ClearAllPoints(); titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",116,-12); titleText:SetWidth(212); titleVisibleChars=28
        volText:ClearAllPoints(); volText:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-8,-62); volText:SetWidth(40)
        artistText:ClearAllPoints(); artistText:SetPoint("TOPLEFT",ui,"TOPLEFT",116,-42); artistText:SetWidth(218)
        albumText:ClearAllPoints(); albumText:SetPoint("TOPLEFT",ui,"TOPLEFT",116,-60); albumText:SetWidth(218)
        modeText:ClearAllPoints(); modeText:SetPoint("TOPLEFT",ui,"TOPLEFT",116,-82); modeText:SetWidth(218); modeText:Show()
        sideDivider:ClearAllPoints(); sideDivider:SetPoint("TOPLEFT",ui,"TOPLEFT",346,-12); sideDivider:SetWidth(1); sideDivider:SetHeight(140); sideDivider:Show()
        controls.prev:ClearAllPoints(); controls.prev:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",116,7)
        playBtn:ClearAllPoints(); playBtn:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",147,7)
        controls.next:ClearAllPoints(); controls.next:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",178,7)
        controls.back:ClearAllPoints(); controls.back:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",209,7); controls.back:SetWidth(27)
        controls.fwd:ClearAllPoints(); controls.fwd:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",239,7); controls.fwd:SetWidth(27)
        controls.shuffle:ClearAllPoints(); controls.shuffle:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",266,7); controls.shuffle:SetWidth(38)
        controls["repeat"]:ClearAllPoints(); controls["repeat"]:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",306,7); controls["repeat"]:SetWidth(40)
        controls.voldown:ClearAllPoints(); controls.voldown:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",352,7); controls.voldown:SetWidth(26)
        controls.volup:ClearAllPoints(); controls.volup:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",380,7); controls.volup:SetWidth(26)
        controls.lyrics:ClearAllPoints(); controls.lyrics:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",408,7); controls.lyrics:SetWidth(26)
        sourceText:Show(); sourceStatus:Show(); volumeLabelText:Show()
        artistText:Show(); albumText:Show(); timeText:Show(); SetButtonText(expandButton,"-")
    elseif square then
        artFrame:ClearAllPoints(); artFrame:SetPoint("TOP",ui,"TOP",0,-12)
        titleText:ClearAllPoints(); titleText:SetPoint("TOP",artFrame,"BOTTOM",0,-6); titleText:SetWidth(206); titleVisibleChars=28
        volText:ClearAllPoints(); volText:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",12,50); volText:SetWidth(70); volText:SetJustifyH("LEFT")
        artistText:ClearAllPoints(); artistText:SetPoint("TOP",titleText,"BOTTOM",0,-4); artistText:SetWidth(206)
        albumText:ClearAllPoints(); albumText:SetPoint("TOP",artistText,"BOTTOM",0,-3); albumText:SetWidth(206)
        modeText:ClearAllPoints(); modeText:SetPoint("TOP",albumText,"BOTTOM",0,-3); modeText:SetWidth(206); modeText:Show()
        timeText:ClearAllPoints(); timeText:SetPoint("BOTTOMRIGHT",ui,"BOTTOMRIGHT",-12,58); timeText:SetJustifyH("RIGHT")
        local squarePlaybackButtons={controls.prev,playBtn,controls.next,controls.back,controls.fwd,controls.voldown,controls.volup}
        for i,button in ipairs(squarePlaybackButtons) do button:ClearAllPoints(); button:SetWidth(28); button:SetHeight(18); button:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",14+(i-1)*30,32) end
        local squareOptionButtons={controls.shuffle,controls["repeat"],controls.lyrics}
        for i,button in ipairs(squareOptionButtons) do button:ClearAllPoints(); button:SetWidth(54); button:SetHeight(18); button:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",22+(i-1)*68,9) end
        timeText:ClearAllPoints(); timeText:SetPoint("BOTTOMRIGHT",ui,"BOTTOMRIGHT",-12,50); timeText:SetJustifyH("RIGHT")
        sourceText:Hide(); sourceStatus:Hide(); volumeLabelText:Hide()
        artistText:Show(); albumText:Show(); timeText:Show(); SetButtonText(expandButton,"+")
        sideDivider:Hide()
    else
        artFrame:ClearAllPoints(); artFrame:SetPoint("TOPLEFT",ui,"TOPLEFT",5,-5)
        titleText:ClearAllPoints(); titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",54,-8); titleText:SetWidth(142); titleVisibleChars=20
        volText:ClearAllPoints(); volText:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-52,-9); volText:SetWidth(40)
        modeText:ClearAllPoints(); modeText:SetPoint("TOPLEFT",ui,"TOPLEFT",54,-29); modeText:SetWidth(190); modeText:Show()
        timeText:ClearAllPoints(); timeText:SetPoint("BOTTOMRIGHT",ui,"BOTTOMRIGHT",-8,29)
        controls.prev:ClearAllPoints(); controls.prev:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",54,8); controls.prev:SetWidth(24); controls.prev:SetHeight(18)
        playBtn:ClearAllPoints(); playBtn:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",81,8); playBtn:SetWidth(24); playBtn:SetHeight(18)
        controls.next:ClearAllPoints(); controls.next:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",108,8); controls.next:SetWidth(24); controls.next:SetHeight(18)
        controls.back:ClearAllPoints(); controls.back:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",135,8); controls.back:SetWidth(27); controls.back:SetHeight(18)
        controls.fwd:ClearAllPoints(); controls.fwd:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",165,8); controls.fwd:SetWidth(27); controls.fwd:SetHeight(18)
        controls.voldown:ClearAllPoints(); controls.voldown:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",195,8); controls.voldown:SetWidth(24); controls.voldown:SetHeight(18)
        controls.volup:ClearAllPoints(); controls.volup:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",222,8); controls.volup:SetWidth(24); controls.volup:SetHeight(18)
        sideDivider:Hide(); sourceText:Hide(); sourceStatus:Hide(); volumeLabelText:Hide()
        controls.shuffle:ClearAllPoints(); controls.shuffle:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",238,7)
        controls["repeat"]:ClearAllPoints(); controls["repeat"]:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",286,7)
        controls.lyrics:ClearAllPoints(); controls.lyrics:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",0,7)
        artistText:Hide(); albumText:Hide(); timeText:Hide(); SetButtonText(expandButton,"□")
    end
    local alpha=(s.border==false) and 0 or 1
    ui:SetBackdropBorderColor(0.72,0.64,0.48,alpha)
    topAccent:SetTexture(r,g,b,s.glow and 0.95 or 0.58); topAccent:SetHeight(s.glow and 2 or 1); sideDivider:SetTexture(r,g,b,0.55)
    for button,fs in pairs(buttonLabels) do
        if fs and fs.SetTextColor then fs:SetTextColor(1,0.82,0.28) end
        if button.SetBackdropColor then button:SetBackdropColor(0.10,0.095,0.085,0.98) end
        if button.SetBackdropBorderColor then button:SetBackdropBorderColor(0.58,0.50,0.36,0.95) end
    end
    titleText:SetTextColor(1,0.82,0.28)
    if compact then titleText:SetFontObject(GameFontNormalSmall) else titleText:SetFontObject(GameFontNormal) end
    art:SetVertexColor(1,1,1,1)
    if s.progressColor then local pr,pg,pb=HexColor(s.progressColor); if pr then r,g,b=pr,pg,pb end end
    progressFill:SetTexture(r,g,b,1)
    local ph=2
    if s.progressStyle=="thick" then ph=4 elseif s.progressStyle=="segmented" then ph=3 end
    progressBg:SetHeight(ph); progressFill:SetHeight(ph)
    for _,segment in pairs(progressSegments) do segment:SetHeight(ph) end
    if s.progress==false then progressBg:Hide(); progressFill:Hide(); progressHit:Hide(); for _,segment in pairs(progressSegments) do segment:Hide() end else progressBg:Show(); progressFill:Show(); progressHit:Show() end
    if s.controls==false then for _,button in pairs(controls) do button:Hide() end else for _,button in pairs(controls) do button:Show() end end
    if compact or s.controls==false then controls.shuffle:Hide(); controls["repeat"]:Hide(); controls.lyrics:Hide() end
    if s.metadata==false then titleText:Hide(); volText:Hide(); artistText:Hide(); albumText:Hide(); art:Hide(); artFrame:Hide() else titleText:Show(); volText:Show(); art:Show(); artFrame:Show(); if expanded or square then artistText:Show(); albumText:Show() end end
end

local titleSource=""; local titleOffset=1; local titleElapsed=0; local titleChars={}
local function UTF8Characters(value)
    local chars={}; local i=1; local n=string.len(value)
    while i<=n do
        local byte=string.byte(value,i); local count=1
        if byte>=240 then count=4 elseif byte>=224 then count=3 elseif byte>=192 then count=2 end
        chars[table.getn(chars)+1]=string.sub(value,i,math.min(n,i+count-1)); i=i+count
    end
    return chars
end
local function RefreshTitle()
    if titleSource=="" then titleText:SetText(T("waiting")); return end
    if table.getn(titleChars)<=titleVisibleChars then titleText:SetText(titleSource); return end
    local shown={}; local count=table.getn(titleChars)
    for i=0,titleVisibleChars-1 do shown[table.getn(shown)+1]=titleChars[((titleOffset+i-1)%count)+1] end
    titleText:SetText(table.concat(shown)); titleOffset=titleOffset+1; if titleOffset>count then titleOffset=1 end
end
RefreshUI=function()
    local np=NowPlaying() or ""
    local displayTitle=np
    if (SpotifyNowDB.style.layout or (SpotifyNowDB.style.expanded and "expanded" or "compact"))~="compact" then displayTitle=SpotifyNowDB.title or "" end
    if displayTitle~=titleSource then
        titleSource=displayTitle; titleChars=UTF8Characters(displayTitle)
        if table.getn(titleChars)>titleVisibleChars then titleChars=UTF8Characters(displayTitle.."   ") end
        titleOffset=1; RefreshTitle()
    end
    artistText:SetText(SpotifyNowDB.artist or ""); albumText:SetText(SpotifyNowDB.album or "")
    sourceStatus:SetText(playing and T("status_playing") or T("status_paused"))
    SetButtonText(playBtn,playing and "II" or ">")
    local volumeValue=volume>=0 and (tostring(volume).."%") or "--%"
    local currentLayout=SpotifyNowDB.style.layout or (SpotifyNowDB.style.expanded and "expanded" or "compact")
    volText:SetText(currentLayout=="square" and (T("volume_label").." "..volumeValue) or volumeValue)
    local pos=currentPosMs; if playing then pos=pos+math.max(0,GetTime()-stateTick)*1000 end
    local maxWidth=ui:GetWidth()-16
    local width=2; if durationMs>0 then width=math.max(1,math.min(maxWidth,maxWidth*pos/durationMs)) end
    if SpotifyNowDB.style.progressStyle=="segmented" then
        progressFill:Hide()
        local ratio=(durationMs>0) and math.min(1,math.max(0,pos/durationMs)) or 0
        for i,segment in pairs(progressSegments) do if i<=progressSegmentCount and (i-1)/progressSegmentCount<ratio then segment:Show() else segment:Hide() end end
    else
        progressFill:Show(); progressFill:SetWidth(width)
        for _,segment in pairs(progressSegments) do segment:Hide() end
    end
    local artwork=SpotifyNowDB.artwork or ""
    if artwork~="" and string.find(artwork,"^[%w_%-]+%.tga$") then
        art:SetTexture("Interface\\AddOns\\SpotiWoW-Dev\\"..artwork)
    else art:SetTexture("Interface\\Icons\\INV_Misc_Note_01") end
    local function Clock(ms) local n=math.floor((ms or 0)/1000); return string.format("%d:%02d",math.floor(n/60),n%60) end
    timeText:SetText(Clock(pos).." / "..Clock(durationMs))
    SetButtonText(controls.shuffle,SpotifyNowDB.shuffle and "S ON" or "S")
    SetButtonText(controls.lyrics,SpotifyNowDB.lyrics and "L+" or "L-")
    local repeatMode=SpotifyNowDB.repeatMode or "off"
    SetButtonText(controls["repeat"],repeatMode=="context" and "R ALL" or (repeatMode=="track" and "R 1" or "R"))
    local ir,ig,ib=HexColor(SpotifyNowDB.style.accent)
    if not ir then local theme=THEMES[SpotifyNowDB.style.theme] or THEMES.obsidian; ir,ig,ib=theme.accent[1],theme.accent[2],theme.accent[3] end
    local function MarkActive(button,active)
        local fs=buttonLabels[button]
        local useAccent=active and SpotifyNowDB.style.buttons~=false
        if fs then if useAccent then fs:SetTextColor(ir,ig,ib) else fs:SetTextColor(1,0.82,0.28) end end
        button:SetBackdropBorderColor(useAccent and ir or 0.58,useAccent and ig or 0.50,useAccent and ib or 0.36,1)
    end
    MarkActive(controls.shuffle,SpotifyNowDB.shuffle)
    MarkActive(controls["repeat"],repeatMode~="off")
    local accentHex=string.format("%02x%02x%02x",floor(ir*255),floor(ig*255),floor(ib*255))
    local indicators={}
    if SpotifyNowDB.shuffle then indicators[table.getn(indicators)+1]="|cff"..accentHex..T("mode_shuffle").."|r" end
    if repeatMode=="context" then indicators[table.getn(indicators)+1]="|cff"..accentHex..T("mode_repeat_all").."|r"
    elseif repeatMode=="track" then indicators[table.getn(indicators)+1]="|cff"..accentHex..T("mode_repeat_track").."|r" end
    modeText:SetText(table.concat(indicators,"  "))
end

local function Help()
    Print(T("help_1")); Print(T("help_2")); Print(T("help_3")); Print(T("help_4")); Print(T("help_5"))
    Print(T("settings_help")); Print(T("settings_help2"))
end
local function ToggleValue(field,arg,default)
    if arg=="on" then SpotifyNowDB.style[field]=true elseif arg=="off" then SpotifyNowDB.style[field]=false else SpotifyNowDB.style[field]=not SpotifyNowDB.style[field] end
    ApplyStyle(); RefreshUI(); Print(T("setting_updated"))
end
local function SettingsCommand(cmd,rest)
    local s=SpotifyNowDB.style
    if cmd=="expand" then
        if s.layout=="expanded" then SetLayout("compact") else SetLayout("expanded") end
        Print(T("setting_updated"))
    elseif cmd=="mode" then
        local mode=strlower(rest or "")
        if mode=="compact" or mode=="square" or mode=="expanded" then SetLayout(mode); Print(T("setting_updated")) else Print(T("layout_help")) end
    elseif cmd=="theme" then
        local theme=strlower(rest or ""); if THEMES[theme] then s.theme=theme; s.accent=nil; s.progressColor=nil; ApplyStyle(); Print(T("setting_updated")) else Print(T("theme_help")) end
    elseif cmd=="accent" or cmd=="progresscolor" then
        if strlower(rest)=="reset" then if cmd=="accent" then s.accent=nil else s.progressColor=nil end; ApplyStyle(); Print(T("setting_updated")); return end
        local r,g,b=HexColor(rest); if r then if cmd=="accent" then s.accent=rest else s.progressColor=rest end; ApplyStyle(); Print(T("setting_updated")) else Print(T("color_help")) end
    elseif cmd=="glow" or cmd=="border" or cmd=="buttons" or cmd=="controls" or cmd=="metadata" or cmd=="progress" then ToggleValue(cmd,rest)
    elseif cmd=="seek" then if strlower(rest)=="on" then s.progressSeek=true elseif strlower(rest)=="off" then s.progressSeek=false else s.progressSeek=not s.progressSeek end; Print(T("setting_updated"))
    elseif cmd=="progressstyle" then local p=strlower(rest); if p=="line" or p=="thick" or p=="segmented" then s.progressStyle=p; ApplyStyle(); RefreshUI(); Print(T("setting_updated")) else Print(T("progressstyle_help")) end
    else return false end
    return true
end

SLASH_SPOTIFYNOW1="/spn"; SLASH_SPOTIFYNOW2="/spotify"
SlashCmdList["SPOTIFYNOW"]=function(msg)
    local _,_,cmd,rest=strfind(msg or "","^(%S*)%s*(.*)$"); cmd=strlower(cmd or ""); rest=rest or ""
    if cmd=="" or cmd=="show" then local np=NowPlaying(); if np then Print(np) else Print(T("no_track")) end
    elseif CHANNELS[cmd] then Announce(cmd)
    elseif CMD[cmd] then SendCommand(CMD[cmd])
    elseif cmd=="ui" then SpotifyNowDB.ui=not SpotifyNowDB.ui; if SpotifyNowDB.ui then ui:Show() else ui:Hide(); settingsPanel:Hide() end
    elseif cmd=="settings" then if settingsPanel:IsShown() then settingsPanel:Hide() else RefreshSettingsPanel(); settingsPanel:Show() end
    elseif cmd=="lyrics" then local a=strlower(rest); if a=="on" then SetLyrics(true,true) elseif a=="off" then SetLyrics(false,true) else SetLyrics(not SpotifyNowDB.lyrics,true) end
    elseif cmd=="channel" then local a=strlower(rest); if CHANNELS[a] then SpotifyNowDB.channel=a; Print(T("lyrics_channel_prefix")..a) else Print(T("channels_available")) end
    elseif cmd=="help" then Help()
    elseif not SettingsCommand(cmd,rest) then Help() end
end

local lastLyricsSequence=nil; local statePollElapsed=0; local importWarningShown=false
local lastStateSequence=nil
local function DecodeField(value)
    return gsub(value or "","%%(%x%x)",function(hex) return strchar(tonumber(hex,16)) end)
end
local function SplitState(payload)
    local fields={}; local startAt=1; local index=1
    while true do
        local stopAt=strfind(payload,"|",startAt,true)
        if not stopAt then fields[index]=strsub(payload,startAt); break end
        fields[index]=strsub(payload,startAt,stopAt-1); index=index+1; startAt=stopAt+1
    end
    return fields
end
local function PollBridgeState()
    if not SpotifyNowDB then return end
    if type(ImportFile)~="function" then if not importWarningShown then Print(T("import_missing")); importWarningShown=true end; return end
    local ok,payload=pcall(ImportFile,"SpotifyNowState"); if not ok or type(payload)~="string" or payload=="" then return end
    payload=gsub(payload,"[\r\n]+$",""); local f=SplitState(payload); if not f or f[1]~="SPN1" then return end
    local seq=tonumber(f[2]); if not seq or seq==lastStateSequence then return end; lastStateSequence=seq
    SpotifyNowDB.artist=DecodeField(f[4]); SpotifyNowDB.title=DecodeField(f[5]); currentPosMs=tonumber(f[6]) or 0; durationMs=tonumber(f[7]) or 0; stateTick=GetTime()
    playing=f[8]=="1"; volume=tonumber(f[9]) or -1
    local lyrics=f[10]=="1"; if lastLyricsModeSeen==nil then lastLyricsModeSeen=lyrics elseif lyrics~=lastLyricsModeSeen then lastLyricsModeSeen=lyrics; PrintLyricsMode(lyrics) end
    SpotifyNowDB.lyrics=lyrics
    local lyricSequence=tonumber(f[11]); if lyricSequence then if lastLyricsSequence==nil then lastLyricsSequence=lyricSequence elseif lyricSequence~=lastLyricsSequence then lastLyricsSequence=lyricSequence; local lyric=DecodeField(f[12]); if lyric~="" then SingLine(lyric) end end end
    SpotifyNowDB.artwork=DecodeField(f[13]); SpotifyNowDB.album=DecodeField(f[14]); SpotifyNowDB.shuffle=f[15]=="1"
    SpotifyNowDB.repeatMode=DecodeField(f[17] or "")
    if SpotifyNowDB.repeatMode=="" then SpotifyNowDB.repeatMode=(f[16]=="1") and "context" or "off" end
    RefreshUI()
end
local progressUiElapsed=0
local poller=CreateFrame("Frame","SpotifyNowStatePoller")
poller:SetScript("OnUpdate",function() local elapsed=arg1 or 0; statePollElapsed=statePollElapsed+elapsed; if statePollElapsed>=0.25 then statePollElapsed=0; PollBridgeState() end
    if table.getn(titleChars)>titleVisibleChars then titleElapsed=titleElapsed+elapsed; if titleElapsed>=0.28 then titleElapsed=titleElapsed-0.28; RefreshTitle() end end
    progressUiElapsed=progressUiElapsed+elapsed
    if progressUiElapsed>=0.25 then
        progressUiElapsed=0
        if durationMs>0 and SpotifyNowDB and SpotifyNowDB.style then
            local pos=currentPosMs+(playing and math.max(0,GetTime()-stateTick)*1000 or 0); local ratio=math.min(1,math.max(0,pos/durationMs)); local maxWidth=ui:GetWidth()-16
            local seconds=math.floor(pos/1000); local total=math.floor(durationMs/1000)
            timeText:SetText(string.format("%d:%02d / %d:%02d",math.floor(seconds/60),seconds%60,math.floor(total/60),total%60))
            if SpotifyNowDB.style.progress~=false then
                if SpotifyNowDB.style.progressStyle=="segmented" then
                    for i,segment in pairs(progressSegments) do if i<=progressSegmentCount and (i-1)/progressSegmentCount<ratio then segment:Show() else segment:Hide() end end
                else progressFill:SetWidth(math.max(1,math.min(maxWidth,maxWidth*ratio))) end
            end
        end
    end
end)

local function ValidTheme(v) return THEMES[v] and v or "obsidian" end
local frame=CreateFrame("Frame"); frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent",function()
    if event~="ADDON_LOADED" or arg1~="SpotiWoW-Dev" then return end
    if not SpotifyNowDB then SpotifyNowDB={} end
    if SpotifyNowDB.artist==nil then SpotifyNowDB.artist="" end; if SpotifyNowDB.title==nil then SpotifyNowDB.title="" end
    if SpotifyNowDB.channel==nil then SpotifyNowDB.channel="say" end; if SpotifyNowDB.ui==nil then SpotifyNowDB.ui=true end
    if not SpotifyNowDB.style then SpotifyNowDB.style={} end
    if SpotifyNowDB.style.theme==nil then SpotifyNowDB.style.theme="obsidian" end
    if SpotifyNowDB.style.glow==nil then SpotifyNowDB.style.glow=true end
    if SpotifyNowDB.style.border==nil then SpotifyNowDB.style.border=true end
    if SpotifyNowDB.style.buttons==nil then SpotifyNowDB.style.buttons=true end
    if SpotifyNowDB.style.controls==nil then SpotifyNowDB.style.controls=true end
    if SpotifyNowDB.style.metadata==nil then SpotifyNowDB.style.metadata=true end
    if SpotifyNowDB.style.progress==nil then SpotifyNowDB.style.progress=true end
    if SpotifyNowDB.style.progressSeek==nil then SpotifyNowDB.style.progressSeek=true end
    if SpotifyNowDB.pos then ui:ClearAllPoints(); ui:SetPoint(SpotifyNowDB.pos[1],UIParent,SpotifyNowDB.pos[2],SpotifyNowDB.pos[3],SpotifyNowDB.pos[4]) end
    if not SpotifyNowDB.ui then ui:Hide() end
    ApplyStyle(); RefreshUI(); Print(T("loaded"))
end)

local sequence=0; local session=floor((GetTime() or 0)*1000); local commandWriteWarningShown=false
SendCommand=function(cmd,value)
    if type(ExportFile)~="function" then if not commandWriteWarningShown then Print(T("export_missing")); commandWriteWarningShown=true end; return end
    sequence=sequence+1; local payload="SPNC1|"..session.."|"..sequence.."|"..cmd.."|"..(value or "")
    local ok=pcall(ExportFile,"SpotifyNowCommand",payload); if not ok and not commandWriteWarningShown then Print(T("command_write_failed")); commandWriteWarningShown=true end
end
