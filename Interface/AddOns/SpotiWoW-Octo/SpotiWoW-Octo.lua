-- SpotiWoW-Octo for Turtle WoW / WoW 1.12.1 (Lua 5.0 + SuperWoW)
-- Spotify bridge files live under the client's Imports folder.

local CHANNELS = { say="SAY", yell="YELL", party="PARTY", guild="GUILD", raid="RAID", emote="EMOTE" }
local CMD = { prev="prev", pause="pause", next="next", back="back", fwd="fwd", voldown="voldown", volup="volup", shuffle="shuffle", ["repeat"]="repeat" }
local Locale = SPOTIWOW_OCTO_L or {}
local function T(key) return Locale[key] or key end
local playing, volume, SendCommand = false, -1, nil
local ApplyStyle, RefreshUI
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
ui:SetWidth(250); ui:SetHeight(58); ui:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
ui:SetFrameStrata("MEDIUM"); ui:SetMovable(true); ui:EnableMouse(true); ui:SetClampedToScreen(true); ui:RegisterForDrag("LeftButton")
ui:SetBackdrop({ bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=12, insets={left=3,right=3,top=3,bottom=3} })
ui:SetScript("OnDragStart", function() this:StartMoving() end)
ui:SetScript("OnDragStop", function() this:StopMovingOrSizing(); local p,_,rp,x,y=this:GetPoint(); SpotifyNowDB.pos={p,rp,x,y} end)

local art = ui:CreateTexture("SpotifyNowArtwork", "ARTWORK")
art:SetWidth(34); art:SetHeight(34); art:SetPoint("TOPLEFT",ui,"TOPLEFT",7,-6); art:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
local titleText=ui:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",46,-8); titleText:SetWidth(128); titleText:SetJustifyH("LEFT")
local volText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
volText:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-30,-8); volText:SetJustifyH("RIGHT")
local artistText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
artistText:SetPoint("TOPLEFT",ui,"TOPLEFT",96,-34); artistText:SetWidth(242); artistText:SetJustifyH("LEFT"); artistText:Hide()
local albumText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
albumText:SetPoint("TOPLEFT",ui,"TOPLEFT",96,-51); albumText:SetWidth(242); albumText:SetJustifyH("LEFT"); albumText:Hide()
local timeText=ui:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
timeText:SetPoint("BOTTOMRIGHT",ui,"BOTTOMRIGHT",-8,30); timeText:SetJustifyH("RIGHT"); timeText:Hide()
local expandButton=CreateFrame("Button","SpotifyNowExpandButton",ui,"UIPanelButtonTemplate")
expandButton:SetWidth(20); expandButton:SetHeight(17); expandButton:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-5,-4); expandButton:SetText("+")
expandButton:SetScript("OnClick",function() SpotifyNowDB.style.expanded=not SpotifyNowDB.style.expanded; ApplyStyle(); RefreshUI() end)
local settingsButton=CreateFrame("Button","SpotifyNowSettingsButton",ui,"UIPanelButtonTemplate")
settingsButton:SetWidth(20); settingsButton:SetHeight(17); settingsButton:SetPoint("TOPRIGHT",ui,"TOPRIGHT",-28,-4); settingsButton:SetText("...")
local settingsPanel=CreateFrame("Frame","SpotifyNowSettingsPanel",UIParent)
settingsPanel:SetWidth(220); settingsPanel:SetHeight(112); settingsPanel:SetPoint("CENTER",UIParent,"CENTER",0,0)
settingsPanel:SetFrameStrata("DIALOG"); settingsPanel:SetMovable(true); settingsPanel:EnableMouse(true); settingsPanel:RegisterForDrag("LeftButton")
settingsPanel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=8,right=8,top=8,bottom=8}})
settingsPanel:SetBackdropColor(0.025,0.035,0.05,0.98)
settingsPanel:SetScript("OnDragStart",function() this:StartMoving() end); settingsPanel:SetScript("OnDragStop",function() this:StopMovingOrSizing() end)
settingsPanel:Hide()
local settingsTitle=settingsPanel:CreateFontString(nil,"OVERLAY","GameFontNormal")
settingsTitle:SetPoint("TOP",settingsPanel,"TOP",0,-15); settingsTitle:SetText(T("settings_title"))
local themeButton=CreateFrame("Button",nil,settingsPanel,"UIPanelButtonTemplate")
themeButton:SetWidth(186); themeButton:SetHeight(24); themeButton:SetPoint("TOP",settingsPanel,"TOP",0,-38)
local sizeButton=CreateFrame("Button",nil,settingsPanel,"UIPanelButtonTemplate")
sizeButton:SetWidth(186); sizeButton:SetHeight(24); sizeButton:SetPoint("TOP",themeButton,"BOTTOM",0,-6)
local function RefreshSettingsPanel()
    local names={obsidian=T("theme_obsidian"),azerite=T("theme_azerite"),fel=T("theme_fel"),bloodmoon=T("theme_bloodmoon")}
    themeButton:SetText(T("settings_theme")..": "..(names[SpotifyNowDB.style.theme] or names.obsidian))
    sizeButton:SetText(SpotifyNowDB.style.expanded and T("settings_compact") or T("settings_expand"))
