<#
    .SYNOPSIS 
        Muestra por pantalla los elementos que se encuentran en la carpeta que se ingresa por consola por nombre y formato, con su peso en bytes. 
         
    .DESCRIPTION
        Muestra por pantalla todos los elementos que no son carpetas, que se encuentran en el directorio en la consola, cada una en una linea diferente
        formando una lista con los datos de nombre con el formato que corresponde, y el tamaño de los mismos en bytes.
        Si no se ingresa el directorio de salida en el parametro va a mostrar en pantalla un error, pero va a funcionar igual.
            
    .EXAMPLE
        .\Ejercicio_1.ps1 "C:\" 3
    
    .NOTES
         Nombre script:  .\Ejercicio_1.ps1
         Autores: 
              Matticoli, Martin                 DNI 37.121.122
              D'Amico, Rodrigo                  DNI 36.817.422
              Ibarra, Gerardo                   DNI 33.530.202
              Lorenz Vieta, German              DNI 32.022.001
              Silvero, Ezequiel                 DNI 36.404.597
              
        Entrega: 1º entrega
        Fecha:   05/09/2016

Responder:

1. ¿Cuál es el objetivo del script? 
    Mostrar por pantalla todos los elementos que se encuentran en la direccion donde se encuentra la linea de comandos, 
    sin incluir carpetas, con su tamaño en bytes, y su extension.

2. ¿Qué validaciones agregaría a la definición de parámetros?
    Agregaria una validacion que solicite una direccion de salida en caso que sea null el contenido del parametro, para impedir errores.

3. ¿Con qué cmdlet se podría reemplazar el script para mostrar una salida similar?
    podria usar Get-Item y el comodin * para que me devuelva una salida similar

#>
    
Param($pathsalida)

$existe = Test-Path $pathsalida

if ($existe -eq $true)

{

$lista = Get-ChildItem -File

foreach ($item in $lista)

{

Write-Host “$($item.Name) $($item.Length)”


}

}

else

{

Write-Error "El path no existe"

}