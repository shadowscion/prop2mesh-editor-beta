
---------------------------------------------------------------
---------------------------------------------------------------
prop2mesh_editor_beta = {}
local prop2mesh_editor_beta = prop2mesh_editor_beta

function prop2mesh_editor_beta.open( ent )
    if not IsValid( ent ) or ( ent:GetClass() ~= "sent_prop2mesh" and ent:GetClass() ~= "sent_prop2mesh_legacy" ) then return end

    local sw = math.Round( ScrW() * 0.5 ) * 2
    local sh = math.Round( ScrH() * 0.5 ) * 2
    local fw = 400
    local fh = math.Round( ( sh * 0.8 ) * 0.5 ) * 2

    local panel = g_ContextMenu:Add( "prop2mesh_editor_beta_frame" )
    panel:SetSize( fw + 8, fh + 8 )
    panel:SetPos( sw - fw - 54, sh - fh - 54 )
    panel:Setup( ent )

    return panel
end


---------------------------------------------------------------
---------------------------------------------------------------
local draw, surface = draw, surface

local editor_colors = {}

editor_colors.window_out = Color( 120, 120, 120, 255 )
editor_colors.window_mid = Color( 255, 255, 255, 255 )
editor_colors.tree_ln = Color( 122, 122, 122, 75 )
editor_colors.tree_txtbox = Color( 255, 255, 255, 255 )

local seed = Color( 122, 189, 254, 255 ) --33, 37, 41, 255 )

editor_colors.window_top = seed
editor_colors.window_bot = seed
editor_colors.tree_bg = Color( seed.r, seed.g, seed.b, 20 )
editor_colors.tree_fg = Color( seed.r, seed.g, seed.b, 40 )

editor_colors.text_diff = Color( 4, 102, 200, 255 )
editor_colors.text_norm = Color( 115, 115, 115, 255 )
editor_colors.text_dark = Color( 85, 85, 85, 255 )

local editor_font = "prop2mesh_editor_beta_fontsmall"
local editor_fontBold = "prop2mesh_editor_beta_fontlarge"

surface.CreateFont( editor_font, { font = "Arial", size = 14 } )
surface.CreateFont( editor_fontBold, { font = "Arial Bold", size = 14 } )

local function editor_drawbox( bevel, x, y, w, h, color, outline, ... )
    if bevel then
        if outline then
            draw.RoundedBoxEx( bevel, x, y, w, h, editor_colors.window_out, ... )
            draw.RoundedBoxEx( bevel, x + 1, y + 1, w - 2, h - 2, color, ... )
        else
            draw.RoundedBoxEx( bevel, x, y, w, h, color, ... )
        end

        return
    end

    if outline then
        surface.SetDrawColor( editor_colors.window_out )
        surface.DrawRect( x, y, w, h )
        surface.SetDrawColor( color )
        surface.DrawRect( x + 1, y + 1, w - 2, h - 2 )
    else
        surface.SetDrawColor( color )
        surface.DrawRect( x, y, w, h )
    end
end

local function editor_drawtextbox( self, w, h )
    editor_drawbox( false, 0, 0, w, h, editor_colors.tree_txtbox, true, true, true, true, true )
    self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
end


---------------------------------------------------------------
---------------------------------------------------------------
local PANEL = { config = { headerH = 24, footerH = 24 } }
vgui.Register( "prop2mesh_editor_beta_frame", PANEL, "DFrame" )

function PANEL:Init()
    self:DockPadding( 4, self.config.headerH + 4, 4, self.config.footerH + 4 )

    self.lblTitle:SetFont( editor_fontBold )
    self.lblTitle:SetColor( color_white )

    self.btnMaxim:Remove()
    self.btnMinim:Remove()
    self.btnClose:Remove()

    self.btnClose = vgui.Create( "DImageButton", self )
    self.btnClose:SetImage( "gui/cross.png" )
    self.btnClose.DoClick = function()
        self:Remove()
    end

    self.btnConfirm = vgui.Create( "DButton", self )
    self.btnConfirm:SetText( "Confirm Changes" )
    self.btnConfirm:SetFont( editor_font )
    self.btnConfirm.DoClick = function()
        PrintTable( self.tree.prop2mesh_upd )
    end

    self.tree = vgui.Create( "prop2mesh_editor_beta_tree", self )
    self.tree.Paint  = nil
    self.tree.Window = self
    self.tree:Dock( FILL )
