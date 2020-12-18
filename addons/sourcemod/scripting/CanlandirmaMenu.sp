#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <warden>
#pragma semicolon 1
#pragma newdecls required

ConVar g_Flag = null;

public Plugin myinfo = 
{
	name = "Canlandırma Menüsü", 
	author = "phiso", 
	description = "Geliştirilmiş canlandırma menüsü", 
	version = "1.0", 
	url = "phiso#3331"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_revm", RevMenu);
	RegConsoleCmd("sm_revmenu", RevMenu);
	
	g_Flag = CreateConVar("sm_revmenu_flag", "f", "Komutçu harici kimler kullanabilsin");
	
	AutoExecConfig(true, "RevMenu", "phiso");
}

public Action RevMenu(int client, int args)
{
	char Yetkiliflag[4];
	g_Flag.GetString(Yetkiliflag, sizeof(Yetkiliflag));
	if (warden_iswarden(client) || CheckAdminFlag(client, Yetkiliflag))
	{
		Rev_Menu().Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

Menu Rev_Menu()
{
	Menu menu = new Menu(RevMenu_Callback);
	menu.SetTitle("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n★ Gelişmiş Canlandırma Menüsü ★\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	menu.AddItem("1", "✦ Mahkumları Canlandır ve Aim`e Işınla");
	menu.AddItem("2", "✦ Gardiyanları Canlandır ve Aim`e Işınla");
	menu.AddItem("3", "✦ Mahkumları Canlandır");
	menu.AddItem("4", "✦ Gardiyanları Canlandır");
	menu.AddItem("5", "✦ Mahkumları Aim`e Işınla");
	menu.AddItem("6", "✦ Gardiyanları Aim`e Işınla");
	return menu;
}

public int RevMenu_Callback(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char item[32];
		menu.GetItem(param2, item, sizeof(item));
		if (strcmp(item, "1") == 0)
		{
			float Konum[3] = 0.0;
			GetAimCoords(client, Konum);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsPlayerAlive(i))
				{
					CS_RespawnPlayer(i);
				}
				if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_T)
				{
					TeleportEntity(i, Konum, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		else if (strcmp(item, "2") == 0)
		{
			float Konum[3] = 0.0;
			GetAimCoords(client, Konum);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsPlayerAlive(i))
				{
					CS_RespawnPlayer(i);
				}
				if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT)
				{
					TeleportEntity(i, Konum, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		else if (strcmp(item, "3") == 0)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsPlayerAlive(i) && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_T)
				{
					CS_RespawnPlayer(i);
				}
			}
		}
		else if (strcmp(item, "4") == 0)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsPlayerAlive(i) && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT)
				{
					CS_RespawnPlayer(i);
				}
			}
		}
		else if (strcmp(item, "5") == 0)
		{
			float Konum[3] = 0.0;
			GetAimCoords(client, Konum);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_T)
				{
					TeleportEntity(i, Konum, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
		else if (strcmp(item, "6") == 0)
		{
			float Konum[3] = 0.0;
			GetAimCoords(client, Konum);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT)
				{
					TeleportEntity(i, Konum, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}
stock bool CheckAdminFlag(int client, const char[] flags)
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
}
public void GetAimCoords(int client, float Konum[3]) {
	float vAngles[3];
	float vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if (TR_DidHit(trace)) {
		TR_GetEndPosition(Konum, trace);
	}
	trace.Close();
}
public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
} 