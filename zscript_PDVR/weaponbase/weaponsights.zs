// sights, for seeing. what else?
// note to self, do some testing on the actor CustomSprite.
// might make cameratextures in-world possible!
// caligari also said something about doing it with shaders, which I don't
// know how to do. if CustomSprite turns out a dead end, I'll probably be
// doing a lot more asking about that.
class PDWeaponSight:actor{
	int distance;
	double pitchoffs;
	property distance:distance;
	property pitchoffs:pitchoffs;
	default{
		+NOCLIP;
		+NOBLOCKMAP;
		+FLATSPRITE;
		+ROLLSPRITE;
		+INTERPOLATEANGLES;
		scale 0.1;
	}
	
	override void tick(){
		let pdp = PDPlayerPawn(master);
		let hands = PD_Hands(pdp.FindInventory("PD_Hands"));
		let weappos = pdp.weaponmodel;
		
		if(!weappos) return;
		
		A_SetScale(cvar.GetCvar("vr_weaponscale",pdp.player).GetFloat() * 0.1);
		
		vector3 dir;
		dir.xy = AngleToVector(weappos.angle);
		vector2 atvp = AngleToVector(weappos.pitch);
		dir.z = -atvp.y;
		
		// they always lag behind. I can't seem to get them to not lag behind no
		// matter how hard I try.
		SetOrigin(weappos.pos + (dir * distance) + (0,0,2.1),true);
		angle = weappos.angle;
		pitch = weappos.pitch - 90.0;
	}
}

extend class PDWeapon{
	class<PDWeaponSight> sightclass[4]; // even this might be overkill but whatever
	PDWeaponSight sights[4];
	
	virtual void Sightclasses(){
		
	}
	
	action void A_OnSelect(){
		invoker.Sightclasses();
		
		for(int i = 0;i < 4;i++){
			if(!invoker.sightclass[i]) break;
			
			invoker.sights[i] = PDWeaponSight(spawn(invoker.sightclass[i]));
			invoker.sights[i].master = invoker.owner;
		}
		
		A_SelectWeapon("PDEmptyOffhand");
	}
	action void A_OnDeselect(){
		for(int i = 0;i < 4;i++){
			if(!invoker.sights[i]) break;
			
			invoker.sights[i].Destroy();
		}
	}
}