end

function PANEL:PerformLayout( w, h )
    self.lblTitle:SetPos( 8, 0 )
    self.lblTitle:SetSize( w - 25, self.config.headerH )
    self.btnClose:SetPos( w - 20, 4 )
    self.btnClose:SetSize( 16, 16 )
    self.btnConfirm:SetPos( 2, h - self.config.footerH + 2 )
    self.btnConfirm:SetSize( w - 4, self.config.footerH - 4 )
end

function PANEL:SetEntity( ent )
    if self.Entity == ent then return end
    if IsValid( self.Entity ) then
        self.Entity:RemoveCallOnRemove( "prop2mesh_editor_beta_onRemove" )
    end

    self.Entity = ent
    self.Entity:CallOnRemove( "prop2mesh_editor_beta_onRemove", function( e )
        timer.Simple( 0, function() if IsValid( self ) and not IsValid( e ) then self:Remove() end end )
    end )

    self:SetTitle( tostring( self.Entity ) )

    self.tree:Setup( self.Entity )
end

function PANEL:Setup( ent )
    self:SetEntity( ent )
end

function PANEL:Paint( w, h )
    editor_drawbox( false, 0, 0, w, self.config.headerH, editor_colors.window_top, true, true, true, false, false )
    editor_drawbox( false, 0, h - self.config.footerH, w, self.config.footerH, editor_colors.window_bot, true, false, false, true, true )
    editor_drawbox( false, 0, self.config.headerH - 1, w, h - self.config.headerH - self.config.footerH + 2, editor_colors.window_mid, true )
end


---------------------------------------------------------------
---------------------------------------------------------------
local PANEL = {}
vgui.Register( "prop2mesh_editor_beta_tree", PANEL, "DTree" )

function PANEL:OnNodeSelected( item )
    self:SetSelectedItem( nil )
    item:SetExpanded( not item:GetExpanded() )
end

function PANEL:Init()
    self.RootNode:Remove()

    self:SetShowIcons( true )
    self:SetIndentSize( 14 )
    self:SetLineHeight( 17 )

    self.RootNode = self:GetCanvas():Add( "prop2mesh_editor_beta_node" )
    self.RootNode:SetRoot( self )
    self.RootNode:SetParentNode( self )
    self.RootNode:Dock( TOP )
    self.RootNode:SetText( "" )
    self.RootNode:SetExpanded( true, true )
    self.RootNode:DockMargin( 0, 0, 0, 0 )
    self.RootNode.Paint = nil

    self:SetPaintBackground( true )
end

