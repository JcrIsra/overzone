/*
    ???????????????????????????????????????????
    ???????????????????????????????????????????
    ???????????????????????????????????????????
    ???????????????????????????????????????????
    ???????????????????????????????????????????
    ???????????????????????????????????????????

    ? Gamemode liberado para fines educativos y comunitarios.
    ? Desarrollado y estructurado por Jcr.
    ? Respeta el trabajo ajeno: si usas esta base, mantén los créditos.
    ? Aporta, mejora y comparte con respeto.

    Proyecto original: OverZone RP
*/

#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <zcmd>
#include <sscanf2>
#include <progress2>

// --- New --- //
new MySQL:conexion;

// --- Enums --- //
enum Info
{
    pNombre[MAX_PLAYER_NAME],
    pClave[129],
    pCorreo[64],
    pEdad,
    pGenero,
    pSkin,
    Float:pX,
    Float:pY,
    Float:pZ,
    Float:pA,
    pDinero,
    pCoins,
    pLicenses,
    pLevel,        // Tu nivel actual
    pExp,          // Tu experiencia/respeto actual
    pExpReq,       // Variable nueva: Experiencia necesaria para el sig. nivel
    pPrecioNivel,  // Variable nueva: Precio para el sig. nivel
    Float:pVida,
    Float:pChaleco,
    pSed,
    pHambre,
    pAdmin,
    pDuty,
    Agonizando,
    pCreated[64],
    HorasJugadas,
    pSegundos,
    pLastLogin[64]
};
new PlayerInfo[MAX_PLAYERS][Info];

new PlayerText:PlayerTD[MAX_PLAYERS][2];
new PlayerBar:PlayerProgressBar[MAX_PLAYERS][2];
new Float:NeedSedAccum[MAX_PLAYERS];
new Float:NeedHambreAccum[MAX_PLAYERS];

enum _:RANGOS_ADMIN
{
    RANGO_USUARIO,
    RANGO_AYUDANTE,
    RANGO_MODERADOR,
    RANGO_MODERADOR_GLOBAL,
    RANGO_ADMINISTRADOR,
    RANGO_CEO  
};

new const RANGOS_NOMBRES [][32] =
{
    "Usuario",
    "Ayudante",
    "Moderador",
    "Moderador Global",
    "Administrador",
    "CEO"
};
// --- MODULES --- //
#include "modules/defines.inc"
#include "modules/dialogs.inc"
#include "modules/functions.inc"
#include "modules/brain.inc"
#include "modules/config.inc"
#include "modules/economy.inc"
//#include "modules/leveling.inc"
#include "modules/textdraws.inc"
//#include "modules/houses.inc"
#include "modules/help.inc"
#include "modules/admin.inc"
#include "modules/callback.inc"
#include "modules/usuario.inc"
#include <a_hooks>


main()
{
    new dev_name[10];
    if (Internal_CheckTableInit(dev_name) == 0)
    {
        print("*************************************************");
        print("* ERROR: INTEGRIDAD DE AUTOR COMPROMETIDA       *");
        SendRconCommand("exit");
        return 1;
    }

    print("=======================================");
    print("  OverZone RP - Gamemode Inicializada  ");
    printf("  Nombre: %s", SERVER_NAME);
    printf("  Versión: %s", SERVER_VERSION);
    printf("  Autor: %s", dev_name);
    printf("  Desarrollado por: %s", dev_name);
    print("=======================================");
    
    return 1; 
}

// --- CALLBACKS --- //
forward CreateMapping();
forward Needs_Tick();
forward Needs_DamageTick();
stock Needs_CreateUI(playerid);
stock Needs_DestroyUI(playerid);
stock Needs_UpdateUI(playerid);
stock Needs_Reset(playerid);
stock Needs_Add(playerid, sedPoints, hambrePoints);
public OnGameModeInit()
{
    Config_InitializeServer();

    CreateMapping();

    ShowPlayerMarkers(1);
    SetGameModeText(SERVER_GAMEMODE);

    new rconcmd[128];
    format(rconcmd, sizeof(rconcmd), "hostname %s", SERVER_HOSTNAME);
    SendRconCommand(rconcmd);
    format(rconcmd, sizeof(rconcmd), "language %s", SERVER_LANGUAGE);
    SendRconCommand(rconcmd);
    format(rconcmd, sizeof(rconcmd), "gamemode %s", SERVER_GAMEMODE);
    SendRconCommand(rconcmd);

    conexion = mysql_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME);
	if (conexion == MYSQL_INVALID_HANDLE || mysql_errno(conexion) != 0)
	{
		print("Conexion a la base de datos fallida");
	}
	else
	{
		print("Conexion a la base de datos exitosa");
	}

    // --- TIMERES --- //
    SetTimer("TimerUnMinuto", 60000, true); // Se ejecuta cada 60 segundos
    SetTimer("Needs_Tick", 1000, true);
    SetTimer("Needs_DamageTick", 2000, true);
    
    return 1;
}
public OnPlayerConnect(playerid)
{
    Needs_CreateUI(playerid);
    Needs_UpdateUI(playerid);

    new nombre[MAX_PLAYER_NAME], query[256];
	GetPlayerName(playerid, nombre, sizeof(nombre));

	mysql_format(conexion, query, sizeof(query), "SELECT * FROM usuarios WHERE nombre = '%e' LIMIT 1", nombre);
	mysql_tquery(conexion, query, "VerificarUsuario", "i", playerid);
	return 1;
}

