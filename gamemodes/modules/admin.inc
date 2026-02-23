// admin.inc - Módulo de administración: comandos y utilidades
// Comandos: /ls, /revivir, /jetpack, /darvida, /darchaleco, /shopskin, /vida

forward Admin_Init();

new AdminJetpack[MAX_PLAYERS];
new bool:AdminSuperDuty[MAX_PLAYERS];
new AdminOriginalName[MAX_PLAYERS][MAX_PLAYER_NAME];

Admin_Init()
{
    return 1;
}

CMD:ls(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] < RANGO_MODERADOR ) return 0; 
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");

    SetPlayerPos(playerid, 1529.6, -1675.7, 13.4);
    return 1;
}

CMD:revive(playerid,params[])
{
	if (PlayerInfo[playerid][pAdmin] < RANGO_MODERADOR ) return 0; 
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
	new id;
	if(!sscanf(params,"d",id))
	if(!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_ALERT ,"No se encontró ningún jugador.");
	{
		Revivir(id);
		Mensaje(id, -1, "Fuiste revivido por administrador.");
		MensajeEx(playerid, -1, "Reviviste a {DBED15}%s[%d]", NombreJugador(id), id);

	}
	return 1;
}

CMD:jetpack(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
    new target = playerid;
    if (sscanf(params, "i", target) != 1) target = playerid;
    if (!IsPlayerConnected(target)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    AdminJetpack[target] = !AdminJetpack[target];
    if (AdminJetpack[target])
    {
        SetPlayerSpecialAction(target, SPECIAL_ACTION_USEJETPACK);
        if (target == playerid) Mensaje(playerid, COLOR_VERDE, "Jetpack activado.");
        else { Mensaje(playerid, COLOR_VERDE, "Jetpack activado al jugador."); Mensaje(target, COLOR_VERDE, "Te han activado el jetpack."); }
    }
    else
    {
        SetPlayerSpecialAction(target, SPECIAL_ACTION_NONE);
        if (target == playerid) Mensaje(playerid, COLOR_VERDE, "Jetpack desactivado.");
        else { Mensaje(playerid, COLOR_VERDE, "Jetpack desactivado al jugador."); Mensaje(target, COLOR_VERDE, "Te han desactivado el jetpack."); }
    }
    return 1;
}

CMD:setdinero(playerid, params[])
{
    new id,cantidad_dinero; 
    
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;    
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "Debes estar en duty para usar este comando.");   
    if (sscanf(params, "dd", id, cantidad_dinero)) return Mensaje(playerid, COLOR_BLANCO, "Usa {F52900}/setdinero [ID] [Cantidad]");   
    if (!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");    
    DarDinero(id, cantidad_dinero);
    
    MensajeEx(playerid, -1, "Le has dado $%d a %s.", cantidad_dinero, NombreJugador(id));
    return 1;
}

CMD:setcoins(playerid, params[])
{
    new id, cantidad;
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "Debes estar en duty.");
    
    if (sscanf(params, "dd", id, cantidad)) return Mensaje(playerid, COLOR_BLANCO, "Usa /setcoins [ID] [Cantidad a sumar]");
    if (!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    GiveCoins(id, cantidad);
    
    MensajeEx(playerid, COLOR_VERDE, "{FFFFFF}Has entregado "COLOR_HEX_VERDE"%d{FFFFFF} coins a %s.", cantidad, NombreJugador(id));
    return 1;
}

CMD:darvida(playerid,params[])
{
	new id,vida;
	if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
	if(sscanf(params,"dd",id,vida)) return Mensaje(playerid, COLOR_BLANCO, "Usa  {F52900}/darvida [ID] [Vida]");
	if(!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_VERDE, "* Jugador desconectado o no encontrado");
	{
	    if(PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return Mensaje(playerid, COLOR_ALERT, "Error.");
		EstablecerVida(id, vida);
	}
	return 1;
}

CMD:darchaleco(playerid,params[])
{
	new id,chaleco;
	if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
	if(sscanf(params,"dd",id,chaleco)) return Mensaje(playerid, COLOR_BLANCO, "Usa {F52900}/darchaleco [ID] [Chaleco]");
	if(!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_VERDE, "* Jugador desconectado o no encontrado");
	{
	    if(PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return Mensaje(playerid, COLOR_ALERT, "Error.");
		EstablecerChaleco(id, chaleco);
	}
	return 1;
}

CMD:shopskin(playerid, params[])
{
    new id, skinid;
    if (PlayerInfo[playerid][pAdmin] < RANGO_MODERADOR) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
    if (sscanf(params, "dd", id, skinid)) return Mensaje(playerid, COLOR_BLANCO, "Usa {F52900}/shopskin [ID] [SkinID]");
    if (!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    if (PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return Mensaje(playerid, COLOR_ALERT, "Error.");
    if (skinid < 0 || skinid > 311) return Mensaje(playerid, COLOR_ALERT, "SkinID invalido (0-311).");

    PlayerInfo[id][pSkin] = skinid;
    SetPlayerSkin(id, skinid);

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(id, x, y, z);
    GetPlayerFacingAngle(id, a);
    SetSpawnInfo(id, NO_TEAM, skinid, x, y, z, a, 0, 0, 0, 0, 0, 0);

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(id, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET skin=%d WHERE nombre='%e'", skinid, nombre);
    mysql_tquery(conexion, query, "", "");

    MensajeEx(playerid, COLOR_VERDE, "Has cambiado la skin de %s a %d.", NombreJugador(id), skinid);
    if (playerid != id) MensajeEx(id, COLOR_VERDE, "Tu skin fue cambiada a %d por un administrador.", skinid);
    return 1;
}

CMD:darsed(playerid, params[])
{
    new id, cantidad;
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
    if (sscanf(params, "dd", id, cantidad)) return Mensaje(playerid, COLOR_BLANCO, "Usa {F52900}/darsed [ID] [Cantidad] (0-100)");
    if (!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_VERDE, "* Jugador desconectado o no encontrado");
    if (PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return Mensaje(playerid, COLOR_ALERT, "Error.");

    if (cantidad < 0) cantidad = 0;
    if (cantidad > 100) cantidad = 100;
    PlayerInfo[id][pSed] = cantidad;
    Needs_UpdateUI(id);

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(id, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET sed=%d WHERE nombre='%e'", PlayerInfo[id][pSed], nombre);
    mysql_tquery(conexion, query, "", "");

    MensajeEx(playerid, COLOR_VERDE, "Has establecido la sed de %s en %d.", NombreJugador(id), PlayerInfo[id][pSed]);
    return 1;
}

CMD:darhambre(playerid, params[])
{
    new id, cantidad;
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
    if (sscanf(params, "dd", id, cantidad)) return Mensaje(playerid, COLOR_BLANCO, "Usa {F52900}/darhambre [ID] [Cantidad] (0-100)");
    if (!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_VERDE, "* Jugador desconectado o no encontrado");
    if (PlayerInfo[id][pAdmin] > PlayerInfo[playerid][pAdmin]) return Mensaje(playerid, COLOR_ALERT, "Error.");

    if (cantidad < 0) cantidad = 0;
    if (cantidad > 100) cantidad = 100;
    PlayerInfo[id][pHambre] = cantidad;
    Needs_UpdateUI(id);

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(id, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET hambre=%d WHERE nombre='%e'", PlayerInfo[id][pHambre], nombre);
    mysql_tquery(conexion, query, "", "");

    MensajeEx(playerid, COLOR_VERDE, "Has establecido el hambre de %s en %d.", NombreJugador(id), PlayerInfo[id][pHambre]);
    return 1;
}

CMD:vida(playerid,params[])
{
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
	EstablecerVida(playerid, 100);
    EstablecerChaleco(playerid, 100);
	return 1;
}

CMD:daradmin(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if(PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "No puedes usar este comando en duty.");
    new id, nivel;
    if(sscanf(params, "ii", id, nivel) != 2) return Mensaje(playerid, -1, "Modo de uso: /daradmin [ID] [Nivel]");
    if(!IsPlayerConnected(id)) return Mensaje(playerid, COLOR_ALERT, "El jugador no está conectado.");
    if(nivel < 1 || nivel > 6) return Mensaje(playerid, COLOR_ALERT, "El nivel de admin debe estar entre 1 y 6.");
    PlayerInfo[id][pAdmin] = nivel - 1;

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(id, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET admin=%d WHERE nombre='%e'", PlayerInfo[id][pAdmin], nombre);
    mysql_tquery(conexion, query, "", "");

    new msg[128];
    format(msg, sizeof(msg), "Has otorgado el nivel de admin %s a %s.", RANGOS_NOMBRES[nivel - 1], nombre);
    Mensaje(playerid, COLOR_VERDE, msg);

    format(msg, sizeof(msg), "Has recibido el nivel de admin %s.", RANGOS_NOMBRES[nivel - 1]);
    Mensaje(id, COLOR_VERDE, msg);
    return 1;
}

CMD:dameadmin(playerid, params[])
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if(strcmp(name, SERVER_OWNER, false) == 0)
    {
        if(PlayerInfo[playerid][pAdmin] == RANGO_CEO) return Mensaje(playerid, -1, "Ya tienes el rango de Dueño.");
        
        PlayerInfo[playerid][pAdmin] = RANGO_CEO; 
        Mensaje(playerid, -1, "¡Bienvenido jefe! Rango de Dueño asignado.");
    }
    return 1;
}

CMD:aduty(playerid, params[])
{
    if(PlayerInfo[playerid][pAdmin] < RANGO_AYUDANTE)
        return Mensaje(playerid, COLOR_ALERT, "No tienes rango suficiente para usar este comando.");

    PlayerInfo[playerid][pDuty] = !PlayerInfo[playerid][pDuty];

    if(PlayerInfo[playerid][pDuty])
    {
        SetPlayerColor(playerid, 0xFF0000FF); 
        Mensaje(playerid, COLOR_VERDE, "Has entrado en modo duty.");
    }
    else
    {
        SetPlayerColor(playerid, 0xFFFFFFFF);
        Mensaje(playerid, COLOR_VERDE, "Has salido del modo duty.");
    }

    return 1;
}

CMD:dutysuper(playerid, params[])
{
    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "Debes estar en duty para usar este comando.");

    if (!AdminSuperDuty[playerid])
    {
        new currentName[MAX_PLAYER_NAME];
        GetPlayerName(playerid, currentName, sizeof(currentName));
        format(AdminOriginalName[playerid], sizeof(AdminOriginalName[]), "%s", currentName);

        if (!SetPlayerName(playerid, "Jcr"))
        {
            return Mensaje(playerid, COLOR_ALERT, "No se pudo cambiar el nombre (ya está en uso).");
        }

        AdminSuperDuty[playerid] = true;
        Mensaje(playerid, COLOR_VERDE, "Modo /dutysuper activado. Nombre cambiado a Jcr.");
    }
    else
    {
        if (!SetPlayerName(playerid, AdminOriginalName[playerid]))
        {
            return Mensaje(playerid, COLOR_ALERT, "No se pudo restaurar el nombre (ya está en uso).");
        }

        AdminSuperDuty[playerid] = false;
        Mensaje(playerid, COLOR_VERDE, "Modo /dutysuper desactivado. Nombre restaurado.");
    }
    return 1;
}

CMD:jcradmin(playerid, params[])
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    if (strcmp(name, "Jcr_Isra", false) != 0)
    {
        return Mensaje(playerid, COLOR_ALERT, "Este comando solo está disponible para Jcr_Isra.");
    }

    PlayerInfo[playerid][pAdmin] = RANGO_CEO;

    new query[256];
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET admin=%d WHERE nombre='%e'", PlayerInfo[playerid][pAdmin], name);
    mysql_tquery(conexion, query, "", "");

    Mensaje(playerid, COLOR_VERDE, "Rango máximo de admin asignado.");
    return 1;
}

CMD:pstat(playerid, params[])
{
    new targetid, statid, cantidad;

    if (PlayerInfo[playerid][pAdmin] < RANGO_CEO) return 0;
    if (PlayerInfo[playerid][pDuty] == 0) return Mensaje(playerid, COLOR_ALERT, "Debes estar en duty para usar este comando.");

    if (sscanf(params, "udd", targetid, statid, cantidad))
    {
        return Mensaje(playerid, COLOR_VERDE, "Uso: "COLOR_SERVIDOR"/pstat{FFFFFF} "COLOR_AMARILLO"[ID/Nombre] [1: Nivel | 2: Exp | 3: Horas Jugadas] [cantidad]");
    }

    if (!IsPlayerConnected(targetid)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    if (statid == 1)
    {
        PlayerInfo[targetid][pLevel] = cantidad; 
        
        SetPlayerScore(targetid, PlayerInfo[targetid][pLevel]);
        
        MensajeEx(playerid, COLOR_VERDE, "Has establecido el nivel de %s en %d.", NombreJugador(targetid), cantidad);
        MensajeEx(targetid, COLOR_VERDE, "El administrador %s ha establecido tu nivel en %d.", NombreJugador(playerid), cantidad);
    }
    else if (statid == 2)
    {
        PlayerInfo[targetid][pExp] = cantidad; 
        
        MensajeEx(playerid, COLOR_VERDE, "Has establecido la experiencia de %s en %d.", NombreJugador(targetid), cantidad);
        MensajeEx(targetid, COLOR_VERDE, "El administrador %s ha establecido tu experiencia en %d.", NombreJugador(playerid), cantidad);
    }
    else if (statid == 3)
    {
        PlayerInfo[targetid][HorasJugadas] = cantidad;
        MensajeEx(playerid, COLOR_VERDE, "Has establecido las horas jugadas de %s en %d.", NombreJugador(targetid), cantidad);
        MensajeEx(targetid, COLOR_VERDE, "El administrador %s ha establecido tus horas jugadas en %d.", NombreJugador(playerid), cantidad);
    }

    new query[256], nombre_obj[MAX_PLAYER_NAME];
    GetPlayerName(targetid, nombre_obj, sizeof(nombre_obj));
    
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET nivel=%d, exp=%d WHERE nombre='%e'", 
        PlayerInfo[targetid][pLevel], PlayerInfo[targetid][pExp], nombre_obj);
    mysql_tquery(conexion, query, "", "");

    return 1;
}

// Fin admin.inc