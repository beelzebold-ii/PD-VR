// zscript hud elements done through an eventhandler
class PD_HudHandler:staticeventhandler{
	override void RenderUnderlay(renderevent e){
		/* // for quick copy pasting lol
		statusbar.drawstring(monofont,"",(20,20));
		*/
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		HUDFont indexfont = HUDFont.Create("INDEXFONT_DOOM",5,monospacing:Mono_CellCenter);
		HUDFont tipfont = HUDFont.Create(newsmallfont,3);
		
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
		if(PD_PainStunDebug){
			statusbar.drawstring(monofont,"pain:    "..pdp.pain,(30,30));
			statusbar.drawstring(monofont,"stun:    "..pdp.stun,(30,40));
			statusbar.drawstring(monofont,"fatigue: "..pdp.fatigue,(30,50));
		}
		
		// draw misc unique weapon information
		
		if(player.readyweapon is "PDWeapon"){
			let pdw = PDWeapon(player.readyweapon);
			pdw.DrawWeaponHud();
		}
		
		// draw encumberance and inv stuff
		
		if(PD_Encumberance && pdp.usetics >= 20){
			statusbar.drawstring(monofont,"ENC: "..pdp.PDPEncumberance(),(20,20));
			int j = 0;
			statusbar.drawstring(monofont,"+1 base enc",(0,30));
			for(int i = 0;i < BURDEN_ITEMS_CNT;i++){
				class<inventory> classn = PDPlayerPawn.BURDEN_ITEMS[i];
				let item = pdp.FindInventory(classn);
				
				if(item){
					j++;
					if(item is "ammo"){
						statusbar.drawstring(monofont,(item.bISHEALTH?"[M]":"[A]")..item.GetTag().." "..item.amount.."/"..item.maxamount,(0,30 + 8*j));
					}else{
						statusbar.drawstring(monofont,"[W]"..item.GetTag(),(0,30 + 8*j));
					}
				}
			}
		}
		
		// draw armor status
		
		let arm = PDArmor(pdp.FindInventory("PDArmor"));
		if(arm){
			statusbar.drawimage(arm.sicon,(170,170));
			if(PD_FriendlyHud){
				statusbar.drawstring(indexfont,string.format("%.0f",arm.mularmor),(176,160));
				statusbar.drawstring(indexfont,string.format("%.0f",arm.subarmor),(176,165));
			}
		}
		
		// if running, draw indicator
		
		bool running = (player.cmd.buttons & BT_RUN) ^ Cvar.GetCvar("cl_run",player).GetBool();
		if(running )statusbar.drawstring(monofont,"RUNNING",(190,160));
		
		// if dead, draw deathtip
		
		if(player.health <= 0){
			statusbar.drawstring(tipfont,"TIP: "..pdp.deathtip,(0,40),0,Font.CR_UNTRANSLATED,pdp.deathtics / 500.,320,1,(0.75,0.75));
		}
	}
}