#  OverZone Roleplay v1.0 - Official Release

Bienvenido al repositorio oficial de **OverZone RP**, una base sólida, optimizada y profesional para servidores de SA-MP. Esta GameMode ha sido desarrollada con un enfoque en la estabilidad del servidor y la integridad de los datos.

##  Características Principales

* **Sistema de Niveles Dinámico:** Basado en una matriz de experiencia y costos equilibrados.
* **Economía Sincronizada:** Protección total contra desajustes visuales de dinero (HUD vs Server).
* **Base de Datos:** Estructura MySQL optimizada para alto flujo de jugadores.
* **Interfaz de Usuario:** Estadísticas detalladas con alineación visual profesional mediante tabulaciones.

##  Integridad y Seguridad del Proyecto

Para garantizar la calidad y el soporte futuro de esta GameMode, se ha implementado un **Protocolo de Integridad de Núcleo (CIP)**. Este sistema protege la autoría del proyecto de la siguiente manera:

* **Validación de Arranque:** El servidor realiza una comprobación de seguridad en el bloque `main()`. Si los archivos base o las firmas de autoría son alterados, el motor de la GameMode abortará el inicio automáticamente para prevenir corrupción de datos.
* **Seguridad de Sesión:** El sistema de inicio de sesión (`DIALOG_LOGIN`) está vinculado directamente a la función de integridad del desarrollador. Cualquier intento de remover los créditos del autor resultará en un cierre inmediato de las conexiones entrantes.
* **Ofuscación de Firma:** Los créditos del desarrollador (**JCR**) están inyectados en el código mediante un método de bajo nivel que los hace resistentes a modificaciones accidentales.

> **Nota para Editores:** Se recomienda no intentar modificar las funciones etiquetadas como `Internal_CheckTableInit` o los bloques de información del `main()`. Estos componentes son vitales para la ejecución del script. Cualquier alteración de estos campos dejará la GameMode inoperativa.

##  Requisitos de Instalación

1. Servidor SA-MP 0.3.7-R2 o superior.
2. Plugin MySQL (v39.1 o superior).
3. Servidor de Base de Datos configurado correctamente en los módulos de conexión.

##  Créditos y Soporte

* **Desarrollador Principal:** JCR
* **Proyecto:** OverZone Roleplay
* **Colaboradores:** No hay colaboradores si quieres colaborar contactame al discord **jcr_isra**

## ?? Licencia

Al utilizar esta GameMode, aceptas mantener los créditos originales del autor visibles tanto en la consola del servidor como en los sistemas de información internos. La remoción de los mismos anula cualquier garantía de funcionamiento del código proporcionado.

______________________________________________________________________
|  __________________________________________________________________  |
| |                                                                  | |
| |   ____                 _____                    _____  _____     | |
| |  / __ \               |___  /                   |  __ \|  __ \   | |
| | | |  | |_   _____ _ __   / /  ___  _ __   ___   | |__) | |__) |  | |
| | | |  | \ \ / / _ \ '__| / /  / _ \| '_ \ / _ \  |  _  /|  ___/   | |
| | | |__| |\ V /  __/ |   / /__| (_) | | | |  __/  | | \ \| |       | |
| |  \____/  \_/ \___|_|  /_____|\___/|_| |_|\___|  |_|  \_\_|       | |
| |                                                                  | |
| |__________________________________________________________________| |
|______________________________________________________________________|
                 DEVELOPED BY: JCR | VERSION: 1.1.10 
 ______________________________________________________________________
  >> SYSTEM INTEGRITY: ACTIVE [CIP PROTOCOL]
  >> CORE VALIDATION:  ENABLED
 ______________________________________________________________________

 [!] INFORMACION DE SEGURIDAD:
 Esta GameMode cuenta con un sistema de proteccion de nucleo (Internal_Check).
 La modificacion de creditos de autor resultara en el bloqueo total del
 motor de ejecucion (Script Termination).

 [!] CARACTERISTICAS:
 - MySQL Global Sync.
 - Dinero & Exp Anti-Cheat.
 - Sistema de Niveles por Matriz JCR.
 ______________________________________________________________________
