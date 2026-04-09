// FUCK SOMEBODY HELP ME
class PD_OuchEffectHandler:StaticEventHandler{
	override void WorldTick(){
		if(players[consoleplayer].mo){
			if(players[consoleplayer].mo.health > 0){
				//player is alive
				if(!(players[consoleplayer].mo is "PDPlayerPawn"))
					ThrowAbortException("Player is not PDPlayerPawn. Non-PDVR player classes are not compatible!");
				let pdp = PDPlayerPawn(players[consoleplayer].mo);
				
				float stun = (pdp.stun/100.);
				stun *= PD_VisStun;
				PPShader.SetUniform1f("OuchDesaturate","stun",stun);
				
				float missinghealth = 0.0;
				missinghealth = (100 - pdp.health) / 100.;
				
				//int woundcount = 0;
				
				float pain = (missinghealth * 0.45) + (pdp.pain/100.) * 0.6;
				pain *= PD_VisPain;
				pain += 0.4;
				PPShader.SetUniform1f("OuchVignette","pain",pain);
				
				PPShader.SetUniform1f("OuchVignette2","fatigue",pdp.fatigue / 210. + 0.55);
			}else{
				//player is dead.
				PPShader.SetUniform1f("OuchDesaturate","stun",0.0);
				PPShader.SetUniform1f("OuchVignette","pain",1.1*PD_VisPain);
				let pdp = PDPlayerPawn(players[consoleplayer].mo);
				if(pdp && pdp.fatigue)
					PPShader.SetUniform1f("OuchVignette2","fatigue",pdp.fatigue / 420. + 0.55);
				else
					PPShader.SetUniform1f("OuchVignette2","fatigue",1.1);
			}
		}else{
			PPShader.SetUniform1f("OuchDesaturate","stun",0.0);
			PPShader.SetUniform1f("OuchVignette","pain",0.0);
		}
	}
}