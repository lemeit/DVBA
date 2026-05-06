@echo off
echo Moviendo carpetas DVBA a la ruta del proyecto...

:: Mover DVBA_BACKUP_CORRECCION
if exist "C:\DVBA_BACKUP_CORRECCION" (
    echo Moviendo DVBA_BACKUP_CORRECCION...
    move "C:\DVBA_BACKUP_CORRECCION" "G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\"
) else (
    echo DVBA_BACKUP_CORRECCION no encontrada en C:\
)

:: Mover DVBA_CAPAS_CORREGIDAS
if exist "C:\DVBA_CAPAS_CORREGIDAS" (
    echo Moviendo DVBA_CAPAS_CORREGIDAS...
    move "C:\DVBA_CAPAS_CORREGIDAS" "G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\"
) else (
    echo DVBA_CAPAS_CORREGIDAS no encontrada en C:\
)

:: Mover DVBA_REPORTES_VALIDACION
if exist "C:\DVBA_REPORTES_VALIDACION" (
    echo Moviendo DVBA_REPORTES_VALIDACION...
    move "C:\DVBA_REPORTES_VALIDACION" "G:\Otros ordenadores\Mi PC\Documentos\QGIS FIles\Proyecto_Redes_Viales\"
) else (
    echo DVBA_REPORTES_VALIDACION no encontrada en C:\
)

echo Operacion completada.
pause