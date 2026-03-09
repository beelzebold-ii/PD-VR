// chaingun! to hell with respect!
class PDMachinegun:PDWeapon{
	default{
		weapon.AmmoType "PDMGunLoaded";
		weapon.AmmoType2 "PDRifleAmmo";
		weapon.AmmoGive2 80;
		weapon.SlotNumber 5;
		tag "Machinegun";
		
		PDWeapon.mass 2.45,3.25;
		PDWeapon.twohanded true;
		PDWeapon.pitchoffs 16.0;
	}
	bool spinning;
	states{
	spawn:
		MGUN A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		CHGG A 1 A_Raise(3);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		CHGG A 1 A_Lower(3);
		loop;
		
	ready:
		CHGG A 1{
			invoker.spinning = false;
			if(countinv("PDMGunLoaded") > 0)
				A_TwoHandsWeaponReady();
			else
				A_TwoHandsWeaponReady(WRF_NOPRIMARY);
		}
		CHGG A 0 A_JumpIf(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK,"spinup");
		loop;
	spinup:
		CHGG BA 5;
		CHGG BA 3;
		CHGG BA 2;
	readyspin:
		CHGG BA 1{
			invoker.spinning = true;
			if(countinv("PDMGunLoaded") > 0)
				A_TwoHandsWeaponReady(WRF_DISABLESWITCH|WRF_NOSECONDARY);
		}
		CHGG A 0{invoker.spinning = false;}
		CHGG A 0 A_JumpIf(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK,"readyspin");
		goto spindown;
	fire:
		CHGG A 0 A_JumpIf(invoker.spinning,"hold");
		CHGG BA 5;
		CHGG BA 3;
		CHGG BA 2;
	hold:
		CHGG B 1{
			A_AlertMonsters(2048 * frandom(1.0,1.5));
			A_PDBulletAttack(0.6,0.6,1,11 * random(2,4),"PDRiflePuff",flags:CBAF_NORANDOM);
			A_MuzzleClimb(1.,0.37,true,0);
			A_TakeInventory("PDMGunLoaded",1);
			A_PlaySound("weapons/pistol",CHAN_WEAPON);
		}
		CHGG A 1 A_JumpIf(countinv("PDMGunLoaded") < 1,"spindown");
		CHGG B 1 A_Refire("hold");
		CHGG A 1 A_JumpIf(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK,"readyspin");
	spindown:
		CHGG ABBAAABBBAAAABBBBA 2;
		goto ready;
	
	// reload states
	reload:
	altfire:
		CHGG A 1{
			if(countinv("PDMGunLoaded") >= 80) return resolvestate("reloadend");
			if(countinv("PDMGunLoaded") > 5)
				A_TakeInventory("PDMGunLoaded",countinv("PDMGunLoaded") - 5);
			if(countinv("PDRifleAmmo") > 0){
				A_SelectWeapon("PDAmmoBoxHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		CHGG A 1{
			if(abs(invoker.pdp.handdist - 4.0) <= 4.0 && invoker.pdp.lateralhanddist <= 5.0 && abs(invoker.pdp.verticalhanddist - 2.0) <= 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = min(80,countinv("PDRifleAmmo"));
				A_GiveInventory("PDMGunLoaded",toreload);
				A_TakeInventory("PDRifleAmmo",toreload,TIF_NOTAKEINFINITE);
				A_SelectWeapon("PDEmptyOffhand");
				return resolvestate("reloadend");
			}
			return resolvestate(null);
		}
		loop;
	reloadend:
		CHGG A 20;
		goto spindown;
	}
}

class PDMGunLoaded:ammo{
	default{
		inventory.MaxAmount 85;
	}
}