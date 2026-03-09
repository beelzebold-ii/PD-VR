// your standard crackshots
class PDMarineSig:PDMonster{
	default{
		Health 100;
		Speed 9; // base behavior should be calling A_Chase every 2 ticks
		Painchance 170;
		Radius 20;
		Height 56;
		Seesound "";
		Attacksound "grunt/attack";
		Painsound "";
		Deathsound "player/death";
		Activesound "";
		
		Dropitem "PDSIG";
		
		Reactiontime 2;
		MinMissilechance 100;
		
		PDMonster.armorlv 20,19;
		PDMonster.helmet true;
		
		Translation "PDGreenMarine";
		
		Obituary "o% ran into another marine.";
	}
	states{
	spawn:
		PLAY AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		PLAY A random(2,6);
		PLAY AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		PLAY A random(2,6) A_Jump(32,"idle");
	idle:
		PLAY BABA 12;
		goto spawn;
	see:
		PLAY AABBCCDD 3 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun();
		PLAY A 0 A_JumpIfCloser(random(512,4096),"missile1");
		goto missile3;
	missile1: // start close range spray
		PLAY E 4 A_FaceTarget();
		PLAY E random(3,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,0.6,0.0);
		PLAY E 2 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,0.6,frandom(-0.3,-0.6));
		PLAY E 0 A_Jump(32,"see");
		PLAY E 12 A_JumpIfCloser(random(128,1024),"missile2",true); // if far enough away, just do a short burst
		goto see;
	missile2: // continue
		PLAY E 2 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,0.7,frandom(-0.2,-0.4));
		PLAY E 2 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,0.6,frandom(-0.1,-0.3));
		PLAY E 12 A_JumpIfCloser(random(-128,512),"missile2",true);
		PLAY E 0 A_Jump(64,"missile1");
		goto see;
	missile3: //start aiming for a long distance shot
		PLAY E 4{
			A_FaceTarget();
			A_SetTics((Distance2D(target) ** 0.7) * frandom(.15,.25));
		}
	missile4:
		PLAY E random(3,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,(200/(Distance2D(target)/10)) / 8,0.0);
		PLAY E 2 A_Jump(96,"see");
		PLAY E random(3,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,(200/(Distance2D(target)/10)) / 8,0.0);
		PLAY E 2 A_Jump(96,"see");
		PLAY E random(3,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		PLAY F 1 bright A_PDFireHitscan(24,48,1,(200/(Distance2D(target)/10)) / 8,0.0);
		PLAY E 10;
		goto see;
	pain:
		PLAY G 2;
		PLAY G 8 A_Pain();
		goto see;
	death:
		PLAY G 0 A_Scream();
	death.headshot:
	death.bleedout:
		PLAY H 6;
		PLAY I 5;
		PLAY J 4 A_NoBlocking();
		PLAY KLM 3;
		PLAY N -1;
		stop;
	death.xdeath:
		PLAY O 2 A_XScream();
		PLAY P 3;
		PLAY Q 3 A_NoBlocking();
		PLAY RSTUV 4;
		PLAY W -1;
		stop;
	raise:
		PLAY LKJIH 5;
		goto see;
	}
}


// also chaingunners since they fill the same spawnslot
class PDChaingunner:PDMonster{
	default{
		Health 130;
		Speed 9; // base behavior should be calling A_Chase every 2 ticks
		Painchance 120;
		Radius 20;
		Height 56;
		SeeSound "chainguy/sight";
		PainSound "chainguy/pain";
		DeathSound "chainguy/death";
		ActiveSound "chainguy/active";
		AttackSound "grunt/attack";
		
		Dropitem "PDMachinegun";
		
		Reactiontime 3;
		MinMissilechance 150;
		
		PDMonster.armorlv 20,15;
		
		Obituary "o% was mowed down by a chaingunner.";
	}
	states{
	spawn:
		CPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		CPOS A random(2,6);
		CPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		CPOS A random(2,6) A_Jump(32,"idle");
	idle:
		CPOS BABA 12;
		goto spawn;
	see:
		CPOS AABBCCDD 3 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun();
	missile1: // start close range spray
		CPOS A 4 A_FaceTarget();
		CPOS AB random(8,14) A_FaceTarget(6,90,0,0,FAF_MIDDLE);
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.6,0.0);
		CPOS E 1 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.6,frandom(-0.3,-0.6));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.9,frandom(-0.3,-0.6));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.1,frandom(-0.3,-0.9));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.3,frandom(-0.5,-1.1));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.1,frandom(-0.3,-0.9));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.3,frandom(-0.5,-1.1));
		CPOS E 0 A_Jump(32,"see");
		CPOS E 12 A_JumpIfCloser(random(256,2048),"missile2",true); // if far enough away, just do a short burst
		goto see;
	missile2: // brrrrrrrrt
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.9,frandom(-0.2,-0.4));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.0,frandom(-0.1,-0.3));
		CPOS E 1 A_FaceTarget(1,90,0,0,FAF_MIDDLE);
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.7,frandom(-0.2,-0.4));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.6,frandom(-0.2,-0.7));
		CPOS E 1;
		CPOS F 1 bright A_PDFireHitscan(24,40,1,0.7,frandom(-0.2,-0.4));
		CPOS E 1 A_FaceTarget(1,90,0,0,FAF_MIDDLE);
		CPOS F 1 bright A_PDFireHitscan(24,40,1,1.0,frandom(-0.1,-0.3));
		CPOS E 12 A_JumpIfCloser(random(0,2048),"missile2",true);
		CPOS E 0 A_Jump(196,"missile1");
		goto see;
	pain:
		CPOS G 2;
		CPOS G 8 A_Pain();
		goto see;
	death:
		CPOS G 0 A_Scream();
	death.headshot:
	death.bleedout:
		CPOS H 6;
		CPOS I 5;
		CPOS J 4 A_NoBlocking();
		CPOS KLM 3;
		CPOS N -1;
		stop;
	death.xdeath:
		CPOS O 2 A_XScream();
		CPOS P 3;
		CPOS Q 3 A_NoBlocking();
		CPOS RS 4;
		CPOS T -1;
		stop;
	raise:
		CPOS LKJIH 5;
		goto see;
	}
}

class PDChainGuySpawner:randomspawner replaces chaingunguy{
	default{
		Dropitem "PDMarineSIG",255,2;
		Dropitem "PDChaingunner",255,1;
	}
}