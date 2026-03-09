// bunch o brainless dickheads with guns
class PDZombie:PDMonster{
	default{
		Health 100;
		Speed 9; // base behavior should be calling A_Chase every 2 ticks
		Painchance 240;
		Radius 20;
		Height 56;
		Seesound "grunt/sight";
		Attacksound "grunt/attack";
		Painsound "grunt/pain";
		Deathsound "grunt/death";
		Activesound "grunt/active";
		
		Reactiontime 2;
		MinMissilechance 140;
	}
}

class PDPistolZombie:PDZombie replaces zombieman{
	default{
		Obituary "%o was shot by a possessed gunner.";
		Dropitem "PDPistolAmmo";
	}
	states{
	spawn:
		POSS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		POSS A random(2,6);
		POSS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		POSS A random(2,6) A_Jump(32,"idle");
	idle:
		POSS BABA 12;
		goto spawn;
	see:
		POSS AABBCCDD 2 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun();
		POSS E 2 A_FaceTarget(); // pre-face target so that its starting angle for the attack is already there
		POSS EEE random(4,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		POSS F 3 bright A_PDFireHitscan(10,20,1,3.0,-0.0);
		POSS E random(4,10) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		POSS F 3 bright A_PDFireHitscan(10,20,1,5.5,-2.0);
		POSS E 10 A_JumpIfCloser(random(128,1024),"missile2",true);
		POSS E random(4,10) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		POSS F 3 bright A_PDFireHitscan(10,20,1,5.5,-2.0);
		POSS E 10;
		goto see;
	missile2:
		POSS E 1{
			if(!random(0,1)) A_SetTics(random(10,20));
		}
		POSS E random(6,10) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		POSS F 3 bright A_PDFireHitscan(10,20,1,5.5,-2.0);
		POSS E random(7,10) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		POSS F 3 bright A_PDFireHitscan(10,20,1,5.5,-3.0);
		POSS E 12 A_JumpIfCloser(random(32,512),"missile2",true);
		goto see;
	pain:
		POSS G 2;
		POSS G 8 A_Pain();
		goto see;
	death:
		POSS G 0 A_Scream();
	death.headshot:
	death.bleedout:
		POSS H 6;
		POSS I 5;
		POSS J 4 A_NoBlocking();
		POSS K 3;
		POSS L -1;
		stop;
	death.xdeath:
		POSS M 2 A_XScream();
		POSS N 3;
		POSS O 3 A_NoBlocking();
		POSS PQRST 4;
		POSS U -1;
		stop;
	raise:
		POSS KJIH 5;
		goto see;
	}
}

class PDShotGuySpawner:randomspawner replaces shotgunguy{
	default{
		Dropitem "PDShotgunZombie",255,2;
		Dropitem "PDVectorZombie",255,1;
	}
}

class PDShotgunZombie:PDZombie{
	default{
		Obituary "%o was blasted by a shotgunner.";
		Attacksound "shotguy/attack";
		Dropitem "PDPumpShotgun";
		
		PDMonster.armorlv 10,5;
	}
	states{
	spawn:
		SPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		SPOS A random(2,6);
		SPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		SPOS A random(2,6) A_Jump(32,"idle");
	idle:
		SPOS BABA 12;
		goto spawn;
	see:
		SPOS AABBCCDD 3 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun();
		SPOS E 4 A_FaceTarget(); // pre-face target so that its starting angle for the attack is already there
		SPOS EEEE random(4,7) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		SPOS F 0{
			angle -= frandom(-2.5,2.5);
		}
		// shotgunguys actually *are* having their shotguns nerfed slightly
		// from avg damage of 120 to avg damage of 108
		SPOS F 3 bright A_PDFireHitscan(5,13,12,1.7,frandom(-1.0,1.0));
		SPOS E 18 A_JumpIfCloser(random(32,512),"missile2",true);
		goto see;
	missile2:
		SPOS E 10;
		SPOS E random(8,10) A_FaceTarget(30,90,0,0,FAF_MIDDLE);
		SPOS F 0{
			angle -= frandom(-4.5,4.5);
		}
		SPOS F 3 bright A_PDFireHitscan(5,13,12,1.7,frandom(-1.0,1.0));
		SPOS E random(8,10) A_FaceTarget(30,90,0,0,FAF_MIDDLE);
		SPOS E 22;
		goto see;
	pain:
		SPOS G 2;
		SPOS G 8 A_Pain();
		goto see;
	death:
		SPOS G 0 A_Scream();
	death.headshot:
	death.bleedout:
		SPOS H 6;
		SPOS I 5;
		SPOS J 4 A_NoBlocking();
		SPOS K 3;
		SPOS L -1;
		stop;
	death.xdeath:
		SPOS M 2 A_XScream();
		SPOS N 3;
		SPOS O 3 A_NoBlocking();
		SPOS PQRST 4;
		SPOS U -1;
		stop;
	raise:
		SPOS KJIH 5;
		goto see;
	}
}
class PDVectorZombie:PDZombie{
	default{
		Obituary "%o was saturated by a trooper.";
		Dropitem "PDKVector";
		Translation "178:178=204:204", "172:172=197:197";
		
		PDMonster.armorlv 10,5;
	}
	states{
	spawn:
		SPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		SPOS A random(2,6);
		SPOS AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		SPOS A random(2,6) A_Jump(32,"idle");
	idle:
		SPOS BABA 12;
		goto spawn;
	see:
		SPOS AABBCCDD 3 A_Chase();
		loop;
	missile:
		TNT1 A 0 A_CheckStun();
		SPOS E 4 A_FaceTarget(); // pre-face target so that its starting angle for the attack is already there
		SPOS EEEE random(3,6) A_FaceTarget(15,90,0,0,FAF_MIDDLE);
		SPOS F 1 bright A_PDFireHitscan(10,30,1,1.0,0.3);
		SPOS E 1 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		SPOS F 1 bright A_PDFireHitscan(10,30,1,1.3,frandom(-0.5,0.1));
		SPOS E 12 A_JumpIfCloser(random(128,2048),"missile2",true); // if far enough away, just do a short burst
		SPOS E 0 A_Jump(32,"see");
		goto see;
	missile2:
		SPOS E 1 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		SPOS F 1 bright A_PDFireHitscan(10,30,1,1.3,frandom(-0.5,0.1));
		SPOS E 1 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		SPOS F 1 bright A_PDFireHitscan(10,30,1,1.65,frandom(-1.0,-0.2));
		SPOS E 12 A_JumpIfCloser(random(-128,512),"missile2",true); // spray n pray at really close range
		SPOS E 0 A_Jump(32,"see");
	missile3:
		SPOS E 0 A_CheckStun();
		SPOS E 1 A_FaceTarget(2,90,0,0,FAF_MIDDLE);
		SPOS F 1 bright A_PDFireHitscan(10,30,1,1.9,frandom(-1.2,-0.2));
		SPOS E random(8,10) A_FaceTarget(30,90,0,0,FAF_MIDDLE); // briefly re aim
		SPOS E 12 A_JumpIfCloser(random(32,1024),"missile2",true); // and immediately start firing again
		SPOS E 0 A_Jump(96,"see");
		goto missile; // do a more thorough readjustment
	pain:
		SPOS G 2;
		SPOS G 8 A_Pain();
		goto see;
	death:
		SPOS G 0 A_Scream();
	death.headshot:
	death.bleedout:
		SPOS H 6;
		SPOS I 5;
		SPOS J 4 A_NoBlocking();
		SPOS K 3;
		SPOS L -1;
		stop;
	death.xdeath:
		SPOS M 2 A_XScream();
		SPOS N 3;
		SPOS O 3 A_NoBlocking();
		SPOS PQRST 4;
		SPOS U -1;
		stop;
	raise:
		SPOS KJIH 5;
		goto see;
	}
}