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
		
		PDWeapon.sprite 'TNT1';
	}
	
	action void A_TwoHandsWeaponReady(int flags = 0){
		if(!(invoker.pdp.twohanding)) flags |= WRF_NOPRIMARY;
		A_WeaponReady(flags);
	}
	
	override void DoEffect(){
		super.DoEffect();
		if(!pdp) return;
		// just to make the visual debugging actor
		if(PD_RoomscaleDebug && pdp.player.readyweapon && pdp.player.readyweapon == self){
			let hands = PD_Hands(pdp.FindInventory("PD_Hands"));
			if(!hands) return;
			pdp.RoomscaleDistance();
		}
	}
	
	// for special stuff like the shotgun's chamber, the rifles' fireselectors, invmanager hud, etc
	ui virtual void DrawWeaponHud(){}
}
class PDOffhandWeapon:PDWeapon{
	default{
		+Weapon.OFFHANDWEAPON;
		+inventory.UNDROPPABLE;
		+inventory.UNTOSSABLE;
	}
}