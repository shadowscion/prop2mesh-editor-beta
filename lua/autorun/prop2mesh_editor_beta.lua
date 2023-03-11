
AddCSLuaFile( "prop2mesh/prop2mesh_editor_beta.lua" )

if CLIENT then
    include( "prop2mesh/prop2mesh_editor_beta.lua" )
end

properties.Add( "prop2mesh_editor_beta", {
    MenuLabel     = "Edit Prop2Mesh (Beta)",
    MenuIcon      = "icon16/image_edit.png",
    PrependSpacer = true,
    Order         = 3001,

    Filter = function( self, ent, ply )
        if IsValid( ent ) and ( ent:GetClass() == "sent_prop2mesh" or ent:GetClass() == "sent_prop2mesh_legacy" ) then
            return gamemode.Call( "CanProperty", ply, "prop2mesh_editor_beta", ent )
        end
        return false
    end,

    Action = function( self, ent )
        prop2mesh_editor.open( ent )
    end,
} )
