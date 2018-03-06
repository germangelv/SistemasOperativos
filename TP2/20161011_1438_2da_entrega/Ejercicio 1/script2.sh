# *****************************************************
# Trabajo Practico N�2
# Entrega N�2
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
#encuentran m�s abajo. Tenga en cuenta que antes de poder ejecutarlos deber� marcar
#ambos scripts como ejecutables.
#Importante: como parte del resultado se deber� entregar los script en archivos tipo sh y las
#respuestas en el script2.sh como comentarios.
#NOTA: Todos los scripts est�n probados y deber�n ser copiados
#textualmente respetando espacios y signos de puntuaci�n tal como son
#presentados.
#Responda:
#a) �Qu� tuvo que realizar para poder ejecutar los scripts luego de generar los archivos?�con qu� comando/s lo realiz�?
#b) �Se present� alg�n error al momento de ejecutar el script?�a qu� se debe el error? �c�mo se solucionar�a? (indique al menos dos formas)
#c) Mencione como se pasan/emplean par�metros en scripts de bash.
#d) �Qu� particularidad detecta dentro de script2 con la variable?
#e) �Qu� significa la l�nea ?#!/bin/bash?? �Cu�les son las diferentes formas de ejecutar un script?
#f) �Qu� informaci�n brinda la variable ?$$?? �Qu� otras variables similares conoce? Expl�quelas.
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
#e)- Indica que se va a utilizar el interprete de bash. Se puede ejecutar el script usando el nombre del archivo, especificando el nombre del int�rprete, usando ". ./", o usando el comando source.
#f)- Brinda el numero de proceso de este shell.
#$1, $2, $3, ... par�metros de posici�n que hacen referencia al primer, segundo, tercer, etc. par�metro pasado al script.
#$_, el �ltimo argumento pasado al �ltimo comando ejecutado (justo despu�s de arrancar la shell, este valor guarda la ruta absoluta del comando que inicio la shell).
#$#, n�mero total de argumentos pasados al script actual.
#$*, la lista completa de argumentos pasados al script. Esta valor es una cadena de texto.
#$@, la lista completa de argumentos pasados al script. Esta valor es una lista.
#$-, la lista de opciones de la shell actual.
#$IFS, el separador utilizado para delimitar los campos.
#$?, el c�digo de salida del pipe m�s reciente (es decir, de la �ltima vez que se encadenaron varios comandos mediante el car�cter pipe que se escribe como |).
#$!, el PID del �ltimo comando ejecutado en segundo plano.
#$0, el nombre de la shell o del script de shell.
#g)- En comillas simples el contenido se interpreta de forma literal.
#Ejemplo:
#SALUDO='Hola $USER, que tal?'
#echo $SALUDO
#En comillas dobles se interpreta las referencias a variable, las explosiona, poniendo en su lugar su contenido
#Ejemplo:
#SALUDO="Hola $USER, que tal?"
#echo "$SALUDO tu directorio de trabajo es $HOME"