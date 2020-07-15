class stubZBoss extends ZombieBoss;


var bool bInitialized;


//=============================================================================
//                              ammo class == none fix
//=============================================================================

state nFireMissile
{
  function AnimEnd( int Channel )
  {
    local vector Start;
    local Rotator R;

    Start = GetBoneCoords('tip').Origin;

    // at least shoot at someone, not walls
    if (Controller.Target == none)
      Controller.Target = Controller.Enemy;

    // fix MyAmmo none logs
    if ( !SavedFireProperties.bInitialized )
    {
      SavedFireProperties.AmmoClass = class'SkaarjAmmo';
      SavedFireProperties.ProjectileClass = class'BossLAWProj';
      SavedFireProperties.WarnTargetPct = 0.15;
      SavedFireProperties.MaxRange = 10000;
      SavedFireProperties.bTossed = false;
      SavedFireProperties.bTrySplash = false;
      SavedFireProperties.bLeadTarget = true;
      SavedFireProperties.bInstantHit = true;
      SavedFireProperties.bInitialized = true;
    }

    R = AdjustAim(SavedFireProperties,Start,100);
    PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
    // added projectile owner
    spawn(class'BossLAWProj',self,,Start,R);

    bShotAnim = true;
    Acceleration = vect(0,0,0);
    SetAnimAction('FireEndMissile');
    HandleWaitForAnim('FireEndMissile');

    // Randomly send out a message about Patriarch shooting a rocket(5% chance)
    if ( FRand() < 0.05 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
    {
      PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
    }

    GoToState('');
  }
}


//=============================================================================
//                              ctrl == none fixes
//=============================================================================

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
  // added 'Controller != none' check
	if (Controller != none && Controller.Target != none && Controller.Target.IsA('NetKActor'))
		pushdir = Normal(Controller.Target.Location-Location)*100000;

	return super(KFMonster).MeleeDamageTarget(hitdamage, pushdir);
}


// non state one
function ClawDamageTarget()
{
	local vector PushDir;
	local name Anim;
	local float frame,rate;
	local float UsedMeleeDamage;
	local bool bDamagedSomeone;
	local KFHumanPawn P;
	local Actor OldTarget;

	if (MeleeDamage > 1)
    UsedMeleeDamage = (MeleeDamage - (MeleeDamage * 0.05)) + (MeleeDamage * (FRand() * 0.1));
	else
    UsedMeleeDamage = MeleeDamage;

	GetAnimParams(1, Anim,frame,rate);

	if (Anim == 'MeleeImpale')
    MeleeRange = ImpaleMeleeDamageRange;
	else
    MeleeRange = ClawMeleeDamageRange;

	if (Controller != none && Controller.Target != none)
		PushDir = (damageForce * Normal(Controller.Target.Location - Location));
	else
		PushDir = damageForce * vector(Rotation);

  class'stubZBoss'.default.bInitialized = false;

	if (Anim == 'MeleeImpale')
    bDamagedSomeone = MeleeDamageTarget(UsedMeleeDamage, PushDir);
	else
	{
    // added 'Controller != none' check
    while (Controller != none && !class'stubZBoss'.default.bInitialized)
    {
      OldTarget = Controller.Target;

      foreach DynamicActors(class'KFHumanPawn', P)
      {
        if ( (P.Location - Location) dot PushDir > 0.0 ) // Added dot Product check in Balance Round 3
        {
          Controller.Target = P;
          bDamagedSomeone = bDamagedSomeone || MeleeDamageTarget(UsedMeleeDamage, damageForce * Normal(P.Location - Location)); // Always pushing players away added in Balance Round 3
        }
      }

      Controller.Target = OldTarget;
      class'stubZBoss'.default.bInitialized = true;
    }
	}

	MeleeRange = Default.MeleeRange;
	// End Balance Round 1, 2, and 3

	if (bDamagedSomeone)
	{
		if (Anim == 'MeleeImpale')
      PlaySound(MeleeImpaleHitSound, SLOT_Interact, 2.0);
		else
      PlaySound(MeleeAttackHitSound, SLOT_Interact, 2.0);
	}
}


defaultproperties{}