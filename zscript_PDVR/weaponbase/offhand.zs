// WHAT DO YOU MEAN THERE ARE TWO
class PDEmptyOffhand:PDOffhandWeapon{
	default{
		tag "empty";
		weapon.SlotNumber 1;
	}
	states{
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		PUNG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}

// offhand "weapons" for when you're holding ammo in the offhand
class PDMagHand:PDOffhandWeapon{
	default{
		tag "magazine";
	}
	states{
	spawn:
		CLIP A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		CLPG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}
class PDShellHand:PDOffhandWeapon{
	default{
		tag "shell";
	}
	states{
	spawn:
		SHLB A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		SHLG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}
class PD2ShellHand:PDOffhandWeapon{
	default{
		tag "shells";
	}
	states{
	spawn:
		2SHL A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		2SHG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}
class PDAmmoBoxHand:PDOffhandWeapon{
	default{
		tag "magazine";
	}
	states{
	spawn:
		AMMO A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		ABXG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}
class PDRocketHand:PDOffhandWeapon{
	default{
		tag "rocket";
	}
	states{
	spawn:
		RKTA A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		RKAG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}
class PDBatteryHand:PDOffhandWeapon{
	default{
		tag "battery";
	}
	states{
	spawn:
		CELL A -1;
		stop;
	select:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		CELG A 1 A_WeaponReady(WRF_NOFIRE);
		loop;
	fire:
		TNT1 A 0;
		goto ready;
	}
}