// bloop
class PDKastet:PDWeapon{
	default{
		weapon.AmmoType "PDKastetLoaded";
		weapon.AmmoType2 "PDRocketAmmo";
		weapon.AmmoGive2 1;
		weapon.SlotNumber 5;
		tag "RGM-40";
		
		PDWeapon.mass 1.2,1.55;
	}
	
	states{
	spawn:
		RGMK A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		PISG A 1 A_Raise(6);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		PISG A 1 A_Lower(6);
		loop;
		
	ready:
		PISG A 1{
			if(countinv("PDKastetLoaded")>0)
				A_WeaponReady();
			else
				A_WeaponReady(WRF_NOPRIMARY);
		}
		loop;
	fire:
		PISG A 4{
			A_TakeInventory("PDKastetLoaded",1);
			A_AlertMonsters(2048 * frandom(1.3,1.7));
			let rkt = A_FireProjectile("PDRocket",0,false);
			rkt.A_ChangeVelocity(0,0,2);
			A_MuzzleClimb(4.,6.,true);
			A_PlaySound("weapons/rocklf",CHAN_WEAPON);
		}
		PISG A 1;
	hold:
		PISG A 1;
		PISG A 1 A_Refire("hold");
		goto ready;
	
	// reload states
	reload:
	altfire:
		PISG A 6;
		PISG A 4{
			if(countinv("PDKastetLoaded") >= 2) return resolvestate("reloadend");
			if(countinv("PDRocketAmmo") > 0){
				A_SelectWeapon("PDRocketHand");
				
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
		PISG A 8;
	reloading:
		PISG A 1{
			if(invoker.pdp.RoomscaleDistance(6.5,-0.33) < 2.5){
				A_StartSound("weapons/shotrack",CHAN_WEAPON);
				A_GiveInventory("PDKastetLoaded",1);
				A_TakeInventory("PDRocketAmmo",1,TIF_NOTAKEINFINITE);
				return resolvestate("reloadend");
			}
			
			return resolvestate(null);
		}
		loop;
	reloadend:
		PISG A 7{
			A_SelectWeapon("PDEmptyOffhand");
		}
		PISG A 2 A_CloseShotgun2();
		goto ready;
	}
}
class PDKastetLoaded:ammo{
	default{
		inventory.MaxAmount 1;
	}
}

// the mighty rocket.
class PDRocket:actor replaces rocket{
	default{
		PROJECTILE;
		+NOTIMEFREEZE;
		-NOGRAVITY;
		gravity 0.4;
		radius 4;
		height 7;
		speed 50;
		damagefunction (60 * random(4,6));
		Damagetype 'explosive';
		scale 0.4;
	}
	states{
	spawn:
		MISL A 1;
		loop;
	death:
		MISL A 0{
			bNOGRAVITY = true;
			A_SetScale(1.0);
			A_StartSound("weapons/rocklx",CHAN_AUTO);
			// full explosive damage
			A_Explode(random(160,220),200,XF_HURTSOURCE|XF_CIRCULAR,true,50);
			
			// shrapnel will just be approximated like this lmao
			A_Explode(random(65,80),500,(Distance3D(target)<random(300,500)?XF_HURTSOURCE:0)|XF_CIRCULAR,false,200,damagetype:'penetrate');
		}
		MISL BCD 4 bright;
		stop;
	}
}