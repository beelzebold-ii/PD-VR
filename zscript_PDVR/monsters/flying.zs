// SHOOT IT DOWN!
class PDTrilobite:PDMonster replaces cacodemon{
	default{
		+FLOAT;
		+NOGRAVITY;
		
		Seesound "caco/sight";
		Attacksound "imp/attack";
		Painsound "caco/pain";
		Deathsound "caco/death";
		Activesound "caco/active";
		
		Speed 7;
		Health 666;
		Mass 500;
		Painchance 180;
		PainThreshold 10;
		MinMissilechance 140;
		PDMonster.bloodfactor 0.5; // you're pretty much intended to bleed them out
		PDMonster.helmet true;
		PDMonster.stuntolerance 0.75; // very hard to stun; you want them dead *now*
		
		Scale 0.8;
		Height 44;
		radius 24;
		
		Obituary "%o was electrocuted by a cacodemon.";
	}
	states{
	spawn:
		HEAD AAAAAAAAAAAAAAAA random(3,5) A_Look();
		HEAD A random(2,6);
		HEAD AAAAAAAAAAAAAAAA random(3,5) A_Look();
		HEAD A random(2,6) A_Jump(32,"idle");
	idle:
		HEAD EFEA 6;
		goto spawn;
	see:
		HEAD A 2 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun("see");
		HEAD A 0 A_JumpIfCloser(random(800,1100),"missile0");
		goto missile1;
	missile0: // standard attack
		HEAD BBBB 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		HEAD C 4;
		HEAD D 10 A_PDFireProjectile("PDTriloBall",2.5,0);
		HEAD C 6 A_Chase(null,null);
		HEAD A 4 A_JumpIfCloser(random(0,512),"missile",true);
		TNT1 A 0 A_Jump(192,"missile"); // even if that above check fails, we still have a 75% chance to continue
		HEAD BBBBBBBBBBBB 2 A_FaceTarget(3,90,0,0,FAF_MIDDLE);
		HEAD C 4;
		HEAD DD 1 A_PDFireProjectile("PDTriloBall",4.5,0);
		HEAD D 7;
		HEAD C 6;
		goto see;
	missile1: // saturate the target as much as possible from long ranges
		HEAD BBBB 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		HEAD C 4;
		HEAD DDDDDDDDDD 1 A_PDFireProjectile("PDTriloBall",2.5,0);
		HEAD C 6 A_Chase(null,null);
		HEAD BBBB 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		HEAD C 4;
		HEAD DDDDDDDDDD 1 A_PDFireProjectile("PDTriloBall",2.5,0);
		HEAD C 6 A_Chase(null,null);
		HEAD BBBB 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		HEAD C 4;
		HEAD DDDDDDDDDD 1 A_PDFireProjectile("PDTriloBall",2.5,0);
		HEAD C 6 A_Chase(null,null);
		goto see;
	pain:
		HEAD E 4;
		HEAD F 6 A_Pain();
		goto see;
	death:
		HEAD H 0 A_Scream();
	death.headshot:
	death.bleedout:
		HEAD G 6;
		HEAD H 5;
		HEAD I 4 A_NoBlocking();
		HEAD JK 3;
		HEAD L -1;
		stop;
	raise:
		HEAD KJIHG 5;
		goto see;
	}
}

class PDTriloBall:PDImpFireball{
	default{
		Gravity 0.00;
		Speed 20;
		Radius 6;
		Height 9;
		Scale 0.6;
		Damagefunction (12 * random(2,4));
	}
	states{
	spawn:
		BAL2 AB random(3,6) bright;
		TNT1 A 0 A_SetSpeed(random(4,10));
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL2 CDE random(3,6) bright;
		stop;
	}
}