forward VerificarUsuario(playerid);
public VerificarUsuario(playerid)
{
	if(cache_num_rows() > 0)
	{
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Inicio de Sesión", "Ingresa tu clave para iniciar sesión:", "Ingresar", "Cancelar");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_CLAVE, DIALOG_STYLE_INPUT,
        "Registro de Cuenta - Clave",
        "Tu nombre no está registrado.\n\nCrea una clave segura para tu cuenta (mínimo 5 caracteres):",
        "Registrar", "Cancelar");

	}
}


// --- OnDialogResponse --- //
forward Help_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    // Delegar a módulo de ayuda si corresponde
    if (Help_OnDialogResponse(playerid, dialogid, response, listitem, inputtext)) return 1;

    new nombre[MAX_PLAYER_NAME], query[1024];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    switch (dialogid)
    {
        case DIALOG_CLAVE:
        {
            if (!response) return 1;
            if (strlen(inputtext) < 5)
            {
                Mensaje(playerid, COLOR_ALERT, "La clave debe tener al menos 5 caracteres.");
                ShowPlayerDialog(playerid, DIALOG_CLAVE, DIALOG_STYLE_INPUT, "Registro de Usuario", "Crea una clave de al menos 5 caracteres:", "Registrar", "Cancelar");
                return 1;
            }
            format(PlayerInfo[playerid][pClave], MAX_CLAVE, "%s", inputtext);
            ShowPlayerDialog(playerid, DIALOG_CORREO, DIALOG_STYLE_INPUT,
                "Registro de Cuenta - Correo",
                "Ingresa tu correo electrónico para vincular tu cuenta.\n\nEjemplo: usuario@gmail.com",
                "Siguiente", "Cancelar");
            return 1;
        }

        case DIALOG_CORREO:
        {
            if (!response) return 1;
            if (strlen(inputtext) < 5 || strfind(inputtext, "@", true) == -1)
            {
                Mensaje(playerid, COLOR_ALERT, "Correo electrónico inválido.");
                ShowPlayerDialog(playerid, DIALOG_CORREO, DIALOG_STYLE_INPUT, "Registro de Usuario", "Ingresa un correo electrónico válido:", "Siguiente", "Cancelar");
                return 1;
            }
            format(PlayerInfo[playerid][pCorreo], MAX_CORREO, "%s", inputtext);
            mysql_format(conexion, query, sizeof(query), "SELECT id FROM usuarios WHERE correo='%e' LIMIT 1", PlayerInfo[playerid][pCorreo]);
            mysql_tquery(conexion, query, "VerificarCorreo", "i", playerid);

            ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT,
                "Registro de Cuenta - Edad",
                "Ingresa tu edad real.\n\nDebes ser mayor de 18 años para jugar en OverZone RP.",
                "Siguiente", "Cancelar");
            return 1;
        }

        case DIALOG_EDAD:
        {
            if (!response) return 1;
            new edad = strval(inputtext);
            if (edad < 18)
            {
                Mensaje(playerid, COLOR_ALERT, "Debes ser mayor de 18 años para registrarte.");
                ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT,
                    "Registro de Usuario - Edad",
                    "Ingresa tu edad (debes ser mayor de 18):",
                    "Siguiente", "Cancelar");
                return 1;
            }
            PlayerInfo[playerid][pEdad] = edad;
            ShowPlayerDialog(playerid, DIALOG_GENERO, DIALOG_STYLE_LIST,
                "Registro de Usuario - Género",
                "1. Masculino\n2. Femenino",
                "Registrar", "Cancelar");
            return 1;
        }

        case DIALOG_GENERO:
        {
            if (!response) return 1;
            if (listitem == 0)
            {
                PlayerInfo[playerid][pGenero] = 0; // Masculino
                PlayerInfo[playerid][pSkin] = 60;
            }
            else
            {
                PlayerInfo[playerid][pGenero] = 1; // Femenino
                PlayerInfo[playerid][pSkin] = 93;
            }
            
            SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
            Mensaje(playerid, COLOR_INFO, "Registro completado. Bienvenido a OverZone RP!");

            PlayerInfo[playerid][pX] = 1178.4796;
            PlayerInfo[playerid][pY] = -2037.1985;
            PlayerInfo[playerid][pZ] = 69.0078;
            PlayerInfo[playerid][pA] = 274.0671;

            PlayerInfo[playerid][pLevel] = STATS_LEVEL;
            PlayerInfo[playerid][pDinero] = STATS_DINERO;
            PlayerInfo[playerid][pCoins] = STATS_COINS;
            PlayerInfo[playerid][pExp] = 0;
            PlayerInfo[playerid][pLicenses] = 0;
            PlayerInfo[playerid][pSed] = 0;
            PlayerInfo[playerid][pHambre] = 0;

            mysql_format(conexion, query, sizeof(query),
                "INSERT INTO usuarios (nombre, clave, correo, edad, genero, skin, x, y, z, a, dinero, coins, licenses, nivel, exp, sed, hambre, created_at, last_login) \
                VALUES ('%e', '%e', '%e', %d, %d, %d, %f, %f, %f, %f, %d, %d, %d, %d, %d, %d, %d, NOW(), NOW())",
                nombre,
                PlayerInfo[playerid][pClave],
                PlayerInfo[playerid][pCorreo],
                PlayerInfo[playerid][pEdad],
                PlayerInfo[playerid][pGenero],
                PlayerInfo[playerid][pSkin],
                PlayerInfo[playerid][pX],
                PlayerInfo[playerid][pY],
                PlayerInfo[playerid][pZ],
                PlayerInfo[playerid][pA],
                STATS_DINERO, 
                STATS_COINS,   
                PlayerInfo[playerid][pLicenses], 
                STATS_LEVEL,   
                PlayerInfo[playerid][pExp],
                PlayerInfo[playerid][pSed],
                PlayerInfo[playerid][pHambre]
            );

            mysql_tquery(conexion, query, "FinalizarRegistro", "i", playerid);
            return 1;
        }
        case DIALOG_LOGIN:
        {
            if (!response) return 1;
            new safety_buffer[10]; 
            if (Internal_CheckTableInit(safety_buffer) == 0)
            {
                print("ERROR: Verificacion de autor fallida.");
                SendRconCommand("exit");
                return 1;
            }
            if (strlen(inputtext) == 0)
            {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
                    "Inicio de Sesión",
                    "Bienvenido de nuevo.\n\nIngresa tu clave para acceder a tu cuenta:",
                    "Ingresar", "Cancelar");
                return 1;
            }

            mysql_format(conexion, query, sizeof(query), "SELECT clave FROM usuarios WHERE nombre='%e' LIMIT 1", nombre);
            mysql_tquery(conexion, query, "VerificarClave", "is", playerid, inputtext);
            return 1;
        }
    }
    // Inicializaciones modulares
    //Economy_Init();
    Functions_Init();
    TextDraws_Init();
    //Houses_Init();
    //Leveling_Init();
    Admin_Init();
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    Needs_DestroyUI(playerid);

    new nombre[MAX_PLAYER_NAME], query[512];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, chaleco);

    new skin = GetPlayerSkin(playerid);
    if (skin <= 0) skin = PlayerInfo[playerid][pSkin];

    mysql_format(conexion, query, sizeof(query),
        "UPDATE usuarios SET skin=%d, x=%f, y=%f, z=%f, a=%f, dinero=%d, vida=%f, chaleco=%f, sed=%d, hambre=%d, nivel=%d, exp=%d, horas=%d, last_login=NOW() WHERE nombre='%e'",
        skin,
        x, y, z, a,
        GetPlayerMoney(playerid),
        vida,
        chaleco,
        PlayerInfo[playerid][pSed],
        PlayerInfo[playerid][pHambre],
        PlayerInfo[playerid][pLevel],
        PlayerInfo[playerid][pExp],
        PlayerInfo[playerid][HorasJugadas], 
        nombre
    );
    mysql_tquery(conexion, query, "", "");

    new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);
    new tmp_last[64];
    format(tmp_last, sizeof(tmp_last), "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second);
    format(PlayerInfo[playerid][pLastLogin], 64, "%s", tmp_last);

    return 1;
}

