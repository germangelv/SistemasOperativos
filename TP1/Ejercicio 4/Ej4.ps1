<#
    .SYNOPSIS
    Muestra los elementos de una colección de objetos que cumplen una condición. 

    .DESCRIPTION
    Se encarga de mostrar en pantalla una colección de objetos, en base a un valor filtro de una propiedad. Tanto las propiedad, como el valor filtro y la colección de objetos son pasados como parámetros al ejecutar el script. 

    .PARAMETER Pipeline
    El script se alimenta de una colección de objetos por pipe.

    .PARAMETER Propiedad
    Nombre de Propiedad sobre la cual se va a operar

    .PARAMETER asc
    Ordena los resultados finales en forma ascendente

    .PARAMETER desc
    Ordena los resultados finales en forma descendente

    .PARAMETER filtro
    Valor que se debe buscar en la propiedad indicada con “-propiedad”. 

    .EXAMPLE
    Get-Process |.\Ej4.ps1 -propiedad Id -asc -filtro 1*
    
    .EXAMPLE 
    Get-Process |.\Ej4.ps1 -propiedad Id -filtro 9*
    
    .EXAMPLE
    Get-Process |.\Ej4.ps1 -propiedad Id -asc -filtro 1* -print Id,Handles,ProcessName

    .NOTES
    Nombre del Script: Ej4.ps1
    Trabajo Practico nro 1
    Programacion de scripts basicos en Powershell
    Ejercicio 04

    Integrantes del grupo:
    D'Amico, Rodrigo       	DNI 36.817.422
    Ibarra, Gerardo         DNI 33.530.202
    Lorenz Vieta, German   	DNI 32.022.001
    Matticoli, Martin	 	DNI 37.121.122
    Silvero, Ezequiel      	DNI 36.404.597

    Entrega: 1º entrega
    Fecha:   05/09/2016
#>

Param(
    #Este va a recibir la entrada por pipe si hubiera. Si no, queda en "blanco"
    [Parameter(Mandatory = $false,ValueFromPipeline=$True)]$Pipeline,
    [Parameter(Mandatory = $true)][String] $propiedad,
    [Parameter(Mandatory = $true)][String] $filtro,
    [Parameter(Mandatory = $false)][String[]] $print,
    [Parameter(Mandatory = $false)][Switch] $asc,
    [Parameter(Mandatory = $false)][Switch] $desc 
    
  )
BEGIN
{
   
    $ArrayList = [System.Collections.ArrayList]@() 
    if($asc -eq $true -and $desc -eq $true)
    {
        Write-Host "Error al invocar script, no puede proporcionarse las opciones de asc y desc en simultaneo" 
        exit
    }
}

PROCESS
{    
    foreach ($obj in $Pipeline) 
    {
    $ArrayList.Add($obj)1>$null #Lleno el array con los objetos que van llegando por el pipeline y redireciono salida para que no aparezca en pantalla
    }          
}

END
{
    
    if($asc -eq $True) #ordenado ascendentemente
    {
        Write-Host Filtro en $propiedad -foregroundcolor yellow
        $ArrayList   |  Sort-Object -Property $propiedad | Where-Object {$_.$propiedad -like $filtro} |Select-Object $print | 
        Format-Table -AutoSize 
    }       
    else
    {
		if($desc -eq $True) #ordenado descendentemente
        {
            Write-Host Filtro en $propiedad -foregroundcolor yellow 
		    $ArrayList  |  Sort-Object -Property $propiedad -Descending| Where-Object {$_.$propiedad -like $filtro} |
            Select-Object $print | Format-Table -AutoSize     
        }
		else
        {
            # muestra sin orden, solo lo que quiero ver
            Write-Host Filtro en $propiedad -foregroundcolor yellow    
            $ArrayList  | Where-Object {$_.$propiedad -like $filtro} |Select-Object -Property $print | Format-Table -AutoSize                  
        }
    }
}