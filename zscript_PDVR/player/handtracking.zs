// much of this code is made with the help of iAmErmac's main hand tracker

class PD_HandTrackHandler:staticeventhandler{
	/*
	// if you want to use this in your own mod without manually giving the item
	// to the player through some other code, uncomment this function
	override void PlayerSpawned(playerevent e){
		let pla = players[e.playernumber].mo;
		pla.GiveInventory("PD_Hands",1);
	}
	*/
}

class PD_Hands:inventory{
	vector3 mainpos;
	double mainangle;
	double mainpitch;
	double mainroll;
	vector3 offpos;
	double offangle;
	double offpitch;
	double offroll;
	
	default{
		inventory.maxamount 1;
	}
	
	override void DoEffect(){
		actor maintracker = owner.SpawnPlayerMissile("PD_PosTracker",aimflags:0);
		if(maintracker){
			maintracker.master = self;
			PD_PosTracker(maintracker).offhand = false;
		}
		actor offtracker = owner.SpawnPlayerMissile("PD_PosTracker",aimflags:ALF_ISOFFHAND);
		if(offtracker){
			offtracker.master = self;
			PD_PosTracker(offtracker).offhand = true;
		}
		
		actor mainroll = owner.SpawnPlayerMissile("PD_RollTracker",angle + 90,aimflags:0);
		if(mainroll){
			mainroll.master = self;
			PD_RollTracker(mainroll).offhand = false;
		}
		actor offroll = owner.SpawnPlayerMissile("PD_RollTracker",angle + 90,aimflags:ALF_ISOFFHAND);
		if(offroll){
			offroll.master = self;
			PD_RollTracker(offroll).offhand = true;
		}
		
		if(PD_TrackDebug){
			owner.SpawnPlayerMissile("PD_PosTrackerDebug",aimflags:0);
			owner.SpawnPlayerMissile("PD_PosTrackerDebug",aimflags:ALF_ISOFFHAND);
			owner.SpawnPlayerMissile("PD_PosTrackerDebug",angle + 90,aimflags:0);
			owner.SpawnPlayerMissile("PD_PosTrackerDebug",angle + 90,aimflags:ALF_ISOFFHAND);
		}
		
		super.DoEffect();
	}
}

//problem: angles are 1 tic behind
//I have however fixed positions being unnecessarily 1 tic behind
class PD_PosTracker:actor{
	vector3 startpos;
	bool offhand;
	
	default{
		projectile;
		+MISSILE;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+DONTSPLASH;
		+THRUACTORS;
		Radius 1;
		Height 1;
		Damage 0;
		Speed 16;
		Renderstyle "None";
	}
	
	override void PostBeginPlay(){
		if(!offhand){
			PD_Hands(master).mainpos = pos;
		}else{
			PD_Hands(master).offpos = pos;
		}
		startpos = pos;
	}
	override void tick(){
		super.tick();
		
		let dX = startpos.x - pos.x;
		let dY = startpos.y - pos.y;
		let dZ = startpos.z - pos.z;
		
		pitch = (atan2(sqrt(dX * dX + dY * dY), dZ) * -1) + 90;
		if(!offhand){
			PD_Hands(master).mainangle = angle;
			PD_Hands(master).mainpitch = pitch;
		}else{
			PD_Hands(master).offangle = angle;
			PD_Hands(master).offpitch = pitch;
		}
	}
	
	states{
	spawn:
		TNT1 A 1;
		stop;
	}
}

class PD_RollTracker:actor{
	vector3 startpos;
	bool offhand;
	
	default{
		projectile;
		+MISSILE;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+DONTSPLASH;
		+THRUACTORS;
		Radius 1;
		Height 1;
		Damage 0;
		Speed 16;
		Renderstyle "None";
	}
	
	override void PostBeginPlay(){
		startpos = pos;
	}
	override void tick(){
		super.tick();
		
		let dX = startpos.x - pos.x;
		let dY = startpos.y - pos.y;
		let dZ = startpos.z - pos.z;
		
		// the theory here is that if we fire the projectile at a 90 degree angle, its pitch will be modified as we roll the gun.
		pitch = (atan2(sqrt(dX * dX + dY * dY), dZ) * -1) + 90;
		// this seems to just go back to center as we go from 50% roll to 100% roll so!!!
		// I'll have to check to see if the projectile is on the side of the hand it should be
		// if it's not then we correct for that
		double handangle = PD_Hands(master).mainangle + 90;
		if(offhand) handangle = PD_Hands(master).offangle - 90;
		vector2 normal = AngleToVector(handangle,1.0);
		double sep = normal dot (dX,dY);
		// if sep is negative, we're on the opposite side of the hand
		if(sep<0){
			// hopefully this actually corrects it?
			pitch = 180.0 - pitch;
		}
		if(!offhand){
			PD_Hands(master).mainroll = pitch + 180;
		}else{
			PD_Hands(master).offroll = -pitch + 180;
		}
	}
	
	states{
	spawn:
		TNT1 A 1;
		stop;
	}
}

//purely for visual debugging
class PD_PosTrackerDebug:actor{
	default{
		projectile;
		+MISSILE;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+DONTSPLASH;
		+THRUACTORS;
		+BRIGHT;
		+FORCEYBILLBOARD;
		Radius 1;
		Height 1;
		Damage 0;
		Speed 2;
		Scale 0.1;
	}
	
	states{
	spawn:
		BAL1 A 6;
		stop;
	}
}