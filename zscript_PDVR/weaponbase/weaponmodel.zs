// cold and hard, heavy. nobody has perfect control over where their gun is pointed.
// these are the models which exist in the world and try to follow the player's main hand as best they can.
CONST WEAP_TRANSFORCE = 6.0;
CONST WEAP_ROTAFORCE = 6.0;
CONST WEAP_TRECOIL = 3.0;
CONST WEAP_RRECOIL = 12.0;
CONST WEAP_LASEROFFSETZ = -12;
CONST WEAP_SHOOTOFFSETZ = -24;

extend class PDWeapon{
	float transmass; // translatory mass
	float rotamass; // rotary mass
	bool twohanded;
	double pitchoffs;
	property mass:transmass,rotamass;
	property twohanded:twohanded;
	property pitchoffs:pitchoffs;
	
	name weapsprite;
	int weapframe;
	property sprite:weapsprite;
	
	// for affecting the in-world weaponmodel
	// takes a velocity, not a force; ignores mass
	// also handles stripping invisibility!
	action void A_MuzzleClimb(double transvel,double rotavel,bool twohands = false,int timer = -1){
		let pdp = PDPlayerPawn(invoker.owner);
		
		if(timer == -1){
			timer = transvel + rotavel * (invoker.transmass + invoker.rotamass) / 4.0;
		}
		
		transvel *= WEAP_TRECOIL;
		rotavel *= WEAP_RRECOIL;
		
		if(twohands && !pdp.twohanding){
			transvel *= 2;
			rotavel *= 2;
		}
		
		if(!pdp.twohanding)
			A_SetBlend("000000",0.2,min(sqrt(timer + 1.) + 1,4));
		
		pdp.weaponmodel.MuzzleClimb(transvel,rotavel);
		pdp.weaponmodel.recoiltimer = timer;
		
		pdp.inviso = min(pdp.inviso,70);
		pdp.inviso = max(0,pdp.inviso - 30);
	}
	
	action void A_PDBulletAttack(float spreadx,float spready,int num,int dmgper,class<PDPuff> puff = "PDPuff",double pitchoffs = 0.0,int flags = 0){
		let pdp = PDPlayerPawn(invoker.owner);
		
		// set flags!
		flags = flags|CBAF_AIMFACING|CBAF_NOPITCH|CBAF_EXPLICITANGLE|CBAF_NORANDOMPUFFZ;
		
		//A_FireBullets(spreadx,spready,num,dmgper);
		// don't let the player shoot themself
		// might change to where the player *can* shoot themself *if* the gun
		// is pointed more directly at them
		pdp.bShootable = false;
		pdp.weaponmodel.pitch += pitchoffs;
		// using explicitangles and manually randomizing the spread inherently
		// breaks multi-shot hitscans; need to manually randomize the spread
		// individually for each round
		for(int i = 0;i<num;i++){
			pdp.weaponmodel.A_CustomBulletAttack(spreadx * frandom(-1.0,1.0),pdp.weaponmodel.pitch + spready * frandom(-1.0,1.0),1,dmgper,puff,0,flags,spawnheight:WEAP_SHOOTOFFSETZ);
		}
		pdp.weaponmodel.pitch -= pitchoffs;
		pdp.bShootable = true;
	}
}

class PDWeaponPos:actor{
	default{
		+THRUACTORS;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOTIMEFREEZE;
		scale 0.4;
		alpha 0.5;
	}
	
	int recoiltimer;
	vector3 veltrans;
	vector2 velrota;
	override void BeginPlay(){
		veltrans = (0,0,0);
		velrota = (0,0);
	}
	
	void MuzzleClimb(double transvel,double rotavel){
		let pdp = PDPlayerPawn(master);
		if(pdp.stun > 5){
			// being stunned at all past 5 incurs a 40% recoil debuff,
			// and an additional 1% per point past that
			// the translational debuff is considerably weaker
			transvel *= 1.0 + (pdp.stun * 0.01) + 0.05;
			rotavel *= 1.0 + (pdp.stun * 0.01) + 0.35;
		}
		veltrans += (0.0, 0.0, transvel);
		velrota += (0.0, -rotavel);
	}
	
