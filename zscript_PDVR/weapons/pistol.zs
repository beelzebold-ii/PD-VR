// surprisingly fun!
class PDPistol:PDWeapon replaces pistol{
	default{
		weapon.AmmoType "PDPistolLoaded";
		weapon.AmmoType2 "PDPistolAmmo";
		weapon.AmmoGive2 15;
		weapon.SlotNumber 2;
		tag "Beretta 92FS";
		
		PDWeapon.mass 1.0,1.5;
		PDWeapon.sprite 'PISG';
	}
	
	states{
	spawn:
		PIST A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		TNT1 A 1 A_Raise(12);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		TNT1 A 1 A_Lower(9);
		loop;
		
	ready:
		TNT1 A 1{
			if(countinv("PDPistolLoaded") > 0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
		}
		loop;
	fire:
		TNT1 A 2{
			A_AlertMonsters(2048 * frandom(1.0,1.5));
			A_PDBulletAttack(0.8,0.8,1,10 * random(1,2),"PDPistolPuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(2.,2.,false,0);
			A_TakeInventory("PDPistolLoaded",1,TIF_NOTAKEINFINITE);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
	hold:
		TNT1 A 1;
		TNT1 A 1 A_Refire("hold");
		goto ready;
	
	// reload states
	reload:
	altfire:
		TNT1 A 10;
		TNT1 A 1{
			if(countinv("PDPistolLoaded") >= 15) return resolvestate("reloadend");
			if(countinv("PDPistolLoaded") > 1)
				A_TakeInventory("PDPistolLoaded",countinv("PDPistolLoaded") - 1);
			if(countinv("PDPistolAmmo") > 0){
				A_SelectWeapon("PDMagHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		TNT1 A 1{
			if(invoker.pdp.RoomscaleDistance(3.0,-3.0) < 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = min(15,countinv("PDPistolAmmo"));
				A_GiveInventory("PDPistolLoaded",toreload);
				A_TakeInventory("PDPistolAmmo",toreload,TIF_NOTAKEINFINITE);
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

class PDPistolLoaded:ammo{
	default{
		inventory.MaxAmount 16;
	}
}