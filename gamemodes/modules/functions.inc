// functions.inc - utilidades y funciones globales

forward DarDinero(playerid, amount);
stock DarDinero(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (amount <= 0) return 0;

    GivePlayerMoney(playerid, amount);

    PlayerInfo[playerid][pDinero] += amount;

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET dinero=%d WHERE nombre='%e'", PlayerInfo[playerid][pDinero], nombre);
    mysql_tquery(conexion, query, "", "");

    return 1;
}

forward SetCoins(playerid, amount);
stock SetCoins(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;
    PlayerInfo[playerid][pCoins] = amount;

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET coins=%d WHERE nombre='%e'", PlayerInfo[playerid][pCoins], nombre);
    mysql_tquery(conexion, query, "", "");

    return 1;
}

stock GiveCoins(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;
    new nuevo_total = PlayerInfo[playerid][pCoins] + amount;
    
    return SetCoins(playerid, nuevo_total);
}

// Variante que solo suma y no persiste (útil para operaciones temporales)
stock DarDineroNoPersist(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (amount <= 0) return 0;
    GivePlayerMoney(playerid, amount);
    PlayerInfo[playerid][pDinero] += amount;
    return 1;
}

// Quitar dinero y persistir
stock QuitarDinero(playerid, amount)
{
    if (!IsPlayerConnected(playerid)) return 0;
    if (amount <= 0) return 0;
    if (PlayerInfo[playerid][pDinero] < amount) return 0;

    GivePlayerMoney(playerid, -amount);
    PlayerInfo[playerid][pDinero] -= amount;

    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET dinero=%d WHERE nombre='%e'", PlayerInfo[playerid][pDinero], nombre);
    mysql_tquery(conexion, query, "", "");
    return 1;
}

// --- Payday y nivel --- //
forward Functions_Init();

Functions_Init()
{
    SetTimerEx("Functions_Payday", 900000, true, "");
    return 1;
}

stock Functions_Payday()
{
    new i;
    new query[256];
    new nombre[MAX_PLAYER_NAME];
    for (i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsPlayerConnected(i)) continue;

        DarDinero(i, 100);

        PlayerInfo[i][pExp]++;

        GetPlayerName(i, nombre, sizeof(nombre));
        mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET exp=%d WHERE nombre='%e'", PlayerInfo[i][pExp], nombre);
        mysql_tquery(conexion, query, "", "");

        SendClientMessage(i, COLOR_VERDE, "Has recibido tu payday: $100 y +1 experiencia.");
    }
    return 1;
}

EstablecerVida(playerid, Float:vida)
{
	SetPlayerHealth(playerid, vida);
	return true;
}

EstablecerChaleco(playerid, Float:chaleco)
{
	SetPlayerArmour(playerid, chaleco);
	return true;
}

stock Revivir(playerid)
{
    PlayerInfo[playerid][Agonizando] = 0; 
    EstablecerVida(playerid, 100.0);
    EstablecerChaleco(playerid, 100.0);
    ClearAnimations(playerid);   
    SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 999); 


    return 1;
}

stock Internal_CheckTableInit(dest[])
{
    dest[0] = 74; 
    dest[1] = 67; 
    dest[2] = 82; 
    dest[3] = 0; 

    if(dest[0] != 74 || dest[2] != 82) return 0; 
    return 1;
}

MensajeEx(playerid, color, form[], {Float, _}: ...)
{
    #pragma unused form
    static tmp[145];
    new t1 = playerid,t2 = color;
    const n4 = -4,n16 = -16,size = sizeof tmp;
    #emit stack 28
    #emit push.c size
    #emit push.c tmp
    #emit stack n4
    #emit sysreq.c format
    #emit stack n16
    return (t1 == -1 ? (SendClientMessageToAll(t2, tmp)) : (SendClientMessage(t1, t2, tmp)) );
}

stock NombreJugador(playerid)
{
    new nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    return nombre;
}

new TipoNivel[16][2] = //Niveles de personajes
{
	{0,0},
	{7,980}, 		//Nivel 1
	{12,3240}, 		//Nivel 2
	{19,7600}, 		//Nivel 3
	{31,16430}, 	//Nivel 4
	{52,34320}, 	//Nivel 5
	{86,67940}, 	//Nivel 6
	{143,131560}, 	//Nivel 7
	{239,250950}, 	//Nivel 8
	{397,468460}, 	//Nivel 9
	{662,867220}, 	//Nivel 10
	{1103,1588320}, //Nivel 11
	{1838,2885660}, //Nivel 12
	{3063,5207100}, //Nivel 13
	{5105,9343150}, //Nivel 14
	{7000,15000000} //Nivel 15
};

stock CalcularNivel(playerid)
{
    new nivel = PlayerInfo[playerid][pLevel];
    // Accedemos a tu tabla TipoNivel usando el nivel actual del jugador
    PlayerInfo[playerid][pExpReq] = TipoNivel[nivel][0];
    PlayerInfo[playerid][pPrecioNivel] = TipoNivel[nivel][1];
    
    UpdateLevel(playerid);
    return 1;
}

static UpdateLevel(playerid)
{
    new data[70];
    if(PlayerInfo[playerid][pExp] >= PlayerInfo[playerid][pExpReq]) 
    {
        format(data, sizeof data, "~w~Nivel %d (~y~/comprar nivel~w~)", PlayerInfo[playerid][pLevel]);
    }
    else 
    {
        format(data, sizeof data, "~w~Nivel %d (~y~%d~w~/~g~%d~w~)", 
            PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], PlayerInfo[playerid][pExpReq]);
    }
    return 1;
}

forward TimerUnMinuto();
public TimerUnMinuto()
{
    for(new i = 0; i < MAX_PLAYERS; i++) 
    {
        if(IsPlayerConnected(i) && !IsPlayerNPC(i))
        {
            PlayerInfo[i][pSegundos] += 60;
            
            if(PlayerInfo[i][pSegundos] >= 3600) // 1 hora
            {
                PlayerInfo[i][HorasJugadas]++;
                PlayerInfo[i][pSegundos] = 0;
                
            }
        }
    }
    return 1;
}