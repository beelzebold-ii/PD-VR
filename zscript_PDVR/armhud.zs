class PD_ArmHudHandler:staticeventhandler{
	override void PlayerSpawned(playerevent e){
		let pla = players[e.playernumber].mo;
		let hud = PD_ArmHud(actor.spawn("PD_ArmHud"));
		hud.pla = pla;
	}
}

// for SOME FUCKING REASON (thanks outdated qzdoom ig?) canvas on an actor
// is just not drawing.
// instead I'll do a sprite with all of the static elements and scaling
// rectangle sprites for "bars"
// no dynamic text... :(
class PD_ArmHud:actor{
	playerpawn pla;
	
	default{
		//+NOBLOCKMAP;
		+NOGRAVITY;
		//+BRIGHT;
		+FORCEXYBILLBOARD;
		+FLATSPRITE;
		+INTERPOLATEANGLES;
		
		//Renderstyle "Add";
		Scale 0.15;
	}
	
	override void PostBeginPlay(){
		super.PostBeginPlay();
		
		bYFlip = true;
		
		picnum = TexMan.CheckForTexture("HUDCANV",TexMan.TYPE_Any);
		if (!picnum.Exists()){
			console.printf("Arm HUD canvas failed!");
			Destroy();
			return;
		}
	}
	override void tick(){
		super.tick();
		
		if(!pla) return;
		
		Canvas canv = TexMan.GetCanvas("HUDCANV");
		canv.Clear(0,0,128,32,0x000000);
		canv.DrawText(smallFont,font.CR_RED,0,0,"HEALTH: "..pla.health);
		
		let hands = PD_Hands(pla.FindInventory("PD_Hands"));
		
		SetOrigin(hands.offpos + (0.,0.,10.),true);
		angle = deltaangle(-70,hands.offangle);
	}
	
	states{
	spawn:
		---- # 1;
		loop;
	}
}