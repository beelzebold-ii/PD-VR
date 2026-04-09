// what the fuck are you doing on my land?
class PDKnight:PDFireballer replaces hellknight{
	default{
		Species "PDNoble";
		
		Seesound "knight/sight";
		Attacksound "imp/attack";
		Painsound "knight/pain";
		Deathsound "knight/death";
		Activesound "knight/active";
		
		Speed 10;
		Health 500;
		Mass 350;
		Painchance 170;
		PainThreshold 12;
		MinMissilechance 175;
		PDMonster.bloodfactor 2.0;
		PDMonster.armorlv 15,2;
		PDMonster.helmet true;
		PDMonster.stuntolerance 0.6;
		
		Scale 0.85;
		Height 55;
		Radius 21;
		
		Obituary "%o was lanced by a knight.";
	}
	states{
	spawn:
		BOS2 AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOS2 A random(2,6);
		BOS2 AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOS2 A random(2,6) A_Jump(32,"idle");
	idle:
		BOS2 BABA 6;
		goto spawn;
	see:
		BOS2 AABBCCDD 2 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun("missile0");
		BOS2 A 0 A_JumpIfCloser(random(0,192),"missile1",true);
		BOS2 EEEEE 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		BOS2 F 4 A_PDProjectileLead(14,target,45);
		BOS2 G 10 A_PDFireProjectile("PDKnightFireball",0.5,0.);
		BOS2 F 6;
		BOS2 A 4 A_JumpIfCloser(random(-128,512),"missile",true);
		goto see;
	missile0:
		TNT1 A 0 A_Jump(128,"pain");
	missile1: // panicfire
		BOS2 A 1 A_FaceTarget(20);
		BOS2 EEE 2 A_FaceTarget(5,90,0,0,FAF_MIDDLE);
		BOS2 F 4;
		BOS2 G 8 A_PDFireProjectile("PDKnightFireball",5.0,1.0);
		BOS2 F 6;
		BOS2 A 0 A_JumpIfCloser(random(32,192),"missile1",true);
		goto see;
	pain:
		BOS2 H 2;
		BOS2 H 8 A_Pain();
		goto see;
	death:
		BOS2 H 0 A_Scream();
	death.headshot:
	death.bleedout:
		BOS2 I 6;
		BOS2 J 5;
		BOS2 K 4 A_NoBlocking();
		BOS2 LMN 3;
		BOS2 O -1;
		stop;
	raise:
		BOS2 LKJI 5;
		goto see;
	}
}

class PDKnightFireball:PDImpFireball{
	default{
		Gravity 0.02;
		Speed 14;
		Radius 6;
		Height 9;
		Scale 0.6;
		Damagefunction (12 * random(2,4));
	}
	states{
	spawn:
		BAL7 AB 3 bright;
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL7 CDE random(2,6) bright;
		stop;
	}
}

class PDBaronSpawner:actor replaces baronofhell{
	override void PostBeginPlay(){
		name map=level.mapname;
		if(map=='e1m8'){
			A_SpawnItemEx("PDMarquess");
		}else{
			if(!random(0,4))
				A_SpawnItemEx("PDMarquess");
			else
				A_SpawnItemEx("PDBaron");
		}
	}
}

class PDBaron:PDKnight{
	default{
		Species "PDNoble";
		
		Seesound "baron/sight";
		Attacksound "imp/attack";
		Painsound "baron/pain";
		Deathsound "baron/death";
		Activesound "baron/active";
		
		Speed 8;
		Health 800;
		Mass 550;
		Painchance 120;
		PainThreshold 11;
		MinMissilechance 200;
		PDMonster.bloodfactor 2.2;
		PDMonster.armorlv 15,5;
		PDMonster.helmet true;
		PDMonster.stuntolerance 0.6;
		
		Scale 0.925;
		Height 60;
		Radius 22;
		
		Obituary "%o was evicted by a baron.";
		
		+BOSS;
	}
	states{
	spawn:
		BOSS AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOSS A random(2,6);
		BOSS AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOSS A random(2,6) A_Jump(32,"idle");
	idle:
		BOSS BABA 6;
		goto spawn;
	see:
		BOSS AABBCCDD 3 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun("missile0");
		BOSS A 1 A_FaceTarget();
		BOSS A 0 A_JumpIfCloser(random(0,192),"missile1",true);
		BOSS EEEE 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		BOSS F 4 A_PDProjectileLead(16,target,45);
		BOSS G 0 A_PDFireProjectile("PDBaronFireballA",0.1,0.);
		BOSS G 10 A_PDFireProjectile("PDBaronFireballB",0.1,0.);
		BOSS F 6;
		BOSS A 4 A_JumpIfCloser(random(-128,512),"missile",true);
		goto see;
	missile0:
		TNT1 A 0 A_Jump(64,"pain");
	missile1: // panicfire
		BOSS A 1 A_FaceTarget(20);
		BOSS EEE 2 A_FaceTarget(5,90,0,0,FAF_MIDDLE);
		BOSS F 4;
		BOSS G 8{
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",7.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",7.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",9.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",9.0,0.);
		}
		BOSS F 6;
		BOSS A 0 A_JumpIfCloser(random(32,192),"missile1",true);
		goto see;
	pain:
		BOSS H 2;
		BOSS H 8 A_Pain();
		goto see;
	death:
		BOSS H 0 A_Scream();
	death.headshot:
	death.bleedout:
		BOSS I 6;
		BOSS J 5;
		BOSS K 4 A_NoBlocking();
		BOSS LMN 3;
		BOSS O -1 A_BossDeath();
		stop;
	raise:
		BOSS LKJI 5;
		goto see;
	}
}