	override void tick(){
		vel = (0,0,0);
		super.tick();
		
		if(!master) return;
		if(master.health <= 0) return;
		let pdp = PDPlayerPawn(master);
		
		if(!pdp.player.readyweapon)
			return;
		let pdw = PDWeapon(pdp.player.readyweapon);
		
		if(recoiltimer > 0){
			recoiltimer--;
		}
		
		if(!pdw)
			return;
		
		// if in pain or fatigue is high enough, start shaking
		// 0.02 degrees per point of fatigue above 30
		// 0.04 degrees per point of pain
		// hard caps at 4 degrees
		float shakeintensity = min( max(0.,(pdp.fatigue - 30.) * 0.02) + pdp.pain * 0.04 ,4.0);
		vector2 shakevector = AngleToVector(random(-180,180),frandom(0.,shakeintensity));
		angle += shakevector.x;
		pitch += shakevector.y;
		
		OwnerForce();
		DampingForce();
		GravityForce();
		SetOrigin(pos + master.vel + veltrans,true);
		if(velrota != velrota){
			//console.printf("NaN velrota!");
			velrota = (0,0);
		}
		angle += velrota.x;
		pitch += velrota.y;
		
		// laser pointer showing the true position of the weapon
		vector3 particlestep;
		particlestep.xy = AngleToVector(angle);
		vector2 atvp = AngleToVector(pitch);
		particlestep.z = -atvp.y;
		
		int pcolor1 = 0xaa2222;
		int pflags = SPF_FULLBRIGHT|SPF_REPLACE;
		int plifetime = 1;
		double pstartalpha = 0.4;
		vector3 ppos =(0,0,0);
		while(pstartalpha > 0){
			pstartalpha -= frandom(0.002,0.01);
			ppos += particlestep * frandom(0.4,1.6);
			
			A_SpawnParticle(pcolor1,pflags,plifetime,xoff:ppos.x,yoff:ppos.y,zoff:ppos.z,startalphaf:pstartalpha);
		}
		
		// there's no linetracing in this version. wtf
		// as much as it pains me, I think I have to use a bulletpuff for the laser
		// pointer, like how m8f's mod does it
		pdp.bShootable = false;
		LineAttack(angle,1024 * PD_LaserPointerDist,pitch,0,'none',"PD_LaserPointerPuff",offsetz:WEAP_LASEROFFSETZ);
		pdp.bShootable = true;
	}
	