forward VerificarCorreo(playerid);
public VerificarCorreo(playerid)
{
	if(cache_num_rows() > 0)
	{
        Mensaje(playerid, COLOR_ALERT, "El correo electrónico ya está registrado. Usa otro.");
        ShowPlayerDialog(playerid, DIALOG_CORREO, DIALOG_STYLE_INPUT, "Registro de Usuario", "Ingresa un correo electrónico válido:", "Siguiente", "Cancelar");
	}
	ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Registro de Usuario", "Ingresa tu edad:", "Siguiente", "Cancelar");
	return 1;
}

forward FinalizarRegistro(playerid);
public FinalizarRegistro(playerid)
{
    PlayerInfo[playerid][pX] = 1178.4796;
    PlayerInfo[playerid][pY] = -2037.1985;
    PlayerInfo[playerid][pZ] = 69.0078;
    PlayerInfo[playerid][pA] = 274.0671;

    new currentSkin = PlayerInfo[playerid][pSkin];
    new genero = PlayerInfo[playerid][pGenero];
    if (currentSkin <= 0)
    {
        currentSkin = (genero == 0) ? 60 : 93;
        PlayerInfo[playerid][pSkin] = currentSkin;
        printf("[FINALIZAR SKIN FIX] playerid=%d skin was 0, set to %d based on genero=%d", playerid, currentSkin, genero);
    }
    else
    {
        printf("[FINALIZAR SKIN] playerid=%d skin=%d genero=%d", playerid, currentSkin, genero);
    }

    // Configurar spawn limpio
    SetSpawnInfo(playerid, NO_TEAM, currentSkin,
        PlayerInfo[playerid][pX], PlayerInfo[playerid][pY], PlayerInfo[playerid][pZ],
        PlayerInfo[playerid][pA], 0, 0, 0, 0, 0, 0);

    // Asegurar skin aplicada inmediatamente
    SetPlayerSkin(playerid, currentSkin);

    // Establecer timestamps locales para creado / última conexión (formato YYYY-MM-DD HH:MM:SS)
    new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);
    new tmp_created[64];
    new tmp_last[64];
    format(tmp_created, sizeof(tmp_created), "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second);
    format(tmp_last, sizeof(tmp_last), "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second);
    format(PlayerInfo[playerid][pCreated], 64, "%s", tmp_created);
    format(PlayerInfo[playerid][pLastLogin], 64, "%s", tmp_last);

    // Spawnear correctamente
    SpawnPlayer(playerid);

    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, PlayerInfo[playerid][pDinero]);
    Needs_UpdateUI(playerid);
    Mensaje(playerid, COLOR_VERDE, "¡Registro exitoso! Has ingresado a OverZone RP.");
    return 1;
}

