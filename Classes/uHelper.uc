class uHelper extends Object
  abstract;

// colors and tags, maybe later I will convert this to a config array
struct ColorRecord
{
  var string ColorName;            // color name, for comfort
  var string ColorTag;             // color tag
  var Color Color;                 // RGBA values
};
var array<ColorRecord> ColorList;   // color list

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


final static function SendMessage(PlayerController pc, coerce string msg, optional bool bAlreadyColored)
{
	if (pc == none || msg == "")
    return;

  if (!bAlreadyColored)
    msg = ParseTags(msg);

  pc.teamMessage(none, msg, 'AdminPlus');
}


defaultproperties
{
  TagsToRemove=("^r","^o","^y","^g","^b","^v","^w","^t","^p","^0","^1","^2","^3","^4","^5","^6","^7","^8","^9")

  ColorList[0]=(ColorName="Red",ColorTag="^r",Color=(B=0,G=0,R=200,A=0))
  ColorList[1]=(ColorName="Orange",ColorTag="^o",Color=(B=0,G=127,R=255,A=0))
  ColorList[2]=(ColorName="Yellow",ColorTag="^y",Color=(B=0,G=255,R=255,A=0))
  ColorList[3]=(ColorName="Green",ColorTag="^g",Color=(B=0,G=200,R=0,A=0))
  ColorList[4]=(ColorName="Blue",ColorTag="^b",Color=(B=200,G=100,R=0,A=0))
  ColorList[5]=(ColorName="Violet",ColorTag="^v",Color=(B=139,G=0,R=255,A=0))
  ColorList[6]=(ColorName="White",ColorTag="^w",Color=(B=255,G=255,R=255,A=0))
}