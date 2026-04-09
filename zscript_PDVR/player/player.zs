#include "deathtips.zs"

// squishy little bitch
class PDPlayerPawn:doomplayer{
	bool twohanding;
	
	PDWeaponPos weaponmodel;
	
	int usetics; // timer for holding the use key to display inventory stuff
	
	// stun hinders movement and heightens recoil
	int stun;
	// pain makes your hands shake and gets in the way of your vision
	int pain;
	// once fatigue reaches 100, stun increases instead
	int fatigue;
	// open wounds bleed at a rate of 0.0033/tic and add base pain
	float openwounds;
	// patched wounds slow bleeding by 95% and that's it, still hurts.
	float patchedwounds;
	// bloodloss adds base fatigue and eventually stun
	// eventually it kills you outright
	float bloodloss;
	
	// health will only regen up to this much
	int regenhealth;
	// your max health will be hindered by this (unless on stims)
	// if it reaches 70 you just die
	int bodydamage;
	
	// invisibility intensity, as a percentage
	int inviso;
	
	default{
		// (sic)
		tag "Vrtual Marine";
		
		player.forwardmove 0.5,0.366;
		player.sidemove 0.5,0.333;
		
		// player.runhealth 25;
		
		player.jumpz 4.0;
		gravity 0.5;
		
		player.displayname "Doomguy start";
		
		player.startitem "PDPistol";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistolAmmo",30;
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
		
		radius 10;
	}
	
	override bool CanReceive(inventory item){
		// oops forgot to allow startitems to be gotten lmfao
		// we'll just check for if totaltime is higher than 0
		if(level.totaltime <= 0) return super.CanReceive(item);
		
		for(int i = 0;i < BURDEN_ITEMS_CNT;i++){
			if(item is BURDEN_ITEMS[i]){
				if(player.cmd.buttons & BT_USE) return super.CanReceive(item);
				else return false;
			}
		}
		return super.CanReceive(item);
	}
	
	override void PostBeginPlay(){
		super.PostBeginPlay();
		GiveInventory("PDEmptyOffhand",1);
		A_SelectWeapon("PDEmptyOffhand");
		
		GiveInventory("PDInvManager",1);
		GiveInventory("PDMedManager",1);
		GiveInventory("PDFragThrower",1);
		
		GiveInventory("PDMagHand",1);
		GiveInventory("PDShellHand",1);
		GiveInventory("PD2ShellHand",1);
		GiveInventory("PDAmmoBoxHand",1);
		GiveInventory("PDRocketHand",1);
		GiveInventory("PDBatteryHand",1);
		
		weaponmodel = PDWeaponPos(spawn("PDWeaponPos",pos + (0,0,32)));
		weaponmodel.master = self;
		
		// for some reason the player isn't correctly being given their
		// handtracker sometimes, so I'm moving it here.
		GiveInventory("PD_Hands",1);
	}
	override void Travelled(){
		weaponmodel = PDWeaponPos(spawn("PDWeaponPos",pos + (0,0,32)));
		weaponmodel.master = self;
	}
	