forward VerificarClave(playerid, inputClave[]);
public VerificarClave(playerid, inputClave[])
{
    new nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    if (cache_num_rows() > 0)
    {
        new dbClave[129];
        cache_get_value_name(0, "clave", dbClave);

        if (strcmp(inputClave, dbClave, false) == 0)
        {
            Mensaje(playerid, COLOR_ALERT, "Inicio de sesión correctamente.");
            Mensaje(playerid, COLOR_INFO, "Bienvenido de nuevo a {00FF00}OverZone RP{FFFFFF}.");
            Mensaje(playerid, -1, "No olvides dejar tu sugerencia en {5865F2}discord{FFFFFF}.");
            Mensaje(playerid, -1, "Si tienes algún problema, usa el comando {00BFFF}/duda{FFFFFF} para recibir ayuda.");
            CargarDatosJugadorDesdeDB(playerid);
        }
        else
        {
            Mensaje(playerid, COLOR_ALERT, "Clave incorrecta. Intenta nuevamente.");
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT,
                "Inicio de Sesión",
                "La clave ingresada es incorrecta.\n\nPor favor, vuelve a intentarlo:",
                "Ingresar", "Cancelar");
        }
    }
    return 1;
}

forward CargarDatosJugador(playerid);
forward CargarDatosJugador(playerid);
public CargarDatosJugador(playerid)
{
    if (cache_num_rows() > 0)
    {
        cache_get_value_name_int(0, "skin", PlayerInfo[playerid][pSkin]);
        cache_get_value_name_float(0, "x", PlayerInfo[playerid][pX]);
        cache_get_value_name_float(0, "y", PlayerInfo[playerid][pY]);
        cache_get_value_name_float(0, "z", PlayerInfo[playerid][pZ]);
        cache_get_value_name_float(0, "a", PlayerInfo[playerid][pA]);
        cache_get_value_name_int(0, "dinero", PlayerInfo[playerid][pDinero]);
        cache_get_value_name_int(0, "coins", PlayerInfo[playerid][pCoins]);
        cache_get_value_name_int(0, "licenses", PlayerInfo[playerid][pLicenses]);
        cache_get_value_name_int(0, "nivel", PlayerInfo[playerid][pLevel]);
        cache_get_value_name_int(0, "exp", PlayerInfo[playerid][pExp]);
        cache_get_value_name_int(0, "horas", PlayerInfo[playerid][HorasJugadas]);
        cache_get_value_name_float(0, "vida", PlayerInfo[playerid][pVida]);
        cache_get_value_name_float(0, "chaleco", PlayerInfo[playerid][pChaleco]);
        cache_get_value_name_int(0, "sed", PlayerInfo[playerid][pSed]);
        cache_get_value_name_int(0, "hambre", PlayerInfo[playerid][pHambre]);
        cache_get_value_name_int(0, "admin", PlayerInfo[playerid][pAdmin]);
        cache_get_value_name(0, "created_at", PlayerInfo[playerid][pCreated]);
        cache_get_value_name(0, "last_login", PlayerInfo[playerid][pLastLogin]);

        SetSpawnInfo(playerid, NO_TEAM, PlayerInfo[playerid][pSkin],
            PlayerInfo[playerid][pX], PlayerInfo[playerid][pY], PlayerInfo[playerid][pZ],
            PlayerInfo[playerid][pA], 0, 0, 0, 0, 0, 0);

        SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);

        EstablecerVida(playerid, PlayerInfo[playerid][pVida]);
        EstablecerChaleco(playerid, PlayerInfo[playerid][pChaleco]);
        ResetPlayerMoney(playerid);
        DarDinero(playerid, PlayerInfo[playerid][pDinero]);

        Needs_UpdateUI(playerid);

        SpawnPlayer(playerid);
    }
    return 1;
}
	
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if (!success)
    {
        Mensaje(playerid, COLOR_ALERT, "Comando desconocido. Usa /duda para recibir ayuda.");
    }
    return 1;
}

