// --- ECONOMY MODULE --- //
stock UpdatePlayerEconomyDB(playerid)
{
    if (!IsPlayerConnected(playerid)) return 0;
    new nombre[MAX_PLAYER_NAME], query[256];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    
    mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET dinero=%d, coins=%d, licenses=%d WHERE nombre='%e'", 
        PlayerInfo[playerid][pDinero], PlayerInfo[playerid][pCoins], PlayerInfo[playerid][pLicenses], nombre);
    mysql_tquery(conexion, query, "", "");
    return 1;
}

CMD:vender(playerid, params[])
{
    new objeto[24], resto[64];
    if (sscanf(params, "s[24]S()[64]", objeto, resto)) return Mensaje(playerid, COLOR_BLANCO, "Uso: /vender [objeto]");

    if (strcmp(objeto, "coins", true) == 0)
    {
        new cantidad;
        if (sscanf(resto, "d", cantidad) || cantidad <= 0) return Mensaje(playerid, COLOR_BLANCO, "Uso: /vender coins [cantidad]");
        if (PlayerInfo[playerid][pCoins] < cantidad) 
        {
            return MensajeEx(playerid, COLOR_ALERT, "No tienes %d coins (Tienes: %d).", cantidad, PlayerInfo[playerid][pCoins]);
        }

        new bruto = cantidad * COIN_VALUE;
        new pago_final = bruto - ((bruto * TAX_PERCENT) / 100);

        GiveCoins(playerid, -cantidad);
        DarDinero(playerid, pago_final);
        
        MensajeEx(playerid, COLOR_VERDE, "Has vendido %d coins. Recibiste: $%d.", cantidad, pago_final);
    }
    else Mensaje(playerid, COLOR_ALERT, "No puedes vender ese objeto.");

    return 1;
}

CMD:comprar(playerid, params[])
{
    new objeto[24], resto[64];
    
    if (sscanf(params, "s[24]S()[64]", objeto, resto)) 
    {
        return Mensaje(playerid, COLOR_BLANCO, "Uso: /comprar [coins | licencia | nivel]");
    }

    // --- SUB-COMANDO: COINS ---
    if (strcmp(objeto, "coins", true) == 0)
    {
        new cantidad;
        if (sscanf(resto, "d", cantidad) || cantidad <= 0) 
        {
            return Mensaje(playerid, COLOR_BLANCO, "Uso: /comprar coins [cantidad]");
        }
        
        new costo_base = cantidad * COIN_VALUE;
        new impuestos = (costo_base * TAX_PERCENT) / 100;
        new total_pagar = costo_base + impuestos;

        if (PlayerInfo[playerid][pDinero] < total_pagar) 
        {
            return MensajeEx(playerid, -1, "No tienes suficiente dinero. Necesitas $%d y tienes $%d.", total_pagar, PlayerInfo[playerid][pDinero]);
        }

        DarDinero(playerid, -total_pagar); 
        GiveCoins(playerid, cantidad);
        MensajeEx(playerid, -1, "[ "COLOR_SERVIDOR">{FFFFFF} ] Has comprado "COLOR_HEX_VERDE"%d coins{FFFFFF} por "COLOR_HEX_VERDE"$%d{FFFFFF}.", cantidad, total_pagar);
    }

    // --- SUB-COMANDO: LICENCIA ---
    else if (strcmp(objeto, "licencia", true) == 0)
    {
        new tipo[20];
        if (sscanf(resto, "s[20]", tipo)) 
        {
            return Mensaje(playerid, COLOR_BLANCO, "Uso: /comprar licencia [driver | weapon | business]");
        }

        new costo_coins, licbit, licname[20];
        if (strcmp(tipo, "driver", true) == 0) { costo_coins = LICENSE_DRIVER_PRICE; licbit = LIC_DRIVER; format(licname, 20, "Conducir"); }
        else if (strcmp(tipo, "weapon", true) == 0) { costo_coins = LICENSE_WEAPON_PRICE; licbit = LIC_WEAPON; format(licname, 20, "Armas"); }
        else if (strcmp(tipo, "business", true) == 0) { costo_coins = LICENSE_BUSINESS_PRICE; licbit = LIC_BUSINESS; format(licname, 20, "Negocios"); }
        else return Mensaje(playerid, COLOR_ALERT, "Opciones: driver, weapon, business");

        if (PlayerInfo[playerid][pCoins] < costo_coins) 
        {
            return MensajeEx(playerid, COLOR_ALERT, "Necesitas %d coins para esta licencia (Tienes: %d).", costo_coins, PlayerInfo[playerid][pCoins]);
        }

        if (PlayerInfo[playerid][pLicenses] & licbit) return Mensaje(playerid, COLOR_INFO, "Ya tienes esta licencia.");

        GiveCoins(playerid, -costo_coins);
        PlayerInfo[playerid][pLicenses] |= licbit;
        UpdatePlayerEconomyDB(playerid);
        
        MensajeEx(playerid, COLOR_VERDE, "Licencia de %s adquirida con éxito.", licname);
    }

    else if (strcmp(objeto, "nivel", true) == 0)
    {
        new nivel_actual = PlayerInfo[playerid][pLevel];

        if(nivel_actual >= 15) 
        {
            return Mensaje(playerid, COLOR_ALERT, "Ya has alcanzado el nivel máximo disponible.");
        }
        if(PlayerInfo[playerid][pExp] < TipoNivel[nivel_actual][0])
        {
            return MensajeEx(playerid, -1, "{FFFFFF}Necesitas {F4FA58}%d{FFFFFF} de exp. (tienes %d).", 
                TipoNivel[nivel_actual][0], PlayerInfo[playerid][pExp]);
        }

        if(PlayerInfo[playerid][pDinero] < TipoNivel[nivel_actual][1])
        {
            return MensajeEx(playerid, -1, "{FFFFFF}Necesitas {00CC00}$%d{FFFFFF} para comprar este nivel.", TipoNivel[nivel_actual][1]);
        }

        QuitarDinero(playerid, TipoNivel[nivel_actual][1]);
        
        PlayerInfo[playerid][pLevel]++;
        PlayerInfo[playerid][pExp] = 0; 
        SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]); 
        CalcularNivel(playerid); 

        new nombre[MAX_PLAYER_NAME], query[200];
        GetPlayerName(playerid, nombre, sizeof(nombre));
        mysql_format(conexion, query, sizeof(query), "UPDATE usuarios SET nivel=%d, exp=0 WHERE nombre='%e'", 
            PlayerInfo[playerid][pLevel], nombre);
        mysql_tquery(conexion, query, "", "");

        Mensaje(playerid, 0xFFFF00FF, "¡Enhorabuena! Has subido de nivel. Tu progreso ha sido guardado.");
        return 1;
    }
    
    return 1;
}

CMD:licencias(playerid, params[])
{
    new flags = PlayerInfo[playerid][pLicenses];
    new buf[128] = "Tus licencias: ";
    new bool:tiene = false;

    if (flags & LIC_DRIVER)   { strcat(buf, "{FFFFFF}[Conducir] "); tiene = true; }
    if (flags & LIC_WEAPON)   { strcat(buf, "{FFFFFF}[Armas] "); tiene = true; }
    if (flags & LIC_BUSINESS) { strcat(buf, "{FFFFFF}[Negocios] "); tiene = true; }

    if (!tiene) return Mensaje(playerid, COLOR_INFO, "No posees licencias.");
    
    SendClientMessage(playerid, COLOR_INFO, buf);
    return 1;
}