	void OwnerForce(){
		let pdp = PDPlayerPawn(master);
		let hands = PD_Hands(pdp.FindInventory("PD_Hands"));
		if(!hands) return;
		let pdw = PDWeapon(pdp.player.readyweapon);
		
		// force penalty from being stunned (0.9% per point of stun)
		double stunpenalty = 1.0 - pdp.stun * 0.009;
		
		// translatory
		vector3 tdiff = hands.mainpos - pos;
		vector3 unittdiff = tdiff / tdiff.Length();
		float tvelTowards = veltrans dot unittdiff;
		if(tdiff.Length() >= 1.0 + tvelTowards){
			double force = min(WEAP_TRANSFORCE,tdiff.Length() - (1.0 + tvelTowards));
			force = max(0.0,force * stunpenalty);
			if(pdw.twohanded && !pdp.twohanding) force /= 2.0;
			// spring force: 100% for every 6 units past 6
			double springforce = max(0.0,(tdiff.Length() - 6.) / 6.);
			force += force * springforce;
			// recoil reaction delay timer cuts force in half briefly
			if(recoiltimer) force /= 2.0;
			double accel = force / pdw.transmass;
			veltrans += unittdiff * accel;
		}else{
			if(tvelTowards >= tdiff.Length())
				veltrans -= unittdiff * (WEAP_TRANSFORCE / pdw.transmass);
		}
		
		// rotary
		vector2 rdiff = (deltaangle(angle,hands.mainangle),(hands.mainpitch + pdw.pitchoffs - 1.0) - pitch);
		vector2 unitrdiff = rdiff / rdiff.Length();
		float rvelTowards = velrota dot unitrdiff;
		if(rdiff.Length() >= 1.0 + rvelTowards){
			double force = min(WEAP_ROTAFORCE,rdiff.Length() - (1.0 + rvelTowards));
			force = max(0.0,force * stunpenalty);
			if(pdw.twohanded && !pdp.twohanding) force /= 2.0;
			// spring force: 100% for every 14 degrees past 6
			double springforce = max(0.0,(rdiff.Length() - 6.) / 14.);
			force += force * springforce;
			// recoil reaction delay timer cuts force in half briefly
			if(recoiltimer) force /= 2.0;
			double accel = force / pdw.rotamass;
			velrota += unitrdiff * accel;
		}else{
			if(rvelTowards >= rdiff.Length())
				velrota -= unitrdiff * (WEAP_ROTAFORCE / pdw.rotamass);
		}
		
		roll = -hands.mainroll;
	}
	void DampingForce(){
		let pdp = PDPlayerPawn(master);
		let pdw = PDWeapon(pdp.player.readyweapon);
		
		veltrans *= min(1.0/(0.5 + pdw.transmass),0.98);
		velrota *= min(1.2/(0.4 + pdw.rotamass),0.99);
	}
	void GravityForce(){
		let pdp = PDPlayerPawn(master);
		let pdw = PDWeapon(pdp.player.readyweapon);
		
		veltrans += (0.,0.,-0.05 * (pdw.transmass + 1.0));
		double gravaccel = 0.025 * pdw.rotamass;
		velrota += (0.,gravaccel);
	}
	
	states{
	cache:
		PISG A 0;
		SHTG AB 0;
		SHT2 ABC 0;
		CHGG AB 0;
		KVEC A 0;
		S552 A 0;
		FAMA SA 0;
		RGMK A 0;
		FRAG ABC 0;
	spawn:
		TNT1 A 1{
			let pdp = PDPlayerPawn(master);
			if(pdp && pdp.player.readyweapon && pdp.player.health > 0){
				let pdw = PDWeapon(pdp.player.readyweapon);
				if(pdw){
					sprite = GetSpriteIndex(pdw.weapsprite);
					// I forgot for a sec that weapons don't actually use their own states. they're
					// used by these, psprites.
					if(pdp.player.FindPSprite(1) && pdp.player.FindPSprite(1).curstate)
						frame = pdp.player.FindPSprite(1).curstate.frame;
				}
			}else{
				sprite = GetSpriteIndex('TNT1');
				frame = 0;
			}
		}
		loop;
	}
}

class PD_LaserPointerPuff:actor{
	default{
		radius 2;
		height 2;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+BLOODLESSIMPACT;
		+PUFFONACTORS;
		+DONTSPLASH;
		+NOTRIGGER;
		+NOTIMEFREEZE;
	}
	states{
	xdeath:
	crash:
	spawn:
		BAL1 A 0{
			vector3 particlestep;
			particlestep.xy = AngleToVector(angle);
			vector2 atvp = AngleToVector(pitch);
			particlestep.z = -atvp.y;
			
			int pcolor1 = 0xaa2222;
			int pflags = SPF_FULLBRIGHT|SPF_REPLACE;
			int plifetime = 1;
			double pstartalpha = frandom(0.7,0.9);
			vector3 ppos = particlestep;
			
			A_SpawnParticle(pcolor1,pflags,plifetime,3.0,xoff:ppos.x,yoff:ppos.y,zoff:ppos.z,startalphaf:pstartalpha);
		}
		stop;
	}
}