	override int DamageMobj(actor inflictor,actor source,int damage,name mod,int flags,double angle){
		if(mod == 'bleedout') return super.DamageMobj(inflictor,source,damage,mod,flags,angle);
		
		if(mod == 'melee') mod = 'slashing';
		if(mod == 'hitscan' || mod == 'slashing') mod = 'penetrate';
		
		// saved so some of it can be applied as blunt force
		int olddamage = damage;
		let arm = PDArmor(FindInventory("PDArmor"));
		if(arm && mod == 'penetrate'){
			// absorb damage into armor
			// outer layer is a percent damage protection
			if(arm.mularmor > 0)
				damage *= (100.0 - arm.mularmor) / 100.0;
			float dmgtomul = olddamage - damage;
			// sub layer is a subtractive damage reduction
			if(arm.subarmor > 0)
				damage -= floor(arm.subarmor + 0.5);
			// *sometimes* can only be reduced to 1
			damage = max(damage,random(0,1));
			float dmgtosub = (olddamage - damage) - dmgtomul;
			
			if(PD_ArmorDebug) console.printf("player armor absorbed %.0f and %.0f damage",dmgtomul,dmgtosub);
			
			// slight flat bonus applied to damage to armor, as lots of small attacks
			// should still shred it up pretty bad
			
			// damages to both layers are also divided by their respective strength levels
			arm.mularmor -= (dmgtomul + random(0,1)) / arm.mulstrength;
			arm.mularmor = max(0,arm.mularmor);
			// if the armor still has its outer layer then that will reduce
			// damage to the sub layer for free
			if(arm.mularmor > 0)
				dmgtosub = max(dmgtosub + 1.0,0) / 1.8;
			arm.subarmor -= dmgtosub / arm.substrength;
			
			// if both layers are completely broken, the armor is destroyed
			if(arm.mularmor <= 4 && arm.subarmor <= 4){
				A_Log("\c[gold]YOUR ARMOR IS DESTROYED",true);
				TakeInventory("PDArmor",1);
			}
		}
		// these damagetypes are still *kinda* affected by armor, just not much
		if(arm && (mod == 'hot' || mod == 'normal' || mod == 'explosive' || mod == 'maul')){
			// half of mularmor is applied
			// for explosive damage only, all of mularmor is applied
			if(arm.mularmor > 1)
				damage *= (100.0 - (arm.mularmor / ((mod == 'explosve')?1.:2.))) / 100.0;
			// no damage is dealt to the armor
			
			// this damage is completely blocked, no blunt force is applied
			olddamage = damage;
		}
		
		// after absorbtion and before blunt force, damage is multiplied by the cvar
		damage *= PD_PlayerDamage;
		
		// no wounds will open when bearing any protection power
		if(mod == 'penetrate' || mod == 'maul' && !bNOBLOOD && !FindInventory("PowerProtection",true)){
			// wounding squares with damage; a huge hit is going to tear straight through
			// and obliterate the poor hit creature's blood volume very fast
			// wounding is exactly equal to incoming damage at 40 damage
			float towound = damage * damage / 40.0 + 1.0;
			if(inflictor is "PDPuff" && damage > 2){
				let pdb = PDPuff(inflictor);
				towound += pdb.extrawound * ((100.0 - arm.mularmor) / 100.0);
			}
			
			if(towound >= 1.0)
				openwounds += towound;
		}
		
		
		// pain is applied BEFORE blunt force damage
		// pain is scaled by damage to 0.8, getting shot HURTS but a larger
		// round will really just kill you deader, without proportionally more pain.
		// flat additive bonus per hit as more small hits will probably
		// hurt more than fewer larger hits.
		int topain = 1;
		if(damage > random(1,3)) topain = floor((damage ** 0.8) * 1.7) + 4;
		
		
		int aabsorbed = olddamage - damage;
		// no blunt force damage when bearing any protection power
		if(aabsorbed > 0 && !FindInventory("PowerProtection",true)){
			// blunt force damage squares with absorbed damage
			// fortunately it's divided by 10 *before square*
			// and causes no wounding
			// this should definitely be a float
			float bluntforce = aabsorbed / 10. + 1.0;
			bluntforce *= bluntforce;
			// blunt force will never be higher than 2/3 of total absorbed damage
			bluntforce = min(bluntforce,aabsorbed * (2./3.));
			
			if(PD_ArmorDebug) console.printf("net blunt force damage: %.0f (absorbed "..aabsorbed..")",bluntforce);
			
			// if you're above 10 hp then blunt force damage will never outright kill you on its own
			// it will only bring you as low as 15 hp unless you start the attack below 10 hp
			if(health > 10){
				bluntforce = min(bluntforce,health - damage - 15);
			}
			
			// blunt force will never be lower than 2
			// yes technically if like exactly 1 point of damage is absorbed then it
			// will actually make the total damage worse
			// ...by one point lol I don't care
			bluntforce = max(bluntforce,2);
			
			damage += floor(bluntforce);
			topain += floor(bluntforce ** 0.8);
		}
		
		// stun increases more when you're already disoriented
		// flat subtractive malus per hit so as to favor individual hits over
		// mass amounts like buckshot.
		int tostun = floor(stun * 0.1) + floor(sqrt(pain) * 0.2) + (damage * 1.2) - 6;
		// 1/3 of absorbed is added to stun, to replace any missing damage from armor absorbtion
		if(aabsorbed > 0)
			tostun += aabsorbed / 3 + 1;
				
		int dmgout = super.DamageMobj(inflictor,source,damage,mod,flags,angle);
		if(PD_PainStun){
			pain += topain;
			if(!FindInventory("PowerProtection",true))
				stun += tostun;
			// cap both at 100
			pain = min(pain,100);
			stun = min(stun,100);
		}
		
		// health to regenerate to is 9 + half of damage (up to the total damage) + an additional point for every 6 hp missing
		// plus a flat extra 4 points higher
		regenhealth = health + min(9 + damage / 2,damage) + ((100 - health) / 6) + 4;
		regenhealth = min(regenhealth,100);
		
		A_SetBlend(0x990000,dmgout / 60.0 + 0.2,dmgout * 0.5);
		
		return dmgout;
	}
	