function PANEL:Setup( ent )
    self:Clear()
    self.Entity = ent

    self.prop2mesh_controller = {}
    self.prop2mesh_nodes = {}
    self.prop2mesh_old = {}
    self.prop2mesh_new = {}
    self.prop2mesh_upd = {}

    for _, controller in ipairs( self.Entity.prop2mesh_controllers ) do
        local json = prop2mesh.getMeshData( controller.crc )
        json = util.Decompress( json )

        local index = controller.index

        self.prop2mesh_controller[index] = controller
        self.prop2mesh_old[index] = util.JSONToTable( json )
        self.prop2mesh_new[index] = util.JSONToTable( json )
        self.prop2mesh_upd[index] = {}

        local old = self.prop2mesh_old[index]
        local new = self.prop2mesh_new[index]
        local upd = self.prop2mesh_upd[index]

        for k, v in ipairs( old ) do
            local text = string.GetFileFromFilename( v.prop or v.holo or v.objn or v.objd or ( v.primitive and "primitive_" .. v.primitive.construct ) )
            old[k]._text = text
            new[k]._text = text
        end

        self.prop2mesh_nodes[index] = {}
        local nodes = self.prop2mesh_nodes[index]

        nodes.controller = self:AddNode( string.format( "controller [%s]", controller.name or index ), "icon16/controller.png" )
        nodes.controller:DockMargin( 0, 0, 0, 4 )
        nodes.controller:SetLineHeight( 24 )
        nodes.controller.Label:SetFont( editor_fontBold )

        nodes.settings = nodes.controller:AddNode( "settings", "icon16/cog.png" )
        nodes.settings:SetLineHeight( 24 )

        nodes.custom = nodes.controller:AddNode( "custom", "icon16/car.png" )
        nodes.custom:SetLineHeight( 24 )

        nodes.models = nodes.controller:AddNode( "models", "icon16/brick.png" )
        nodes.models:SetLineHeight( 24 )

        local mdlCount = 0
        local objCount = 0

        for part, data in SortedPairsByMemberValue( old, "_text" ) do
            if not data._text or part == "custom" then goto SKIP end

            if data.objd then
                objCount = objCount + 1

                local root = nodes.custom
                local node = root:AddNode( string.format( "[%d] %s", objCount, data._text ), "icon16/bullet_black.png" )
            else
                mdlCount = mdlCount + 1

                local root = nodes.models
                local node = root:AddNode( string.format( "[%d] %s", mdlCount, data._text ), "icon16/bullet_black.png" )
                node:SetLineHeight( 20 )

                node.prop2mesh = { editor = self, controller = index, part = part, old = old[part], new = new[part], upd = upd }
                node.prop2mesh_setupModel = true
            end

            ::SKIP::
        end
    end
end

function PANEL:PerformLayoutInternal()
    local Tall = self.pnlCanvas:GetTall()
    local Wide = self:GetWide()
    local YPos = 0

    self:Rebuild()

    self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
    YPos = self.VBar:GetOffset()

    if self.VBar.Enabled then Wide = Wide - self.VBar:GetWide() - 3 end

    self.pnlCanvas:SetPos( 0, YPos )
    self.pnlCanvas:SetWide( Wide )

    self:Rebuild()

    if Tall ~= self.pnlCanvas:GetTall() then
        self.VBar:SetScroll( self.VBar:GetScroll() ) -- Make sure we are not too far down!
    end
end


---------------------------------------------------------------
---------------------------------------------------------------
local PANEL = { lineHeight = 20 }

AccessorFunc( PANEL, "m_bDrawIcons", "DrawIcons", FORCE_BOOL )
AccessorFunc( PANEL, "m_bDrawLayer", "DrawLayer", FORCE_BOOL )

vgui.Register( "prop2mesh_editor_beta_node", PANEL, "DTree_Node" )

function PANEL:ShowIcons()
    return self.m_bDrawIcons
end

function PANEL:SetLineHeight( num )
    self.lineHeight = num
    self:SetTall( num )
end

function PANEL:GetLineHeight()
    return self.lineHeight or self:GetParentNode():GetLineHeight()
end

function PANEL:AddNode( strName, strIcon )
    self:CreateChildNodes()

    local pNode = vgui.Create( "prop2mesh_editor_beta_node", self )
    pNode:SetText( strName )
    pNode:SetParentNode( self )
    pNode:SetTall( self:GetLineHeight() )
    pNode:SetRoot( self:GetRoot() )
    pNode:SetIcon( strIcon )
    pNode:SetDrawLines( not self:IsRootNode() )
    pNode:SetDrawIcons( true )
    pNode:SetDrawLayer( true )
    pNode.Label:SetFont( editor_font )
    pNode.Label:SetTextColor( editor_colors.text_norm )

    if not self.indentLevel then self.indentLevel = 1 end
    pNode.indentLevel = self.indentLevel + 1

    self:InstallDraggable( pNode )

    self.ChildNodes:Add( pNode )
    self:InvalidateLayout()

    self:OnNodeAdded( pNode )

    return pNode
end

