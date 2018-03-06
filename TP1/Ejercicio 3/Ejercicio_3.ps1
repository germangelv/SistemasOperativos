<#
	.SYNOPSIS
        Ordena archivos siguiendo ciertas reglas en los nombres de archivos.    
         
	.DESCRIPTION
        Recibe por parámetro una ruta para ordenar archivos y un parametro de la cantidad de caracteres para aplicar las reglas de ordenamiento.
     
    .PARAMETER ruta
        Para especificar la ruta en la cual se analizara los nombres de archivos para aplicar las reglas de ordenamiento. La misma ebe ser una ruta valida dentro del directorio donde se encuentra el script.

    .PARAMETER cant
        Para especificar la longitud del nombre de archivo desde el cual se aplicara el ordenamiento. El mismo debe ser valor numerico entero.

    .EXAMPLE
    .\Ejercicio_3.ps1 -ruta .\subdirectorio -cant 10

    .EXAMPLE
      .\Ejercicio_3.ps1 -ruta .\in -cant 4
  
    .EXAMPLE
     .\Ejercicio_3.ps1 -ruta .\in\analisis -cant 1
    
    .NOTES
         Nombre script:  .\Ejercicio_3.ps1
         Autores: 
              Matticoli, Martin                 DNI 37.121.122
              D'Amico, Rodrigo                  DNI 36.817.422
              Ibarra, Gerardo                   DNI 33.530.202
              Lorenz Vieta, German              DNI 32.022.001
              Silvero, Ezequiel                 DNI 36.404.597
             
        Entrega: 1º entrega
        Fecha:   05/09/2016

#>
Param
(
	[Parameter(Position=1,Mandatory = $true)] 
	[ValidateNotNullOrEmpty()]       # Valido que la ruta no este vacia
	[String] $ruta = ".",
    
    [Parameter(Position=2,Mandatory = $true)]
    [ValidateNotNullOrEmpty()]       # Valido que el patrón no sea vacio
	[int] $cant

)
# Para usar la funcion isNumber. 
[reflection.assembly]::LoadWithPartialName("'Microsoft.VisualBasic") > $null

# Validacion de ruta y de la cantidad de caracteres a considerar
if (-Not (Test-Path $ruta -PathType Container)){
    Write-Host ""
    Write-Warning "La ruta para analisis [$ruta] no existe."
    Write-Host ""
    return
}
if( [Microsoft.VisualBasic.Information]::isnumeric($cant) -eq $false){
    Write-Host ""
    Write-Warning "La cantidad de caracteres para evaluar [$cant] debe ser numerico"
    Write-Host ""
    return
}
if($cant -le 0){
    Write-Host ""
    Write-Warning "El parametro -cant debe ser mayor a cero"
    Write-Host ""
    return
}


# Valido que la carpeta de origen no este vacia
if ( (Get-ChildItem $ruta -Force ).count -eq 0){
    Write-Host ""
    Write-Warning "La ruta [$ruta] no tiene archivos."
    Write-Host ""
    exit
}

# Obtengo todos los archivos con extension .cualquiera del directorio $ruta
$items = Get-ChildItem -Path $ruta *.* -Recurse

foreach ($item in $items) {

	#Creo un item_name String porque BaseName es un Script y no acepta SubString
	[String]$item_name = $item.BaseName

    # Correccion de Substring que tira error si corto una cadena mas corta que el Substring a extraer
    if( $item_name.Length -ge $cant){
        [String]$item_recortado = $item_name.Substring(0,$cant)
    }
    else{
        [String]$item_recortado = $item_name
    }
    # Para obtener el nombre del archivo sin los espacios para luego analizar contra el nombre con espacios
    $item_recortado_sin_espacios = $item_recortado.Replace(" ","")
    
    # Evaluo la condicion de espacios en blanco y la de nombre mas largo que el parametro limitante
    if ( ($item_recortado.Length - $item_recortado_sin_espacios.Length) -ne $cant -and $item.BaseName.Length -gt $cant ){

        # Para evitar intentar hacer Directorios que ya fueron creados con nombres de archivos que son similares
        if( -not (Test-Path ($item.DirectoryName+"\"+$item_recortado) -PathType Container ) ){
            # Creo carpeta en subdirectorio con el nombre del archivo recortado a $cant caracteres
            New-item -path ($item.DirectoryName+"\"+$item_recortado) –type directory > $null
        }
        # Muevo el archivo original al directorio ordenado literalpath para que tome caracteres especiales
        Move-Item -literalpath $item.FullName -Destination ($item.DirectoryName+"\"+$item_recortado) -Force
    }		
}