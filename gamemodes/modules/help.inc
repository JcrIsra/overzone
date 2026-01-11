forward Help_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);

public Help_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_HELP_MAIN)
    {
        if (!response) return 1;
        switch (listitem)
        {
            case 0: return ShowHelp_General(playerid);
            case 1: return ShowHelp_Autos(playerid);
            case 2: return ShowHelp_Houses(playerid);
            case 3: return ShowHelp_Jobs(playerid);
            case 4: return ShowHelp_Band(playerid);
            default: return 1;
        }
    }
    if (dialogid == DIALOG_HELP_GENERAL || dialogid == DIALOG_HELP_AUTOS
        || dialogid == DIALOG_HELP_HOUSES || dialogid == DIALOG_HELP_JOBS
        || dialogid == DIALOG_HELP_BAND)
    {
    
        return 1;
    }

    return 0; 
}

// -------------------------------------------------
// Funciones que muestran cada caja de ayuda (MSGBOX)
// -------------------------------------------------
stock ShowHelp_General(playerid)
{
    new text[1024];
    format(text, sizeof(text), "%s", "{00FF00}OverZone RP{FFFFFF}\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Bienvenido a OverZone RP. Aquí tienes información general para empezar:\n\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}1.{FFFFFF} Registro e inicio de sesión: crea una cuenta y usa tu clave para acceder.\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}2.{FFFFFF} Respeto RP: sigue las normas de roleplay y evita metagaming.\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}3.{FFFFFF} Comandos útiles: /coins /buycoins /sellcoins /houses /buyhouse.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FF0000}Soporte:{FFFFFF} Si necesitas ayuda, usa /duda o contacta con staff en Discord.");
    ShowPlayerDialog(playerid, DIALOG_HELP_GENERAL, DIALOG_STYLE_MSGBOX, "{00FF00}Ayuda - General{FFFFFF}", text, "Cerrar", "");
    return 1;
}

stock ShowHelp_Autos(playerid)
{
    new text[1024];
    format(text, sizeof(text), "%s", "{00FF00}Autos - Compra y uso{FFFFFF}\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Comprar un vehículo:\n - Dirígete a una tienda o usa el comando del servidor si existe.\n - Paga con coins (Petro) o $ según la configuración del servidor.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Usar y guardar:\n - Al comprarlo se asigna a tu cuenta como propiedad.\n - Usa /vehiculo guardar (o la acción del menú) para almacenarlo.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Consejos:\n - Nunca abandones vehículos desbloqueados en lugares públicos.\n - Respeta límites y evita grief/robo ilegal (RP).");
    ShowPlayerDialog(playerid, DIALOG_HELP_AUTOS, DIALOG_STYLE_MSGBOX, "{00FF00}Ayuda - Autos{FFFFFF}", text, "Cerrar", "");
    return 1;
}

stock ShowHelp_Houses(playerid)
{
    new text[1024];
    format(text, sizeof(text), "%s", "{00FF00}Casas - Compra y gestión{FFFFFF}\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Comprar una casa:\n - Lista: usa /houses para ver casas disponibles.\n - Compra: /buyhouse [id] pagando en coins.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Propiedad y usos:\n - La casa queda a tu nombre en la base de datos.\n - Puedes entrar/salir y, si el servidor lo soporta, decorar o guardar items.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Venta:\n - Vende con /sellhouse [id] y recupera un porcentaje del precio.\n\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}Nota:{FFFFFF} Algunas casas son 24/7 y otras tienen horarios definidos.");
    ShowPlayerDialog(playerid, DIALOG_HELP_HOUSES, DIALOG_STYLE_MSGBOX, "{00FF00}Ayuda - Casas{FFFFFF}", text, "Cerrar", "");
    return 1;
}

stock ShowHelp_Jobs(playerid)
{
    new text[1024];
    format(text, sizeof(text), "%s", "{00FF00}Trabajos - ¿Cómo funcionan?{FFFFFF}\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Encontrar trabajo:\n - Consulta la lista de trabajos (según el sistema instalado) o ve a los puntos de empleo.\n - Usa /trabajo o el menú para postular o aceptar misiones.\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Salario y progreso:\n - Cada trabajo paga un salario (puede ser por misión o por paycheck).\n - Mejora tu posición realizando tareas y cumpliendo objetivos RP.\n\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}Consejos de RP:{FFFFFF} Mantén coherencia con tu rol y evita romper la inmersión.");
    ShowPlayerDialog(playerid, DIALOG_HELP_JOBS, DIALOG_STYLE_MSGBOX, "{00FF00}Ayuda - Trabajos{FFFFFF}", text, "Cerrar", "");
    return 1;
}

stock ShowHelp_Band(playerid)
{
    new text[1024];
    format(text, sizeof(text), "%s", "{00FF00}Banda - Organización y reglas{FFFFFF}\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Crear o unirse a una banda:\n - Usa los comandos del servidor para crear o unirte a grupos (si están implementados).\n\n");
    format(text, sizeof(text), "%s%s", text, "{FFFFFF}Reglas básicas:\n - No abuses del poder del grupo ni rompas normas de RP.\n - Coordina acciones con tu banda y evita PK/FK sin contexto.\n\n");
    format(text, sizeof(text), "%s%s", text, "{00FF00}Sugerencia:{FFFFFF} Designa roles claros (líder, segundo, operativo) y mantén comunicación.");
    ShowPlayerDialog(playerid, DIALOG_HELP_BAND, DIALOG_STYLE_MSGBOX, "{00FF00}Ayuda - Banda{FFFFFF}", text, "Cerrar", "");
    return 1;
}

// FIN - help.inc