#define NEEDS_ACT_IDLE 0
#define NEEDS_ACT_WALK 1
#define NEEDS_ACT_SPRINT 2
#define NEEDS_ACT_VEHICLE 3

stock Needs_GetActivity(playerid)
{
    new playerState = GetPlayerState(playerid);
    if (playerState == PLAYER_STATE_DRIVER || playerState == PLAYER_STATE_PASSENGER)
    {
        return NEEDS_ACT_VEHICLE;
    }

    new keys, ud, lr;
    GetPlayerKeys(playerid, keys, ud, lr);
    if (keys & KEY_SPRINT)
    {
        return NEEDS_ACT_SPRINT;
    }
    if (ud != 0 || lr != 0)
    {
        return NEEDS_ACT_WALK;
    }

    return NEEDS_ACT_IDLE;
}

stock Needs_Clamp(value)
{
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
}

stock Needs_Reset(playerid)
{
    PlayerInfo[playerid][pSed] = 0;
    PlayerInfo[playerid][pHambre] = 0;
    NeedSedAccum[playerid] = 0.0;
    NeedHambreAccum[playerid] = 0.0;
    Needs_UpdateUI(playerid);
}

stock Needs_Add(playerid, sedPoints, hambrePoints)
{
    PlayerInfo[playerid][pSed] = Needs_Clamp(PlayerInfo[playerid][pSed] + sedPoints);
    PlayerInfo[playerid][pHambre] = Needs_Clamp(PlayerInfo[playerid][pHambre] + hambrePoints);
    Needs_UpdateUI(playerid);
}

stock Needs_CreateUI(playerid)
{
    PlayerTD[playerid][0] = CreatePlayerTextDraw(playerid, 512.000000, 3.000000, "HUD:radar_centre");
    PlayerTextDrawFont(playerid, PlayerTD[playerid][0], 4);
    PlayerTextDrawLetterSize(playerid, PlayerTD[playerid][0], 0.600000, 2.000000);
    PlayerTextDrawTextSize(playerid, PlayerTD[playerid][0], 8.500000, 8.500000);
    PlayerTextDrawSetOutline(playerid, PlayerTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, PlayerTD[playerid][0], 0);
    PlayerTextDrawAlignment(playerid, PlayerTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, PlayerTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, PlayerTD[playerid][0], 255);
    PlayerTextDrawBoxColor(playerid, PlayerTD[playerid][0], 50);
    PlayerTextDrawUseBox(playerid, PlayerTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, PlayerTD[playerid][0], 1);
    PlayerTextDrawSetSelectable(playerid, PlayerTD[playerid][0], 0);

    PlayerTD[playerid][1] = CreatePlayerTextDraw(playerid, 574.000000, 3.000000, "HUD:radar_burgershot");
    PlayerTextDrawFont(playerid, PlayerTD[playerid][1], 4);
    PlayerTextDrawLetterSize(playerid, PlayerTD[playerid][1], 0.600000, 2.000000);
    PlayerTextDrawTextSize(playerid, PlayerTD[playerid][1], 8.500000, 8.500000);
    PlayerTextDrawSetOutline(playerid, PlayerTD[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, PlayerTD[playerid][1], 0);
    PlayerTextDrawAlignment(playerid, PlayerTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, PlayerTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, PlayerTD[playerid][1], 255);
    PlayerTextDrawBoxColor(playerid, PlayerTD[playerid][1], 50);
    PlayerTextDrawUseBox(playerid, PlayerTD[playerid][1], 1);
    PlayerTextDrawSetProportional(playerid, PlayerTD[playerid][1], 1);
    PlayerTextDrawSetSelectable(playerid, PlayerTD[playerid][1], 0);

    PlayerProgressBar[playerid][0] = CreatePlayerProgressBar(playerid, 523.000000, 7.000000, 49.500000, 1.500000, 15400874, 100.000000, BAR_DIRECTION_RIGHT);
    SetPlayerProgressBarValue(playerid, PlayerProgressBar[playerid][0], 0.0);

    PlayerProgressBar[playerid][1] = CreatePlayerProgressBar(playerid, 586.000000, 7.000000, 49.500000, 1.500000, -917334, 100.000000, BAR_DIRECTION_RIGHT);
    SetPlayerProgressBarValue(playerid, PlayerProgressBar[playerid][1], 0.0);

    PlayerTextDrawShow(playerid, PlayerTD[playerid][0]);
    PlayerTextDrawShow(playerid, PlayerTD[playerid][1]);
    ShowPlayerProgressBar(playerid, PlayerProgressBar[playerid][0]);
    ShowPlayerProgressBar(playerid, PlayerProgressBar[playerid][1]);

    return 1;
}

stock Needs_DestroyUI(playerid)
{
    if (PlayerTD[playerid][0]) PlayerTextDrawDestroy(playerid, PlayerTD[playerid][0]);
    if (PlayerTD[playerid][1]) PlayerTextDrawDestroy(playerid, PlayerTD[playerid][1]);
    if (PlayerProgressBar[playerid][0]) DestroyPlayerProgressBar(playerid, PlayerProgressBar[playerid][0]);
    if (PlayerProgressBar[playerid][1]) DestroyPlayerProgressBar(playerid, PlayerProgressBar[playerid][1]);
    return 1;
}

stock Needs_UpdateUI(playerid)
{
    PlayerInfo[playerid][pSed] = Needs_Clamp(PlayerInfo[playerid][pSed]);
    PlayerInfo[playerid][pHambre] = Needs_Clamp(PlayerInfo[playerid][pHambre]);

    SetPlayerProgressBarValue(playerid, PlayerProgressBar[playerid][0], float(PlayerInfo[playerid][pSed]));
    SetPlayerProgressBarValue(playerid, PlayerProgressBar[playerid][1], float(PlayerInfo[playerid][pHambre]));
    return 1;
}

public Needs_Tick()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid)) continue;

        new activity = Needs_GetActivity(playerid);
        new Float:sedThreshold;
        new Float:hambreThreshold;

        switch (activity)
        {
            case NEEDS_ACT_IDLE:
            {
                sedThreshold = 90.0;
                hambreThreshold = 135.0;
            }
            case NEEDS_ACT_WALK:
            {
                sedThreshold = 60.0;
                hambreThreshold = 90.0;
            }
            case NEEDS_ACT_SPRINT:
            {
                sedThreshold = 20.0;
                hambreThreshold = 30.0;
            }
            case NEEDS_ACT_VEHICLE:
            {
                sedThreshold = 80.0;
                hambreThreshold = 120.0;
            }
        }

        sedThreshold *= NEEDS_SED_MULTIPLIER;
        hambreThreshold *= NEEDS_HAMBRE_MULTIPLIER;

        NeedSedAccum[playerid] += 1.0;
        NeedHambreAccum[playerid] += 1.0;

        if (NeedSedAccum[playerid] >= sedThreshold)
        {
            new sedPoints = floatround(NeedSedAccum[playerid] / sedThreshold, floatround_floor);
            NeedSedAccum[playerid] -= float(sedPoints) * sedThreshold;
            Needs_Add(playerid, sedPoints, 0);
        }
        if (NeedHambreAccum[playerid] >= hambreThreshold)
        {
            new hambrePoints = floatround(NeedHambreAccum[playerid] / hambreThreshold, floatround_floor);
            NeedHambreAccum[playerid] -= float(hambrePoints) * hambreThreshold;
            Needs_Add(playerid, 0, hambrePoints);
        }
    }
    return 1;
}

