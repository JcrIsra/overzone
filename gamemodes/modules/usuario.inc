// --- CMD --- //

CMD:ayuda(playerid, params[])
{
    new list[128];
    format(list, sizeof(list), "General\nAutos\nCasas\nTrabajos\nBanda");
    ShowPlayerDialog(playerid, DIALOG_HELP_MAIN, DIALOG_STYLE_LIST, "Ayuda - MenÃº", list, "Seleccionar", "Cerrar");
    return 1;
}

CMD:est(playerid, params[])
{
    new target = playerid;
    if (sscanf(params, "i", target) == 1) {
        if (!IsPlayerConnected(target)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    }
    ShowEst(playerid, target);
    return 1;
}

CMD:estadisticas(playerid, params[])
{
    new target = playerid;
    if (sscanf(params, "i", target) == 1) {
        if (!IsPlayerConnected(target)) return Mensaje(playerid, COLOR_ALERT, "Jugador no conectado.");
    }
    ShowEst(playerid, target);
    return 1;
}

stock ShowEst(viewer, target)
{
    if (!IsPlayerConnected(target)) return 0;

    ResetPlayerMoney(target);
    GivePlayerMoney(target, PlayerInfo[target][pDinero]);

    new name[MAX_PLAYER_NAME];
    GetPlayerName(target, name, sizeof(name));
    
    new lvl = PlayerInfo[target][pLevel];
    new exp = PlayerInfo[target][pExp];
    new index = (lvl > 15) ? 15 : lvl;
    new req = TipoNivel[index][0]; 
    new costo_sig = TipoNivel[index][1];

    new genero_text[16];
    format(genero_text, sizeof(genero_text), (PlayerInfo[target][pGenero] == 0) ? ("Masculino") : ("Femenino"));

    new info[1500]; 
    format(info, sizeof(info), 
        "{00FF00}Estadísticas Generales de %s{FFFFFF}\n\n"\
        "{AFAFAF}Nombre:\t\t\t{FFFFFF}%s\n"\
        "{AFAFAF}Correo:\t\t\t{FFFFFF}%s\n"\
        "{AFAFAF}Género:\t\t\t{FFFFFF}%s\n"\
        "{AFAFAF}Nivel:\t\t\t{6EF1FF}%d\n"\
        "{AFAFAF}Experiencia:\t\t{6EF1FF}%d / %d\n"\
        "{AFAFAF}Precio Sig. Nivel:\t{00CC00}$%d\n\n"\
        "{AFAFAF}Dinero en Mano:\t{00CC00}$%d\n"\
        "{AFAFAF}Coins:\t\t\t{F1C40F}%d\n\n"\
        "{AFAFAF}Cuenta creada:\t\t{D1D1D1}%s\n"\
        "{AFAFAF}Última conexión:\t{D1D1D1}%s",
        name, name, PlayerInfo[target][pCorreo], genero_text, lvl, exp, req, costo_sig, 
        PlayerInfo[target][pDinero], PlayerInfo[target][pCoins], 
        PlayerInfo[target][pCreated], PlayerInfo[target][pLastLogin]
    );

    ShowPlayerDialog(viewer, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "{00FF00}> {FFFFFF}Hoja de Personaje", info, "Cerrar", "");
    return 1;
}