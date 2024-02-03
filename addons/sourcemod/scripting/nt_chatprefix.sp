#include <sourcemod>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = {
    name = "NT Chat Prefixed",
    description = "Removes the team tag unless team only",
    author = "Agiel",
    version = PLUGIN_VERSION,
    url = "https://github.com/Agiel/nt-chatprefix"
};

DynamicHook hGetChatPrefix;

public void OnPluginStart()
{
    Handle gd = LoadGameConfigFile("neotokyo/chatprefix");
    if (gd == INVALID_HANDLE)
    {
        SetFailState("Failed to load GameData");
    }

    int offset = GameConfGetOffset(gd, "GetChatPrefix");
    hGetChatPrefix = DHookCreate(offset, HookType_GameRules, ReturnType_CharPtr, ThisPointer_Ignore, GetChatPrefix);
    DHookAddParam(hGetChatPrefix, HookParamType_Bool);
    DHookAddParam(hGetChatPrefix, HookParamType_ObjectPtr);

    CloseHandle(gd);
}

public void OnMapStart()
{
    DHookGamerules(hGetChatPrefix, true);
}

MRESReturn GetChatPrefix(DHookReturn hReturn, DHookParam hParams)
{
    if (DHookIsNullParam(hParams, 2))
    {
        hReturn.SetString("[G33K]");
        return MRES_Supercede;
    }

    bool teamOnly = hParams.Get(1);
    int m_lifeState = hParams.GetObjectVar(2, 140, ObjectValueType_Int);
    int m_iTeamNum = hParams.GetObjectVar(2, 520, ObjectValueType_Int);

    if (teamOnly)
    {
        if (m_iTeamNum == 1) // Spectator
        {
            hReturn.SetString("[Spectators]");
        }
        else if (m_iTeamNum == 2) // Jinrai
        {
            if (m_lifeState == 2) // Dead
            {
                hReturn.SetString("[DEAD][Jinrai]");
            }
            else
            {
                hReturn.SetString("[Jinrai]");
            }
        }
        else if (m_iTeamNum == 3) // NSF
        {
            if (m_lifeState == 2) // Dead
            {
                hReturn.SetString("[DEAD][NSF]");
            }
            else
            {
                hReturn.SetString("[NSF]");
            }
        }
        else
        {
            hReturn.SetString("[G33K]");
        }
    }
    else
    {
        if (m_iTeamNum != 1 && m_lifeState == 2) // Dead
        {
            hReturn.SetString("[DEAD]");
        }
        else
        {
            hReturn.SetString("");
        }
    }

    return MRES_Supercede;
}
