// scary...
class PDMonster:actor{
	// stun makes monsters less likely to attack.
	int stun;
	// stuntolerance is the minimum stun before the monster's aggression is reduced
	// from 0 to 1
	double stuntolerance;
	property stuntolerance:stuntolerance;
	// pain makes monsters' attacks more erratic.
	int pain;
	// wounds make monsters bleed. if it bleeds you can kill it.
	// if it doesn't bleed you can probably still kill it.
	float openwounds;
	// max bloodloss scales on max hp times bloodfactor.
	float bloodloss;
	float bloodfactor;
	property bloodfactor:bloodfactor;
	// mularmor is percent damage reduction, applied before subarmor.
	// subarmor is flat subtractive damage reduction.
	int mularmor;
	int subarmor;
	property armorlv:mularmor,subarmor;
	//if no helmet, headshots ignore armor.
	bool hashelmet;
	property helmet:hashelmet;
	
	default{
		MONSTER;
		+FLOORCLIP;
		PDMonster.stuntolerance 0.1;
		PDMonster.bloodfactor 1.0;
		PDMonster.armorlv 0,0;
		PDMonster.helmet false;
		health 100;
		mass 150;
		Radius 20;
		Height 56;
		Bloodtype "PDNoBlood";
	}
	
	
	// shame if they got... damaged.
	override int DamageMobj(actor inflictor,actor source,int damage,name mod,int flags,double angle){
		// if you shoot something, they're gonna know.
		if(source && !target){
			target = source;
		}
		
		// how far up the hit actor the inflictor is; used for headshots
		float inflictorheight = inflictor.pos.z - pos.z;
		inflictorheight /= height;
		
		if(PD_HeadshotDebug) console.printf("hit height: "..inflictorheight);
		
		bool headshot = false;
		if(inflictorheight >= 0.75) headshot = true;
		
		if(PD_HeadshotDebug && headshot) console.printf("HEADSHOT");
		
		// saved so some of it can be applied as blunt force
		int olddamage = damage;
		if((hashelmet || !headshot) && mod == 'penetrate'){
			damage *= (100.0 - mularmor) / 100.0;
			damage -= subarmor;
			// can only be reduced to 1
			damage = max(damage,1);
			
			// if this were for the player, armor would be damaged here
		}
		
		if(mod == 'penetrate' && !bNOBLOOD){
			// wounding squares with damage; a huge hit is going to tear straight through
			// and obliterate the poor hit creature's blood volume very fast
			// wounding is exactly equal to incoming damage at 40 damage
			float towound = damage * damage / 40.0;
			if(inflictor is "PDPuff"){
				let pdb = PDPuff(inflictor);
				towound += pdb.extrawound;
			}
			
			if(headshot){
				// 30% more wounding on headshots
				towound *= 1.3;
				// and an extra 2 points
				towound += 2;
			}
			
			if(towound >= 1.0)
				openwounds += towound;
		}
		
		int absorbed = olddamage - damage;
		if(absorbed > 0){
			// blunt force damage squares with absorbed damage
			// fortunately it's divided by 10 *before square*
			// and causes no wounding
			int bluntforce = absorbed / 10 + 2;
			bluntforce *= bluntforce;
			// blunt force will never be higher than 2/3 of total absorbed damage
			bluntforce = min(bluntforce,absorbed * (2/3));
			
			damage += bluntforce;
		}
		
		// pain scaled by is damage to 0.8, getting shot HURTS but a larger
		// round will really just kill you deader, without proportionally more pain.
		// flat additive bonus per hit as more small hits will probably
		// hurt more than fewer larger hits.
		int topain = floor((damage ** 0.8) * 1.5) + 4;
		
		// stun increases more when you're already disoriented
		// flat subtractive malus per hit so as to favor individual hits over
		// mass amounts like buckshot.
		int tostun = floor(stun * 0.2) + damage - 4;
		
		if(headshot){
			// headshots stun the shit out of you, but don't really affect pain
			// you'll feel it later :)
			stun += floor(damage / 2) - 2;
			
			// they also add a flat 50% extra damage unless the target is helmed
			if(!hashelmet) damage *= 1.5;
			// in which case it's just 20% extra
			else damage *= 1.2;
		}
		
		// for headshot death or pain states
		if(headshot) mod = 'headshot';
		
		if(PD_DamageDebug) console.printf(source.GetClassName().." hit "..GetClassName().." for "..damage.." "..mod.." dmg, "..topain.." pain, and "..tostun.." stun");
		pain += topain;
		stun += tostun;
		
		return super.DamageMobj(inflictor,source,damage,mod,flags,angle);
	}
	
	
	// tick, tock, tick, tock
	override void tick(){
		super.tick();
		
		if(health <= 0) return;
		
		if(stun > 0 && stun >= random(-10,70) && gametic%3 == 0) stun--;
		if(pain > 0 && gametic%6 == 0) pain--;
		
		if(openwounds > 4.0){
			// 80 units of openwounds means 1 point of bloodloss every tick
			// for a humanoid this means death by bleedout very fast. (3 sec)
			bloodloss += openwounds / 80.0;
			if(gametic % 35 == 0 && PD_DamageDebug)
				console.printf(GetClassName().." bleeding; total bloodloss %.1f / %i",bloodloss,floor(GetSpawnHealth() * bloodfactor));
			
			// slowly close openwounds
			if(!random(0,7)){
				// 1/8 chance every tick to patch one singular point of wounds
				openwounds -= 1.0;
			}
			// this goes by much faster if we have no target or if they're out of sight
			if(!target || !CheckSight(target,SF_IGNOREVISIBILITY|SF_SEEPASTBLOCKEVERYTHING|SF_IGNOREWATERBOUNDARY)){
				// every 60 tics patch a whole 15 points of wounds
				// this likely won't save a humanoid from horrible critical bleeding
				// to the tune of 60+ total wounds
				if(gametic % 60 == 0){
					SetStateLabel("pain");
					openwounds -= 15.0;
					openwounds = max(2.0,openwounds);
					if(PD_DamageDebug) console.printf(GetClassName().." patched 15 wounds (now at "..openwounds..")");
				}
			}
		}
		
		if(gametic % 10 == 0 && bloodloss >= GetSpawnHealth() * bloodfactor){
			DamageMobj(self,self,GetSpawnHealth() / 3 + 3,'bleedout');
		}
	}
	
	
	// for checking if a monster will be blocked from attacking due to stun
	bool CheckStun(){
		if(stun < GetSpawnHealth() * stuntolerance) return false;
		if(stun >= GetSpawnHealth() * (frandom(-0.1,0.4) + stuntolerance)){
			return true;
		}
		return false;
	}
	action state A_CheckStun(statelabel st = "see"){
		bool toostunned = invoker.CheckStun();
		if(PD_DamageDebug && toostunned) console.printf(GetClassName().." is too stunned to attack");
		if(toostunned)
			return ResolveState(st);
		else
			return ResolveState(null);
	}
	
	
	// fight back you idiots!
	
