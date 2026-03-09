// squishy little bitch
class PDPlayerPawn:doomplayer{
	bool twohanding;
	
	PDWeaponPos weaponmodel;
	
	int usetics; // timer for holding the use key to display inventory stuff
	
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
		
		//player.startitem "PDEmptyOffhand";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
		
		radius 10;
	}
	
	override void PostBeginPlay(){
		super.PostBeginPlay();
		GiveInventory("PDEmptyOffhand",1);
		A_SelectWeapon("PDEmptyOffhand");
		
		GiveInventory("PDInvManager",1);
		
		GiveInventory("PDMagHand",1);
		GiveInventory("PDShellHand",1);
		GiveInventory("PD2ShellHand",1);
		GiveInventory("PDAmmoBoxHand",1);
		
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
		if(!(source is "PDMonster")){
			damage *= 1.5;
		}
		
		if(mod == 'hitscan' || mod == 'melee') mod = 'penetrate';
		
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
			arm.mularmor -= (dmgtomul+1) / arm.mulstrength;
			// if the armor still has its outer layer then that will reduce
			// damage to the sub layer for free
			if(arm.mularmor >= 0)
				dmgtosub = max(dmgtosub + 1.0,0) / 1.8;
			arm.subarmor -= dmgtosub / arm.substrength;
			
			// if both layers are completely broken, the armor is destroyed
			if(arm.mularmor <= 1 && arm.subarmor <= 1){
				A_Log("\c[gold]YOUR ARMOR IS DESTROYED",true);
				TakeInventory("PDArmor",1);
			}
		}
		
		// after absorbtion and before blunt force, damage is multiplied by the cvar
		damage *= PD_PlayerDamage;
		
		// later
		/*
		if(mod == 'penetrate' && !bNOBLOOD){
			// wounding squares with damage; a huge hit is going to tear straight through
			// and obliterate the poor hit creature's blood volume very fast
			// wounding is exactly equal to incoming damage at 40 damage
			float towound = damage * damage / 40.0;
			if(inflictor is "PDPuff"){
				let pdb = PDPuff(inflictor);
				towound += pdb.extrawound;
			}
			
			if(towound >= 1.0)
				openwounds += towound;
		}
		*/
		
		int aabsorbed = olddamage - damage;
		if(aabsorbed > 0){
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
		}
		
		//if(PD_DamageDebug) console.printf(source.GetClassName().." hit "..GetClassName().." for "..damage.." "..mod.." dmg, "..topain.." pain, and "..tostun.." stun");
		
		int dmgout = super.DamageMobj(inflictor,source,damage,mod,flags,angle);
		
		A_SetBlend(0x990000,dmgout / 60.0 + 0.2,dmgout * 1.5);
		
		return dmgout;
	}
	
	override void tick(){
		super.Tick();
		// detect if the mainhand weapon is currently being stabilized by the offhand
		twohanding = player.WeaponState & WF_TWOHANDSTABILIZED;
		
		// get roomscale gesture values
		RoomscaleTick();
		
		// strip vanilla armor if for some reason we have any
		let varm = FindInventory("armor",true);
		if(varm) varm.destroy();
		
		PDPSetSpeed();
		
		bool pressuse = player.cmd.buttons & BT_USE;
		if(pressuse){
			if(usetics < 35)
				usetics++;
		}else{
			if(usetics > 0)
				usetics--;
		}
	}
	
	void PDPSetSpeed(){
		double speedf = 1.0;
		double runspeedf = 1.0; // applied *on top of* speed penalties to runspeed
		
		// move 20% slower when severely injured
		if(health < 25){
			speedf *= 0.8;
			runspeedf *= 0.85;
		}
		
		// move slower when carrying more
		if(PD_Encumberance){
			int enc = PDPEncumberance();
			enc = max(0,enc - 7);
			
			// 6% speed penalty per point of encumberance above 7 up to 12
			speedf *= 1.0 - (min(enc,5) * 0.06);
			// additional 4% running speed penalty per point above 10 up to 16
			if(enc > 3){
				runspeedf *= 1.0 - ((min(enc,9) - 3) * 0.04);
			}
		}
		
		if(player.readyweapon){
			// move 15% slower when twohanding or reloading a twohanded weapon
			if(twohanding || player.readyweapon.curstate.InStateSequence(player.readyweapon.ResolveState("reloading")))
				speedf *= 0.85;
		}
		
		// armor movement penalty
		let arm = PDArmor(FindInventory("PDArmor"));
		if(arm){
			speedf *= 1.0 - arm.speedpenalty;
		}
		
		// walking movespeed penalties are cut to 2/3 for forward runspeed
		double speedf2 = (speedf + 0.5) / 1.5;
		
		ForwardMove1 = 0.6 * speedf;
		ForwardMove2 = 0.395 * speedf2 * runspeedf;
		SideMove1 = 0.55 * speedf;
		SideMove2 = 0.325 * speedf * runspeedf;
	}
	
	static const class<inventory> BURDEN_ITEMS[] = {
		"PDPistolAmmo",
		"PDShotgunAmmo",
		"PDRifleAmmo",
		"PDPistol",
		"PDPumpShotgun",
		"PDDoubleShotgun",
		"PDKVector",
		"PDSIG",
		"PDFamas",
		"PDMachinegun"//, more to come laterrrrr :3
	};
	// I wish there was a way to enumerate on the entire inventory...
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
				totalenc += 1;
				double amt = amm.amount / (amm.maxamount / 1.0);
				amt *= 2.;
				amt -= 1.;
				if(amt > 0)
					totalenc += floor(amm.mass * amt + 0.99);
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
}
const BURDEN_ITEMS_CNT = 10;

// starting loadouts
class PDPArmor:PDPlayerPawn{
	default{
		player.displayname "Pistol start";
		
		player.startitem "PDPistol";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
	}
}
class PDPVector:PDPlayerPawn{
	default{
		player.displayname "SMG start";
		
		player.startitem "PDKVector";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",66;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
	}
}
class PDPShot:PDPlayerPawn{
	default{
		player.displayname "Shotgun start";
		
		player.startitem "PDPumpShotgun";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDShotgunAmmo",16;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
	}
}
class PDPSIG:PDPlayerPawn{
	default{
		player.displayname "Rifle start";
		
		player.startitem "PDSIG";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDRifleAmmo",60;
		player.startitem "PDGreenArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
	}
}
class PDPMGun:PDPlayerPawn{
	default{
		player.displayname "Chaingun start";
		
		player.startitem "PDMachinegun";
		player.startitem "PDEmptyOnhand";
		player.startitem "PDPistol";
		player.startitem "PDPistolAmmo",30;
		player.startitem "PDRifleAmmo",160;
		player.startitem "PDBlueArmorGiver";
		
		player.startitem "PDPistolLoaded",15;
		player.startitem "PDPumpShotLoaded",7;
		player.startitem "PDDoubleShotLoaded",2;
		player.startitem "PDSMGLoaded",33;
		player.startitem "PDSIGLoaded",30;
		player.startitem "PDFamasLoaded",30;
		player.startitem "PDMGunLoaded",80;
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