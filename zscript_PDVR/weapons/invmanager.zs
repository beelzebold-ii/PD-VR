// I can't come up with a funny comment to put here idk
class PDInvManager:PDWeapon{
	int selected;
	
	override void DrawWeaponHud(){
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		let Inv = PDInvManager(self);
		for(int i = -2;i < 3;i++){
			int index = (Inv.selected + i) % BURDEN_ITEMS_CNT;
			if(index < 0) index += BURDEN_ITEMS_CNT;
			double a = (i==0)?1.0:0.333;
			class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[index];
			let item = pdp.FindInventory(classn);
			if(item){
				if(item is "ammo"){
					statusbar.drawstring(monofont,index..(item.bISHEALTH?". [M]":". [A]")..item.GetTag().." "..item.amount.."/"..item.maxamount,(60 + i * 10,60 + i * 10),0,Font.CR_GOLD,a);
				}else{
					statusbar.drawstring(monofont,index..". [W]"..item.GetTag(),(60 + i * 10,60 + i * 10),0,Font.CR_GOLD,a);
				}
			}else{
				statusbar.drawstring(monofont,index..". [?]no item",(60 + i * 10,60 + i * 10),0,Font.CR_BROWN,a);
			}
		}
		statusbar.drawstring(monofont,"offhandattack/attack - left/right",(20,110),0,Font.CR_ICE);
		statusbar.drawstring(monofont,"altattack - drop item",(20,120),0,Font.CR_ICE);
	}
	
	default{
		tag "Inventory manager";
		weapon.SlotNumber 0;
		
		PDWeapon.mass 1.1,1.33;
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
// 			if(player.cmd.buttons & BT_OFFHANDALTATTACK){
// 				return resolvestate("offaltattack");
// 			}
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
	altfire:
		TNT1 A 25{
			class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[invoker.selected];
			let item = FindInventory(classn);
			
			if(item){
				DropInventory(item,PDInvManager.DropAmt[invoker.selected]);
			}
		}
		goto ready;
	}
	
	static const int DropAmt[] = {
		// ammo
		15,
		4,
		40,
		1,
		1,
		1,
		// meds
		1,4,
		// weapons
		1,1,1,1,1,1,1,1,1,1
	};
}