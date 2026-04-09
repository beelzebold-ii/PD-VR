extend class PDPlayerPawn{
	vector3 ArtifactBeltPos(int index){
		// starting pos
		vector3 beltpos = (8,12,28);
		// each one goes + (2,-3)
		beltpos += (2,-3,0) * index;
		// stagger height by + 6 on odd numbered artifacts
		// will uncomment this if there end up being more artifacts to deem it necessary
		/*
		if(index % 2 == 1){
			beltpos.z += 6;
		}
		*/
		return beltpos;
	}
	void ArtifactBeltTick(){
		array<PD_Artifact> artifacts;
		// populate artifacts array
		for(let item = inv;item != null;item = item.inv){
			if(item is "PD_Artifact"){
				artifacts.push(PD_Artifact(item));
			}
		}
		
		for(int i = 0;i < artifacts.Size();i++){
			PD_DisplayItem.Create(self,"PINS",artifacts[i].Icon,ArtifactBeltPos(i));
			RoomscaleDistanceChest(true,ArtifactBeltPos(i),false);
		}
	}
}

class PD_DisplayItem:actor{
	default{
		+NOBLOCKMAP;
		+NOCLIP;
		+FORCEXYBILLBOARD;
		
		Renderstyle "translucent";
		Alpha 0.8;
		Scale 0.8;
	}
	
	name sprname;
	TextureID picn;
	
	static void Create(actor origin,name spritename,TextureID pic,vector3 relpos){
		// rotate relpos based on origin angle
		relpos.xy = RotateVector(relpos.xy,origin.angle);
		
		// translate to origin position
		relpos += origin.pos;
		
		let pddi = PD_DisplayItem(actor.spawn("PD_DisplayItem",relpos));
		pddi.sprname = spritename;
		pddi.picn = pic;
	}
	
	states{
	cache:
		PTIM ABCD 0;
		PINS ABCD 0;
		PINV ABCD 0;
		SOUL ABCD 0;
	spawn:
		UNKN A 1{
			picnum = picn;
		}
		stop;
	}
}