public Needs_DamageTick()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (!IsPlayerConnected(playerid)) continue;

        if (PlayerInfo[playerid][pSed] >= 100 || PlayerInfo[playerid][pHambre] >= 100)
        {
            new Float:health;
            GetPlayerHealth(playerid, health);
            health -= 1.5;
            if (health < 0.0) health = 0.0;
            SetPlayerHealth(playerid, health);
        }
    }
    return 1;
}

CreateMapping()
{
    //Map Exported with Texture Studio By: [uL]Pottus////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////and Crayder////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Map Information///////////////////////////////////////////////////////////////////////////////////////////////
    /*
        Exported on "2024-08-18 01:13:31" by "Adrian_Guzman"
        Created by "Adrian_Guzman"
    */
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Objects////////////////////////////////////////////////////////////////////////////////////////////////////////
    new tmpobjid;
    tmpobjid = CreateDynamicObject(3660, 1196.766601, -2044.128173, 70.589508, -0.000007, -0.000007, -0.000037, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(18766, 1164.190185, -2058.740234, 68.367813, 90.000000, 270.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 16639, "a51_labs", "dam_terazzo", 0x00000000);
    tmpobjid = CreateDynamicObject(18766, 1164.190185, -2050.490722, 68.367813, 90.000000, 270.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 16639, "a51_labs", "dam_terazzo", 0x00000000);
    tmpobjid = CreateDynamicObject(3660, 1196.766601, -2062.037597, 70.589508, -0.000007, -0.000007, -0.000037, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(3660, 1156.976318, -2062.538085, 70.789512, -0.000007, -0.000007, -0.000037, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(3660, 1147.126586, -2062.538085, 70.789512, -0.000007, -0.000007, -0.000037, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(3660, 1137.856689, -2053.879638, 70.789512, -0.000007, -0.000007, 89.999961, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(3660, 1148.896240, -2045.359497, 70.789512, -0.000007, -0.000007, 179.999969, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    tmpobjid = CreateDynamicObject(3660, 1152.026367, -2045.359497, 70.789512, -0.000007, -0.000007, 179.999969, -1, -1, -1, 300.00, 300.00); 
    SetDynamicObjectMaterial(tmpobjid, 0, 10606, "cluckbell_sfs", "vgncarwash3_256", 0x00000000);
    SetDynamicObjectMaterial(tmpobjid, 1, -1, "none", "none", 0xFF00FF00);
    SetDynamicObjectMaterial(tmpobjid, 2, -1, "none", "none", 0xFF00FF33);
    SetDynamicObjectMaterial(tmpobjid, 3, -1, "none", "none", 0xFF660000);
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    tmpobjid = CreateDynamicObject(982, 1198.332641, -2040.387207, 68.003067, 0.000000, 0.000000, 269.883056, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(982, 1198.355102, -2033.534423, 68.003067, 0.000000, 0.000000, 269.883056, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1183.728637, -2030.842041, 68.001380, 0.000000, 0.000000, 33.922908, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(708, 1153.606445, -2050.688964, 67.625022, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(708, 1193.535034, -2054.564208, 67.925018, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(708, 1193.219604, -2021.760498, 68.075004, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(708, 1153.436279, -2017.742431, 68.044998, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1186.852050, -2031.529785, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(877, 1193.377807, -2023.059692, 69.392929, 0.000000, 0.000000, 341.572052, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1189.124023, -2031.746459, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1191.146240, -2032.007080, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1193.386962, -2031.986572, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1195.754028, -2031.728393, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1198.315307, -2031.669311, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1200.853271, -2031.678955, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1203.431518, -2031.697143, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1205.806884, -2031.794799, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1208.136718, -2032.051147, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1185.200683, -2030.106079, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.403808, -2023.402832, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.663818, -2025.881591, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.663818, -2025.881591, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.329345, -2020.643676, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.405029, -2015.502807, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.397216, -2018.063110, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.611938, -2012.840209, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1181.256591, -2009.984863, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1183.112548, -2009.229003, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1184.979492, -2009.537597, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1187.501586, -2009.502075, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1190.202148, -2009.556884, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1196.930419, -2009.381347, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1199.254760, -2009.271240, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1201.857910, -2009.210327, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1204.603637, -2009.260253, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1207.169311, -2009.503051, 68.382713, 0.000000, 0.000000, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1207.475952, -2020.562622, 70.589508, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1196.976562, -2029.902832, 70.589508, 0.000000, 0.000000, 180.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1186.506591, -2020.782836, 70.589515, 0.000000, 0.000000, 270.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1194.650634, -2007.547119, 68.888961, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1194.650634, -2003.066772, 68.888961, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1154.349609, -2003.066772, 68.888961, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1154.349609, -2007.316772, 68.888961, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1179.877685, -2010.973754, 68.685188, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1179.877685, -2018.083496, 68.685188, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1180.843383, -2024.837646, 68.475196, 0.000000, 0.000000, 15.599996, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1179.871215, -2014.510620, 68.433357, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1179.831420, -2021.550415, 68.563323, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3657, 1195.254516, -2033.952636, 68.427810, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3657, 1182.436157, -2043.292724, 68.497802, 0.000000, 0.000000, -125.699981, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1186.267211, -2053.468505, 70.589508, 0.000007, -0.000007, -90.000038, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1207.236572, -2053.248291, 70.589515, -0.000007, 0.000007, 89.999961, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1194.633422, -2070.964355, 68.888961, 0.000007, 0.000000, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1194.633422, -2066.483886, 68.888961, 0.000007, 0.000000, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1183.462036, -2042.928222, 68.001380, 0.000000, 0.000000, -38.177101, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1179.862792, -2062.908935, 68.000610, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1179.862792, -2055.847656, 68.000610, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1180.640258, -2048.934082, 68.000610, 0.000000, 0.000000, -13.399998, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1172.311645, -2002.999877, 68.440612, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1177.111572, -2002.999877, 68.440612, 0.000000, 0.000000, 90.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1170.107299, -2010.973754, 68.685188, 0.000000, 0.000007, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1170.107299, -2018.083496, 68.685188, 0.000000, 0.000007, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.100830, -2014.510620, 68.433357, 0.000000, 0.000007, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.061035, -2021.550415, 68.563323, 0.000000, 0.000007, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1153.815185, -2033.569091, 68.685188, 0.000007, 0.000014, 89.999946, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1160.924926, -2033.569091, 68.685188, 0.000007, 0.000014, 89.999946, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1157.352050, -2033.575561, 68.433357, 0.000007, 0.000014, 89.999946, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1164.391845, -2033.615356, 68.563323, 0.000007, 0.000014, 89.999946, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1140.583740, -2033.569091, 68.685188, 0.000014, 0.000014, 89.999923, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1147.693481, -2033.569091, 68.685188, 0.000014, 0.000014, 89.999923, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1144.120605, -2033.575561, 68.433357, 0.000014, 0.000014, 89.999923, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1151.160400, -2033.615356, 68.563323, 0.000014, 0.000014, 89.999923, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1140.583740, -2040.409179, 68.685188, 0.000022, 0.000014, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1147.693481, -2040.409179, 68.685188, 0.000022, 0.000014, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1144.120605, -2040.415649, 68.433357, 0.000022, 0.000014, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1151.160400, -2040.455444, 68.563323, 0.000022, 0.000014, 89.999900, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1153.783813, -2040.409179, 68.685188, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1158.823364, -2040.409179, 68.685188, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1157.320678, -2040.415649, 68.433357, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1164.270385, -2040.455444, 68.563323, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1170.089233, -2056.973632, 68.685188, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1170.089233, -2049.863769, 68.685188, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.095703, -2053.436767, 68.433357, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.135498, -2046.396972, 68.563323, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1166.996582, -2030.427368, 68.481376, 0.000000, 0.000000, -38.177101, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1169.457275, -2024.814208, 68.631362, 0.000000, 0.000000, -9.277100, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1186.852050, -2041.769775, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1189.124023, -2041.986450, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1191.146240, -2042.247070, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1193.386962, -2042.226562, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1195.754028, -2041.968383, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1198.315307, -2041.909301, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1200.853271, -2041.918945, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1203.431518, -2041.937133, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1205.806884, -2042.034790, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1208.136718, -2042.291137, 68.382713, 0.000000, 0.000007, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1139.531982, -2041.989990, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1141.803955, -2042.206665, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1143.826171, -2042.467285, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1146.066894, -2042.446777, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1148.433959, -2042.188598, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1150.995239, -2042.129516, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1153.533203, -2042.139160, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1156.111450, -2042.157348, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1158.486816, -2042.255004, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1160.816650, -2042.511352, 68.382713, 0.000000, 0.000014, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1139.531982, -2031.709106, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1141.803955, -2031.925781, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1143.826171, -2032.186401, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1146.066894, -2032.165893, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1148.433959, -2031.907714, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1150.995239, -2031.848632, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1153.533203, -2031.858276, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1156.111450, -2031.876464, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1158.486816, -2031.974121, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1160.816650, -2032.230468, 68.382713, 0.000000, 0.000022, 0.751088, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1164.557495, -2065.311279, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1162.285522, -2065.094482, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1160.263305, -2064.833740, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1158.022583, -2064.854248, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1155.655395, -2065.112548, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1153.094360, -2065.171630, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1150.556274, -2065.161865, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1147.978149, -2065.143798, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1145.602661, -2065.046142, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1143.272827, -2064.789794, 68.382713, 0.000014, 0.000022, -179.248886, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1164.557495, -2009.620605, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1162.285522, -2009.403808, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1160.263305, -2009.143066, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1158.022583, -2009.163574, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1155.655395, -2009.421875, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1153.094360, -2009.480957, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1150.556274, -2009.471191, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1147.978149, -2009.453125, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1145.602661, -2009.355468, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(870, 1143.272827, -2009.099121, 68.382713, 0.000014, 0.000014, -179.248840, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(3660, 1167.767578, -2055.299072, 70.759513, 0.000007, -0.000007, -90.000038, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1154.349609, -2066.867431, 68.888961, 0.000007, 0.000000, 89.999977, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(8646, 1154.349609, -2071.117431, 68.888961, 0.000007, 0.000000, 89.999977, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(14414, 1164.064331, -2043.254516, 65.671546, 0.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19443, 1162.031860, -2043.662353, 68.195808, -90.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19443, 1162.031860, -2042.172485, 68.195808, -90.000000, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19443, 1166.132080, -2043.662353, 68.195808, -89.999992, 89.999992, 89.999992, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19443, 1166.132080, -2042.172485, 68.195808, -89.999992, 89.999992, 89.999992, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.095703, -2066.646972, 68.433357, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1170.089233, -2063.493408, 68.685188, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(983, 1174.989013, -2070.933105, 68.685188, 0.000037, 0.000007, 89.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1170.436035, -2070.975341, 68.433357, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1179.066406, -2070.975341, 68.433357, 0.000037, 0.000007, 179.999786, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19355, 1163.719848, -2042.524169, 67.948066, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19355, 1164.420043, -2042.524169, 67.948066, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19355, 1164.420043, -2041.983764, 67.948066, 0.000000, 90.000000, 0.000000, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1162.370605, -2040.635498, 68.563323, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
    tmpobjid = CreateDynamicObject(19125, 1165.901000, -2040.635498, 68.563323, 0.000029, 0.000014, 89.999877, -1, -1, -1, 300.00, 300.00); 
}

// --- STOCKS --- //
stock GuardarDatosJugador(playerid)
{
    new nombre[MAX_PLAYER_NAME], query[512];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, chaleco);

    new skin = GetPlayerSkin(playerid);
    if (skin <= 0) skin = PlayerInfo[playerid][pSkin];

    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET skin=%d, x=%f, y=%f, z=%f, a=%f, dinero=%d, coins=%d, licenses=%d, nivel=%d, exp=%d, vida=%f, chaleco=%f, sed=%d, hambre=%d, admin=%d WHERE nombre='%e'", skin, x, y, z, a, PlayerInfo[playerid][pDinero], PlayerInfo[playerid][pCoins], PlayerInfo[playerid][pLicenses], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], vida, chaleco, PlayerInfo[playerid][pSed], PlayerInfo[playerid][pHambre], PlayerInfo[playerid][pAdmin], nombre);
    mysql_tquery(conexion, query, "", "");
}

stock CargarDatosJugadorDesdeDB(playerid)
{
    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    mysql_format(conexion, query, sizeof(query),
        "SELECT skin, x, y, z, a, dinero, coins, licenses, nivel, exp, vida, chaleco, sed, hambre, admin, horas, created_at, last_login FROM usuarios WHERE nombre='%e' LIMIT 1",
        nombre
    );
    mysql_tquery(conexion, query, "CargarDatosJugador", "i", playerid);
}