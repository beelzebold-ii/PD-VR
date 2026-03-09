// excuse me there's nothing "sub" about me
class PDKVector:PDWeapon{
	default{
		weapon.AmmoType "PDSMGLoaded";
		weapon.AmmoType2 "PDPistolAmmo";
		weapon.AmmoGive2 33;
		weapon.SlotNumber 4;
		tag "Vector";
		
		PDWeapon.mass 1.45,1.35;
		PDWeapon.twohanded true;
	}
	states{
	spawn:
		KVEC A -1;
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
			if(countinv("PDSMGLoaded") > 0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
		}
		loop;
	fire:
		PISG B 1{
			A_AlertMonsters(2048 * frandom(1.0,1.5));
			A_PDBulletAttack(0.6,0.6,1,10,"PDPistolPuff");
			A_MuzzleClimb(1.0,0.1,false);
			A_TakeInventory("PDSMGLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		PISG A 1 A_JumpIf(countinv("PDSMGLoaded") < 1,"ready");
		PISG A 1 A_Refire("hold");
		goto ready;
	
	// reload states
	reload:
	altfire:
		PISG A 1{
			if(countinv("PDSMGLoaded") >= 33) return resolvestate("reloadend");
			if(countinv("PDSMGLoaded") > 1)
				A_TakeInventory("PDSMGLoaded",countinv("PDSMGLoaded") - 1);
			if(countinv("PDPistolAmmo") > 0){
				A_SelectWeapon("PDMagHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		PISG A 1{
			if(abs(invoker.pdp.handdist - 4.0) <= 4.0 && invoker.pdp.lateralhanddist <= 3.0 && abs(invoker.pdp.verticalhanddist + 1.0) <= 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = min(33,countinv("PDPistolAmmo"));
				A_GiveInventory("PDSMGLoaded",toreload);
				A_TakeInventory("PDPistolAmmo",toreload,TIF_NOTAKEINFINITE);
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

class PDSMGLoaded:ammo{
	default{
		inventory.MaxAmount 34;
	}
}