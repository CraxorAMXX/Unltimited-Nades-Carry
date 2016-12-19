#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <fun>

new const EntClass[ ] = "player";

const XoCArmoury = 4;
const m_iCount = 35

const NadeBits = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_FLASHBANG ) )

// Smokegrenade has the same price as hegrenade, so we using one const for both comparations.
const HeGrenadePrice = 300;
const FlashBangPrice = 200;


public plugin_init( )
{
	register_plugin( "Unlimited Nade Carry", "1.0", "Craxor" );

	register_touch( "armoury_entity", EntClass, "touch_handle" );
	register_logevent( "eRound_start", 2, "1=Round_Start" );

	register_clcmd( "hegren" , "hook_hegren" );
	register_clcmd( "flash" , "hook_flash" );
	register_clcmd( "sgren" , "hook_sgren" );
}

public hook_hegren( id )
{
	if( cs_get_user_money( id ) >= HeGrenadePrice )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_HEGRENADE );
		
		give_user_weapon( id , CSW_HEGRENADE, HgBpammo + 1 );
		cs_set_user_money( id, cs_get_user_money( id ) - HeGrenadePrice );
		
		return PLUGIN_HANDLED;

	}			
	else
	{
		client_print( id , print_chat, " You don't have enough money! " );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public hook_sgren( id )
{
	if( cs_get_user_money( id ) >= HeGrenadePrice )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_SMOKEGRENADE );
		
		give_user_weapon( id , CSW_SMOKEGRENADE, HgBpammo + 1 );
		cs_set_user_money( id, cs_get_user_money( id ) - HeGrenadePrice );
		
		return PLUGIN_HANDLED;

	}			
	else
	{
		client_print( id , print_chat, " You don't have enough money! " );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public hook_flash( id )
{
	if( cs_get_user_money( id ) >= FlashBangPrice )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_FLASHBANG );
		
		give_user_weapon( id , CSW_FLASHBANG, HgBpammo + 1 );
		cs_set_user_money( id, cs_get_user_money( id ) - FlashBangPrice );
		
		return PLUGIN_HANDLED;

	}			
	else
	{
		client_print( id , print_chat, " You don't have enough money! " );
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}




public eRound_start( )
{
	new iEntity;

	while ( ( iEntity = find_ent_by_class( iEntity , "armoury_entity" ) ) )
	{
		if ( pev_valid( iEntity ) && cs_get_armoury_type( iEntity ) )
		{
			ExecuteHam( Ham_CS_Restart , iEntity );	
			set_pev( iEntity, pev_solid, SOLID_TRIGGER );
		}
	}
}

public touch_handle( Ent , id )
{
	if( !pev_valid( Ent ) || !id )
		return -1;

	new iWeaponID = cs_get_armoury_type( Ent );

	if( NadeBits & ( 1 << iWeaponID ) )
	{
		new UserBpAmmo = cs_get_user_bpammo( id, iWeaponID );

		client_print( id , print_chat, " bpammo total: %i", UserBpAmmo + 1 );

		set_pdata_int( Ent , m_iCount , 0 , XoCArmoury );
		set_pev( Ent , pev_solid , SOLID_NOT );

		
		if( UserBpAmmo == 0 )
			give_user_weapon( id, iWeaponID, 1 );
			
		else if( UserBpAmmo == 1 )
			give_user_weapon( id, iWeaponID, 2 );
		
		else
			give_user_weapon( id, iWeaponID, UserBpAmmo + 1 );
			
	}

	return PLUGIN_CONTINUE;
}

give_user_weapon( index , iWeaponTypeID , iClip=0 , iBPAmmo=0 , szWeapon[]="" , maxchars=0 )
{
	if ( !( CSW_P228 <= iWeaponTypeID <= CSW_P90 ) || ( iClip < 0 ) || ( iBPAmmo < 0 ) || !is_user_alive( index ) )
		return -1;
    
	new szWeaponName[ 20 ] , iWeaponEntity , bool:bIsGrenade;
    
	const GrenadeBits = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_FLASHBANG ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_C4 ) );
    
	if ( ( bIsGrenade = bool:!!( GrenadeBits & ( 1 << iWeaponTypeID ) ) ) )
		iClip = clamp( iClip ? iClip : iBPAmmo , 1 );
    
	get_weaponname( iWeaponTypeID , szWeaponName , charsmax( szWeaponName ) );
    
	if ( ( iWeaponEntity = user_has_weapon( index , iWeaponTypeID ) ? find_ent_by_owner( -1 , szWeaponName , index ) : give_item( index , szWeaponName ) ) > 0 )
	{
		if ( iClip && !bIsGrenade )
			cs_set_weapon_ammo( iWeaponEntity , iClip );

		if ( iWeaponTypeID == CSW_C4 ) 
			cs_set_user_plant( index , 1 , 1 );
		else
			cs_set_user_bpammo( index , iWeaponTypeID , bIsGrenade ? iClip : iBPAmmo ); 
            
		if ( maxchars )
			copy( szWeapon , maxchars , szWeaponName[7] );
	}
	return iWeaponEntity;
}
