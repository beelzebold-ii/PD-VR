// not a little red guy with a pitchfork.
// bit hardier than a human.
class PDFireballer:PDZombie replaces doomimp{
	default{
		+NOINFIGHTSPECIES;
		
		Species "PDFireballer";
		
		Seesound "imp/sight";
		Attacksound "imp/attack";
		Painsound "imp/pain";
		Deathsound "imp/death";
		Activesound "imp/active";
		
		Speed 10;
		Health 120;
		MinMissilechance 200;
		PDMonster.bloodfactor 100./120. + 0.01;
		
		Obituary "%o was burnt by an imp.";
	}
	states{
	spawn:
		TROO AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		TROO A random(2,6);
		TROO AAAAAAAAAAAAAAAA random(3,5) A_LookEx(0,0,8192,8192,160);
		TROO A random(2,6) A_Jump(32,"idle");
	idle:
		TROO BABA 12;
		goto spawn;
	see:
		TROO AABBCCDD 2 A_Chase();
		loop;
	missile:
		TROO A 0 A_JumpIfCloser(random(512,1024),"missile1",true);
		TROO EEEEEEE 1 A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 8 A_PDFireProjectile("PDImpFireball3",0.5,0.5);
		TROO F 4;
	missile0:
		TROO E 1{
			if(!random(0,3)) A_SetTics(random(20,30));
		}
		TROO E random(5,15) A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 8 A_PDFireProjectile("PDImpFireball3",0.5,0.5);
		TROO F 4 A_JumpIf(Distance2D(target) > random(256,1024) && random(0,5),"missile0");
		goto see;
	missile1:
		TNT1 A 0 A_CheckStun();
		TROO A 0 A_Jump(96,"missile2");
		TROO EEEEEE 1 A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 8 A_PDFireProjectile("PDImpFireball",1.5,1.0);
		TROO F 6;
		goto see;
	missile2:
		TROO EEEEEE 1 A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 8 A_PDFireProjectile("PDImpFireball",2.5,1.0);
		TROO F 4;
		TROO EEEE 1 A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 8 A_PDFireProjectile("PDImpFireball",2.5,1.5);
		TROO F 4;
		TROO EEEEEEEEE 1 A_FaceTarget(0,90,0,0,FAF_MIDDLE);
		TROO F 4;
		TROO G 12{
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
			A_PDFireProjectile("PDImpFireball2",3.5,1.5);
		}
		TROO F 8;
		goto see;
	pain:
		TROO H 2;
		TROO H 8 A_Pain();
		goto see;
	death:
		TROO H 0 A_Scream();
	death.headshot:
	death.bleedout:
		TROO I 6;
		TROO J 5;
		TROO K 4 A_NoBlocking();
		TROO L 3;
		TROO M -1;
		stop;
	death.xdeath:
		TROO N 2 A_XScream();
		TROO O 3;
		TROO P 3 A_NoBlocking();
		TROO QRST 4;
		TROO U -1;
		stop;
	raise:
		TROO LKJI 5;
		goto see;
	}
}

class PDImpFireball:actor{
	default{
		PROJECTILE;
		-NOGRAVITY;
		Gravity 0.1;
		Speed 20;
		Radius 6;
		Height 8;
		Damagefunction (10 * random(2,4));
		Damagetype 'hot';
	}
	states{
	spawn:
		BAL1 ABABABABABABABAB 4 bright;
		BAL1 ABABABABABABABAB 4 bright;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL1 CDE 6 bright;
		stop;
	}
}
class PDImpFireball2:PDImpFireball{
	default{
		Gravity 0.25;
		Speed 30;
		Radius 4;
		Height 5;
		Scale 0.6;
		Damagefunction (4 * random(2,4));
	}
	states{
	spawn:
		BAL1 ABABABABABABABAB random(2,4) bright;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL1 CDE random(2,6) bright;
		stop;
	}
}
class PDImpFireball3:PDImpFireball{
	default{
		Gravity 0.02;
		Speed 40;
		Radius 4;
		Height 5;
		Scale 0.6;
		Damagefunction (4 * random(2,4));
	}
	states{
	spawn:
		BAL1 AB 3 bright;
		loop;
	death:
		TNT1 A 0{
			bNOGRAVITY = true;
		}
		BAL1 CDE random(2,6) bright;
		stop;
	}
}