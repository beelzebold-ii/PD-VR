// piff poff puff poof...
class PDPuff:bulletpuff{
	float extrawound;
	int puffarmor;
	property extra:extrawound;
	property puffarmor:puffarmor;
	
	default{
		+PUFFONACTORS;
		+HITTRACER;
		+FORCEDECAL;
		-ALLOWPARTICLES;
		Damagetype 'penetrate';
		PDPuff.extra 0.0;
		PDPuff.puffarmor 30;
	}
	
	virtual void OnHitActor(PDMonster tracer){
		if(!tracer) return;
		//check for headshots; no armor there means we should show blood, not puff
		float hitheight = pos.z - tracer.pos.z;
		hitheight /= tracer.height;
		bool headshot = false;
		if(hitheight >= 0.8) headshot = true;
		
		// if headshot and no helm, bleed bigger
		if(headshot && !tracer.hashelmet){
			bNOGRAVITY = false;
			SetStateLabel("hithead");
			return;
		}
		
		// use the *effective* subarmor after mularmor
		if(tracer.subarmor / ((100.0 - tracer.mularmor) * 0.01) >= puffarmor + random(-10,5) || tracer.bNOBLOOD){
			// give the player feedback that their bullet was stopped by enemy armor
			SetStateLabel("hitarmor");
			return;
		}
		bNOGRAVITY = false;
		SetStateLabel("hitflesh");
	}
	
	states{
	spawn:
		PUFF ABCD 0;
		BLUD ABC 0;
	crash:
	death:
	xdeath:
		TNT1 A 0{
			OnHitActor(PDMonster(tracer));
		}
		goto hitwall;
	hitwall:
		PUFF ABCCDD 2;
		stop;
	hithead:
		BLUD CBA 2;
	hitflesh:
		BLUD BBA 6;
		stop;
	hitarmor:
		PUFF CD 4;
		stop;
	}
}

// for pistol bullets, which deal higher bleeding
class PDPistolPuff:PDPuff{
	default{
		PDPuff.extra 15.0;
		PDPuff.puffarmor 15;
		Scale 0.75;
	}
	states{
	hithead:
		BLUD CBA 2;
	hitflesh:
		BLUD BBA 4;
		stop;
	}
}
// for shotgun pellets, which puff more easily on armor
class PDPelletPuff:PDPuff{
	default{
		PDPuff.extra 0.0;
		PDPuff.puffarmor 15;
		Scale 0.75;
	}
	states{
	hithead:
		BLUD CBA 2;
	hitflesh:
		BLUD BBA random(4,6);
		stop;
	}
}
// for rifle bullets, which puff less easily on armor
// ik their puffarmor is the same as base but they also have a diff animation
class PDRiflePuff:PDPuff{
	default{
		PDPuff.extra 0.0;
		PDPuff.puffarmor 30;
	}
	states{
	hithead:
		BLUD CBA 2;
	hitflesh:
		BLUD CCBA 4;
		stop;
	}
}

// blood! or a lack thereof.
class PDNoBlood:actor{
	states{
	spawn:
		TNT1 A 0;
		stop;
	}
}