<#
	.SYNOPSIS
        Muestra la relación de compresión de archivos dentro de un zip.
         
	.DESCRIPTION
        Muestra el nombre y la relación de compresión de cada archivo que se encuentra dentro de uno de tipo .zip .
    
    .PARAMETER filepath
        Para especificar el archivo .zip que queremos analizar.
		
    .EXAMPLE
        .\Ejercicio_6.ps1 -filepath C:\Users\Rodrigo\Desktop\archivo.zip

    .EXAMPLE
        .\Ejercicio_6.ps1 -filepath in.zip
		
    .NOTES
         Nombre script:  .\Ejercicio_6.ps1
         Autores: 
              Autores: 
              Matticoli, Martin                 DNI 37.121.122
              D'Amico, Rodrigo                  DNI 36.817.422
              Ibarra, Gerardo                   DNI 33.530.202
              Lorenz Vieta, German              DNI 32.022.001
              Silvero, Ezequiel                 DNI 36.404.597
              
        Entrega: 1º entrega
        Fecha:   05/09/2016

#> 
 
 [CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$filepath
)

if (-Not (Test-Path $filepath)){
    Write-Host ""
    Write-Warning "El archivo especificado [$filepath] no existe."
    Write-Host ""
    return
}

function StringVersions { 
param([string]$inputString1,[string]$inputString2,[string]$inputString3,[string]$inputString4) 
  $obj = New-Object PSObject 
  $obj | Add-Member NoteProperty Nombre($inputString1) 
  $obj | Add-Member NoteProperty Tamanio_original($inputString2) 
  $obj | Add-Member NoteProperty Tamanio_comprimido($inputString3)
  $obj | Add-Member NoteProperty Relacion($inputString4)  
  Write-Output $obj 
};

Add-Type -AssemblyName “system.io.compression.filesystem”;

[io.compression.zipfile]::OpenRead("$filepath").entries |% {

$cadena1="$($_.Name)";
$cadena2="$($($_.Length)/1000000)";
$cadena3="$($($_.CompressedLength)/1000000)";
$cadena4="$([math]::Round(($_.CompressedLength/$_.Length),2))";

StringVersions $cadena1 $cadena2 $cadena3 $cadena4
};

