// apply tourniquet directly to neck
class PDMedManager:PDWeapon{
	int selected;
	
	static const string MEDI_LABELS[] = {
		"Bandages",
		"Stimpack",
		"Medikit",
		"Berserk"
	};
	static const class<ammo> MEDI_CLASSN[] = {
		"PDStimpack",
		"PDMedikit",
		"PDBerserk"
	};
	
	// OW GOD JESUS CHRIST FUCK
	static const string MEDI_PAIN[] = {
		"FUCK THAT HURTS",
		"OH GOD",
		"THAT FUCKING HURTS",
		"OH HOLY FUCKING SHIT",
		"FUCK!!",
		"SHIT!"
	};
	
	override void DrawWeaponHud(){
		HUDFont monofont = HUDFont.Create(smallfont,8,monospacing:Mono_CellCenter);
		let pdp = PDPlayerPawn(owner);
		string bleeding = (pdp.openwounds >= 4.?"\cgINJURED":"\cdFINE")
			.. (pdp.openwounds >= 4. && pdp.patchedwounds >= pdp.openwounds?"\cc, but mostly \cdSTABLE\cc.":"\cc.");
		statusbar.drawstring(monofont,"you are ".. bleeding,(20,40),0,Font.CR_GREY);
		
		for(int i = 0;i < MEDI_ITEMS_CNT;i++){
			double a = (i == selected)?1.0:0.45;
			color txtcol = (i == selected)?Font.CR_BRICK:Font.CR_DARKRED;
			
			if(i){
				// draw all normal items' info
				let classn = MEDI_CLASSN[i-1];
				int cnt = owner.countinv(classn);
				if(!cnt) txtcol = Font.CR_BLACK;
				statusbar.drawstring(monofont,MEDI_LABELS[i].." ("..cnt..")",(60,60 + i * 10),0,txtcol,a);
			}else{
				// special case for drawing bandages info specifically
				statusbar.drawstring(monofont,MEDI_LABELS[i],(60,60 + i * 10),0,txtcol,a);
			}
		}
		statusbar.drawstring(monofont,"offhandattack/attack - left/right",(20,110),0,Font.CR_ICE);
		statusbar.drawstring(monofont,"altattack - use item",(20,120),0,Font.CR_ICE);
	}
	
	default{
		tag "Medical manager";
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
		TNT1 A 7{
			invoker.selected = (invoker.selected + 1) % MEDI_ITEMS_CNT;
		}
		goto ready;
	offattack:
		TNT1 A 7{
			invoker.selected = (invoker.selected - 1);
			if(invoker.selected < 0)
				invoker.selected = (MEDI_ITEMS_CNT - 1);
		}
		goto ready;
	
	altfire:
		TNT1 A 5;
		TNT1 A 5{
			switch(invoker.selected){
			default:
			case 0:
				return resolvestate("useBandages");
				break;
			case 1:
				return resolvestate("useStimpack");
				break;
			case 2:
				return resolvestate("useMedikit");
				break;
			case 3:
				return resolvestate("useBerserk");
				break;
			}
			return resolvestate(null);
		}
		goto ready;
	
	// states for using items
	
	useBandages:
		TNT1 A 10 A_JumpIf(invoker.pdp.openwounds <= invoker.pdp.patchedwounds,"noBandages");
		TNT1 A 25 A_StartBandage();
		TNT1 A 25 A_StartBandage();
		TNT1 A 5 A_EndBandage();
		goto ready;
	noBandages:
		TNT1 A 10 A_Log("You aren't bleeding.",true);
		goto ready;
	
	useStimpack:
		TNT1 A 0 A_JumpIf(!countinv("PDStimpack"),"noStim");
		//TNT1 A 0 A_JumpIf(health >= 90,"noStim2");
		TNT1 A 10 A_JumpIf(invoker.pdp.stimulation >= 100,"noStim3");
	useStimpack2:
		TNT1 A 10 A_InjectStim();
		goto ready;
	noStim:
		TNT1 A 10 A_Log("You don't have any stimpacks.",true);
		goto ready;
	noStim2:
		TNT1 A 10 A_Log("You aren't in pain.",true);
		goto ready;
	noStim3:
		TNT1 A 40 A_Log("Are you sure you want to do that?",true);
		TNT1 A 5 A_JumpIf(player.cmd.buttons & BT_ALTATTACK,"useStimpack2");
		goto ready;
	
	useMedikit:
		TNT1 A 0 A_JumpIf(!countinv("PDMedikit"),"noMedikit");
		TNT1 A 0 A_JumpIf(invoker.pdp.openwounds <= 0.,"noBandages");
		TNT1 A 30 A_JumpIf(invoker.pdp.pain - min(invoker.pdp.openwounds * 2,50) >= 30,"noMedikit2");
		TNT1 A 25 A_StapleMedikit();
		goto ready;
	noMedikit:
		TNT1 A 10 A_Log("You don't have any sutures.",true);
		goto ready;
	noMedikit2:
		TNT1 A 10 A_Log("It hurts too much to suture carefully.",true);
		goto ready;
	
	useBerserk:
		goto ready;
	}
	