function PANEL:PerformLayout( w, h )
    if self:IsRootNode() then
        return self:PerformRootNodeLayout()
    end

    if self.animSlide:Active() then return end

    local LineHeight = self:GetLineHeight()

    if self.m_bHideExpander then
        self.Expander:SetPos( -11, 0 )
        self.Expander:SetSize( 15, 15 )
        self.Expander:SetVisible( false )
    else
        self.Expander:SetPos( 2, ( LineHeight - 15 ) * 0.5 + 1 )
        self.Expander:SetSize( 15, 15 )
        self.Expander:SetVisible( self:HasChildren() || self:GetForceShowExpander() )
        self.Expander:SetZPos( 10 )
    end

    self.Label:StretchToParent( 0, nil, 0, nil )
    self.Label:SetTall( LineHeight )

    if self:ShowIcons() then
        self.Icon:SetVisible( true )
        self.Icon:SetPos( self.Expander.x + self.Expander:GetWide() + 4, ( LineHeight - self.Icon:GetTall() ) * 0.5 )
        self.Label:SetTextInset( self.Icon.x + self.Icon:GetWide() + 4, 0 )
    else
        self.Icon:SetVisible( false )
        self.Label:SetTextInset( self.Expander.x + self.Expander:GetWide() + 4, 0 )
    end

    if not IsValid( self.ChildNodes ) or not self.ChildNodes:IsVisible() then
        self:SetTall( LineHeight )
        return
    end

    self.ChildNodes:SizeToContents()
    self:SetTall( LineHeight + self.ChildNodes:GetTall() )

    self.ChildNodes:StretchToParent( LineHeight, LineHeight, 0, 0 )

    self:DoChildrenOrder()
end

function PANEL:Paint( w, h )
    -- if self.m_bDrawLayer then
    --     surface.SetDrawColor( editor_colors.tree_bg )

    --     surface.DrawRect( 0, 0, w, h )
    --     if self.Label.Hovered then
    --         surface.DrawRect( 0, 0, w, self:GetLineHeight() )
    --     end
    -- end

    if self.Label.Hovered then
        surface.SetDrawColor( editor_colors.tree_fg )
        surface.DrawRect( 8, 0, w - 8, self:GetLineHeight() )
    end

    if self.m_bDrawLines then
        surface.SetDrawColor( editor_colors.tree_ln )

        local z = self:GetLineHeight() * 0.5
        surface.DrawLine( 8, 0, 8, self.m_bLastChild and z or h )
        surface.DrawLine( 8, z, 16, z )
    end
end

function PANEL:DoRightClick()
    if self.prop2mesh_setupModel then
        self:SetupModelNode()
        self.prop2mesh_setupModel = nil
    end
end


---------------------------------------------------------------
---------------------------------------------------------------
local function SetUpdate( self, key, val )
    self.prop2mesh.new[key] = val

    local diff = self.prop2mesh.old[key] ~= self.prop2mesh.new[key]

    if diff then
        if not self.prop2mesh.upd[self.prop2mesh.part] then
            self.prop2mesh.upd[self.prop2mesh.part] = {}
        end
        self.prop2mesh.upd[self.prop2mesh.part][key] = val
        self.prop2mesh.modelNode.Label:SetTextColor( editor_colors.text_diff )
    else
        if self.prop2mesh.upd[self.prop2mesh.part] then
            self.prop2mesh.upd[self.prop2mesh.part][key] = nil
            if not next( self.prop2mesh.upd[self.prop2mesh.part] ) then
                self.prop2mesh.upd[self.prop2mesh.part] = nil
                self.prop2mesh.modelNode.Label:SetTextColor( editor_colors.text_norm )
            end
        end
    end

    return diff
end

