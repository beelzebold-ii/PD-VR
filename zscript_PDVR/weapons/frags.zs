// oops
class PDFragThrower:PDWeapon{
	vector3 oldHandPos;
	default{
		weapon.AmmoType "PDFragAmmo";
		weapon.SlotNumber 9;
		tag "Hand grenade";
		
		PDWeapon.mass 1.5,1.5;
		PDWeapon.sprite 'FRAG';
		
		+inventory.undroppable;
	}
	states{
	spawn:
		FRAG A 0;
		stop;
	select:
		TNT1 D 0 A_OnSelect();
	select2:
		TNT1 D 1 A_Raise(10);
		loop;
	deselect:
		TNT1 D 0 A_OnDeselect();
	deselect2:
		TNT1 D 1 A_Lower(8);
		loop;
	
	ready:
		TNT1 A 1{
			if(countinv("PDFragAmmo") > 0)
				A_WeaponReady();
			else{
				A_SelectWeapon("PDEmptyOnHand");
				A_WeaponReady(WRF_NOFIRE);
			}
		}
		loop;
	fire:
		TNT1 A 1{
			if(invoker.pdp.twohanding && player.cmd.buttons & BT_OFFHANDATTACK){
				return resolvestate("live");
			}
			return resolvestate(null);
		}
		TNT1 A 1 A_Refire("fire");
		goto ready;
	live:
		TNT1 B 1{
			let hands = PD_Hands(invoker.pdp.FindInventory("PD_Hands"));
			if(hands){
				invoker.oldHandPos = hands.mainpos;
			}
		}
		TNT1 B 0 A_Refire("live");
		TNT1 B 1{
			let hands = PD_Hands(invoker.pdp.FindInventory("PD_Hands"));
			if(hands){
				A_TakeInventory("PDFragAmmo",1,TIF_NOTAKEINFINITE);
				vector3 fragvel = (hands.mainpos - invoker.oldHandPos) - vel;
				//console.printf("Fragvel: %.1f, %.1f, %.1f",fragvel.x,fragvel.y,fragvel.z);
				fragvel *= 2.;
				let frag = spawn("PDFragGrenade",hands.mainpos);
				frag.vel = fragvel;
				frag.target = invoker.owner;
			}
		}
		TNT1 D 25;
		goto ready;
	}
}

class PDFragGrenade:actor{
	int fuse;
	override void PostBeginPlay(){
		super.PostBeginPlay();
		fuse = TICRATE * frandom(2.9,3.5);
	}
	override void tick(){
		super.tick();
		fuse--;
		if(fuse==0) SetStateLabel("fragexp");
		
		if(vel.Length() > 0.5){
			pitch += vel.Length() * 2.;
			angle += vel.Length();
		}
	}
	override bool CanCollideWith(actor other,bool passive){
		if(other == target) return false;
		return super.CanCollideWith(other,passive);
	}
	default{
		BounceType 'Grenade';
		+BOUNCEONWALLS;
		+BOUNCEONFLOORS;
		+BOUNCEONCEILINGS;
		+ALLOWBOUNCEONACTORS;
		+BOUNCEONACTORS;
		+BOUNCEAUTOOFFFLOORONLY;
		+NOTIMEFREEZE;
		BounceFactor 0.4;
		WallBounceFactor 0.35;
		Gravity 0.22;
		Damagetype 'explosive';
		
		Radius 3;
		Height 6;
	}
	states{
	spawn:
	death:
		FRAG A 1;
		loop;
	fragexp:
		TNT1 A 0{
			bNOGRAVITY = true;
			bMISSILE = true;
			
			A_ScaleVelocity(0.0);
			
			A_SetScale(1.0);
			A_StartSound("weapons/rocklx",CHAN_AUTO);
			// full explosive damage
			A_Explode(random(90,110),150,XF_HURTSOURCE|XF_CIRCULAR,true,50);
			
			// shrapnel will just be approximated like this lmao
			A_Explode(random(85,110),400,(Distance3D(target)<random(200,400)?XF_HURTSOURCE:0)|XF_CIRCULAR,false,200,damagetype:'penetrate');
			
			bMISSILE = false;
		}
		MISL BCD 4 bright;
		stop;
	}
}