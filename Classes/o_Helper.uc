class o_Helper extends object
  config(KFPatcher);

// colors and tags, maybe later I will convert this to a config array
struct ColorRecord
{
  var string ColorName;            // color name, for comfort
  var string ColorTag;             // color tag
  var Color Color;                 // RGBA values
};
var config array<ColorRecord> ColorList;   // color list

var array<string> TagsToRemove;     // list of unnesesary tags to remove
// var array<string> sHelp;            // help messages
// var array<string> sHelpS;           // sneaky cmd list


// // help list for zed spawning
// final static function TellAbout(PlayerController pc, UltraAdmin Admin, string whatToTell)
// {
//   local int i;
//   local array<string> StrTemp;

//   switch (whatToTell)
//   {
//     case "sHelp":
//       StrTemp = default.sHelp;
//       break;
//     case "sHelp":
//       StrTemp = default.sHelpS;
//       break;
//     default:
//       // fallback warning
//       StrTemp[0] = "^rKF Patcher HELPER: We shouldn't get to this so this means you used WRONG modifier!";
//   }

// 	for (i = 0; i < StrTemp.Length; i++)
//   {
//     Admin.SendMessage(pc, StrTemp[i],false);
//   }
// }


// final static function TellAbout2(PlayerController pc, UltraAdmin Admin, array<string> whatToTell)
// {
//   local int i;

//   if (admin == none)
//     return;

//   for (i = 0; i < whatToTell.Length; i++)
//   {
//     if (pc == none)
//     {
//       Admin.SendMessage(pc, whatToTell[i],false);
//       continue;
//     }
//     Admin.BroadcastText(whatToTell[i]);
//   }
// }


// converts color tags to colors
final static function string ParseTags(out string input)
{
	local int i;
  local array<ColorRecord> Temp;
  local string strTemp;

  Temp = default.ColorList;
  for (i=0; i<Temp.Length; i++)
  {
    strTemp = class'GameInfo'.static.MakeColorCode(Temp[i].Color);
    ReplaceText(input, Temp[i].ColorTag, strTemp);
  }
  return input;
}


// removes color tags
final static function string StripTags(out string input)
{
  local int i;

  for (i=0; i<default.TagsToRemove.Length; i++)
  {
    ReplaceText(input, default.TagsToRemove[i], "");
  }
  return input;
}


// removes colors from a string
final static function string StripColor(out string s)
{
  local int p;

  p = InStr(s,chr(27));
  while ( p>=0 )
  {
    s = left(s,p)$mid(S,p+4);
    p = InStr(s,Chr(27));
  }
  return s;
}


final static function string ParsePlayerName(PlayerController pc)
{
	if (pc != none || pc.playerReplicationInfo != none)
		return "^b" $ StripTags(pc.playerReplicationInfo.PlayerName) $ "^w";
}


final static function SendMessage(PlayerController pc, coerce string msg, bool bAlreadyColored)
{
	if (pc == none || msg == "")
    return;

  if (!bAlreadyColored)
    msg = ParseTags(msg);

  pc.teamMessage(none, msg, 'KFPatcher');
}


// broadcasts a global message
final static function BroadcastText(levelInfo level, string message, optional bool bBroadcastToCenter)
{
	local Controller C;
  local PlayerController PC;

	for(C = Level.ControllerList; C != none; C = C.NextController)
	{
    // only proceed on PlayerControllers, but skip bots.
    PC = PlayerController(C);
    if (PC == none || KFFriendlyAI(C) != none)
      continue;

    // Remove color tags for WebAdmin and Log.
    if (MessagingSpectator(C) != none)
    {
      message = StripColor(message);
      // log(message, Class.Outer.Name);
    }
    else
      message = ParseTags(message);
    
    // broadcast text to the center like admin say. WebAdmin ignores this so make it use the usual TeamMessage.
    if (bBroadcastToCenter && MessagingSpectator(C) == none)
    {
      PC.ClearProgressMessages();
      PC.SetProgressTime(4);
      PC.SetProgressMessage(0, message, class'Canvas'.Static.MakeColor(255,255,255));
    }
    else
      PC.TeamMessage(none, message, 'Say');
	}
}


final static function ShowPatHP(PlayerController pc, ZombieBoss pat)
{
  SendMessage(pc, "^wThe ^b" $ pat.MenuName $ "^w's health is ^r" $ pat.health $ " ^w/ ^r" $ pat.HealthMax $ "^w. Syringes used - ^r " $ pat.SyringeCount $ "^w.", false);
}


defaultproperties
{
  TagsToRemove=("^r","^o","^y","^g","^b","^v","^w","^t","^p","^0","^1","^2","^3","^4","^5","^6","^7","^8","^9")
}