function PANEL:SetupModelNode()
    self:Clear()

    local Paint = self.Paint
    self.Paint = function( pnl, w, h )
        if self:IsChildHovered() then
            surface.SetDrawColor( editor_colors.tree_fg )
            surface.DrawRect( 8, 0, w - 8, h )
            surface.SetDrawColor( editor_colors.tree_ln )
            surface.DrawOutlinedRect( 8, 0, w - 8, h )
        end

        return Paint( self, w, h )
    end

    self.Label:SetFont( editor_fontBold )
    self.Icon:SetImage( "icon16/brick_edit.png" )

    if self.prop2mesh.old.scale == nil then
        self.prop2mesh.old.scale = Vector( 1, 1, 1 )
        self.prop2mesh.new.scale = Vector( 1, 1, 1 )
    end

    for k, v in pairs( { "vinvert", "vinside", "vsmooth" } ) do
        if self.prop2mesh.old[v] == nil then
            self.prop2mesh.old[v] = 0
            self.prop2mesh.new[v] = 0
        end
    end

    self.prop2mesh.modelNode = self

    self:SetupVariable( { key = "pos", title = "local pos", type = "vector", icon = "icon16/bullet_wrench.png" } )
    self:SetupVariable( { key = "ang", title = "local ang", type = "angle", icon = "icon16/bullet_wrench.png" } )
    self:SetupVariable( { key = "scale", title = "model scale", type = "vector", icon = "icon16/bullet_wrench.png", min = Vector( 0, 0, 0 ), max = Vector( 50, 50, 50 ) } )

    local path = self.prop2mesh.old.prop and "prop" or self.prop2mesh.old.holo and "holo"
    if path then
        local temp = self:SetupVariable( { key = path, title = "model path", type = "string", icon = "icon16/bullet_wrench.png" } )
        temp.node.prop2mesh = self.prop2mesh
        temp.node:SetupVariable( { key = "test", title = "disable sub-model 1", type = "bool" } )
    end

    local options = self:AddNode( "model options", "icon16/bullet_wrench.png" ) -- ??? maybe do an 'options' node the way the vector nodes work
    options.prop2mesh = self.prop2mesh

    options:SetupVariable( { key = "vsmooth", title = "flatten normals", type = "bool" } )
    options:SetupVariable( { key = "vinvert", title = "invert mesh", type = "bool" } )
    options:SetupVariable( { key = "vinside", title = "render inside", type = "bool" } )

    self:ExpandRecurse( true )
end


---------------------------------------------------------------
---------------------------------------------------------------
local panelTypes = {
    ["vector"] = "SetupVector",
    ["angle"]  = "SetupVector",
    ["string"] = "SetupString",
    ["bool"]   = "SetupBool",
}

function PANEL:SetupVariable( edit )
    local panels

    local node = self:AddNode( edit.title, edit.icon or "icon16/bullet_black.png" )
    local func = panelTypes[edit.type]

    if func then
        panels = node[func]( node, edit )
        panels.node = node

        panels.container.ValueChanged = function( _, val )
            local diff = SetUpdate( self, edit.key, val )

            node.Label:SetTextColor( diff and editor_colors.text_diff or editor_colors.text_norm )
            panels.container:UpdateOnChange( diff, self.prop2mesh.old[edit.key] )
        end

        panels.container.Think = function( _ )
            if not panels.container:IsEditing() then
                panels.container:SetValue( self.prop2mesh.new[edit.key] )
            end
        end

        panels.container.Revert = function( _ )
            panels.container:ValueChanged( self.prop2mesh.old[edit.key] )
        end

        node.DoRightClick = function()
            local menu = DermaMenu()

            local opt = menu:AddOption( "revert changes", panels.container.Revert )
            opt:SetIcon( "icon16/bullet_blue.png" )

            local x, y = node:LocalToScreen( 0, node:GetLineHeight() )
            menu:Open()

            local mx, my = menu:GetPos()
            menu:SetPos( mx, y )
        end
    end

    return panels
end

