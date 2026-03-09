//note: def check what using weapon.a_setcrosshair does
//note: player has member offhandweapon which is the readyweapon in the offhand
//note: look into playerpawn.offhanddir and playerpawn.attackdir // I'm an idiot and forgot abt that entirely
//note: lineattack flags seems to include a flag for if the offhand is used, hopefully so do projectile ones
// that would make hand tracking almost trivial with an eventhandler spawning things from player hands
// and tracking those actors' positions as the player's hand positions
//note: button 64 lights up when holding left hand grip button
version "3.6"

#include "zscript_PDVR/zshud.zs"
//#include "zscript_PDVR/armhud.zs" // no dice

#include "zscript_PDVR/player/handtracking.zs"
#include "zscript_PDVR/player/player.zs"
#include "zscript_PDVR/player/roomscale.zs"

#include "zscript_PDVR/weaponbase/weapon.zs"
#include "zscript_PDVR/weaponbase/weaponmodel.zs"
#include "zscript_PDVR/weaponbase/bulletpuffs.zs"
#include "zscript_PDVR/weaponbase/offhand.zs"
#include "zscript_PDVR/weaponbase/weaponsights.zs"

#include "zscript_PDVR/weapons/ammotypes.zs"
#include "zscript_PDVR/weapons/fist.zs"
#include "zscript_PDVR/weapons/pistol.zs"
#include "zscript_PDVR/weapons/shotguns.zs"
#include "zscript_PDVR/weapons/vector.zs"
#include "zscript_PDVR/weapons/rifles.zs"
#include "zscript_PDVR/weapons/machinegun.zs"
#include "zscript_PDVR/weapons/sights.zs"
#include "zscript_PDVR/weapons/spawners.zs"

#include "zscript_PDVR/monsterbase/monster.zs"

#include "zscript_PDVR/monsters/zombies.zs"
#include "zscript_PDVR/monsters/imp.zs"
#include "zscript_PDVR/monsters/marines.zs"

#include "zscript_PDVR/weapons/invmanager.zs"
#include "zscript_PDVR/items/armor.zs"