	void PDPSetSpeed(){
		double speedf = 1.0;
		double runspeedf = 1.0; // applied *on top of* speed penalties to runspeed
		
		// move 30% slower when severely injured
		if(health < 35){
			speedf *= 0.8;
			runspeedf *= 0.85;
		}
		
		// move slower based on stun
		if(stun >= 15){
			// 0.75% speed decrease per point of stun, plus a baseline 15% decrease for being stunned at all
			speedf *= 1.0 - ( (stun * 0.0075) + 0.15 );
			// 1% runspeed decrease per point over 15 as well
			runspeedf *= 1.0 - ( (stun - 15) * 0.01 );
		}
		
		// move slower when carrying more
		if(PD_Encumberance){
			// every point of stun adds some encumberance
			int enc = PDPEncumberance() + (stun / 15);
			enc = max(0,enc - 9);
			
			// if under the effects of stims, encumberance limits set in 2 points higher
			if(stimulation) enc = max(0,enc - 2);
			
			// 4% speed penalty per point of encumberance above 9 up to 22
			speedf *= 1.0 - (min(enc,13) * 0.04);
			// additional 3.5% running speed penalty per point above 15 up to 22
			if(enc > 6){
				runspeedf *= 1.0 - ((min(enc,13) - 4) * 0.035);
			}
		}
		
		if(player.readyweapon){
			// move 30% slower when twohanding or reloading a twohanded weapon
			if(twohanding || player.readyweapon.curstate.InStateSequence(player.readyweapon.ResolveState("reloading"))){
				speedf *= 0.7;
				runspeedf *= 0.875;
			}
		}
		
		// armor movement penalty
		let arm = PDArmor(FindInventory("PDArmor"));
		if(arm){
			speedf *= 1.0 - arm.speedpenalty;
		}
		
		// being at/very near full health cuts movespeed penalties in half
		if(player.health >= 96){
			speedf = (speedf + 1.) / 2.;
		}
		
		// stims increase movement speed by 15%
		if(stimulation > 0) speedf *= 1.15;
		
		// walking movespeed penalties are cut to 2/3 for forward runspeed
		double speedf2 = (speedf + 0.5) / 1.5;
		
		// these things completely disable running
		if(
			health < 20
			|| stun >= 30
		){
			runspeedf = 0.5;
		}
		
		ForwardMove1 = 0.6 * speedf;
		ForwardMove2 = 0.395 * speedf2 * runspeedf;
		SideMove1 = 0.55 * speedf;
		SideMove2 = 0.315 * speedf * runspeedf;
	}
	