end
settingsPanel:SetScript("OnShow",function() RefreshSettingsPanel() end)
settingsButton:SetScript("OnClick",function() if settingsPanel:IsShown() then settingsPanel:Hide() else RefreshSettingsPanel(); settingsPanel:Show() end end)
themeButton:SetScript("OnClick",function()
    local order={"obsidian","azerite","fel","bloodmoon"}; local current=SpotifyNowDB.style.theme or "obsidian"; local nextIndex=1
    for i,name in ipairs(order) do if name==current then nextIndex=(i%table.getn(order))+1; break end end
    SpotifyNowDB.style.theme=order[nextIndex]; SpotifyNowDB.style.accent=nil; SpotifyNowDB.style.progressColor=nil
    ApplyStyle(); RefreshUI(); RefreshSettingsPanel()
end)
sizeButton:SetScript("OnClick",function() SpotifyNowDB.style.expanded=not SpotifyNowDB.style.expanded; ApplyStyle(); RefreshUI(); RefreshSettingsPanel() end)
local function MakeButton(name,label,tip,w,x,cmd)
    local b=CreateFrame("Button","SpotifyNowBtn"..name,ui,"UIPanelButtonTemplate")
    b:SetWidth(w); b:SetHeight(19); b:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",x,7); b:SetText(label)
    b:SetScript("OnClick",function() SendCommand(cmd) end)
    b:SetScript("OnEnter",function() GameTooltip:SetOwner(this,"ANCHOR_TOP"); GameTooltip:SetText(tip); GameTooltip:Show() end)
    b:SetScript("OnLeave",function() GameTooltip:Hide() end)
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
controls.shuffle=MakeButton("Shuffle","S",T("shuffle"),25,238,"shuffle")
controls["repeat"]=MakeButton("Repeat","R",T("repeat"),25,267,"repeat")

local progressBg=ui:CreateTexture(nil,"BORDER"); progressBg:SetTexture(0.08,0.09,0.11,1); progressBg:SetPoint("BOTTOMLEFT",ui,"BOTTOMLEFT",8,3); progressBg:SetWidth(234); progressBg:SetHeight(2)
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
for i=1,38 do
    local segment=ui:CreateTexture(nil,"ARTWORK")
    segment:SetTexture("Interface\\Buttons\\WHITE8X8")
    segment:SetPoint("BOTTOMLEFT",progressBg,"BOTTOMLEFT",(i-1)*9,0)
    segment:SetWidth(8); segment:SetHeight(2); segment:Hide()
    progressSegments[i]=segment
end

local THEMES={
    obsidian={bg={0.035,0.045,0.06},accent={0.12,0.84,0.38}},
    azerite={bg={0.025,0.12,0.18},accent={0.08,0.78,0.92}},
    fel={bg={0.08,0.035,0.12},accent={0.24,0.95,0.28}},
    bloodmoon={bg={0.14,0.025,0.035},accent={0.92,0.17,0.20}},
}
local function HexColor(value)
    if not value then return nil end
    value=string.gsub(value,"#",""); if string.len(value)~=6 or string.find(value,"[^%x]") then return nil end
    return tonumber(string.sub(value,1,2),16)/255,tonumber(string.sub(value,3,4),16)/255,tonumber(string.sub(value,5,6),16)/255
