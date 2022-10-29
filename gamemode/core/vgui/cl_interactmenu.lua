local PANEL = {}

function PANEL:Init()
end

function PANEL:Setup(ent)
    self.entity = ent
    
    for v,k in pairs(impulse.InteractionMenuOptions) do
        if k.class and k.class != ent:GetClass() then
            return false
        end
        
        if k.customCheck and not k.customCheck(ent) then
            return false
        end
        
        local x = self:AddOption(k.name)
        
        if k.icon then
            x:SetIcon(k.icon)
        end
    end
    
    self:Open()
end

vgui.Register("impulseInteractionMenu", PANEL, "DMenu")
