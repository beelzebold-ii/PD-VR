// I can't come up with a funny comment to put here idk
class PDInvManager:PDWeapon{
	int selected;
	default{
		tag "Inventory manager";
		PDWeapon.mass 0.8,1.33;
	}
	states{
	select:
		TNT1 A 0 A_OnSelect();
	select2:
		TNT1 A 1 A_Raise();
		loop;
	deselect:
		TNT1 A 0 A_OnDeselect();
	deselect2:
		TNT1 A 1 A_Lower();
		loop;
	ready:
		TNT1 A 1{
			A_WeaponReady();
			if(player.cmd.buttons & BT_OFFHANDATTACK){
				return resolvestate("offattack");
			}
			if(player.cmd.buttons & BT_OFFHANDALTATTACK){
				return resolvestate("offaltattack");
			}
			return resolvestate(null);
		}
		loop;
	
	fire:
		TNT1 A 10{
			invoker.selected = (invoker.selected + 1) % BURDEN_ITEMS_CNT;
		}
		goto ready;
	offattack:
		TNT1 A 10{
			invoker.selected = (invoker.selected - 1);
			if(invoker.selected < 0)
				invoker.selected = (BURDEN_ITEMS_CNT - 1);
		}
		goto ready;
	offaltattack:
		TNT1 A 25{
			class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[invoker.selected];
			let item = FindInventory(classn);
			
			if(item){
				DropInventory(item,PDInvManager.DropAmt[invoker.selected]);
			}
		}
		goto ready;
	altfire:
		TNT1 A 1 A_SelectWeapon("PDEmptyOnHand");
		goto ready;
	}
	
	static const int DropAmt[] = {
		15,
		4,
		40,
		1,1,1,1,1,1
	};
}