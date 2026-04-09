// pumping is romantic and satisfying.
extend class PDPlayerPawn{
	float handdist;
	float deltahanddist;
	float lateralhanddist;
	float verticalhanddist;
	
	// old code only included to not break things that might still use it.
	void RoomscaleTick(){
		let hands = PD_Hands(FindInventory("PD_Hands"));
		
		if(!hands){
			if(player && player.mo && player.mo == self)
				GiveInventory("PD_Hands",1);
			return;
		}
		
		// we take the 2d difference vector, and project it onto a normal which
		// just faces to the front or side of the mainhand, whichever we need
		vector2 diff = (hands.mainpos.xy - hands.offpos.xy);
		
		// sideways for lateral distance
		vector2 sidenorm = AngleToVector(DeltaAngle(hands.mainangle,-90),1.0);
		double sep = diff dot sidenorm;
		lateralhanddist = abs(sep);
		
		//slope to be used for projecting foredist and verticaldist onto the gun
		vector2 slope = AngleToVector(hands.mainpitch,1.0);
		
		// frontways for frontways distance
		vector2 forenorm = AngleToVector(hands.mainangle,1.0);
		float newhanddist = -(diff dot forenorm);
		if(slope.x != 0)
			newhanddist /= slope.x;
		deltahanddist = handdist - newhanddist;
		handdist = newhanddist;
		
		
		float foredist = abs(handdist * slope.x);
		verticalhanddist = (hands.mainpos.y + slope.y*foredist) - hands.offpos.y;
		
		// for debuggening!!!
		// seems to work just fine yay
		//RoomscaleDistanceChest(false,(12,0,28),true);
	}
	
	
	// this should simplify things VASTLY and make them more consistent.
	float RoomscaleDistance(float dist = 0.0,float height = 0.0,float xy_offs = 0.0){
		let hands = PD_Hands(FindInventory("PD_Hands"));
		
		if(!hands){
			console.printf("no hands!");
			return 0.0;
		}
		
		// hopefully all this code should be fairly self explanatory.
		
		vector3 dir;
		dir.xy = AngleToVector(hands.mainangle);
		vector2 atvp = AngleToVector(hands.mainpitch);
		dir.z = -atvp.y;
		vector3 offdir;
		offdir.xy = AngleToVector(hands.offangle);
		atvp = AngleToVector(hands.offpitch);
		offdir.z = -atvp.y;
		
		vector3 pointpos = hands.mainpos + (dir * dist);
		pointpos.z += height;
		
		if(xy_offs){
			vector2 sidedir = AngleToVector(Normalize180(hands.mainangle + 90),1.0);
			pointpos.xy += sidedir * xy_offs;
		}
		
		// spawn visual debug actors on both hands
		// always do it to let the player have that visual feedback
		//if(PD_RoomscaleDebug){
			spawn("PD_RSDebug",pointpos);
			spawn("PD_RSDebug",(hands.offpos));
		//}
		
		vector3 diff = (hands.offpos) - pointpos;
		return diff.Length();
	}
	// similar to above, but gets distance between specified hand and some point relative to the player
	float RoomscaleDistanceChest(bool offhand,vector3 pointpos,bool drawguide = false){
		let hands = PD_Hands(FindInventory("PD_Hands"));
		
		if(!hands){
			console.printf("no hands!");
			return 0.0;
		}
		
		// get the correct hand's position
		vector3 handpos;
		if(!offhand){
			handpos = hands.mainpos;
		}else{
			handpos = hands.offpos;
		}
		
		// rotate pointpos based on player angle
		pointpos.xy = RotateVector(pointpos.xy,angle);
		
		// translate to player position
		pointpos += pos;
		
		// spawn guide bubbles
		if(drawguide || pd_roomscaledebug){
			spawn("PD_RSDebug",pointpos);
			spawn("PD_RSDebug",handpos);
		}
		
		vector3 diff = handpos - pointpos;
		return diff.Length();
	}
}

//purely for visual debugging
class PD_RSDebug:actor{
	default{
		projectile;
		+MISSILE;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+DONTSPLASH;
		+THRUACTORS;
		+BRIGHT;
		+FORCEYBILLBOARD;
		+NOTIMEFREEZE;
		Radius 1;
		Height 1;
		Damage 0;
		Speed 0;
		Scale 0.2;
		Alpha 0.4;
		Translation "168:191=192:207", "208:235=192:207";
	}
	
	states{
	spawn:
		BAL1 A 1;
		BAL1 AA 1 A_FadeOut(0.15);
		stop;
	}
}