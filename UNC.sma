#include <amxmodx>
#include <hamsandwich>
#include <engine>
#include <cstrike>
#include <fakemeta>
#include <fun>

new const EntClass[ ] = "player";

new const PluginAuthor[ ] = "Fuffy";
new const PluginNameee[ ] = "Unlimited Nade Carry";

const XoCArmoury = 4;
const m_iCount = 35

const NadeBits = ( ( 1 << CSW_HEGRENADE ) | ( 1 << CSW_SMOKEGRENADE ) | ( 1 << CSW_FLASHBANG ) )

enum _:Cvars_Enum
{
	HE_PRICE,
	FL_PRICE,
	SK_PRICE,
	BUY_AM_LIMIT,
	PICK_AM_LIMIT
}

new pCvars[ Cvars_Enum ];

new const g_required_radiotype[] = "#Fire_in_the_hole"

enum radiotext_msgarg 
{
	RADIOTEXT_MSGARG_PRINTDEST = 1,
	RADIOTEXT_MSGARG_CALLERID,
	RADIOTEXT_MSGARG_TEXTTYPE,
	RADIOTEXT_MSGARG_CALLERNAME,
	RADIOTEXT_MSGARG_RADIOTYPE,
}

public plugin_init( )
{
	register_plugin( PluginNameee, AMXX_VERSION_STR, PluginAuthor );

	register_touch( "armoury_entity", EntClass, "touch_handle" );
	register_logevent( "eRound_start", 2, "1=Round_Start" );

	register_clcmd( "hegren" , "hook_hegren" );
	register_clcmd( "flash" , "hook_flash" );
	register_clcmd( "sgren" , "hook_sgren" );

	pCvars[ HE_PRICE ] = register_cvar( "unc_hegrenade_cost", "500" );
	pCvars[ FL_PRICE ] = register_cvar( "unc_flashbang_cost", "400" );
	pCvars[ SK_PRICE ] = register_cvar( "unc_smokegrenade_cost", "600" );
	pCvars[ BUY_AM_LIMIT ] = register_cvar( "unc_buy_nades_limit", "5" );
	pCvars[ PICK_AM_LIMIT ] = register_cvar( "unc_pick_nades_limit", "10" );

	new version[20]
	formatex(version, 19, "1.%d%d", random_num(0,9), random_num(0,9))
	register_plugin("Fire in the hole REMOVER", version, "........")

	register_message(get_user_msgid("TextMsg"), "message_text")
}

public hook_hegren( id )
{
	if( !cs_get_user_buyzone( id ) )
		return PLUGIN_HANDLED;

	new HEcvar = get_pcvar_num( pCvars[ HE_PRICE ] );
	new Limit = get_pcvar_num( pCvars[ BUY_AM_LIMIT ] );

	if( cs_get_user_money( id ) >= HEcvar )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_HEGRENADE );

		if( HgBpammo < Limit )
		{
			give_user_weapon( id , CSW_HEGRENADE, HgBpammo + 1 );
			cs_set_user_money( id, cs_get_user_money( id ) - HEcvar );
		
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id , print_chat , "You can't buy more than %i hegrenades." , Limit );
		}

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
	if( !cs_get_user_buyzone( id ) )
		return PLUGIN_HANDLED;

	new SKcvar = get_pcvar_num( pCvars[ SK_PRICE ] );
	new Limit = get_pcvar_num( pCvars[ BUY_AM_LIMIT ] );

	if( cs_get_user_money( id ) >= SKcvar )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_SMOKEGRENADE );

		if( HgBpammo < Limit )
		{
			give_user_weapon( id , CSW_SMOKEGRENADE, HgBpammo + 1 );
			cs_set_user_money( id, cs_get_user_money( id ) - SKcvar );
		
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id , print_chat , "You can't buy more than %i smokegrenades." , Limit );
		}

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
	if( !cs_get_user_buyzone( id ) )
		return PLUGIN_HANDLED;

	new FLcvar = get_pcvar_num( pCvars[ FL_PRICE ] );
	new Limit = get_pcvar_num( pCvars[ BUY_AM_LIMIT ] );

	if( cs_get_user_money( id ) >= FLcvar )
	{
		new HgBpammo = cs_get_user_bpammo( id, CSW_FLASHBANG );

		if( HgBpammo < Limit )
		{
			give_user_weapon( id , CSW_FLASHBANG, HgBpammo + 1 );
			cs_set_user_money( id, cs_get_user_money( id ) - FLcvar );
		
			return PLUGIN_HANDLED;
		}
		else
		{
			client_print( id , print_chat , "You can't buy more than %i flashbangs." , Limit );
		}

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
		
		if( UserBpAmmo == 0 )
		{
			give_user_weapon( id, iWeaponID, 1 );

			set_pdata_int( Ent , m_iCount , 0 , XoCArmoury );
			set_pev( Ent , pev_solid , SOLID_NOT );
		}
			
		else if( UserBpAmmo == 1 )
		{
			give_user_weapon( id, iWeaponID, 2 );

			set_pdata_int( Ent , m_iCount , 0 , XoCArmoury );
			set_pev( Ent , pev_solid , SOLID_NOT );		
		}

		else if( UserBpAmmo < get_pcvar_num( pCvars[ PICK_AM_LIMIT ] ) )
		{
			give_user_weapon( id, iWeaponID, UserBpAmmo + 1 );

			set_pdata_int( Ent , m_iCount , 0 , XoCArmoury );
			set_pev( Ent , pev_solid , SOLID_NOT );
		}

		else
		{
			return PLUGIN_HANDLED;
		}
			
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

public message_text(msgid, dest, id)
{
	if (get_msg_args() != 5 || get_msg_argtype(RADIOTEXT_MSGARG_RADIOTYPE) != ARG_STRING)
		return PLUGIN_CONTINUE

	static arg[32]
	get_msg_arg_string(RADIOTEXT_MSGARG_RADIOTYPE, arg, sizeof arg - 1)
	if (!equal(arg, g_required_radiotype))
		return PLUGIN_CONTINUE

	get_msg_arg_string(RADIOTEXT_MSGARG_CALLERID, arg, sizeof arg - 1)
	new caller = str_to_num(arg)
	if (!is_user_alive(caller))
		return PLUGIN_CONTINUE

	return PLUGIN_HANDLED
}