	action void A_PDFireHitscan(int damagemin,int damagemax,int count,double spread,double pitchoffs = 0.0,int flags = 0){
		A_StartSound(attacksound,CHAN_AUTO);
		
		double painratio = invoker.pain / GetSpawnHealth();
		if(painratio > 0.1){
			// stun increases spread by percent
			double pspread = spread * (1.0 + painratio);
			// also by a flat 1 degree per 25% stunratio
			// for those sharpshooters with low base spread
			pspread += painratio * 4.0;
			
			angle -= pspread * frandom(-1.0,1.0);
		}
		
		angle = normalize180(angle);
		
		flags = flags | CBAF_NORANDOM|CBAF_EXPLICITANGLE|CBAF_NOPITCH|CBAF_AIMFACING;
		for(int i = 0;i<count;i++){
			A_CustomBulletAttack(spread * frandom(-1.0,1.0),pitch + pitchoffs + spread * frandom(-1.0,1.0),1,random(damagemin,damagemax),"PDPuff",8192,flags);
		}
	}
	
	// this seems to be a little broken, particularly as far as pitch goes
	action void A_PDFireProjectile(class<actor> cls,double spread,double pitchoffs = 0.0,int flags = 0){
		A_StartSound(attacksound,CHAN_AUTO);
		
		double painratio = invoker.pain / GetSpawnHealth();
		if(painratio > 0.1){
			// stun increases spread by percent
			double pspread = spread * (1.0 + painratio);
			// also by a flat 1 degree per 25% stunratio
			// for those sharpshooters with low base spread
			pspread += painratio * 4.0;
			
			angle -= pspread * frandom(-1.0,1.0);
		}
		
		angle = normalize180(angle);
		
		flags = flags | CMF_AIMDIRECTION|CMF_SAVEPITCH;
		A_SpawnProjectile(cls,32,0,spread * frandom(-1.0,1.0),flags,pitch + pitchoffs + spread * frandom(-1.0,1.0));
	}
}