function PANEL:SetupVector( edit )
    local node = self:AddNode( "" )
    node.Label:SetVisible( false )

    node:SetDrawIcons( false )
    node:SetDrawLines( false )
    node:SetDrawLayer( false )

    local panels = {}

    panels.container = node:Add( "Panel" )
    panels.container:DockMargin( 4, 1, 4, 1 )
    panels.container:Dock( FILL )
    panels.container.Paint = nil

    local isAngle = edit.type == "angle"
    local internalValue = isAngle and Angle() or Vector()

    for k, v in ipairs( { "A", "B", "C" } ) do
        panels[v] = panels.container:Add( "DNumberWang" )
        panels[v].Paint = editor_drawtextbox
        panels[v]:SetFont( editor_font )
        panels[v]:SetDecimals( isAngle and 3 or 6 )
        panels[v]:HideWang( true )
        panels[v]:SetPaintBackground( false )

        panels[v]:SetMin( edit.min and edit.min[k] or -16384 )
        panels[v]:SetMax( edit.max and edit.max[k] or 16384 )

        panels[v].OnValueChanged = function( _, val )
            internalValue[k] = val
            panels.container:ValueChanged( internalValue )
        end
    end

    panels.container.PerformLayout = function( pnl, w, h )
        local l = math.floor( w / 3 )

        panels.A:SetSize( l - 8, h )
        panels.B:SetSize( l - 8, h )
        panels.C:SetSize( l - 8, h )

        panels.A:SetPos( 4, 0 )
        panels.B:SetPos( l + 4, 0 )
        panels.C:SetPos( l + l + 4, 0 )
    end

    local decimalPattern = isAngle and "%.3f" or "%.6f"

    panels.container.SetValue = function( _, val )
        internalValue[1] = val[1]
        internalValue[2] = val[2]
        internalValue[3] = val[3]

        panels.A:SetText( string.format( decimalPattern, val[1] ) )
        panels.B:SetText( string.format( decimalPattern, val[2] ) )
        panels.C:SetText( string.format( decimalPattern, val[3] ) )
    end

    panels.container.IsEditing = function()
        return panels.A:IsHovered() or panels.B:IsHovered() or panels.C:IsHovered() or panels.A:IsEditing() or panels.B:IsEditing() or panels.C:IsEditing()
    end

    panels.container.UpdateOnChange = function( _, diff, val )
        if not diff then
            panels.A:SetTextColor( nil )
            panels.B:SetTextColor( nil )
            panels.C:SetTextColor( nil )

            return
        end

        panels.A:SetTextColor( val[1] ~= internalValue[1] and editor_colors.text_diff or nil )
        panels.B:SetTextColor( val[2] ~= internalValue[2] and editor_colors.text_diff or nil )
        panels.C:SetTextColor( val[3] ~= internalValue[3] and editor_colors.text_diff or nil )
    end

    return panels
end

function PANEL:SetupBool( edit )
    local panels = {}

    panels.container = self:Add( "Panel" )
    panels.container:SetSize( self:GetLineHeight(), self:GetLineHeight() )
    panels.container:DockMargin( 0, 0, 8, 0 )
    panels.container:Dock( RIGHT )
    panels.container.Paint = nil

    local z = ( self:GetLineHeight() - 15 ) * 0.5

    panels.box = panels.container:Add( "DCheckBox" )
    panels.box.OnChange = function( _, val )
        panels.container:ValueChanged( val and 1 or 0 )
    end

    panels.container.PerformLayout = function( pnl, w, h )
        panels.box:SetPos( w - 15, z )
    end

    panels.container.SetValue = function( _, val )
        panels.box:SetChecked( tobool( val ) )
    end

    panels.container.IsEditing = function()
        return panels.box:IsEditing()
    end

    panels.container.UpdateOnChange = function( _, diff )
        print( diff )
    end

    return panels
end

function PANEL:SetupString( edit )
    local node = self:AddNode( "" )
    node.Label:SetVisible( false )

    node:SetDrawIcons( false )
    node:SetDrawLines( false )
    node:SetDrawLayer( false )

    local panels = {}

    panels.container = node:Add( "Panel" )
    panels.container:DockMargin( 4, 1, 4, 1 )
    panels.container:Dock( FILL )
    panels.container.Paint = nil

    panels.text = panels.container:Add( "DTextEntry" )
    panels.text.Paint = editor_drawtextbox
    panels.text:SetFont( editor_font )
    panels.text:SetUpdateOnType( true )
    panels.text:SetPaintBackground( false )

    panels.text.OnValueChange = function( _, val )
        panels.container:ValueChanged( val )
    end

    panels.container.PerformLayout = function( pnl, w, h )
        panels.text:SetSize( w - 8, h )
        panels.text:SetPos( 4, 0 )
    end

    panels.container.SetValue = function( _, val )
        panels.text:SetText( util.TypeToString( val ) )
    end

    panels.container.IsEditing = function()
        return panels.text:IsHovered() or panels.text:IsEditing()
    end

    panels.container.UpdateOnChange = function( _, diff )
        panels.text:SetTextColor( diff and editor_colors.text_diff or nil )
    end

    return panels
end
