// groovy.
class PDPumpShotgun:PDWeapon{
	bool chambered;
	bool empty;
	// where the player's hand was when they first started pumping the shotgun
	// they've gotta go back 2 units and then make it back to the front
	// to complete the pumping gesture
	double pumpdist;
	override void BeginPlay(){
		chambered = true;
		empty = false;
		super.BeginPlay();
	}
	
	override inventory CreateTossable(int amt){
		inventory inv = super.CreateTossable(amt);
		PDPumpShotgun(inv).chambered = chambered;
		return inv;
	}
	
	default{
		// this just prevents an offhand weapon from being out which
		// we don't want for any weapon
		//+Weapon.TWOHANDED;
		
		weapon.AmmoType "PDPumpShotLoaded";
		weapon.AmmoType2 "PDShotgunAmmo";
		weapon.AmmoGive2 8;
		weapon.SlotNumber 3;
		tag "Pump Shotgun";
		
		PDWeapon.mass 1.5,2.2;
		PDWeapon.twohanded true;
	}
	
	states{
	spawn:
		SHOT A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		SHTG A 1 A_Raise(5);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		SHTG A 1 A_Lower(5);
		loop;
		
	ready:
		SHTG A 1{
			if(invoker.chambered)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
			
			if(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK){
				invoker.pumpdist = invoker.pdp.handdist;
				return resolvestate("startpump");
			}
			return resolvestate(null);
		}
		loop;
	fire:
		SHTG B 4{
			invoker.chambered = false;
			A_AlertMonsters(3072 * frandom(1.0,1.5));
			A_PDBulletAttack(1.7,1.4,12,5,"PDPelletPuff");
			A_MuzzleClimb(4.,5.,true);
			A_PlaySound("weapons/shotgun",CHAN_WEAPON);
		}
		SHTG A 3;
	hold:
		SHTG A 1;
		SHTG A 1 A_Refire("hold");
		goto ready;
	
	startpump:
		SHTG A 1{
			if(!(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK)){
				return resolvestate("ready");
			}else{
				if(invoker.pdp.handdist <= invoker.pumpdist - 2.0){
					if(!invoker.empty){
						if(!invoker.chambered)
							A_FireProjectile("PDEjectedShell",90,false,pitch:frandom(-65.,-40.));
						else
							A_GiveInventory("PDShotgunAmmo",1);
					}
					invoker.chambered = false;
					invoker.empty = true;
					A_PlaySound("weapons/shotrack",CHAN_WEAPON);
					return resolvestate("pumpback");
				}
			}
			return resolvestate(null);
		}
		loop;
	pumpback:
		SHTG C 1{
			// letting go of offhand attack won't abort at this stage, the only thing that will is
			// completely taking your hand off the gun
			if(!invoker.pdp.twohanding){
				return resolvestate("ready");
			}else{
				//give the player a 1.33 unit grace where it'll snap forward
				//to avoid accidental aborts
				if(invoker.pdp.handdist >= invoker.pumpdist - 1.33){
					if(countinv("PDPumpShotLoaded")>0){
						invoker.chambered = true;
						invoker.empty = false;
						A_TakeInventory("PDPumpShotLoaded",1);
					}
					A_PlaySound("weapons/shotrack",CHAN_WEAPON);
					return player.cmd.buttons & BT_OFFHANDATTACK?resolvestate("startpump"):resolvestate("ready");
				}
			}
			return resolvestate(null);
		}
		loop;
	
	// reload states
	reload:
	altfire:
		SHTG A 1{
			if(countinv("PDPumpShotLoaded") >= 7) return resolvestate("reloadend");
			if(countinv("PDShotgunAmmo") > 0){
				A_SelectWeapon("PDShellHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
		SHTG A 2;
	reloading:
		SHTG A 1{
			if(abs(invoker.pdp.handdist - 1.0) <= 4.0 && invoker.pdp.lateralhanddist <= 3.0 && abs(invoker.pdp.verticalhanddist + 1.0) <= 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				A_GiveInventory("PDPumpShotLoaded",1);
				A_TakeInventory("PDShotgunAmmo",1,TIF_NOTAKEINFINITE);
				return resolvestate("reloaddelay");
			}
			
			if(player.cmd.buttons & BT_ATTACK || player.cmd.buttons & BT_OFFHANDATTACK) return resolvestate("reloadend");
			
			return resolvestate(null);
		}
		loop;
	reloaddelay:
		SHTG B 14{
			if(countinv("PDPumpShotLoaded") >= 7 || countinv("PDShotgunAmmo") < 1){
				return resolvestate("reloadend");
			}
			return resolvestate(null);
		}
		SHTG A 3;
		goto reloading;
	reloadend:
		SHTG B 12{
			A_SelectWeapon("PDEmptyOffhand");
		}
		SHTG A 2;
		goto ready;
	}
}
class PDPumpShotLoaded:ammo{
	default{
		inventory.MaxAmount 7;
	}
}


// almost as groovy
class PDDoubleShotgun:PDWeapon replaces SuperShotgun{
	default{
		weapon.AmmoType "PDDoubleShotLoaded";
		weapon.AmmoType2 "PDShotgunAmmo";
		weapon.AmmoGive2 8;
		weapon.SlotNumber 3;
		tag "Double Shotgun";
		
		PDWeapon.mass 1.2,2.0;
		PDWeapon.twohanded true;
	}
	
	states{
	spawn:
		SGN2 A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		SHT2 A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		SHT2 A 1 A_Lower(6);
		loop;
		
	ready:
		SHT2 A 1{
			if(countinv("PDDoubleShotLoaded")>0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
		}
		loop;
	fire:
		SHT2 B 4{
			A_TakeInventory("PDDoubleShotLoaded",1);
			A_AlertMonsters(3072 * frandom(1.3,1.7));
			A_PDBulletAttack(2.2,2.0,12,7,"PDPelletPuff");
			A_MuzzleClimb(5.,6.,true);
			A_PlaySound("weapons/shotgun",CHAN_WEAPON);
		}
		SHT2 A 1;
	hold:
		SHT2 A 1;
		SHT2 A 1 A_Refire("hold");
		goto ready;
	
	// reload states
	reload:
	altfire:
		SHT2 B 6;
		SHT2 A 4{
			if(countinv("PDDoubleShotLoaded") >= 2) return resolvestate("reloadend");
			if(countinv("PDShotgunAmmo") > 1){
				A_OpenShotgun2();
				
				A_SelectWeapon("PD2ShellHand");
				// give the player the remaining shell
				if(countinv("PDDoubleShotLoaded") > 0)
					A_GiveInventory("PDShotgunAmmo",countinv("PDDoubleShotLoaded"));
				// eject spent shells
				A_FireProjectile("PDEjectedShell",170,false,pitch:-frandom(-75.,-60.));
				if(countinv("PDDoubleShotLoaded") <= 0)
					A_FireProjectile("PDEjectedShell",-170,false,pitch:-frandom(-75.,-60.));
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
		SHT2 C 8;
	reloading:
		SHT2 C 1{
			if(abs(invoker.pdp.handdist + 1.0) <= 3.0 && invoker.pdp.lateralhanddist <= 3.0 && abs(invoker.pdp.verticalhanddist + 4.0) <= 5.0){
				A_PlaySound("weapons/sshotl",CHAN_WEAPON);
				A_GiveInventory("PDDoubleShotLoaded",2);
				A_TakeInventory("PDShotgunAmmo",2,TIF_NOTAKEINFINITE);
				return resolvestate("reloadend");
			}
			
			return resolvestate(null);
		}
		loop;
	reloadend:
		SHT2 B 12{
			A_SelectWeapon("PDEmptyOffhand");
		}
		SHT2 A 2 A_CloseShotgun2();
		goto ready;
	}
}
class PDDoubleShotLoaded:ammo{
	default{
		inventory.MaxAmount 2;
	}
}



class PDEjectedShell:actor{
	default{
		gravity 0.45;
		projectile;
		speed 2;
		-NOGRAVITY;
		+BOUNCEONWALLS;
		+NOBLOCKMAP;
		+THRUACTORS;
		scale 0.3;
		
		radius 2;
		height 4;
	}
	states{
	spawn:
		SHEL BC 6 A_CheckFloor("landed");
		SHEL # 0{
			bYFLIP = !bYFLIP;
			bXFLIP = !bXFLIP;
		}
		loop;
	spawn2:
		SHEL BC 3;
	spawn3:
		SHEL BC 3 A_CheckFloor("staylanded");
		SHEL # 0{
			bYFLIP = !bYFLIP;
			bXFLIP = !bXFLIP;
		}
		loop;
	death:
	landed:
		SHEL C 0{
			if(!random(0,1)){
				A_PlaySound("weapons/sshoto",CHAN_AUTO,0.4,pitch:1.2);
				bYFLIP = !bYFLIP;
				bXFLIP = !bXFLIP;
				A_ChangeVelocity(4,0,2,CVF_RELATIVE|CVF_REPLACE);
				return resolvestate("spawn2");
			}
			return resolvestate(null);
		}
	staylanded:
		SHEL C 0 A_PlaySound("weapons/sshotl",CHAN_AUTO,0.4,pitch:1.2);
		SHEL CC 350;
	fadeout:
		SHEL C 12 A_FadeOut();
		loop;
	}
}