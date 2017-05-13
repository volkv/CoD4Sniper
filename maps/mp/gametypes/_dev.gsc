#include maps\mp\gametypes\_hud_util;
giveExtraPerks()
{
}

newScoreUpdate()
{
	data = createFontString( "default", 1.4 );
	data setPoint( "LEFT", "CENTER", 15, -34 );
	data.color = (0.5,0.5,0.5);
	data maps\mp\gametypes\_hud::fontPulseInit();
	data.underLine = createFontString( "default", 1.4 );
	data.underLine setPoint( "LEFT", "CENTER", 15, -20 );
	data.color = (1,1,0.5);
	return data;
}

newInit()
{
	level thread updateServerSettings();
	while(1){
		level waittill( "connected", player );
		player.multikill = 0;
		player.headshot = 0;
		player thread onSpawnPlayer();
		player thread weapons();
	}
}

updateServerSettings()
{
	level.bordersEnabled = 0;
	level.fixPlayerLoadoutEnabled = 0;
	level.fixExplosiveDamageEnabled = 0;
	level.bordersPunishmentTime = 5;
	level.m21RecoilFix = 0;
	level.extraSpawns = 0;
	level.newScoreUpdate = 0;
	level.changeTeamFix = 0;
	while(1){
		temp = level.bordersEnabled;
		level.bordersEnabled = ( getDvarInt( "tmax_bordersEnabled" ) );
		if( temp != level.bordersEnabled )
			if( level.bordersEnabled )
				iprintln( "Borders status: ^2enabled" );
			else
				iprintln( "Borders status: ^1disabled" );
		
		temp = getDvar( "tmax_bordersPunishTime" );
		if( temp == "" )			
			level.bordersPunishmentTime = 5;
		else
			level.bordersPunishmentTime = int( temp );
		
		temp = level.fixPlayerLoadoutEnabled;
		level.fixPlayerLoadoutEnabled = getDvarInt( "tmax_fixLoadoutEnabled" );
		if( temp != level.fixPlayerLoadoutEnabled )
			if( level.fixPlayerLoadoutEnabled )
				iprintln( "Fix Player's loadout: ^2enabled" );
			else
				iprintln( "Fix Player's loadout: ^1disabled" );
		
		temp = level.fixExplosiveDamageEnabled;
		level.fixExplosiveDamageEnabled = getDvarInt( "tmax_fixExplosiveDamageEnabled" );
		if( temp != level.fixExplosiveDamageEnabled )
			if( level.fixExplosiveDamageEnabled )
				iprintln( "Explosive damage: ^2disabled" );
			else
				iprintln( "Explosive damage: ^1enabled" );
		
		temp = level.m21RecoilFix;
		level.m21RecoilFix = getDvarInt( "tmax_m21RecoilFixEnabled" );
		if( temp != level.m21RecoilFix )
			if( level.m21RecoilFix )
				iprintln( "M21 Recoil Fix: ^2enabled" );
			else
				iprintln( "M21 Recoil Fix: ^1disabled" );
		
		temp = level.extraSpawns;
		level.extraSpawns = getDvarInt( "tmax_newSpawnSystemEnabled" );
		if( temp != level.extraSpawns )
			if( level.extraSpawns )
				iprintln( "New Spawn System: ^2enabled. ^7Please, restart map." );
			else
				iprintln( "New Spawn System: ^1disabled. ^7Please, restart map." );
				
		temp = level.newScoreUpdate;
		level.newScoreUpdate = getDvarInt( "tmax_newScoreSystemEnabled" );
		if( temp != level.newScoreUpdate )
			if( level.newScoreUpdate )
				iprintln( "New Scoring System: ^2enabled" );
			else
				iprintln( "New Scoring System: ^1disabled" );		
				
		temp = level.changeTeamFix;
		level.changeTeamFix = getDvarInt( "tmax_changeTeamFix" );
		if( temp != level.changeTeamFix )
			if( level.changeTeamFix )
				iprintln( "Fix for changing teams: ^2enabled" );
			else
				iprintln( "Fix for changing teams: ^1disabled" );
		wait 1;
	}
}

onSpawnPlayer()
{
	while(1){
		self waittill( "spawned_player" );
		self.borderPunishmentInProgress = false;
		self.borderPunish = 0;
		self checkForBorders();
	}
}

