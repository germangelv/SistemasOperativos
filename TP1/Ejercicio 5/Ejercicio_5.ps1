################################################################################
<#
    .SYNOPSIS
        Muestra una lista de los procesos que utilizan mayor memoria
    .DESCRIPTION
        El comando genera una lista de los M procesos que mas "Working Set" utilizan dentro del sistema.
        El reporte se genera en un archivo en el directorio actual, cada N segundos o una sola vez si se eligen 0 segundos
    .PARAMETER segundos
        Cantidad de segundos para reportar la lista de procesos, si se elige 0 se reporta una sola vez y termina
    .PARAMETER cantidad
        Cantidad de procesos de la lista a reportar
    .EXAMPLE
        .\Ejercicio5.ps1 0 2
    .EXAMPLE
        .\Ejercicio5.ps1 2 5
    .NOTES
         Nombre script:  .\Ejercicio_5.ps1
         Autores:
              Matticoli, Martin                 DNI 37.121.122
              D'Amico, Rodrigo                  DNI 36.817.422
              Ibarra, Gerardo                   DNI 33.530.202
              Lorenz Vieta, German              DNI 32.022.001
              Silvero, Ezequiel                 DNI 36.404.597

        Entrega: 1º entrega
        Fecha:   05/09/2016
#>

################################################################################
<#
Realizar un script que escriba en un archivo, cada N segundos, un listado de
los M procesos que más utilización de memoria tienen, especificando por cada
uno de ellos la siguiente información:
    Identificador (PID) - Path del ejecutable - Memoria (Working Set).
Tanto N como M deben ser pasados como parámetros al script, si N es igual
a 0, entonces la información deberá guardarse sólo una vez. En caso de N
mayor a cero, la información se actualizará cada N segundos.
El intervalo de N segundos se debe controlar con un objeto Timer
(System.Timers.Timer). No se puede utilizar sleep.
#>

################################################################################
Param
(
    [Parameter(Position=1, Mandatory = $true)][ValidateNotNullOrEmpty()][Int] $segundos
   ,[Parameter(Position=2, Mandatory = $true)][ValidateNotNullOrEmpty()][Int] $cantidad
)


if ($segundos -lt 0)
{
    Write-Host "El parametro de segundos tiene que ser mayor o igual a 0"
    return
}
if ($cantidad -le 0)
{
    Write-Host "El parametro de cantidad de procesos tiene que ser mayor a 0"
    return
}


Unregister-Event -SourceIdentifier thetimer -ErrorAction SilentlyContinue -ErrorVariable errorEvent
if (!$errorEvent) {
    Write-Host "Se cancelo el evento"
    return
}

$pathArchivoSalida="MonitorProcesos.txt"
$existeArchivoSaluda = Test-Path $pathArchivoSalida
if ($existeArchivoSaluda -eq $true)
{
    Remove-Item $pathArchivoSalida
}
if ($segundos -eq 0)
{
    Write-Host "Iniciando el reporte"
        $current_date=(get-date -Format 'dd-MM-yyyy--H-mm-ss');
        "##" + $current_date >> $pathArchivoSalida
        #Get-WmiObject Win32_PerfFormattedData_PerfProc_Process |
        #    Where-Object -Property IdProcess -gt 0 |
        #    Sort-Object -property WorkingSet -Descending |
        #    Select-Object -First $cantidad |
        #    Format-List -Property IdProcess,Name,Path,WorkingSet >> $pathArchivoSalida
        Get-WmiObject Win32_Process |
            Where-Object -Property ProcessId -gt 0 |
            Sort-Object -property WorkingSetSize -Descending |
            Select-Object -First $cantidad |
            Format-List -Property ProcessId,Name,Path,WorkingSetSize >> $pathArchivoSalida
}
else
{
    Write-Host "Iniciando el evento de reporte, ejecute nuevamente para detener el evento"
    try
    {

        $timer = New-object timers.timer

        $action = {

                #Write-Host "Ejecutando action"

                $cantidad = $($event.MessageData.cantidadProcesos)
                $pathArchivoSalida = $($event.MessageData.archivoSalida)

                $current_date=(get-date -Format 'dd-MM-yyyy--H-mm-ss');

                "##" + $current_date >> $pathArchivoSalida
                #Get-WmiObject Win32_PerfFormattedData_PerfProc_Process |
                #    Where-Object -Property IdProcess -gt 0 |
                #    Sort-Object -property WorkingSet -Descending |
                #    Select-Object -First $cantidad |
                #    Format-List -Property IdProcess,Name,Path,WorkingSet >> $pathArchivoSalida
                Get-WmiObject Win32_Process |
                    Where-Object -Property ProcessId -gt 0 |
                    Sort-Object -property WorkingSetSize -Descending |
                    Select-Object -First $cantidad |
                    Format-List -Property ProcessId,Name,Path,WorkingSetSize >> $pathArchivoSalida

                #Write-Host "Termino action"
        }

        $timer.Interval = $segundos * 1000

        $pso = New-Object PSObject -property @{cantidadProcesos = $cantidad; archivoSalida=$pathArchivoSalida;}

        Register-ObjectEvent -InputObject $timer -EventName elapsed -SourceIdentifier thetimer -MessageData $pso -Action $action

        $timer.start()

        return

    }
    finally
    {
    #   Unregister-Event -SourceIdentifier thetimer
    #    Write-Host "FIN"
    }
}
