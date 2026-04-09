// now, this is just unfair.
class PDArmor:inventory{
	// percent damage reduction
	float mularmor;
	// subtractive damage reduction applied after mularmor
	float subarmor;
	
	// these are durability multipliers for each layer
	// incoming durability damage is divided by these
	float mulstrength;
	float substrength;
	
	// from 0 to 1, 1 being of course 100% (can't move at all)
	float speedpenalty;
	
	string sicon;
	string spritename;
	
	default{
		inventory.maxamount 1;
	}
	
	states{
	spawn:
		#### A 350{
			sprite = GetSpriteIndex(spritename);
			icon = TexMan.CheckForTexture(sicon,TexMan.TYPE_Any);
		}
		loop;
	}
	
	// armor's actual damage reduction will be handled via player's DamageMobj function.
}

// spawners
class PDArmorSpawner:actor{
	float mularmor;
	float subarmor;
	property protection:mularmor,subarmor;
	
	float mulstrength;
	float substrength;
	property durability:mulstrength,substrength;
	
	float speedpenalty;
	property speedpenalty:speedpenalty;
	
	string icon;
	string spritename;
	property icon:icon,spritename;
	
	override void PostBeginPlay(){
		super.PostBeginPlay();
		let arm = PDArmor(spawn("PDArmor",pos));
		arm.mularmor = mularmor;
		arm.subarmor = subarmor;
		arm.mulstrength = mulstrength;
		arm.substrength = substrength;
		arm.speedpenalty = speedpenalty;
		arm.sicon = icon;
		arm.spritename = spritename;
	}
	
	default{
		PDArmorSpawner.protection 0,0;
		PDArmorSpawner.durability 1.0,1.0;
		PDArmorSpawner.speedpenalty 0.0;
		PDArmorSpawner.icon "ARM5A0","ARM5";
	}
}

// standard armors. balanced enough.

// green armor is pretty light and will protect you from most small attacks.
// stops up to 20 damage; 30 damage becomes 9 damage.
class PDGreenArmor:PDArmorSpawner{
	default{
		PDArmorSpawner.protection 20,15;
		PDArmorSpawner.durability 3.5,17.0;
		PDArmorSpawner.speedpenalty 0.09;
		PDArmorSpawner.icon "ARM1A0","ARM1";
	}
}
// stops up to 35 damage; 50 damage becomes 10 damage.
class PDBlueArmor:PDArmorSpawner{
	default{
		PDArmorSpawner.protection 40,20;
		PDArmorSpawner.durability 2.33,14.0;
		PDArmorSpawner.speedpenalty 0.20;
		PDArmorSpawner.icon "ARM2A0","ARM2";
	}
}

// specialized armors. have fairly distinct weaknesses.

// brown armor is light but will let larger attacks through way too well.
// it specializes in stopping smaller attacks dead in their tracks.
// stops up to 26 damage; 40 damage becomes 15 damage
class PDBrownArmor:PDArmorSpawner{
	default{
		PDArmorSpawner.protection 0,25;
		PDArmorSpawner.durability 1.0,14.0;
		PDArmorSpawner.speedpenalty 0.06;
		PDArmorSpawner.icon "ARM3A0","ARM3";
	}
}
// black armor lasts quite a while but will always let some penetration through.
// it specializes in making heavier attacks not quite as immediately lethal.
// stops up to 7 damage; 50 damage becomes 14 damage
// 200 damage becomes 68 damage. could potentially save you from an explosion.
// blunt force damage from that would be fuckin insane though...
class PDBlackArmor:PDArmorSpawner{
	default{
		PDArmorSpawner.protection 65,2;
		PDArmorSpawner.durability 5.0,20.0;
		PDArmorSpawner.speedpenalty 0.15;
		PDArmorSpawner.icon "ARM4A0","ARM4";
	}
}


// item to give the player an armor vest and configure it to be a green armor
class PDGreenArmorGiver:inventory{
	override void DoEffect(){
		owner.GiveInventory("PDArmor",1);
		let arm = PDArmor(owner.FindInventory("PDArmor"));
		if(arm){
			arm.mularmor = 20;
			arm.subarmor = 15;
			arm.mulstrength = 3.5;
			arm.substrength = 17.0;
			arm.speedpenalty = 0.09;
			arm.sicon = "ARM1A0";
			arm.spritename = "ARM1";
		}
		
		Destroy();
	}
}
// and for blue armor
class PDBlueArmorGiver:inventory{
	override void DoEffect(){
		owner.GiveInventory("PDArmor",1);
		let arm = PDArmor(owner.FindInventory("PDArmor"));
		if(arm){
			arm.mularmor = 40;
			arm.subarmor = 20;
			arm.mulstrength = 2.33;
			arm.substrength = 14.0;
			arm.speedpenalty = 0.20;
			arm.sicon = "ARM2A0";
			arm.spritename = "ARM2";
		}
		
		Destroy();
	}
}

class pd_greenarmspawn:randomspawner replaces greenarmor{
	default{
		dropitem "PDGreenArmor",255,4;
		dropitem "PDBrownArmor",255,1;
		dropitem "PDBlackArmor",255,1;
	}
}
class pd_bluearmspawn:randomspawner replaces bluearmor{
	default{
		dropitem "PDBlueArmor",255,5;
		dropitem "PDBlackArmor",255,2;
		dropitem "PDBrownArmor",255,1;
	}
}