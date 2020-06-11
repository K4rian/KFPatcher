class stubGT extends KFGameType;


// disable slomo!
// tick will be called constantly but now it does nothing :3
event Tick(float DeltaTime){}
function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration){}


// DO NOT Force slomo for a longer period of time when the boss dies
function DoBossDeath()
{
  local Controller C;
  local Controller nextC;
  local int num;

  // bZEDTimeActive =  true;
  // bSpeedingBackUp = false;
  // LastZedTimeEvent = Level.TimeSeconds;
  // CurrentZEDTimeDuration = ZEDTimeDuration*2;
  // SetGameSpeed(ZedTimeSlomoScale);

  num = NumMonsters;
  c = Level.ControllerList;

  // turn off all the other zeds so they don't attack the player
  while (c != none && num > 0)
  {
    nextC = c.NextController;
    if (KFMonsterController(C)!=none)
    {
      C.GotoState('GameEnded');
      --num;
    }
    c = nextC;
  }
}


// remove latejoiner shit, GameInfo code
event PreLogin( string Options, string Address, string PlayerID, out string Error, out string FailCode )
{
  super(GameInfo).PreLogin( Options, Address, PlayerID, Error, FailCode );
}


function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
  local Controller P;
  local PlayerController Player;
  local bool bSetAchievement;
  local string MapName;

  EndTime = Level.TimeSeconds + EndTimeDelay;

  if ( WaveNum > FinalWave )
  {
    GameReplicationInfo.Winner = Teams[0];
    KFGameReplicationInfo(GameReplicationInfo).EndGameType = 2;

    if ( GameDifficulty >= 2.0 )
    {
      bSetAchievement = true;

      //Get the MapName out of the URL
      MapName = GetCurrentMapName(Level);
    }
  }
  else
    KFGameReplicationInfo(GameReplicationInfo).EndGameType = 1;

  if ( (GameRulesModifiers != none) && !GameRulesModifiers.CheckEndGame(Winner, Reason) ) 
  {
    KFGameReplicationInfo(GameReplicationInfo).EndGameType = 0;
    return false;
  }

  for ( P = Level.ControllerList; P != none; P = P.nextController )
  {
    Player = PlayerController(P);
    if ( Player != none )
    {
      Player.ClientSetBehindView(true);
      
      //Player.ClientGameEnded(); //disable this so players can move freely after the game ends
      if ( bSetAchievement && KFSteamStatsAndAchievements(Player.SteamStatsAndAchievements) != none )
        KFSteamStatsAndAchievements(Player.SteamStatsAndAchievements).WonGame(MapName, GameDifficulty, KFGameLength == GL_Long);
    }
    //P.GameHasEnded(); //and this
  }
  if ( CurrentGameProfile != none )
    CurrentGameProfile.bWonMatch = false;

  return true;
}


// show perk, health in server info
function GetServerPlayers( out ServerResponseLine ServerState )
{
  local Mutator M;
  local Controller C;
  local PlayerReplicationInfo PRI;
  local int i, TeamFlag[2];

  // our new functions is a bit heavy, so limit its execution
  if(Level.TimeSeconds < class'MuVariableClass'.default.varTimerGetServerInfo)
    return;
  class'MuVariableClass'.default.varTimerGetServerInfo = Level.TimeSeconds + 3.0f;

  i = ServerState.PlayerInfo.Length;
  TeamFlag[0] = 1 << 29;
  TeamFlag[1] = TeamFlag[0] << 1;

  for( C=Level.ControllerList; C != none; C=C.NextController )
  {
    PRI = C.PlayerReplicationInfo;
    if( (PRI != none) && !PRI.bBot && MessagingSpectator(C) == none )
    {
      ServerState.PlayerInfo.Length = i+1;
      ServerState.PlayerInfo[i].PlayerNum  = C.PlayerNum;
      ServerState.PlayerInfo[i].PlayerName = class'stubGT'.static.ParsePlayerName(PRI, C, bWaitingToStartMatch); // PRI.PlayerName;
      ServerState.PlayerInfo[i].Score      = PRI.Score;
      ServerState.PlayerInfo[i].Ping       = 4 * PRI.Ping;
      // if (bTeamGame && PRI.Team != none)
      // ServerState.PlayerInfo[i].StatsID = class'stubGT'.static.GetPerkInfo(PRI); // ServerState.PlayerInfo[i].StatsID | TeamFlag[PRI.Team.TeamIndex];
      i++;
    }
  }

  // Ask the mutators if they have anything to add.
  for (M = BaseMutator.NextMutator; M != none; M = M.NextMutator)
    M.GetServerPlayers(ServerState);
}


