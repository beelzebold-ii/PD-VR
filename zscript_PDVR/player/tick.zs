// this code was getting kinda long, so I'm putting it here

const STIM_OVERDOSE = 1700;
const STIM_ODAMOUNT = 175; // for every 175 tics of stim overdose, add 1 dmg

extend class PDPlayerPawn{
	// ticks of stimpack effect
	int stimulation;
	
	string deathtip;
	int deathtics;
	
	override void tick(){
		super.Tick();
		
		if(health>0){
			// bleed out.
			// no bloodloss when bearing any protection power
			if(openwounds >= 4.0 && !FindInventory("PowerProtection",true)){
				// wounds add 2 pain each up to 25
				// stims cut that amount down by 25%
				pain = max(pain,min(openwounds * 2,50) * (stimulation?0.75:1.0));
				// bleeds at a rate of 0.0033/tic/point
				// bandaged wounds still bleed at 5% the normal rate
				// stims cut down bloodloss to 50% while active
				// that may sound like a lot but consider their relatively short duration
				bloodloss += ((openwounds - patchedwounds * 0.95) / 300.) * (stimulation?0.5:1.0);
				// bloodloss adds base fatigue and beyond 60% also adds base stun
				stun = max(stun,bloodloss - 60.);
				fatigue = max(fatigue,bloodloss * 0.75);
				// subtle red flash which gets more frequent the more you're bleeding
				// I almost missed a divide by zero here lmao
				// this case is another w for n/0 = inf tho
				if(openwounds - patchedwounds > 0){
					if(gametic % floor(1500 / (openwounds - patchedwounds)) == 0){
						A_SetBlend("660000",0.11 + openwounds*0.0022,8 + floor(openwounds/10));
					}
				}
			}
			// you are dying!!! get your sleepy ass up!!!
			if(bloodloss >= 90.){
				// past 90% bloodloss take about 0.8 damage/sec
				// past 110% bloodloss take abt 3.9 damage/sec
				// past 120% bloodloss take abt 11.7 damage/sec
				if(gametic%45 == 0){
					actor bleedcauser = self;
					if(player.attacker) bleedcauser = player.attacker;
					DamageMobj(self,bleedcauser,1,'bleedout');
					if(bloodloss >= 110.)
						DamageMobj(self,bleedcauser,4,'bleedout');
					if(bloodloss >= 120.)
						DamageMobj(self,bleedcauser,10,'bleedout');
				}
			}
		}else{
			// I don't rly like that thing where you face the enemy that killed you
			// I wish I could leave turning enabled as it's a bit jarring to not
			// be able to turn at all but whatever
			player.attacker = self;
		}
		
		// detect if the mainhand weapon is currently being stabilized by the offhand
		twohanding = player.WeaponState & WF_TWOHANDSTABILIZED;
		
		// get roomscale gesture values
		RoomscaleTick();
		// handle artifact belt stuff
		// 1. this isn't finished yet 2. I suspect it of causing issues so it's canned for now
		//ArtifactBeltTick();
		
		// strip vanilla armor if for some reason we have any
		let varm = FindInventory("armor",true);
		if(varm) varm.destroy();
		
		PDPSetSpeed();
		
		// if running, build fatigue, then stun
		bool running = (player.cmd.buttons & BT_RUN) ^ Cvar.GetCvar("cl_run",player).GetBool();
		if(running && vel.xy.Length() > 0.1){
			if(fatigue < 100){
				if(gametic % 3 == 0)
					fatigue++;
			}else{
				if(stun < 40)
					stun++;
			}
		}else{
			if(fatigue > random(-5,20) + bloodloss && stun < random(0,40) && gametic % 2 == 0) fatigue--;
		}
		
		// for holding use to see extra information
		bool pressuse = player.cmd.buttons & BT_USE;
		if(pressuse){
			if(usetics < 35)
				usetics++;
		}else{
			if(usetics > 0)
				usetics--;
		}
		
		// decay stun and pain
		if(stun > 0 + max(0,bloodloss - 40.) && stun >= random(-20,40) + max(0,bloodloss - 30.) && gametic%2 == 0) stun--;
		if(pain > 0 + max(0,openwounds) && gametic%20 == 0) pain--;
		
		// for some reason these can sometimes be negative. whatever.
		if(stun < 0) stun = 10;
		if(pain < 0) pain = 10;
		
		if(health > 0){
			// regenerate health
			if(stun <= 0 && fatigue <= 10 && pain - min(openwounds * 2,50) < random(25,75) && gametic%10 == 0){
				if(health < regenhealth && health < regenhealth - random(-7,20)){
					A_SetHealth(health + 1); //GiveBody activates a haptic feedback in the controllers, which is weird for passive regen.
					// for every point of health regenerated, 1/8 chance to also heal
					// one point of bloodloss
					if(bloodloss && !random(0,7))
						bloodloss--;
				}
			}
			
			// 1/4 chance every 2 seconds to regenerate one point of blood
			if(gametic % 70 == 0 && bloodloss && !random(0,3)){
				bloodloss--;
			}
			
			if(stimulation > 0){
				StimTick();
				if(stimulation == 1) StimEnd();
			}
		}else{
			// dying. dead.
			fatigue++;
			
			if(deathtics == 0)
				deathtip = PD_DEATHTIPS[random(0,25)];
			
			deathtics++;
		}
		
		bloodloss = max(0,bloodloss);
		bloodloss = min(150,bloodloss);
	}
	
	// stim effects!
	void StimTick(){
		stimulation--;
		
		// every 2 seconds, chance to increase max regen health
		if(gametic % 70 == 0 && !random(0,1)){
			regenhealth = min(100,regenhealth + random(1,2));
		}
		// guaranteed health regen every second
		if(gametic % 35 == 0 && health < regenhealth){
			A_SetHealth(health + 1);
		}
		// guaranteed blood regen every 4 seconds
		if(gametic % 140 == 0 && bloodloss){
			bloodloss--;
		}
		// extra pain decay every 6 tics
		if(pain > 0 && gametic % 6 == 0){
			pain--;
		}
		// extra stun decay every 6 tics
		if(stun > 0 && gametic % 6 == 0){
			stun--;
		}
		// extra fatigue decay every 5 tics
		// which means you can run for like over twice as long since standard
		// fatigue buildup is every 3 tics
		if(fatigue > 0 && gametic % 5 == 0){
			fatigue--;
		}
		
		// if you're overdosing, take a point of damage for every 5 seconds of overdose duration, every 20 tics
		if(gametic % 20 == 0){
			if(stimulation > STIM_OVERDOSE){
				int overstim = stimulation - STIM_OVERDOSE;
				overstim = floor(overstim / STIM_ODAMOUNT) + 1;
				
				DamageMobj(self,null,overstim,"stim");
			}
		}
	}
	void StimEnd(){
		// when stims wear off, all of that fatigue will be felt immediately
		fatigue = max(10,fatigue);
		fatigue += 30;
		stun += 15;
		pain += 10;
	}
}