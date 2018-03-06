# *****************************************************
# Trabajo Practico Nº2
# Entrega Nº2
# Fecha 12/10/2016
#
# Ejercicio 1
# Nombre del script: Ejercicio_1.sh
#
#*****************************************************
#
# Integrantes:  
#
# Apellido y nombre               DNI
#----------------------------------------------
# D'Amico, Rodrigo                  DNI 36.817.422
# Ibarra, Gerardo                   DNI 33.530.202
# Lorenz Vieta, German              DNI 32.022.001
# Matticoli, Martin                 DNI 37.121.122
# Silva, Ezequiel                   DNI 36.404.597           
#
#*****************************************************
#
# 
#Tomando en cuenta las siguientes ejecuciones de scripts responda las preguntas que se
#encuentran más abajo. Tenga en cuenta que antes de poder ejecutarlos deberá marcar
#ambos scripts como ejecutables.
#Importante: como parte del resultado se deberá entregar los script en archivos tipo sh y las
#respuestas en el script2.sh como comentarios.
#NOTA: Todos los scripts están probados y deberán ser copiados
#textualmente respetando espacios y signos de puntuación tal como son
#presentados.
#Responda:
#a) ¿Qué tuvo que realizar para poder ejecutar los scripts luego de generar los archivos?¿con qué comando/s lo realizó?
#b) ¿Se presentó algún error al momento de ejecutar el script?¿a qué se debe el error? ¿cómo se solucionaría? (indique al menos dos formas)
#c) Mencione como se pasan/emplean parámetros en scripts de bash.
#d) ¿Qué particularidad detecta dentro de script2 con la variable?
#e) ¿Qué significa la línea ?#!/bin/bash?? ¿Cuáles son las diferentes formas de ejecutar un script?
#f) ¿Qué información brinda la variable ?$$?? ¿Qué otras variables similares conoce? Explíquelas.
#g) Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en Shell scripts. Realice un ejemplo para tipo de comilla.
#
#*****************************************************

cat script2.sh
#!/bin/bash
./script1.sh 10
echo "Resultado $variable"
. script1.sh 15
echo "Resultado $variable"
./script1.sh $$
echo 'Resultado $variable'
script1.sh 35
echo "Resultado $variable"

#********************RESPUESTAS***********************
#a)- Asignar los permisos de lectura, escritura, y ejecucion atraves del comando chmod 777 ruta/script2.sh
#b)- Si en la ante ultima linea del script2.sh. Se debe a que no reconoce lo que se ingreso en la linea 9. Lo solucionaria indicandole que es otro script poniendole un punto y espacio adelante del nombre, o un punto barra y espacio.
#c)- Para pasar o emplear parametros se usan "$1,$2,...,$n" $n representa el llamado para solicitar que se ingrese un parametro por consola.
#d)- Al ejecutar un script asi "./script" las variables solo existiran dentro del subproceso mientras que si se ejecuta asi ". script" (o source) las variables perteneceran al entorno global. Por esto $variable adquiere el valor 15.
#e)- Indica que se va a utilizar el interprete de bash. Se puede ejecutar el script usando el nombre del archivo, especificando el nombre del intérprete, usando ". ./", o usando el comando source.
#f)- Brinda el numero de proceso de este shell.
#$1, $2, $3, ... parámetros de posición que hacen referencia al primer, segundo, tercer, etc. parámetro pasado al script.
#$_, el último argumento pasado al último comando ejecutado (justo después de arrancar la shell, este valor guarda la ruta absoluta del comando que inicio la shell).
#$#, número total de argumentos pasados al script actual.
#$*, la lista completa de argumentos pasados al script. Esta valor es una cadena de texto.
#$@, la lista completa de argumentos pasados al script. Esta valor es una lista.
#$-, la lista de opciones de la shell actual.
#$IFS, el separador utilizado para delimitar los campos.
#$?, el código de salida del pipe más reciente (es decir, de la última vez que se encadenaron varios comandos mediante el carácter pipe que se escribe como |).
#$!, el PID del último comando ejecutado en segundo plano.
#$0, el nombre de la shell o del script de shell.
#g)- En comillas simples el contenido se interpreta de forma literal.
#Ejemplo:
#SALUDO='Hola $USER, que tal?'
#echo $SALUDO
#En comillas dobles se interpreta las referencias a variable, las explosiona, poniendo en su lugar su contenido
#Ejemplo:
#SALUDO="Hola $USER, que tal?"
#echo "$SALUDO tu directorio de trabajo es $HOME"