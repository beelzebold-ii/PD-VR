// weapon randomspawners!

class pd_sgspawn:randomspawner replaces shotgun{
	default{
		dropitem "PDPumpShotgun",255,3;
		dropitem "PDKVector",255,1;
	}
}
class pd_cgspawn:randomspawner replaces chaingun{
	default{
		dropitem "PDKVector",255,2;
		dropitem "PDSIG",255,4;
		dropitem "PDFamas",255,1;
		dropitem "PDMachinegun",255,2;
	}
}
class pd_rlspawn:randomspawner replaces rocketlauncher{
	default{
		dropitem "PDFamas",255,1;
		dropitem "PDMachinegun",255,2;
		//dropitem "PDLauncher",255,5; // someday... when I'm less lazy lol
	}
}