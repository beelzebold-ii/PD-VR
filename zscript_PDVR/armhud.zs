class PD_ArmHudHandler:staticeventhandler{
	override void PlayerSpawned(playerevent e){
		let pla = players[e.playernumber].mo;
		let hud = PD_ArmHud(actor.spawn("PD_ArmHud"));
		hud.pla = pla;
	}
}

// for SOME FUCKING REASON (thanks outdated qzdoom ig?) canvas on an actor
// is just not drawing.

// some time has passed and I now have some theories based on how my old code
// from a different project worked.
// said old code has the canvas updated every tic in one actor, which also spawns
// the actual display actor every tic, which tells itself to use the canvas as a
// sprite. it could possibly be the case that the actor either can't update its
// own canvas, or the canvas just needs to be updated before the actor is spawned.
// if it works, this could allow me to make the arm hud, and also in-world 
// pic-in-pic magnified scopes. wonderful!
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