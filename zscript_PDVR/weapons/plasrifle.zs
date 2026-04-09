// PLAS - Pulse Laser Armament System
// MIPL - Multipurpose Infantry Pulse Laser
// I think I'll stick with PLAS rifle (not a rifle)
class PDPLAS:PDWeapon replaces plasmarifle{
	static const color PLAS_COLORS[] = {
		0x2277aa,
		0x3355bb,
		0x4455bb,
		0x5555cc,
		0x6655dd,
		0x7744ee,
		0x7733ff, // my most beloved purple color
		0x7744ee,
		0x8833ff,
		0x8833ff
	};
	
	int charge;
	
	override void DrawWeaponHud(){
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		//statusbar.fill(0x3344ff,80,135,3 + charge * 4,20); // why no worky?
		statusbar.drawstring(monofont,"CHARGE: "..charge,(55,135));
	}
	
	// create the laser tracer
	action void A_LaserFX(int charge){
		let pdp = PDPlayerPawn(invoker.owner);
		
		vector3 particlestep;
		particlestep.xy = AngleToVector(pdp.weaponmodel.angle);
		vector2 atvp = AngleToVector(pdp.weaponmodel.pitch);
		particlestep.z = -atvp.y;
		
		int pcolor1 = PDPLAS.PLAS_COLORS[random(0,2) + floor(charge / 7)];
		int pflags = SPF_FULLBRIGHT|SPF_REPLACE;
		int plifetime = 3 + (charge / 7);
		double pstartalpha = 0.35 + (charge / 90.);
		vector3 ppos = (0,0,0);
		while(pstartalpha > 0){
			pstartalpha -= frandom(0.002,0.006);
			ppos += particlestep * frandom(1.4,1.8);
			
			pdp.weaponmodel.A_SpawnParticle(pcolor1,pflags,plifetime + random(-1,2),3.,xoff:ppos.x,yoff:ppos.y,zoff:ppos.z,startalphaf:pstartalpha);
		}
	}
	
	default{
		weapon.AmmoType "PDPLASLoaded";
		weapon.AmmoType2 "PDBatteryAmmo";
		weapon.AmmoGive2 1;
		weapon.SlotNumber 6;
		tag "Pulse Laser";
		
		PDWeapon.mass 2.1,2.35;
		PDWeapon.twohanded true;
	}
	states{
	spawn:
		PLAS A -1;
		stop;
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		PLSG A 1 A_Raise(3);
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		PLSG A 1 A_Lower(3);
		loop;
		
	ready:
		PLSG A 1{
			if(invoker.charge > 0 && gametic % 20 == 0) invoker.charge--;
			if(countinv("PDPLASLoaded") > 0 || invoker.charge > 4)
				A_TwoHandsWeaponReady();
			else
				A_TwoHandsWeaponReady(WRF_NOPRIMARY);
		}
		PLSG A 0 A_JumpIf(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK,"chargeme");
		loop;
	chargeme:
		PLSG A 0 A_JumpIf(invoker.charge > 45,"cooldown");
		PLSG A 0 A_JumpIf(countinv("PDPLASLoaded") < 1,"cooldown");
		PLSG A 1{
			invoker.charge++;
			if(invoker.charge % 3 == 1)
				A_TakeInventory("PDPLASLoaded",1);
		}
		PLSG A 1 A_JumpIf(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK,"chargeme");
		PLSG A 1 A_StartSound("weapons/plascharge",CHAN_WEAPON,attenuation:ATTN_STATIC);
		goto cooldown;
	fire:
		PLSG A 0 A_JumpIf(invoker.charge >= 3,"hold");
		PLSG AAAA 1{
			invoker.charge++;
			if(invoker.charge % 4 == 0)
				A_TakeInventory("PDPLASLoaded",1);
		}
	quickcharge:
		PLSG A 1;
		PLSG AA 1{
			invoker.charge++;
			if(invoker.charge % 2 == 0)
				A_TakeInventory("PDPLASLoaded",1);
		}
	hold:
		PLSG A 1{
			A_AlertMonsters(1024 * frandom(1.0,1.5));
			int lasdmg = (4 + 0.65 * invoker.charge) * frandom(2.2,3.);
			//console.printf("LAS DMG: "..lasdmg);
			A_PDBulletAttack(0.1,0.1,1,lasdmg,"PDPlasPuff",0.,CBAF_NORANDOM);
			A_LaserFX(invoker.charge);
			bool slow = false;
			if(invoker.charge > 20){
				slow = true;
			}
			invoker.charge = 0;
			A_MuzzleClimb(0.7,0.1,true,0);
			A_PlaySound("weapons/plasmaf",CHAN_WEAPON);
			if(slow)
				return resolvestate("cooldown");
			else
				return resolvestate(null);
		}
		PLSG A 1 A_JumpIf(countinv("PDPLASLoaded") < 1,"cooldown");
		PLSG A 1 A_Refire("quickcharge");
	cooldown:
		PLSG A 5;
		goto ready;
	
	// reload states
	reload:
	altfire:
		PLSG A 10;
		PLSG A 1{
			if(countinv("PDPLASLoaded") >= 95) return resolvestate("reloadend");
			if(countinv("PDPLASLoaded") > 0)
				A_TakeInventory("PDPLASLoaded",countinv("PDPLASLoaded"));
			if(countinv("PDBatteryAmmo") > 0){
				A_SelectWeapon("PDBatteryHand");
				return resolvestate(null);
			}else{
				return resolvestate("ready");
			}
		}
	reloading:
		PLSG A 1{
			if(invoker.pdp.RoomscaleDistance(3.0,-2.0,4.0) < 4.0){
				A_PlaySound("weapons/shotrack",CHAN_WEAPON);
				int toreload = 100;
				A_GiveInventory("PDPLASLoaded",toreload);
				A_TakeInventory("PDBatteryAmmo",1,TIF_NOTAKEINFINITE);
				A_SelectWeapon("PDEmptyOffhand");
				return resolvestate("reloadend");
			}
			return resolvestate(null);
		}
		loop;
	reloadend:
		PLSG B 12;
		goto ready;
	}
}

class PDPLASLoaded:ammo{
	default{
		inventory.MaxAmount 100;
	}
}