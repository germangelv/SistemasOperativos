<#
	.SYNOPSIS
        Muestra el porcentaje de caracteres que se encuentran en un archivo de texto.
         
	.DESCRIPTION
        Muestra la cantidad de repeticiones (en porcentaje) de los distintos caracteres que hay en un archivo de texto.
    
    .PARAMETER filepath
        Para especificar el directorio del archivo para el analisis.
		
    .EXAMPLE
        .\Ejercicio_2.ps1 -filepath 'C:\Users\darkk\Desktop\tp.txt'
		
    .NOTES
         Nombre script:  .\Ejercicio_2.ps1
         Autores: 
              Matticoli, Martin                 DNI 37.121.122
              D'Amico, Rodrigo                  DNI 36.817.422
              Lorenz Vieta, German              DNI 32.022.001
              Silvero, Ezequiel                 DNI
              
        Entrega: 1º entrega
        Fecha:   05/09/2016

#>

Param( [Parameter(Mandatory=$True,Position=1)][string]$filepath)

if((Test-Path $filepath -PathType Leaf) -eq $false){
    Write-Host ""
    Write-Warning "El archivo [$filepath] no existe."
    Write-Host ""
    return
}

$aux1 = Get-Content $filepath
$flag=0;
$cant=0;
$array=@{}
$array2=@{}

foreach($aux in $aux1){
    if($flag -eq 1){
        $cant++;
        if($array.ContainsKey("Enter")){
            $array["Enter"]++
        }else{
            $array.Add("Enter",1)
        }
    }
    $cant+=$aux.Length;
    for($i=0;$i -lt $aux.Length;$i++){
        if($array.ContainsKey($aux[$i])){
            $array[$aux[$i]]++
        }else{
            $array.Add($aux[$i],1)
        }
    }
    $flag=1;
}


foreach($item in $array.Keys){
    $array2.Add($item,(($array[$item])/$cant).ToString('P'))
}

$array2.GetEnumerator()|sort value |ft name,value;