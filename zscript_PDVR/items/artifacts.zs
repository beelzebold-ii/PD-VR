// not made by human hands.

// powerups
class PD_TimeFreeze:PowerTimeFreezer{
	default{
		Inventory.Icon "PTIMC0";
		Powerup.Colormap 0.6, 0.6, 0.6; // should just grayscale the screen
		Powerup.Duration -10;
	}
}
class PD_MinorProtection:PowerProtection{
	default{
		Inventory.Icon "SOULA0";
		Powerup.Duration -4;
		DamageFactor 0.3; // 70% damage reduction
	}
	// give instant healing effects
	override void InitEffect(){
		owner.GiveBody(40,70);
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			pdp.openwounds = max(0,pdp.openwounds - 60);
			pdp.pain = max(0,pdp.pain - 50);
			pdp.stun = 0;
		}
		super.InitEffect();
	}
}
class PD_MajorProtection:PowerProtection{
	default{
		Inventory.Icon "PINVA0";
		Powerup.Colormap 1.0, 0.88, 0.0, 0.0, 0.0, 0.0; // inverse colormap but piss colored
		Powerup.Duration -30;
		DamageFactor 0.01; // 99% damage reduction! still not total invulnerability, and effective damage reduction isn't quite so high.
	}
	// damage surrounding enemies
	override void InitEffect(){
		super.InitEffect();
		owner.GiveBody(30,60);
		owner.RadiusAttack(owner,100,512,'explosive',RADF_SOURCEISSPOT|RADF_THRUSTZ|RADF_NOALLIES|RADF_CIRCULAR,128);
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			pdp.stun = min(100,pdp.stun + 30);
		}
	}
	// no pain while invulnerable. duh.
	override void DoEffect(){
		super.DoEffect();
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			pdp.pain = 10;
			
			// also, regen 1 health every 20 ticks, constantly, while invulnerable.
			if(gametic%20 == 0) pdp.GiveBody(1);
		}
	}
}
class PD_Inviso:PowerInvisibility{
	default{
		Inventory.Icon "PINSA0";
		Powerup.Colormap 0.549, 0.482, 0.392; // hopefully will be a decent looking sepia filter
		Powerup.Duration -20;
		Powerup.Mode "Translucent";
	}
	override void InitEffect(){
		super.InitEffect();
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			pdp.inviso = 60;
		}
	}
	override void DoEffect(){
		super.DoEffect();
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			if(pdp.inviso < 100) pdp.inviso++;
		}
	}
}

// base class for artifacts
class PD_Artifact:inventory{
	class<inventory> PowerToGive;
	property Power:PowerToGive;
	int bloodcost;
	property Bloodcost:bloodcost;
	
	default{
		Inventory.Amount 3;
		Inventory.MaxAmount 9;
		Inventory.InterHubAmount 9;
		+Inventory.INVBAR;
		+Inventory.PERSISTENTPOWER;
		+Inventory.BIGPOWERUP;
		+BRIGHT;
		//+FLOATBOB;
		
		Scale 0.5;
	}
	
	override bool Use(bool pkup){
		// already under the effects of this artifact's powers
		let pdp = PDPlayerPawn(owner);
		if(!pdp) return false;
		if(pdp.bloodloss > 90 - bloodcost){
			owner.A_Log("The blood cost is too high.",true);
			return false;
		}
		if(owner.FindInventory(PowerToGive)){
			return false;
		}else{
			owner.GiveInventory(PowerToGive,1);
			pdp.bloodloss += bloodcost;
		}
		return true;
	}
}

// THE ARTIFACTS
class PDSoulsphere:PD_Artifact{
	default{
		Inventory.Amount 2;
		Inventory.MaxAmount 6;
		Inventory.Icon "SOULA0";
		Inventory.PickupMessage "Picked up an artifact of healing.";
		Tag "Health artifact";
		PD_Artifact.Power "PD_MinorProtection";
		PD_Artifact.Bloodcost 6;
	}
	states{
	spawn:
		SOUL ABCD 6;
		loop;
	}
}
class PDTimepiece:PD_Artifact{
	default{
		Inventory.Icon "PTIMC0";
		Inventory.PickupMessage "Picked up an artifact of time.";
		Tag "Time artifact";
		PD_Artifact.Power "PD_TimeFreeze";
		PD_Artifact.Bloodcost 16;
	}
	states{
	spawn:
		PTIM ABCB 4;
		loop;
	}
}
class PDStealth:PD_Artifact{
	default{
		Inventory.Icon "PINSA0";
		Inventory.PickupMessage "Picked up an artifact of stealth.";
		Tag "Stealth artifact";
		PD_Artifact.Power "PD_Inviso";
		PD_Artifact.Bloodcost 11;
	}
	states{
	spawn:
		PINS ABCDCB random(3,9);
		loop;
	}
}
class PDProtection:PD_Artifact{
	default{
		Inventory.Amount 1;
		Inventory.MaxAmount 3;
		Inventory.Icon "PINVA0";
		Inventory.PickupMessage "Picked up an artifact of protection.";
		Tag "Protection artifact";
		PD_Artifact.Power "PD_MajorProtection";
		PD_Artifact.Bloodcost 21;
	}
	states{
	spawn:
		PINV ABCD 10;
		loop;
	}
}

// spawners
class pd_soulspherespawn:randomspawner replaces soulsphere{
	default{
		Dropitem "PDSoulsphere",255,3;
		Dropitem "PDTimepiece",255,1;
		Dropitem "PDProtection",255,1;
	}
}
class pd_blurspawn:randomspawner replaces blursphere{
	default{
		Dropitem "PDStealth",255,3;
		Dropitem "PDTimepiece",255,1;
	}
}
class pd_megaspawn:actor replaces megasphere{
	override void PostBeginPlay(){
		spawn("pd_soulspherespawn",pos - (8,8,0));
		spawn("PDBlueArmor",pos + (8,8,0));
		Destroy();
	}
}
class pd_protectspawn:randomspawner replaces invulnerabilitysphere{
	default{
		Dropitem "PDProtection",255,3;
		Dropitem "PDSoulsphere",255,1;
	}
}