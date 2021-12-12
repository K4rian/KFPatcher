class stub_Nade extends Nade;


// EXPERIMENTAL!! NOT IN A USE!!!
// fixes nade crashes, but obviously we can't use this :yoba:
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex){}


simulated function Explode(vector HitLocation, vector HitNormal)
{
  local PlayerController LocalPlayer;
  local Projectile P;
  local byte i;

  bHasExploded = true;
  BlowUp(HitLocation);

  // null reference fix
  if (ExplodeSounds.length > 0)
    PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);

  // Shrapnel
  for (i = Rand(6); i < 10; i++)
  {
    P = Spawn(ShrapnelClass,,,,RotRand(true));
    if (P != none)
      P.RemoteRole = ROLE_None;
  }

  if (EffectIsRelevant(Location, false))
  {
    Spawn(class'KFmod.KFNadeExplosion',,, HitLocation, rotator(vect(0,0,1)));
    Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
  }

  // Shake nearby players screens
  LocalPlayer = Level.GetLocalPlayerController();
  if ( (LocalPlayer != none) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
    LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

  Destroy();
}


defaultproperties{}