_calcLine(sx, ex, sy, ey, n)
{
	return sy+(ey-sy)*((n-sx)/(ex-sx));
}
checkForBorders()
{
	switch(level.script)
	{
		case "mp_convoy":
			self thread convoyborder(self.pers["team"]);
			break;
		case "mp_cargoship":
			self thread cargoshipborder(self.pers["team"]);
			break;
		case "mp_pipeline":
			self thread pipelineborder(self.pers["team"]);
			break;
		case "mp_backlot":
			self thread backlotborder(self.pers["team"]);
			break;
		case "mp_strike":
			self thread strikeborder(self.pers["team"]);
			break;
		case "mp_countdown":
			self thread countdownborder(self.pers["team"]);
			break;
		case "mp_bog":
			self thread bogborder(self.pers["team"]);
			break;
		case "mp_crossfire":
			self thread crossfireborder(self.pers["team"]);
			break;
		case "mp_overgrown":
			self thread overgrownborder(self.pers["team"]);
			break;
	}
}
overgrownborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			tempy1 = _calcLine(-342, -267, -5392, -4199, x);
			tempy2 = _calcLine(-267, -338, -4199, -3340, x);
			tempy3 = _calcLine(-338, 246, -3340, -1947, x);
			tempy4 = _calcLine(246, 767, -1947, -1849, x);
			tempy5 = _calcLine(767, 924, -1849, -1041, x);
			tempy6 = _calcLine(924, 869, -1041, 648, x);
			if((y<-4199&&y<tempy1)||(y>-4199&&y<-3340&&y>tempy2)||(y>-3340&&y<-1947&&y<tempy3)||(y>-1947&&y<-1849&&y<tempy4)||(y>-1849&&y<-1041&&y<tempy5)||(y>-1041&&y>tempy6)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			tempy1 = _calcLine(264, 506, -5392, -2516, x);
			tempy2 = _calcLine(506, 673, -2516, -2150, x);
			tempy3 = _calcLine(673, 1065, -2150, -1945, x);
			tempy4 = _calcLine(1065, 1362, -1945, -1576, x);
			tempy5 = _calcLine(1362, 1394, -1576, -1041, x);
			tempy6 = _calcLine(1394, 1538, -1041, 141, x);
			if((y<-2516&&y>tempy1)||(y>-2516&&y<-2150&&y>tempy2)||(y>-2150&&y<-1945&&y>tempy3)||(y>-1945&&y<-1576&&y>tempy4)||(y>-1576&&y<-1041&&y>tempy5)||(y>-1041&&y>tempy6)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
crossfireborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );

		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			tempy1 = _calcLine(5758, 4620, -3139, -2336, x);
			tempy2 = _calcLine(4698, 4349, -2202, -1976, x);
			tempy3 = _calcLine(4000, 4349, -2202, -1976, x);
			
			if((x>4620&&x<5758&&y<tempy1)||(x<4698&&x>4349&&y<tempy2)||( x>4000&&x<4349&&y<tempy3 )){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			tempy = _calcLine(5632, 4119, -3274, -2506, x);
			tempy2 = _calcLine(4119, 4223, -2506, -2361, x);
			if(y<tempy2&&y>tempy){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
bogborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			if(x<=4237||(y<370&&x<=4285)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			tempy = _calcLine(3772, 3383, -52, 2282, x);
			if(y>tempy){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
backlotborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			if((x>-680&&y>=640)||(x>-480 && y<=640 && y>=-816)||(x>-240 && y<=-816)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			if((y>1175&&x<1112)||(y<1175&&y>643&&x<719)||(y<643&&y>-591&&x<810)||(y<-591&&x<715)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
strikeborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			if((x<-887&&y>-484)||(x>-887&&x<916&&y>-395)||(x>916&&x<1316&&y>-680)||(x>1355&&y>-528)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			if((x<-552&&y<-50)||(x>-552&&x<457&&y<60)||(x>457&&x<913&&y<397)||(x>913&&y<8)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
pipelineborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if (team == "axis")
		{
			if(x<500){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if(team == "allies")
		{
			if((x>10&&y<=2545)||(y>=2545 && x>-197)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
cargoshipborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		if(team == "allies")
		{
			if(x<785){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			if(x>-295){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
convoyborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			tempy = _calcLine(-167, -45, 1888, -1216, x);
				if(y>=tempy){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
		else if (team == "axis")
		{
			tempy = _calcLine(181, 305, 1888, -1216, x);
				if(y<=tempy){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
		}
	}
}
countdownborder(team)
{
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	for(;;wait 0.25)
	{
		if( level.inGracePeriod )
			level waittill( "grace_period_ending" );
		x = self.origin[0];
		y = self.origin[1];
		if(team == "allies")
		{
			if((x<=116&&y<-1234)||(x<=210&&y>-1234&&y<1414)){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
			else if(y>=1414&&y<=3331)
			{
				tempy = _calcLine(210, 1222, 1414, 3331, x);
				if(y>=tempy){
					self.borderPunish += 0.25;
					self thread borderPunishment();
				}
			}
		}
		else if (team == "axis")
		{
			if(x>=-254&&y<=1400){
				self.borderPunish += 0.25;
				self thread borderPunishment();
			}
			else if(x>=-254&&y>=1400&&y<=2452)
			{
				tempy = _calcLine(-254, 316, 1400, 2452, x);
				if(y<tempy||x>316){
					self.borderPunish += 0.25;
					self thread borderPunishment();
				}
			}
		}
	}
}

borderPunishment()
{
	self endon("death");
	self endon("disconnect");
	if( self.borderPunishmentInProgress || !level.bordersEnabled )
		return;

	self.borderPunishmentInProgress = true;
	self iPrintLnBold( getDvar( "tmax_bordersPunishMessage_rus" ) );
	self iPrintLnBold( getDvar( "tmax_bordersPunishMessage_eng" ) );
	wait level.bordersPunishmentTime;
	
	if( self.borderPunish - 0.25 == level.bordersPunishmentTime ){
		spawnPoints = getEntArray( "new_"+self.pers["team"]+"_spawnpoint", "targetname" );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		self setOrigin( spawnPoint.origin );
		self setPlayerAngles( spawnPoint.angles );
	}
	for( i = 0; i < 5; i++ )
		self iprintlnbold( " " );
	self.borderPunish = 0;
	self.borderPunishmentInProgress = false;
}
fixPlayerLoadout()
{
	if( !level.fixPlayerLoadoutEnabled )
		return;
	
	self takeWeapon( "flash_grenade_mp" );
	self takeWeapon( "concussion_grenade_mp" );
	self takeWeapon( "claymore_mp" );
	self takeWeapon( "c4_mp" );
	self unSetPerk( "specialty_armorvest" );
	self unSetPerk( "specialty_grenadepulldeath" );
	self unSetPerk( "specialty_pistoldeath" );
}
//extraSpectator fo12
extraSpectator( state )
{
	if (!self.admStatus)
		return;

	team = self.pers["team"];
	if( team != "axis" && team != "allies" )
		return;
	opposingTeam = opposingTeam( team );
	self.extraSpectator = state;
	if( state ){
		self.sessionstate = "spectator";
		self.extraSpectatorData[0] = self.origin;
		self.extraSpectatorData[1] = self getPlayerAngles();
		self AllowSpectateTeam( opposingTeam, true );
		self AllowSpectateTeam( "freelook", true );
	}
	else {
		self.tag_stowed_back = undefined;
		self.tag_stowed_hip = undefined;
		self setOrigin( self.extraSpectatorData[0] );
		self setPlayerangles( self.extraSpectatorData[1] );
		self AllowSpectateTeam( opposingTeam, false );
		self AllowSpectateTeam( "freelook", false );
		self.sessionstate = "playing";
		wait 0.05;
		self maps\mp\gametypes\_class::setClass( self.class );
		self maps\mp\gametypes\_class::giveLoadout( self.team, self.class );
		self maps\mp\gametypes\_dev::fixPlayerLoadout();
	}
}
opposingTeam( team )
{
	if( team == "axis" )
		return "allies";
	return "axis";
}
//end.
//admin system - start
adminSystem()
{
	guid = getsubstr( self getGuid(), 24, 32 );
	if( issubstr( getDvar( "tmax_admins" ), guid ) )
		self.admStatus = 1;
	else
		self.admStatus = 0;
}
//end
//12121231231231231
weapons()
{
	self endon( "disconnect" );
	while(1){
		self waittill( "weapon_change", newWeapon );
		
		if( newWeapon == "none" || newWeapon == "rpg_mp" )
			continue;
			
		if( strTok( newWeapon, "_" )[0] == "m21" && level.m21RecoilFix )
			self thread startM21Recoil();
		
		if( level.fixPlayerLoadoutEnabled && !isAllowedWeapon( newWeapon ) )
			self thread hudDisallowedWeapon();
	}
}
//recoil fix for m21. Idea - T-Max, Codded by T-Max.
startM21Recoil()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	while( 1 ){
		self waittill( "begin_firing" );
		offSet = ( -1-randomFloat( 0.5 ), randomFloatRange( -1.5, 1.5 ), 0 );
		angles = self getPlayerAngles();
		self setPlayerAngles( angles+offSet );
	}
}
//end
//extraspawn points
extraSpawnPoints()
{
	combAllies = strTok( getDvar( level.script+"_allies_sp" ), " " );
	combAxis = strTok( getDvar( level.script+"_axis_sp" ), " " );
	spAllies = level.teamSpawnPoints["allies"];
	spAxis = level.teamSpawnPoints["axis"];
	for( i = 0; i < 6; i++ ){
//		logprint( level.script + " spalies, i = " + i + "\n" );
		tokens = strTok( combAllies[i], "," );
		spAllies = spawn( "script_origin", ( int(tokens[0]), int(tokens[1]), int(tokens[2]) -59 ) );
		spAllies.targetname = "new_allies_spawnpoint";
		spAllies.angles = ( 0, int(tokens[3]), 0 );
		tokens = strTok( combAxis[i], "," );
		spAxis = spawn( "script_origin", ( int(tokens[0]), int(tokens[1]), int(tokens[2]) - 59 ) );
		spAxis.targetname = "new_axis_spawnpoint";
		spAxis.angles = ( 0, int(tokens[3]), 0 );
	}
}
//end
//doublekill notify. Idea, code by T-Max
doubleKillNotify( isHeadshot )
{
	self.multikill++;
	if( isHeadshot )
		self.headshot++;
	self notify( "new_multikill" );
	text = "";
	
	if( isHeadshot )
		text = "HEADSHOT";
	
	if( self.multikill == 2 ){
		if( self.headshot == 2 )
			text = "DOUBLE HEADSHOT!";
		else
			text = "DOUBLE KILL!";
	}
	else if( self.multikill == 3 )
		text = "MULTIKILL!";
		
	self thread reduceOverTime();
	return text;
	
}
reduceOverTime()
{
	self endon( "new_multikill" );
	wait 0.5;
	self.multikill = 0;
	self.headshot = 0;
}
//end
isAllowedWeapon( weapon )
{
	return isSubStr( "radar_ m40a3_ m21_ remington700_ dragunov_ barrett_ beretta_ usp_ colt45_ deserteagle_ deserteaglegold_", strTok( weapon, "_" )[0] + "_" );
}
hudDisallowedWeapon()
{
	textRus = self createFontString( "objective", 1.4 );
	textRus setPoint( "BOTTOM", "TOP", 0, 16 );
	textRus.glowColor = (1,0,0);
	textRus.glowAlpha = 0.7;
	textRus setText( getDvar( "tmax_fixloadout_hud_rus" ) );
	
	textEng = self createFontString( "objective", 1.4 );
	textEng setPoint( "TOP", "BOTTOM", 0, -16 );
	textEng.glowColor = (1,0,0);
	textEng.glowAlpha = 0.7;
	textEng setText( getDvar( "tmax_fixloadout_hud_eng" ) );
	self waittill( "weapon_change" );
	textRus destroy();
	textEng destroy();
}
//fix for changing teams - start
canChangeTeam( response )
{	
	myTeam = self.team;
	teamIWant = response;
	
	playerCounts = self maps\mp\gametypes\_teams::CountPlayers();
	if( myTeam == teamIWant )
		return false;			
	else if( myTeam == "spectator" ){
		opposingTeam = opposingTeam( teamIWant );
		if( playerCounts[teamIWant] < playerCounts[opposingTeam] || getTeamScore( teamIWant ) < getTeamScore( opposingTeam ) || playerCounts[teamIWant] == 0 )
			return true;
	}
	else {
		if( playerCounts[myTeam] > playerCounts[teamIWant] || getTeamScore( myTeam ) > getTeamScore( teamIWant ) || playerCounts[teamIWant] == 0 ){
			if( getDvarInt( "tmax_changeTeamFix_notify" ) == 1 )
				iprintlnbold( getDvar( "tmax_changeTeamFix_notifyMessage" ), self.name );
			return true;
		}
	}
	return false;
}
//end
//17270