static final function string ParsePlayerName(out PlayerReplicationInfo PRI, out Controller C, bool bWaitingToStartMatch)
{
  local string status, perk;

  if (C == none || PRI == none || KFPlayerReplicationInfo(PRI) == none)
    return "NULL PRI";

  // in case we are in
  if (C.IsInState('PlayerWaiting'))
  {
    if (!bWaitingToStartMatch)
    {
      if(PRI.bReadyToPlay)
        Status = "^g[Ready]";
      else
        Status = "^g[Not Ready]";
    }
    else
      Status = "^g[Awaiting]";
  }

  // if we are spectator, do not check perk, kills, etc
  else if (PRI.bOnlySpectator)
    return class'uHelper'.static.StripTags(PRI.PlayerName) $ class'uHelper'.static.ParseTags("^o[Spectator]");

  else if (PRI.bOutOfLives && !PRI.bOnlySpectator)
    status = "^o[Dead] ^y[^k kills]^w";

  // else we are alive and need more info
  else
    status = "^y[^h hp] ^y[^k kills]^w";

  // parse kills, health
  status = repl(status, "^h", KFPlayerReplicationInfo(PRI).PlayerHealth);
  status = repl(status, "^k", PRI.Kills);
  // status ready !

  // parse perk
  switch (string(KFPlayerReplicationInfo(PRI).ClientVeteranSkill))
  {
    case "KFMod.KFVetSharpshooter":
    case "ServerPerksP.SRVetSharpshooter":
    case "ScrnBalanceSrv.ScrnVetSharpshooter":
      perk = "Sharp";
      break;
    case "KFMod.KFVetFieldMedic":
    case "ServerPerksP.SRVetFieldMedic":
    case "ScrnBalanceSrv.ScrnVetFieldMedic":
      perk = "Medic";
      break;
    case "KFMod.KFVetBerserker":
    case "ServerPerksP.SRVetBerserker":
    case "ScrnBalanceSrv.ScrnVetBerserker":
      perk = "Zerk";
      break;
    case "KFMod.KFVetCommando":
    case "ServerPerksP.SRVetCommando":
    case "ScrnBalanceSrv.ScrnVetCommando":
      perk = "Mando";
      break;
    case "KFMod.KFVetDemolitions":
    case "ServerPerksP.SRVetDemolitions":
    case "ScrnBalanceSrv.ScrnVetDemolitions":
      perk = "Demo";
      break;
    case "KFMod.KFVetFirebug":
    case "ServerPerksP.SRVetFirebug":
    case "ScrnBalanceSrv.ScrnVetFirebug":
      perk = "Pyro";
      break;
    case "KFMod.KFVetSupportSpec":
    case "ServerPerksP.SRVetSupportSpec":
    case "ScrnBalanceSrv.ScrnVetSupportSpec":
      perk = "Sup";
      break;
    case "ScrnBalanceSrv.ScrnVetGunslinger":
      perk = "Slinger";
      break;
    default:
      perk = "NULL perk";
  }

  perk @= KFPlayerReplicationInfo(PRI).ClientVeteranSkillLevel;
  perk = "^r[" $ perk $ "]^w"; 

  return class'uHelper'.static.ParseTags(perk $ PRI.PlayerName $ status);
}