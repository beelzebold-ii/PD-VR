// plural of bonus!
class PDHealthBonus:inventory replaces healthbonus{
	default{
		+Inventory.AUTOACTIVATE;
		Inventory.Amount 1;
		Inventory.MaxAmount 9;
	}
	override bool CanPickup(actor toucher){
		if(toucher is "PDPlayerPawn"){
			let pdp = PDPlayerPawn(toucher);
			if(pdp.health < 100 || pdp.bloodloss > 1 || pdp.openwounds > 1) return true;
		}
		return false;
	}
	override bool Use(bool pkup){
		owner.GiveBody(1,100);
		let pdp = PDPlayerPawn(owner);
		if(pdp){
			pdp.bloodloss--;
			pdp.openwounds--;
			pdp.patchedwounds = min(pdp.openwounds,pdp.patchedwounds);
		}
		return true;
	}
	states{
	spawn:
		BON1 A random(105,315);
		BON1 BCDCB 10;
		loop;
	}
}
class PDArmorBonus:inventory replaces armorbonus{
	default{
		+Inventory.AUTOACTIVATE;
		Inventory.Amount 1;
		Inventory.MaxAmount 9;
	}
	override bool CanPickup(actor toucher){
		if(toucher is "PDPlayerPawn"){
			if(toucher.FindInventory("PDArmor")) return true;
		}
		return false;
	}
	override bool Use(bool pkup){
		let pda = PDArmor(owner.FindInventory("PDArmor"));
		if(pda){
			pda.mularmor += 0.55;
			pda.subarmor += 0.08;
			pda.mulstrength += 0.1;
			pda.substrength += 0.3;
		}
		return true;
	}
	states{
	spawn:
		BON2 A random(105,315);
		BON2 BCDCB 10;
		loop;
	}
}