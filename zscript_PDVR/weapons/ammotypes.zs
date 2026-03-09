// the humanity! my big gun is out of bullets!
// mass is treated as how much you're encumbered by going above 50% of maxamount
// from 1 at 50% to [mass] at 100%
class PDPistolAmmo:ammo replaces clip{
	default{
		inventory.Amount 15;
		inventory.MaxAmount 180;
		inventory.PickupMessage "Picked up 15 pistol rounds.";
		tag "Pistol ammo";
		Mass 3;
		
		scale 0.6;
	}
	
	states{
	spawn:
		CLIP A -1;
		stop;
	}
}
class PDShotgunAmmo:ammo replaces shell{
	default{
		inventory.Amount 4;
		inventory.MaxAmount 56;
		inventory.PickupMessage "Picked up 4 shotgun shells.";
		tag "Shotgun ammo";
		Mass 4;
		
		scale 0.4;
	}
	
	states{
	spawn:
		SHEL A -1;
		stop;
	}
}
class PDShotgunAmmoBox:PDShotgunAmmo replaces shellbox{
	default{
		inventory.Amount 18;
		inventory.PickupMessage "Picked up 18 shotgun shells.";
		
		scale 0.4;
	}
	
	states{
	spawn:
		SBOX A -1;
		stop;
	}
}
class PDRifleAmmo:ammo replaces clipbox{
	default{
		inventory.Amount 50;
		inventory.MaxAmount 160;
		inventory.PickupMessage "Picked up 50 rifle rounds.";
		tag "Rifle ammo";
		Mass 6;
		
		scale 0.4;
	}
	
	states{
	spawn:
		AMMO A -1;
		stop;
	}
}