	// functions for the item use states
	
	action void A_StartBandage(){
		invoker.pdp.DamageMobj(self,self,1,'bandage');
		invoker.pdp.vel.xy += (frandom(-2.,2.),frandom(-2.,2.));
		invoker.pdp.pain += random(13,20);
		invoker.pdp.pain = min(invoker.pdp.pain,100);
	}
	action void A_EndBandage(){
		invoker.pdp.DamageMobj(self,self,1,'bandage');
		invoker.pdp.vel.xy += (frandom(-2.,2.),frandom(-2.,2.));
		invoker.pdp.pain += 20;
		invoker.pdp.pain = min(invoker.pdp.pain,100);
		
		invoker.pdp.patchedwounds = min(invoker.pdp.patchedwounds + 15.,invoker.pdp.openwounds);
		
		if(invoker.pdp.pain > random(70,90))A_Log(PDMedManager.MEDI_PAIN[random(0,5)],true);
	}
	
	action void A_InjectStim(){
		invoker.pdp.DamageMobj(self,self,5,'bandage');
		invoker.pdp.vel.xy += (frandom(-2.,2.),frandom(-2.,2.));
		invoker.pdp.pain += 20;
		invoker.pdp.pain = min(invoker.pdp.pain,100);
		
		// stims last roughly 40 seconds
		// give or take abt 3 sec
		invoker.pdp.stimulation += random(650,750) * 2;
		
		invoker.pdp.regenhealth += 15;
		invoker.pdp.regenhealth = min(100,invoker.pdp.regenhealth);
		
		TakeInventory("PDStimpack",1);
	}
	
	action void A_StapleMedikit(){
		invoker.pdp.DamageMobj(self,self,5,'bandage');
		invoker.pdp.vel.xy += (frandom(-2.,2.),frandom(-2.,2.));
		invoker.pdp.pain += 10;
		invoker.pdp.pain = min(invoker.pdp.pain,100);
		
		invoker.pdp.openwounds = max(0.,invoker.pdp.openwounds - 10.);
		invoker.pdp.patchedwounds = min(invoker.pdp.patchedwounds + 2.,invoker.pdp.openwounds);
		
		invoker.pdp.regenhealth += 25;
		invoker.pdp.regenhealth = min(100,invoker.pdp.regenhealth);
		
		TakeInventory("PDMedikit",1);
	}
}
const MEDI_ITEMS_CNT = 4;

// actual medical items
// for these, mass is how many it takes to equal 1 enc
class PDStimpack:ammo replaces stimpack{
	default{
		+inventory.ISHEALTH;
		
		inventory.Amount 1;
		inventory.MaxAmount 10;
		inventory.PickupMessage "Picked up a stimpack.";
		tag "Stimpack";
		Mass 2;
		
		scale 0.6;
	}
	states{
	spawn:
		STIM A -1;
		stop;
	}
}
class PDMedikit:ammo replaces medikit{
	default{
		+inventory.ISHEALTH;
		
		inventory.Amount 4;
		inventory.MaxAmount 20;
		inventory.PickupMessage "Picked up a medikit.";
		tag "Medikit";
		Mass 6;
		
		scale 0.6;
	}
	states{
	spawn:
		MEDI A -1;
		stop;
	}
}
class PDBerserk:ammo replaces berserk{
	default{
		+inventory.ISHEALTH;
		
		inventory.Amount 1;
		inventory.MaxAmount 4;
		inventory.PickupMessage "Picked up a berserk pack.";
		tag "Berserk";
		Mass 1;
		
		scale 0.6;
	}
	states{
	spawn:
		PSTR A -1;
		stop;
	}
}