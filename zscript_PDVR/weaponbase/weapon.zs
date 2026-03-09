// These are my rifles, these are my guns; this one's for fighting, this one's for fun.
class PDWeapon:Weapon{
	PDPlayerPawn pdp;
	override void AttachToOwner(actor other){
		pdp = PDPlayerPawn(other);
		super.AttachToOwner(other);
	}
	override void DetachFromOwner(){
		pdp = null;
		super.DetachFromOwner();
	}
	default{
		+Weapon.NOHANDSWITCH;
		+Weapon.NOAUTOAIM;
		+Weapon.NOALERT;
	}
	
	action void A_TwoHandsWeaponReady(int flags = 0){
		if(!(invoker.pdp.twohanding)) flags |= WRF_NOPRIMARY;
		A_WeaponReady(flags);
	}
}
class PDOffhandWeapon:PDWeapon{
	default{
		+Weapon.OFFHANDWEAPON;
		+inventory.UNDROPPABLE;
		+inventory.UNTOSSABLE;
	}
}