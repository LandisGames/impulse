local PANEL = {}

function PANEL:Init()
	self:SetCursor("hand")
	self.news = {}
	self.materials = {}

	http.Fetch(impulse.Config.WordPressURL.."/wp-json/wp/v2/posts?per_page=4", 
	function(body)
		if IsValid(self) then
			self:SetupNews(util.JSONToTable(body))
		end
	end, 
	function(error) 
		if IsValid(self) then 
			self:Remove()
			print("[impulse] Failed to load newsfeed. Error: "..error)
		end 
	end)
end

function PANEL:SetupNews(newsData)
	if not newsData then
		return print("[impulse] Failed to load newsfeed.")
	end
	
	for v,postData in pairs(newsData) do
		if postData.type == "post" and postData.status == "publish" then
			local image
			if postData.better_featured_image and postData.better_featured_image.media_type == "image" then
				if postData.better_featured_image.media_details.sizes.medium_large then
					image = postData.better_featured_image.media_details.sizes.medium_large.source_url
				elseif postData.better_featured_image.media_details.sizes.medium then
					image = postData.better_featured_image.media_details.sizes.medium.source_url
				end
			end

			table.insert(self.news, {postData.id, postData.title.rendered, postData.link, image or impulse.Config.DefaultWordPressImage})
		end
	end

	local firstPost

	for v,postData in pairs(self.news) do
		local postParent = vgui.Create("DPanel", self)
		postParent:DockMargin(0,0,0,0)
		postParent:DockPadding(0,0,0,0)
		postParent:Dock(FILL)
		postParent:SetDrawBackground(true)
		postParent:SetBackgroundColor(Color(20,20,20,255))
		postParent:SetCursor("hand")

		if v == 1 then
			firstPost = postParent
			self.selected = postParent
		end

		if postData[4] then
			local postBackground = vgui.Create("HTML", postParent)
			postBackground:SetPos(-10,-10)
			postBackground:SetSize(self:GetWide()+20, self:GetTall()+10)
			postBackground:SetCursor("hand")
			postBackground:SetHTML([[<style type="text/css">
				body {
					overflow:hidden;
				}
				</style>
				<img src="]]..postData[4]..[[" style="width:100%;height:100%;">]])

		end

		local postInfoBackground = vgui.Create("DPanel", postParent)
		postInfoBackground:SetPos(0, self:GetTall()-60)
		postInfoBackground:SetSize(self:GetWide(), 60)
		postInfoBackground:SetBackgroundColor(Color(10,10,10,190))
		postInfoBackground:SetCursor("hand")

		local title = vgui.Create("DLabel", postParent)
		title:SetPos(10, self:GetTall()-50)
		title:SetText(postData[2])
		title:SetFont("Impulse-Elements20-Shadow")
		title:SizeToContents()

		local readMore = vgui.Create("DLabel", postParent)
		readMore:SetPos(10, self:GetTall()-30)
		readMore:SetText("Click to read more...")
		readMore:SetFont("Impulse-Elements18-Shadow")
		readMore:SizeToContents()

		local postButton = vgui.Create("DPanel", postParent)
		postButton:Dock(FILL)
		postButton:SetDrawBackground(false)
		postButton:SetCursor("hand")
		function postButton:OnMousePressed()
			gui.OpenURL(postData[3])
		end

		local selectBtn = vgui.Create("DButton", self)
		selectBtn:SetText("")
		selectBtn:SetSize(16, 16)
		selectBtn:SetPos((self:GetWide() - 100) + (v * 20), self:GetTall()-18)
		selectBtn.post = postParent
		selectBtn:SetColor(color_white)

		function selectBtn:Think()
			self:MoveToFront()
		end

		local panel = self
		local btnCol = Color(60,60,60,140)
		function selectBtn:Paint(w,h)
			if panel.selected == self.post then
				draw.RoundedBox(0, 0, 0, w, h, impulse.Config.MainColour)
			else
				draw.RoundedBox(0, 0, 0, w, h, btnCol)
			end
		end

		function selectBtn:DoClick()
			self.post:MoveToFront()
			panel.selected = self.post
		end

		firstPost:MoveToFront()
	end
end

local gradient = Material("vgui/gradient-l")
local outlineCol = Color(190,190,190,240)
local darkCol = Color(30,30,30,200)

function PANEL:Paint(w,h)
	surface.SetDrawColor(outlineCol)
	surface.DrawOutlinedRect(0,0,w, h)
 	surface.SetMaterial(gradient)
	surface.SetDrawColor(darkCol)
 	surface.DrawTexturedRect(1,1,w-1,h-2)
end

vgui.Register("impulseNewsfeed", PANEL, "DPanel")