	static const class<inventory> BURDEN_ITEMS[] = {
		"PDPistolAmmo",
		"PDShotgunAmmo",
		"PDRifleAmmo",
		"PDRocketAmmo",
		"PDBatteryAmmo",
		"PDFragAmmo",
		"PDStimpack",
		"PDMedikit",
		"PDPistol",
		"PDPumpShotgun",
		"PDDoubleShotgun",
		"PDKVector",
		"PDSIG",
		"PDFamas",
		"PDMachinegun",
		"PDKastet",
		"PDPLAS"//, more to come laterrrrr :3
	};
	// I wish there was a way to enumerate on the entire inventory...
	// hey turns out there is I'm just stupid
	clearscope int PDPEncumberance(){
		int totalenc = 1;
		for(int i = 0;i < BURDEN_ITEMS_CNT;i++){
			class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[i];
			let item = FindInventory(classn);
			
			if(!item) continue;
			
			if(item is "ammo"){
				let amm = ammo(item);
				// ammo encumberance is from 1 at 50% to its "mass" at (or near) 100%
				// plus one for having the ammo at all
				// backpack max amount isn't used for this so you *will* overencumber
				// yourself if you fill all the way up
				if(!amm.bISHEALTH){
					// ammo
					if(amm.amount > 0)
						totalenc += 1;
					double amt = amm.amount / (amm.maxamount / 1.0);
					amt *= 2.;
					amt -= 1.;
					if(amt > 0)
						totalenc += floor(amm.mass * amt + 0.99);
				}else{
					// medical supplies
					// for med supplies, "mass" is how many of the item make 1 point of encumberance
					totalenc += floor(amm.amount / amm.mass);
				}
			}else{
				if(item is "PDWeapon"){
					let pdw = PDWeapon(item);
					// weapon encumberance is its masses multiplied
					int weaponenc = floor(pdw.transmass * pdw.rotamass);
					// mass above 4 is halved
					if(weaponenc > 4) weaponenc -= (weaponenc - 4) / 2;
					totalenc += weaponenc;
				}
			}
		}
		
		return totalenc;
	}
	states{
	pain.bleedout:
		PLAY G 8;
		goto spawn;
	death.bleedout:
		TNT1 A 0{ deathsound = ""; }
		goto death;
	}
}
const BURDEN_ITEMS_CNT = 17;
const BURDEN_AMMO_CNT = 6;
const BURDEN_MEDS_CNT = 2;

// starting loadouts
class PDPArmor:PDPlayerPawn{
	default{
		player.displayname "Pistol start";
		
		player.startitem "PDPistol";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDFragAmmo",2;
		player.startitem "PDMedikit",4;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPVector:PDPlayerPawn{
	default{
		player.displayname "SMG start";
		
		player.startitem "PDKVector";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",99;
		player.startitem "PDFragAmmo",3;
		player.startitem "PDMedikit",4;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPShot:PDPlayerPawn{
	default{
		player.displayname "Shotgun start";
		
		player.startitem "PDPumpShotgun";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDShotgunAmmo",18;
		player.startitem "PDFragAmmo",3;
		player.startitem "PDMedikit",4;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPSIG:PDPlayerPawn{
	default{
		player.displayname "Rifle start";
		
		player.startitem "PDSIG";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDRifleAmmo",90;
		player.startitem "PDFragAmmo",4;
		player.startitem "PDMedikit",4;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPKastet:PDPlayerPawn{
	default{
		player.displayname "Rocketeer";
		
		player.startitem "PDKastet";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",45;
		player.startitem "PDRocketAmmo",10;
		player.startitem "PDMedikit",4;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPMGun:PDPlayerPawn{
	default{
		player.displayname "Machinegunner";
		
		player.startitem "PDMachinegun";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDRifleAmmo",160;
		player.startitem "PDMedikit",4;
		player.startitem "PDBlueArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}
class PDPPlas:PDPlayerPawn{
	default{
		player.displayname "Energy Specialist";
		
		player.startitem "PDPLAS";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDBatteryAmmo",6;
		player.startitem "PDMedikit",4;
		player.startitem "PDBlueArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		player.startitem "PDKastetLoaded",1;
		player.startitem "PDPLASLoaded",100;
	}
}

class PD_InputOverrideHander:staticeventhandler{
	/*
	override bool InputProcess(inputevent e){
		// if we're trying to twohand the weapon:
		if(e.keyscan == InputEvent.Key_Pad_RThumb){
			let player = players[consoleplayer];
			// block the input if our offhand isn't empty
			if(player.offhandweapon && ~(player.offhandweapon is "PDEmptyOffhand")) return true;
		}
		
		return false;
	}
	*/
}