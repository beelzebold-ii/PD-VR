// AHH GET IT OFF ME GET IT OFF ME
class PDPinky:PDMonster replaces demon{
	default{
		Seesound "demon/sight";
		Attacksound "";
		Painsound "demon/pain";
		Deathsound "demon/death";
		Activesound "demon/active";
		
		Painchance 130;
		Speed 8;
		Health 140;
		PDMonster.bloodfactor 4.0; // 560 total blood
		PDMonster.stuntolerance 0.75;
		PDMonster.helmet true;
		
		MinMissilechance 200;
		MeleeThreshold 128;
		MeleeRange 54; // 10 units higher than default; should prevent the ability to just. shimmy
		
		Obituary "%o was mauled by a demon.";
	}
	
	override int DamageMobj(actor inflictor,actor source,int damage,name mod,int flags,double hangle){
		// unarmored from behind; quite a fair bit of armor from the front
		if(!inflictor) return super.DamageMobj(inflictor,source,damage,mod,flags,hangle);
		if(AbsAngle(angle,AngleTo(inflictor)) > 75){
			mularmor = 0;
			subarmor = 0;
		}else{
			mularmor = 40;
			subarmor = 3;
		}
		return super.DamageMobj(inflictor,source,damage,mod,flags,hangle);
	}
	
	states{
	spawn:
		SARG AAAAAAAAAAAAAAAA random(3,5) A_Look();
		SARG A random(2,6);
		SARG AAAAAAAAAAAAAAAA random(3,5) A_Look();
		SARG A random(2,6) A_Jump(32,"idle");
	idle:
		SARG BABA 12;
		goto spawn;
	see:
		SARG AABBCCDD 2 A_Chase();
		loop;
	melee:
		TNT1 A 0 A_CheckStun("stun");
		SARG E 2 A_StartSound("demon/melee");
		SARG EFF 2 A_Chase(null,null);
		SARG G 13 A_CustomMeleeAttack(10 * random(3,6),"","",'maul');
		SARG F 8;
		SARG ABAB 8;
		goto see;
	missile:
		TNT1 A 0 A_CheckStun("stun");
		SARG ABAB 2 A_FaceTarget();
		SARG AABBCCDDAABBCCDDAABBCCDDAABBCCDDAABBCCDDAABBCCDD 1 {
			A_ChangeVelocity(8,0,vel.z,CVF_RELATIVE|CVF_REPLACE);
			if(Distance3D(target) < 64) return resolvestate("missile0");
			return resolvestate(null);
		}
		TNT1 A 0 A_JumpIfCloser(64,"missile0");
		goto missile0fail;
	missile0:
		SARG E 2 A_StartSound("demon/melee");
		SARG EFF 2 A_Chase(null,null,CHF_STOPIFBLOCKED);
		SARG G 13 A_CustomMeleeAttack(10 * random(3,6),"","",'maul');
		SARG F 8;
	missile0fail:
		SARG ABABAB 16;
		goto see;
	stun:
		SARG H 2 A_SetAngle(angle + 180 + random(-90,90));
	pain:
		SARG H 2;
		SARG H 8 A_Pain();
		SARG H 0 A_JumpIf(stun > GetSpawnHealth() * 0.8,"see");
		SARG AABBCCDDAABBCCDD 3 A_Wander();
		goto see;
	death:
		SARG H 0 A_Scream();
	death.headshot:
	death.bleedout:
		SARG I 6;
		SARG J 5;
		SARG K 4 A_NoBlocking();
		SARG LM 3;
		SARG N -1;
		stop;
	raise:
		SARG MLKJI 5;
		goto see;
	}
}

class PDSpectre:PDPinky replaces spectre{
	default{
		Speed 7;
		Health 100;
		Painchance 160;
	}
	override void tick(){
		super.tick();
		if(!target || target.health <= 0 || health <= 0){
			A_SetRenderStyle(0.8,STYLE_TRANSLUCENT);
		}else{
			A_SetRenderStyle(0.8,STYLE_FUZZY);
			if(!random(0,2)){
				if(random(0,2))
					A_SetRenderStyle(0.1,STYLE_NONE);
				else
					A_SetRenderStyle(0.4,STYLE_SUBTRACT);
			}
		}
	}
}