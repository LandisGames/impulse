local PANEL = {}

function PANEL:Init()
	self:MakePopup()
end

local naturalOrder = {
	["pos"] = 1,
	["endpos"] = 2,
	["start_pos"] = 3,
	["end_pos"] = 4,
	["ang"] = 5,
	["start_ang"] = 6,
	["end_ang"] = 7,
	["endang"] = 8,
	["class"] = 9,
	["sound"] = 10,
	["model"] = 11,
	["message"] = 12,
	["text"] = 12.1,
	["pos_x"] = 13,
	["pos_y"] = 14,
	["start"] = 15,
	["end"] = 16,
	["colour"] = 17,
	["col"] = 18,
	["duration"] = 19,
	["time"] = 19.1,
	["speed"] = 20,
	["url"] = 21,
	["volume"] = 22,
	["level"] = 23
}
function PANEL:SetTable(prop, callback)
	self.props = vgui.Create("DProperties", self)
	--self.props:DockMargin(0, 30, 0, 0)
	self.props:Dock(FILL)

	local function setupProp(v, k)
		if isbool(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Boolean")
			row:SetValue(k)

			function row:DataChanged(newVal)
				callback(v, tobool(newVal))
			end
		elseif isnumber(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Float", {min = -10000, max = 10000})
			row:SetValue(k)

			function row:DataChanged(newVal)
				if tonumber(newVal) then
					callback(v, newVal)
				end
			end
		elseif isstring(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue(k)
			row.Value = k

			function row:DataChanged(newVal)
				row.Value = newVal
				callback(v, newVal)
			end

			local i = vgui.Create("DImageButton", row)
			i:SetSize(16, 16)
			i:SetPos(105, 2)
			i:SetIcon("icon16/page_white_edit.png")
			i:SetTooltip("Text editor")

			function i:DoClick()
				if IsValid(ACTIVE_EM_TXTEDITOR) then
					ACTIVE_EM_TXTEDITOR:Remove()
				end

				local m = vgui.Create("DFrame")
				m:SetSize(550, 700)
				m:Center()
				m:MakePopup()
				m:SetTitle("Text Edtior for property "..v.." | Remember multi-line will not work with most events!")

				ACTIVE_EM_TXTEDITOR = m
				
				local txt = vgui.Create("DTextEntry", m)
				txt:Dock(FILL)
				txt:SetText(row.Value)
				txt:SetEditable(true)
				txt:SetMultiline(true)
				txt:SetFont("Impulse-Elements18")
				txt:SetUpdateOnType(true)
				txt:SetPlaceholderText("Click to edit text...")

				function txt:Think()
					if not IsValid(row) then
						return m:Remove()
					end
				end

				function txt:OnChange(t)
					if IsValid(row) then
						local val = self:GetValue()
						row:SetValue(val)
						row.DataChanged(row, val)
					end
				end
			end
		elseif IsColor(k) or (istable(k) and k.r and k.g and k.b) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("VectorColor")
			row:SetValue(Vector(k.r / 255, k.g / 255, k.b / 255))

			function row:DataChanged(newVal)
				local vec = string.Split(newVal, " ")

				for v,k in pairs(vec) do
					if not tonumber(k) then
						return Vector(0, 0, 0)
					else
						vec[v] = tonumber(k)
					end
				end

				callback(v, Color(vec[1] * 255, vec[2] * 255, vec[3] * 255))
			end
		elseif isvector(k) then
			local row = self.props:CreateRow("Properties", v)
			row:Setup("Generic")
			row:SetValue(k.x..", "..k.y..", "..k.z)

			function row:DataChanged(newValue)
				local vec = string.Trim(newValue, " ")

				if string.EndsWith(vec, ")") then
					if string.StartWith(vec, "Vector(") then
						self:SetValue(string.Trim(string.sub(vec, 8), ")"))
						return
					elseif string.StartWith(vec, "Angle(") then
						self:SetValue(string.Trim(string.sub(vec, 7), ")"))
						return
					end
				end

				local cVec = vec
				vec = string.Split(vec, ",")

				if #vec == 1 and #string.Split(cVec, " ") == 2 then
					self:SetValue(string.Replace(cVec, " ", ", "))
					return
				end
				
				for v,k in pairs(vec) do
					string.Trim(k, " ")

					if not tonumber(k) then
						return Vector(0, 0, 0)
					else
						vec[v] = tonumber(k)
					end
				end

				callback(v, Vector(vec[1], vec[2], vec[3]))
			end

			local i = vgui.Create("DImageButton", row)
			i:SetSize(16, 16)
			i:SetPos(105, 2)
			i:SetIcon("icon16/map_edit.png")
			i:SetTooltip("Quick set")

			function i:DoClick()
				local m = DermaMenu()

				m:AddOption("Use eye pos", function() 
					local x = LocalPlayer():EyePos()
					row:SetValue(x.x..", "..x.y..", "..x.z)
					callback(v, x)
				end)
				m:AddOption("Use eye angle", function() 
					local x = LocalPlayer():EyeAngles()
					row:SetValue(x.p..", "..x.y..", "..x.r)
					callback(v, Vector(x.p, x.y, x.r))
				end)

				local tr = LocalPlayer():GetEyeTrace()

				if IsValid(tr.Entity) then
					m:AddOption("Use "..tostring(tr.Entity).." pos", function() 
						local x = tr.Entity:GetPos()
						row:SetValue(x.x..", "..x.y..", "..x.z)
						callback(v, x)
					end)

					m:AddOption("Use "..tostring(tr.Entity).." angle", function() 
						local x = tr.Entity:GetAngles()
						row:SetValue(x.p..", "..x.y..", "..x.r)
						callback(v, Vector(x.p, x.y, x.r))
					end)
				end
				m:Open()
			end
		end
	end

	local done = {}
	local add = {}

	for v,k in pairs(naturalOrder) do
		if prop[v] then
			add[k] = v
		end

		done[v] = true
	end

	for v,k in SortedPairs(add) do
		setupProp(k, prop[k])
	end


	for v,k in pairs(prop) do
		if done[v] then
			continue
		end
		
		setupProp(v, k)
	end
end

vgui.Register("impulsePropertyEditor", PANEL, "DFrame")