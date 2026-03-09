// pumping is romantic and satisfying.
extend class PDPlayerPawn{
	float handdist;
	float deltahanddist;
	float lateralhanddist;
	float verticalhanddist;
	
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
	}
}