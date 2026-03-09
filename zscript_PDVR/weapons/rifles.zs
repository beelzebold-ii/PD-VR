// there are many like it. this one's not mine no I just found it on the floor
class PDSIG:PDWeapon{
	bool semi;
	
	default{
		weapon.AmmoType "PDSIGLoaded";
		weapon.AmmoType2 "PDRifleAmmo";
		weapon.AmmoGive2 30;
		weapon.SlotNumber 4;
		tag "SIG 552";
		
		PDWeapon.mass 1.5,2.5;
		PDWeapon.twohanded true;
	}
	states{
	spawn:
		S552 A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		PISG A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		PISG A 1 A_Lower(7);
		loop;
		
	ready:
		PISG A 1{
			if(countinv("PDSIGLoaded") > 0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
			
			if(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK){
				A_SetTics(10);
				frame = 1;
				invoker.semi = !invoker.semi;
			}
		}
		loop;
	fire:
		PISG B 2{
			A_AlertMonsters(2048 * frandom(1.25,1.75));
			A_PDBulletAttack(0.4,0.4,1,12 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(2.5,0.4,true,8);
			A_TakeInventory("PDSIGLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		PISG A 0 A_JumpIf(invoker.semi,"hold2");
		PISG A 1 A_JumpIf(countinv("PDSIGLoaded") < 1,"ready");
		PISG A 1 A_Refire("hold");
		goto ready;
	hold:
		PISG B 2{
			A_AlertMonsters(2048 * frandom(1.75,2.0));
			A_PDBulletAttack(0.55,0.55,1,12 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_TakeInventory("PDSIGLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		PISG A 1 A_JumpIf(countinv("PDSIGLoaded") < 1,"ready");
		PISG A 1 A_Refire("hold");
		goto ready;
	hold2:
		PISG B 1;
		PISG B 1 A_Refire("hold2");
		goto ready;
		
	// reload states
	reload:
	altfire:
		PISG A 1{
			if(countinv("PDSIGLoaded") >= 30) return resolvestate("reloadend");
			if(countinv("PDSIGLoaded") > 1)
				A_TakeInventory("PDSIGLoaded",countinv("PDSIGLoaded") - 1);
			if(countinv("PDRifleAmmo") > 0){
				A_SelectWeapon("PDMagHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		PISG A 1{
			if(abs(invoker.pdp.handdist - 6.0) <= 4.0 && invoker.pdp.lateralhanddist <= 3.0 && abs(invoker.pdp.verticalhanddist + 1.0) <= 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = min(30,countinv("PDRifleAmmo"));
				A_GiveInventory("PDSIGLoaded",toreload);
				A_TakeInventory("PDRifleAmmo",toreload,TIF_NOTAKEINFINITE);
				A_SelectWeapon("PDEmptyOffhand");
				return resolvestate("reloadend");
			}
			return resolvestate(null);
		}
		loop;
	reloadend:
		PISG B 12;
		PISG A 2;
		goto ready;
	}
}

class PDSIGLoaded:ammo{
	default{
		inventory.MaxAmount 31;
	}
}

class PDFamas:PDWeapon{
	bool semi;
	
	default{
		weapon.AmmoType "PDFamasLoaded";
		weapon.AmmoType2 "PDRifleAmmo";
		weapon.AmmoGive2 30;
		weapon.SlotNumber 4;
		tag "FAMAS";
		
		PDWeapon.mass 1.9,2.2;
		PDWeapon.twohanded true;
	}
	states{
	spawn:
		FAMA S -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		PISG A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		PISG A 1 A_Lower(7);
		loop;
		
	ready:
		PISG A 1{
			if(countinv("PDFamasLoaded") > 0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
			
			if(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK){
				A_SetTics(10);
				frame = 1;
				invoker.semi = !invoker.semi;
			}
		}
		loop;
	fire:
		PISG B 1{
			A_AlertMonsters(2048 * frandom(1.25,1.55));
			A_PDBulletAttack(0.25,0.25,1,13 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(1.5,0.25,true);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		PISG A 0 A_JumpIf(invoker.semi,"hold2");
		PISG A 1 A_JumpIf(countinv("PDFamasLoaded") < 1,"ready");
		PISG A 0 A_Refire("hold");
		goto ready;
	hold:
		PISG B 1{
			A_AlertMonsters(2048 * frandom(1.35,1.85));
			A_PDBulletAttack(0.25,0.25,1,13 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(1.0,0.15,true);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		PISG A 1 A_JumpIf(countinv("PDFamasLoaded") < 1,"ready");
		PISG B 1{
			A_AlertMonsters(2048 * frandom(1.35,1.85));
			A_PDBulletAttack(0.3,0.3,1,13 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(2.5,0.5,true,10);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
	hold2:
		PISG B 1;
		PISG B 1 A_Refire("hold2");
		goto ready;
	
	// reload states
	reload:
	altfire:
		PISG A 1{
			if(countinv("PDFamasLoaded") >= 30) return resolvestate("reloadend");
			if(countinv("PDFamasLoaded") > 1)
				A_TakeInventory("PDFamasLoaded",countinv("PDFamasLoaded") - 1);
			if(countinv("PDRifleAmmo") > 0){
				A_SelectWeapon("PDMagHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		PISG A 1{
			if(abs(invoker.pdp.handdist + 8.0) <= 8.0 && invoker.pdp.lateralhanddist <= 6.0 && abs(invoker.pdp.verticalhanddist - 1.0) <= 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = min(30,countinv("PDRifleAmmo"));
				A_GiveInventory("PDFamasLoaded",toreload);
				A_TakeInventory("PDRifleAmmo",toreload,TIF_NOTAKEINFINITE);
				A_SelectWeapon("PDEmptyOffhand");
				return resolvestate("reloadend");
			}
			return resolvestate(null);
		}
		loop;
	reloadend:
		PISG B 12;
		PISG A 2;
		goto ready;
	}
}

class PDFamasLoaded:ammo{
	default{
		inventory.MaxAmount 31;
	}
}