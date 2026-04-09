// weapon randomspawners!

class pd_sgspawn:randomspawner replaces shotgun{
	default{
		dropitem "PDPumpShotgun",255,3;
		dropitem "PDKVector",255,1;
	}
}
class pd_cgspawn:randomspawner replaces chaingun{
	default{
		dropitem "PDKVector",255,2;
		dropitem "PDSIG",255,4;
		dropitem "PDFamas",255,1;
		dropitem "PDMachinegun",255,2;
	}
}
class pd_rlspawn:randomspawner replaces rocketlauncher{
	default{
		dropitem "PDFamas",255,1;
		dropitem "PDMachinegun",255,2;
		dropitem "PDKastet",255,5;
	}
}

class PD_FragSpawner:staticeventhandler{
	override void WorldThingSpawned(worldevent e){
		// don't run on dropped items
		if(e.thing.bDROPPED) return;
		
		if(e.thing is "ammo"){
			// 1 in 15 chance to spawn 1-3 frags over every ammo pickup
			if(!random(0,14)){
				int count = random(1,3);
				for(int i = 0;i < count;i++){
					let frg = actor.spawn("PDFragAmmo",e.thing.pos + (frandom(-16.,16.),frandom(-16.,16.),0.));
					frg.vel = (frandom(-5.,5.),frandom(-5.,5.),1.);
				}
			}
		}
		
		if(e.thing is "chainsaw"){
			// spawn 3-6 frags on every chainsaw
			int count = random(3,6);
			for(int i = 0;i < count;i++){
				let frg = actor.spawn("PDFragAmmo",e.thing.pos + (frandom(-10.,10.),frandom(-10.,10.),0.));
				frg.vel = (frandom(-5.,5.),frandom(-5.,5.),1.);
			}
			
			e.thing.Destroy();
		}
	}
}