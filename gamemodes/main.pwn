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
    pAdmin,
    pDuty,
    Agonizando,
    pCreated[64],
    HorasJugadas,
    pSegundos,
    pLastLogin[64]
};
new PlayerInfo[MAX_PLAYERS][Info];

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
public OnGameModeInit()
{
    Config_InitializeServer();

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
    
    return 1;
}

public OnPlayerConnect(playerid)
{
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

            mysql_format(conexion, query, sizeof(query),
                "INSERT INTO usuarios (nombre, clave, correo, edad, genero, skin, x, y, z, a, dinero, coins, licenses, nivel, exp, created_at, last_login) \
                VALUES ('%e', '%e', '%e', %d, %d, %d, %f, %f, %f, %f, %d, %d, %d, %d, %d, NOW(), NOW())",
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
                PlayerInfo[playerid][pExp]       
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
    new nombre[MAX_PLAYER_NAME], query[512];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    new Float:vida, Float:chaleco;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, chaleco);

    mysql_format(conexion, query, sizeof(query),
        "UPDATE usuarios SET skin=%d, x=%f, y=%f, z=%f, a=%f, dinero=%d, vida=%f, chaleco=%f, nivel=%d, exp=%d, horas=%d, last_login=NOW() WHERE nombre='%e'",
        GetPlayerSkin(playerid),
        x, y, z, a,
        GetPlayerMoney(playerid),
        vida,
        chaleco,
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
    // Posición inicial
    PlayerInfo[playerid][pX] = 1178.4796;
    PlayerInfo[playerid][pY] = -2037.1985;
    PlayerInfo[playerid][pZ] = 69.0078;
    PlayerInfo[playerid][pA] = 274.0671;

    // Asegurar skin válida; si está en 0 fallback según género
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

    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET skin=%d, x=%f, y=%f, z=%f, a=%f, dinero=%d, coins=%d, licenses=%d, nivel=%d, exp=%d, vida=%f, chaleco=%f, admin=%d WHERE nombre='%e'", GetPlayerSkin(playerid), x, y, z, a, PlayerInfo[playerid][pDinero], PlayerInfo[playerid][pCoins], PlayerInfo[playerid][pLicenses], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pExp], vida, chaleco, PlayerInfo[playerid][pAdmin], nombre);
    mysql_tquery(conexion, query, "", "");
}

stock CargarDatosJugadorDesdeDB(playerid)
{
    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));

    mysql_format(conexion, query, sizeof(query),
        "SELECT skin, x, y, z, a, dinero, coins, licenses, nivel, exp, vida, chaleco, admin, created_at, last_login FROM usuarios WHERE nombre='%e' LIMIT 1",
        nombre
    );
    mysql_tquery(conexion, query, "CargarDatosJugador", "i", playerid);
}