// hell hath no fury, etc etc.
class PDEmptyOnHand:PDWeapon{
	default{
		tag "unarmed";
		weapon.SlotNumber 1;
		
		PDWeapon.mass 1.1,1.33;
	}
	states{
	select:
		TNT1 A 0 A_OnSelect();
	select1:
		TNT1 A 0 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_OnSelect();
	deselect1:
		TNT1 A 0 A_Lower();
		loop;
	
	ready:
		PUNG A 1{
			A_WeaponReady();
			if(player.cmd.buttons & BT_OFFHANDATTACK){
				return resolvestate("stripnakey");
			}
			return resolvestate(null);
		}
		loop;
	fire:
		TNT1 A 10;
		PUNG A 6 A_CustomPunch(10 * random(2,4),true,0,"PDPuff",18);
		TNT1 A 4;
		goto ready;
	
	altfire:
		TNT1 A 50;
		TNT1 A 20 A_DropInventory("PDArmor",1);
		goto ready;
	}
}