class PDBaronFireballA:PDImpFireball{
	default{
		Gravity 0.02;
		Speed 18;
		Radius 6;
		Height 9;
		Scale 0.6;
		Damagefunction (6 * random(3,5));
	}
	states{
	spawn:
		BAL7 AAABBB 1 bright A_Weave(2,0,2.0,0.0);
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL7 CDE random(2,6) bright;
		stop;
	}
}
class PDBaronFireballB:PDImpFireball{
	default{
		Gravity 0.02;
		Speed 18;
		Radius 6;
		Height 9;
		Scale 0.6;
		Damagefunction (6 * random(3,5));
	}
	states{
	spawn:
		BAL7 AAABBB 1 bright A_Weave(2,0,-2.0,0.0);
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL7 CDE random(2,6) bright;
		stop;
	}
}
class PDBaronFireballSmall:PDImpFireball{
	default{
		Gravity 0.04;
		Speed 14;
		Radius 6;
		Height 9;
		Scale 0.6;
		Damagefunction (4 * random(1,5));
	}
	states{
	spawn:
		BAL7 A 0 A_SetSpeed(random(10,14));
	spawn2: // hmm, what will this do?
		BAL7 AAABBB 1 bright A_Weave(2,0,frandom(-3.0,3.0),0.0);
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL7 CDE random(2,6) bright;
		stop;
	}
}

// basically just bigger, tougher, meaner barons.
class PDMarquess:PDBaron{
	default{
		Species "PDNoble";
		
		Seesound "baron/sight";
		Attacksound "imp/attack";
		Painsound "baron/pain";
		Deathsound "baron/death";
		Activesound "baron/active";
		
		Speed 8;
		Health 1200;
		Mass 650;
		Painchance 90;
		PainThreshold 11;
		MinMissilechance 180;
		PDMonster.bloodfactor 5.0; // virtually inexsanguinable
		PDMonster.armorlv 15,6;
		PDMonster.helmet true;
		PDMonster.stuntolerance 0.6;
		
		Translation "PDMarquess";
		
		Scale 1.0;
		Height 68;
		Radius 26;
		
		Obituary "%o was eviscerated by a marquess.";
		
		+BOSS;
		+E1M8BOSS;
	}
	states{
	spawn:
		BOSS AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOSS A random(2,6);
		BOSS AAAAAAAAAAAAAAAA random(3,5) A_Look();
		BOSS A random(2,6) A_Jump(32,"idle");
	idle:
		BOSS BABA 6;
		goto spawn;
	see:
		BOSS AABBCCDD 2 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun("missile0");
		BOSS A 1 A_FaceTarget();
		BOSS A 0 A_JumpIfCloser(random(0,192),"missile1",true);
		BOSS EEEEE 2 A_FaceTarget(4,90,0,0,FAF_MIDDLE);
		BOSS F 4 A_PDProjectileLead(16,target,45);
		BOSS G 0 A_PDFireProjectile("PDBaronFireballA",0.1,0.);
		BOSS G 10 A_PDFireProjectile("PDBaronFireballB",0.1,0.);
		BOSS F 6;
		BOSS A 4 A_JumpIfCloser(random(-128,512),"missile",true);
		goto see;
	missile0:
		TNT1 A 0 A_Jump(96,"pain");
	missile1: // panicfire
		BOSS A 1 A_FaceTarget(20);
		BOSS EEE 2 A_FaceTarget(5,90,0,0,FAF_MIDDLE);
		BOSS F 4;
		BOSS G 8{
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",5.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",7.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",7.0,0.);
			A_PDFireProjectile("PDBaronFireballSmall",7.0,0.);
		}
		BOSS F 6;
		BOSS A 0 A_JumpIfCloser(random(32,192),"missile1",true);
		goto see;
	pain:
		BOSS H 2;
		BOSS H 8 A_Pain();
		goto see;
	death:
		BOSS H 0 A_Scream();
	death.headshot:
	death.bleedout:
		BOSS I 6;
		BOSS J 5;
		BOSS K 4 A_NoBlocking();
		BOSS LMN 3;
		BOSS O -1 A_BossDeath();
		stop;
	raise:
		BOSS LKJI 5;
		goto see;
	}
}