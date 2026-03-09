// this file contains the actual actor definitions of all sights


// PUMP SHOTGUN
extend class PDPumpShotgun{
	override void Sightclasses(){
		sightclass[0] = "PDPumpShotBacksight";
		sightclass[1] = "PDPumpShotFrontsight";
	}
}
class PDPumpShotBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -7;
	}
	states{
	spawn:
		SGST A -1;
		stop;
	}
}
class PDPumpShotFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance 4;
	}
	states{
	spawn:
		SGST B -1;
		stop;
	}
}


// DOUBLE SHOTGUN
extend class PDDoubleShotgun{
	override void Sightclasses(){
		sightclass[0] = "PDDoubleShotBacksight";
		sightclass[1] = "PDDoubleShotFrontsight";
	}
}
class PDDoubleShotBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -6;
	}
	states{
	spawn:
		SSGS A -1;
		stop;
	}
}
class PDDoubleShotFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance 2;
	}
	states{
	spawn:
		SSGS B -1;
		stop;
	}
}

// VECTOR
extend class PDKVector{
	override void Sightclasses(){
		sightclass[0] = "PDHoloBacksight";
		sightclass[1] = "PDHoloFrontsight";
	}
}
class PDHoloBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -9;
	}
	states{
	spawn:
		HLST A -1;
		stop;
	}
}
class PDHoloFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance 11;
		+BRIGHT;
		Renderstyle "Add";
		Alpha 0.4;
	}
	states{
	spawn:
		HLST B -1;
		stop;
	}
	
	/*
	override void tick(){
		super.tick();
		
		// holo reticle should essentially be placed along the gun's direction
		// vector, but relative to the player's camera
		// however, it should also disappear if the player isn't looking through the sight
		
		let pdp = PDPlayerPawn(master);
		let hands = PD_Hands(pdp.FindInventory("PD_Hands"));
		
		vector3 dir;
		dir.xy = AngleToVector(hands.mainangle);
		vector2 atvp = AngleToVector(hands.mainpitch + pitchoffs);
		dir.z = -atvp.y;
		
		SetOrigin(pdp.pos + (0,0,pdp.player.viewheight) + (dir * distance),true);
	}
	*/
}


// SIG SG552
extend class PDSIG{
	override void Sightclasses(){
		sightclass[0] = "PDSIGBacksight";
		sightclass[1] = "PDSIGFrontsight";
	}
}
class PDSIGBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -6;
	}
	states{
	spawn:
		S55S A -1;
		stop;
	}
}
class PDSIGFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance 0;
	}
	states{
	spawn:
		S55S B -1;
		stop;
	}
}


// FAMAS
extend class PDFamas{
	override void Sightclasses(){
		sightclass[0] = "PDFamasBacksight";
		sightclass[1] = "PDFamasFrontsight";
	}
}
class PDFamasBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -12;
	}
	states{
	spawn:
		FAMS A -1;
		stop;
	}
}
class PDFamasFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance -3;
	}
	states{
	spawn:
		FAMS B -1;
		stop;
	}
}


// MACHINEGUN
extend class PDMachinegun{
	override void Sightclasses(){
		sightclass[0] = "PDMGunBacksight";
		sightclass[1] = "PDMGunFrontsight";
	}
}
class PDMGunBacksight:PDWeaponSight{
	default{
		PDWeaponSight.distance -7;
		PDWeaponSight.pitchoffs 16.0;
	}
	states{
	spawn:
		MGST A -1;
		stop;
	}
}
class PDMGunFrontsight:PDWeaponSight{
	default{
		PDWeaponSight.distance 4;
		PDWeaponSight.pitchoffs 16.0;
	}
	states{
	spawn:
		MGST B -1;
		stop;
	}
}