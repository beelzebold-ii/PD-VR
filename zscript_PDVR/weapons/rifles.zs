// there are many like it. this one's not mine no I just found it on the floor
class PDSIG:PDWeapon{
	bool semi;
	
	override void DrawWeaponHud(){
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		statusbar.drawstring(monofont,semi?"SEMI":"FULL",(80,145));
	}
	
	default{
		weapon.AmmoType "PDSIGLoaded";
		weapon.AmmoType2 "PDRifleAmmo";
		weapon.AmmoGive2 30;
		weapon.SlotNumber 4;
		tag "SIG 552";
		
		PDWeapon.mass 1.5,2.5;
		PDWeapon.twohanded true;
		PDWeapon.sprite 'S552';
	}
	states{
	spawn:
		S552 A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		TNT1 A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		TNT1 A 1 A_Lower(7);
		loop;
		
	ready:
		TNT1 A 1{
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
		TNT1 A 2{
			A_AlertMonsters(2048 * frandom(1.25,1.75));
			A_PDBulletAttack(0.4,0.4,1,12 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(1.0,0.5,true,8);
			A_TakeInventory("PDSIGLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		TNT1 A 0 A_JumpIf(invoker.semi,"hold2");
		TNT1 A 1 A_JumpIf(countinv("PDSIGLoaded") < 1,"ready");
		TNT1 A 1 A_Refire("hold");
		goto ready;
	hold:
		TNT1 A 2{
			A_AlertMonsters(2048 * frandom(1.75,2.0));
			A_PDBulletAttack(0.55,0.55,1,12 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(0.2,0.5,true);
			A_TakeInventory("PDSIGLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		TNT1 A 1 A_JumpIf(countinv("PDSIGLoaded") < 1,"ready");
		TNT1 A 1 A_Refire("hold");
		goto ready;
	hold2:
		TNT1 A 1;
		TNT1 A 1 A_Refire("hold2");
		goto ready;
		
	// reload states
	reload:
	altfire:
		TNT1 A 10;
		TNT1 A 1{
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
		TNT1 A 1{
			if(invoker.pdp.RoomscaleDistance(5.0,-2.0) < 4.0){
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
		TNT1 A 12;
		TNT1 A 2;
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
	
	override void DrawWeaponHud(){
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		statusbar.drawstring(monofont,semi?"SEMI":"BURST",(80,145));
	}
	
	default{
		weapon.AmmoType "PDFamasLoaded";
		weapon.AmmoType2 "PDRifleAmmo";
		weapon.AmmoGive2 30;
		weapon.SlotNumber 4;
		tag "FAMAS";
		
		PDWeapon.mass 1.9,2.2;
		PDWeapon.twohanded true;
		PDWeapon.sprite 'FAMA';
	}
	states{
	spawn:
		FAMA S -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		TNT1 A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		TNT1 A 1 A_Lower(7);
		loop;
		
	ready:
		TNT1 A 1{
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
		TNT1 B 1{
			A_AlertMonsters(2048 * frandom(1.25,1.55));
			A_PDBulletAttack(0.25,0.25,1,14 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(1.0,0.2,true);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		TNT1 A 0 A_JumpIf(invoker.semi,"hold2");
		TNT1 A 1 A_JumpIf(countinv("PDFamasLoaded") < 1,"ready");
		TNT1 A 0 A_Refire("hold");
		goto ready;
	hold:
		TNT1 A 1{
			A_AlertMonsters(2048 * frandom(1.35,1.85));
			A_PDBulletAttack(0.25,0.25,1,14 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(0.5,0.10,true);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		TNT1 A 1 A_JumpIf(countinv("PDFamasLoaded") < 1,"ready");
		TNT1 A 1{
			A_AlertMonsters(2048 * frandom(1.35,1.85));
			A_PDBulletAttack(0.3,0.3,1,14 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(0.5,0.5,true,10);
			A_TakeInventory("PDFamasLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
	hold2:
		TNT1 A 1;
		TNT1 A 1 A_Refire("hold2");
		goto ready;
	
	// reload states
	reload:
	altfire:
		TNT1 A 10;
		TNT1 A 1{
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
		TNT1 A 1{
			if(invoker.pdp.RoomscaleDistance(-4.0,-4.0) < 5.0){
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
		TNT1 A 12;
		TNT1 A 2;
		goto ready;
	}
}

class PDFamasLoaded:ammo{
	default{
		inventory.MaxAmount 31;
	}
}