end
ApplyStyle=function()
    local s=SpotifyNowDB.style or {}; local th=THEMES[s.theme] or THEMES.obsidian
    local r,g,b=HexColor(s.accent); if not r then r,g,b=th.accent[1],th.accent[2],th.accent[3] end
    ui:SetBackdropColor(th.bg[1],th.bg[2],th.bg[3],0.96)
    local expanded=s.expanded==true
    ui:SetWidth(expanded and 360 or 250); ui:SetHeight(expanded and 126 or 58)
    progressBg:SetWidth(ui:GetWidth()-16); progressHit:SetWidth(ui:GetWidth()-16)
    progressSegmentCount=expanded and 38 or 26
    local segmentSpace=(ui:GetWidth()-16)/progressSegmentCount
    for i,segment in pairs(progressSegments) do
        segment:ClearAllPoints(); segment:SetPoint("BOTTOMLEFT",progressBg,"BOTTOMLEFT",(i-1)*segmentSpace,0)
        segment:SetWidth(segmentSpace-1)
    end
    art:SetWidth(expanded and 78 or 34); art:SetHeight(expanded and 78 or 34)
    if expanded then
        art:ClearAllPoints(); art:SetPoint("TOPLEFT",ui,"TOPLEFT",8,-8)
        titleText:ClearAllPoints(); titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",96,-9); titleText:SetWidth(250)
        artistText:Show(); albumText:Show(); timeText:Show(); expandButton:SetText("-")
    else
        art:ClearAllPoints(); art:SetPoint("TOPLEFT",ui,"TOPLEFT",7,-6)
        titleText:ClearAllPoints(); titleText:SetPoint("TOPLEFT",ui,"TOPLEFT",46,-8); titleText:SetWidth(128)
        artistText:Hide(); albumText:Hide(); timeText:Hide(); expandButton:SetText("+")
    end
    local alpha=(s.border==false) and 0 or (s.glow and 1 or 0.55)
    ui:SetBackdropBorderColor(r,g,b,alpha)
    for _,button in pairs(controls) do
        local fs=getglobal(button:GetName().."Text")
        if fs and fs.SetTextColor then if s.buttons==false then fs:SetTextColor(0.88,0.88,0.88) else fs:SetTextColor(r,g,b) end end
    end
    art:SetVertexColor(1,1,1,1)
    if s.progressColor then local pr,pg,pb=HexColor(s.progressColor); if pr then r,g,b=pr,pg,pb end end
    progressFill:SetTexture(r,g,b,1)
    local ph=2
    if s.progressStyle=="thick" then ph=4 elseif s.progressStyle=="segmented" then ph=3 end
    progressBg:SetHeight(ph); progressFill:SetHeight(ph)
    for _,segment in pairs(progressSegments) do segment:SetHeight(ph) end
    if s.progress==false then progressBg:Hide(); progressFill:Hide(); progressHit:Hide(); for _,segment in pairs(progressSegments) do segment:Hide() end else progressBg:Show(); progressFill:Show(); progressHit:Show() end
    if s.controls==false then for _,button in pairs(controls) do button:Hide() end else for _,button in pairs(controls) do button:Show() end end
    if not expanded or s.controls==false then controls.shuffle:Hide(); controls["repeat"]:Hide() end
    if s.metadata==false then titleText:Hide(); volText:Hide(); artistText:Hide(); albumText:Hide(); art:Hide() else titleText:Show(); volText:Show(); art:Show(); if expanded then artistText:Show(); albumText:Show() end end
end

local titleSource=""; local titleOffset=1; local titleElapsed=0; local TITLE_VISIBLE_CHARS=28
local function RefreshTitle()
    if titleSource=="" then titleText:SetText(T("waiting")); return end
    if strlen(titleSource)<=TITLE_VISIBLE_CHARS then titleText:SetText(titleSource); return end
    local cycle=titleSource.."     "; local shown=strsub(cycle,titleOffset,titleOffset+TITLE_VISIBLE_CHARS-1)
    if strlen(shown)<TITLE_VISIBLE_CHARS then shown=shown..strsub(cycle,1,TITLE_VISIBLE_CHARS-strlen(shown)) end
    titleText:SetText(shown); titleOffset=titleOffset+1; if titleOffset>strlen(cycle) then titleOffset=1 end
end
RefreshUI=function()
    local np=NowPlaying() or ""
    local displayTitle=np
    if SpotifyNowDB.style.expanded then displayTitle=SpotifyNowDB.title or "" end
    if displayTitle~=titleSource then titleSource=displayTitle; titleOffset=1; RefreshTitle() end
    artistText:SetText(SpotifyNowDB.artist or ""); albumText:SetText(SpotifyNowDB.album or "")
    playBtn:SetText(playing and "II" or ">")
    volText:SetText(volume>=0 and (T("volume_label").." "..volume) or (T("volume_label").." --"))
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
    if artwork~="" and string.find(artwork,"^[%w_%-]+%.tga$") then art:SetTexture("Interface\\AddOns\\SpotiWoW-Octo\\"..artwork) else art:SetTexture("Interface\\Icons\\INV_Misc_Note_01") end
    local function Clock(ms) local n=math.floor((ms or 0)/1000); return string.format("%d:%02d",math.floor(n/60),n%60) end
    timeText:SetText(Clock(pos).." / "..Clock(durationMs))
    controls.shuffle:SetText(SpotifyNowDB.shuffle and "S*" or "S")
    controls["repeat"]:SetText(SpotifyNowDB.repeatMode and "R*" or "R")
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
    if cmd=="expand" then s.expanded=not s.expanded; ApplyStyle(); RefreshUI(); Print(T("setting_updated"))
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
    SpotifyNowDB.artwork=DecodeField(f[13]); SpotifyNowDB.album=DecodeField(f[14]); SpotifyNowDB.shuffle=f[15]=="1"; SpotifyNowDB.repeatMode=f[16]=="1"
    RefreshUI()
end
local progressUiElapsed=0
local poller=CreateFrame("Frame","SpotifyNowStatePoller")
poller:SetScript("OnUpdate",function() local elapsed=arg1 or 0; statePollElapsed=statePollElapsed+elapsed; if statePollElapsed>=0.25 then statePollElapsed=0; PollBridgeState() end
    if strlen(titleSource)>TITLE_VISIBLE_CHARS then titleElapsed=titleElapsed+elapsed; if titleElapsed>=0.28 then titleElapsed=titleElapsed-0.28; RefreshTitle() end end
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
    if event~="ADDON_LOADED" or arg1~="SpotiWoW-Octo" then return end
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
