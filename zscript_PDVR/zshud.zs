// zscript hud elements done through an eventhandler
class PD_HudHandler:staticeventhandler{
	override void RenderUnderlay(renderevent e){
		/* // for quick copy pasting lol
		statusbar.drawstring(monofont,"",(20,20));
		*/
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		HUDFont indexfont = HUDFont.Create("INDEXFONT_DOOM",5,monospacing:Mono_CellCenter);
		
		let pdp = PDPlayerPawn(players[consoleplayer].mo);
		let player = players[consoleplayer];
		
		// draw debugging strings
		
		if(PD_RoomscaleDebug){
			statusbar.drawstring(monofont,"foredist:  "..pdp.handdist,(20,20));
			statusbar.drawstring(monofont,"latdist:   "..pdp.lateralhanddist,(20,30));
			statusbar.drawstring(monofont,"deltadist: "..pdp.deltahanddist,(20,40));
			statusbar.drawstring(monofont,"vertdist:  "..pdp.verticalhanddist,(20,50));
		}
		if(PD_TrackDebug){
			let hands = PD_Hands(pdp.FindInventory("PD_Hands"));
			statusbar.drawstring(monofont,"mainpos:   "..hands.mainpos.x..","..hands.mainpos.y..","..hands.mainpos.z,(20,20));
			statusbar.drawstring(monofont,"mainangle: "..hands.mainangle..","..hands.mainpitch..","..hands.mainroll,(20,30));
			statusbar.drawstring(monofont,"offpos:    "..hands.offpos.x..","..hands.offpos.y..","..hands.offpos.z,(20,40));
			statusbar.drawstring(monofont,"offangle:  "..hands.offangle..","..hands.offpitch..","..hands.offroll,(20,50));
		}
		
		// draw invmanager hud
		
		if(player.readyweapon && player.readyweapon is "PDInvManager"){
			let Inv = PDInvManager(player.readyweapon);
			for(int i = -2;i < 3;i++){
				int index = (Inv.selected + i) % BURDEN_ITEMS_CNT;
				if(index < 0) index += BURDEN_ITEMS_CNT;
				double a = (i==0)?1.0:0.333;
				class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[index];
				let item = pdp.FindInventory(classn);
				if(item){
					if(item is "ammo"){
						statusbar.drawstring(monofont,index..". [a]"..item.GetClassName().." "..item.amount.."/"..item.maxamount,(60 + i * 10,60 + i * 10),0,Font.CR_GOLD,a);
					}else{
						statusbar.drawstring(monofont,index..". [w]"..item.GetClassName(),(60 + i * 10,60 + i * 10),0,Font.CR_GOLD,a);
					}
				}else{
					statusbar.drawstring(monofont,index..". [?]no item",(60 + i * 10,60 + i * 10),0,Font.CR_BROWN,a);
				}
			}
			statusbar.drawstring(monofont,"offhandattack/attack - left/right",(20,110),0,Font.CR_ICE);
			statusbar.drawstring(monofont,"offhandaltattack - drop item",(20,120),0,Font.CR_ICE);
			statusbar.drawstring(monofont,"altattack - exit inventory manager",(20,130),0,Font.CR_ICE);
		}
		
		// draw encumberance and inv stuff
		
		if(PD_Encumberance && pdp.usetics >= 30){
			statusbar.drawstring(monofont,"ENC: "..pdp.PDPEncumberance(),(20,20));
			int j = 0;
			statusbar.drawstring(monofont,"+1 base enc",(0,30));
			for(int i = 0;i < BURDEN_ITEMS_CNT;i++){
				class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[i];
				let item = pdp.FindInventory(classn);
				
				if(item){
					j++;
					if(item is "ammo"){
						statusbar.drawstring(monofont,"[a]"..item.GetClassName().." "..item.amount.."/"..item.maxamount,(0,30 + 8*j));
					}else{
						statusbar.drawstring(monofont,"[w]"..item.GetClassName(),(0,30 + 8*j));
					}
				}
			}
		}
		
		// draw misc unique weapon information
		
		if(player.readyweapon is "PDPumpShotgun" && PD_FriendlyHud){
			bool chambered = PDPumpShotgun(player.readyweapon).chambered;
			statusbar.drawimage(chambered?"ONESHEL":"NONESHEL",(80,145),scale:(2,2));
		}
		
		if(player.readyweapon is "PDSIG"){
			bool semi = PDSIG(player.readyweapon).semi;
			statusbar.drawstring(monofont,semi?"SEMI":"FULL",(80,145));
		}
		if(player.readyweapon is "PDFamas"){
			bool semi = PDFamas(player.readyweapon).semi;
			statusbar.drawstring(monofont,semi?"SEMI":"BURST",(80,145));
		}
		
		// draw armor status
		
		let arm = PDArmor(pdp.FindInventory("PDArmor"));
		if(arm){
			statusbar.drawimage(arm.sicon,(150,170));
			if(PD_FriendlyHud){
				statusbar.drawstring(indexfont,string.format("%.0f",arm.mularmor),(160,160));
				statusbar.drawstring(indexfont,string.format("%.0f",arm.subarmor),(160,165));
			}
		}
	}
}