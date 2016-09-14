# CAPITULO 4

Pruebas de ejecución

## 4.1 Introducción

En este capitulo se presentan los resultados obtenidos en cada etapa de la optimización, especialmente el speedup de la aplicación pero también mostrando el uso de archivos en disco así como la cantidad de memoria necesaria. Se mostrará también el estado del sistema durante las distintas ejecuciones de la aplicación.

Como la optimización se realizó en varios pasos, se mostrarán los resultados iniciales, parciales y finales del proceso. De esta manera es posible ver el impacto de cada parte de la optimización en el código legacy. Como indican Grama-Gupta et Al. [cap 2] la optimización previa del código serial es necesaria para evitar efectos indeseados en las mediciones, y puede representar un factor de speedup de la aplicación de entre 2X y 5X. 

La aplicación fue modificada lo menos posible en el proceso de optimización, por lo cual no toda la ganancia posible en una recodificación es alcanzada, pero como se explicó en el capitulo anterior, se trató de hacer los cambios lo más transparentes posibles al usuario y creador de la aplicación.

El código de la aplicación objeto de estudio de esta tesis es entregado junto con los resultados generados para dos conjuntos de datos de entrada, uno para un número total de paneles de 50x50 y otra para un número total de 80x80, siendo estos valores definidos en un archivo que sirve de entrada de datos. Para este trabajo de tesis se elige trabajar principalmente con el conjunto de datos resultante del caso de cantidad de paneles 50x50. Sin embargo, se presentan observaciones obtenidas de una prueba en uno solo de los equipos para el caso de tamaño 80x80. El creador de la aplicación indicó que la ejecución con el tamaño del problema en 50x50 paneles demoraba en el orden de horas de ejecución, indicando que se dejaba corriendo de un día para el otro. La corrida para el tamaño de 80x80 podía llegar a durar días. No se tienen datos fehacientes de estas ejecuciones, las cuales eran realizadas en computadoras de principios de la década del 90.

## 4.2 Equipos/Computadoras/Arquitecturas de prueba

Las pruebas se llevaron a cabo en dos equipos para obtener resultados que permitieran realizar una mejor evaluación del proceso de optimización. 
Las computadoras utilizadas fueron una PC y una Notebook, ambas multiprocesador y con arquitectura de 64 bits. A continuación la descripción de los equipos: 

* Equipo 1 (PC Clon):
      * Procesador AMD Phenom II x4 955 x86_64
             * 4 cores reales.
             * Frecuencia máxima de 3.2 Ghz.
             * Release date: Abril del 2009.
      * Mother ASUS M4A785TD-V EVO
      * 4Gb RAM DDR3 1333Mhz.
      * HD SATA II 3Gbps.
      * USB 2.0 (480 Mbps)
* Equipo 2 (Notebook):
      * Procesador Intel Core i3-370M x86_64
             * 2 cores reales + 2 hilos de control por core.
             * Frecuencia máxima de 2.4 Ghz
             * Release date: Junio del 2010.
      * Mother Dell 0PJTXT-A11.
      * 6Gb RAM DDR3 1333Mhz.
      * HD SATA II 3Gbps.
      * USB 2.0 (480 Mbps)

Nos referiremos en adelante al primer equipo como PC1 y al segundo equipo como PC2.
Se utilizó una versión Live USB de Slackware Linux como sistema operativo para las pruebas. Como disco de almacenamiento sobre el que corría la aplicación se utilizó un Flash Drive USB, en el cual se crearon los archivos durante la ejecución.
Una nota sobre la arquitectura del procesador de PC2. En este caso el procesador tiene dos núcleos, pero al ofrecer dos hilos de control por núcleo, el sistema operativo los ve como si tuviera disponibles cuatro núcleos. El procesador luego distribuye los recursos disponibles sobre cada hilo de acuerdo a lo solicitado por el sistema operativo.

## 4.3 Pruebas de tiempo.
Para las pruebas de tiempo se utilizó el comando time [ref al man time online?] de manera de poder evaluar el tiempo real consumido por la aplicación en sus diferentes etapas: programa original, optimizado serialmente, optimizado paralelamente. Mostraremos los tiempos en los equipos seleccionados para las pruebas y las mejoras en desempeño que obtuvimos en el programa en cada iteración de la optimización. El tamaño de programa seleccionado para las pruebas generales es de 50x50 paneles, el más pequeño provisto por el usuario de la aplicación.
También se incluyen muestras del estado de los archivos en disco luego de la ejecución del programa, el estado de la memoria y la CPU en plena ejecución del programa, para mostrar los resultados de las optimizaciones realizadas.
### 4.3.1 Estado inicial y primeras mediciones
Como se indicó previamente, sólo contamos con el código original y los datos de resultados provistos por el usuario de la aplicación. Lo primero que hicimos fue compilar y ejecutar el programa original para calcular el tiempo inicial de referencia para el resto del trabajo, resguardando de una posible reescritura a los datos originales, que luego utilizaremos para poder verificar la correctitud de las distintas versiones del proceso de optimización. 
En ambos equipos realizamos la compilación con el siguiente comando:

      $ gfortran -o serial invisidos2fin.for

Esto crea un archivo ejecutable llamado “serial”.
Para poder lanzar el ejecutable y poder verificar el tiempo lo realizamos con el comando:

      $ time ./original

El tiempo resultante calculado por el comando “time” arroja para la linea “real” (tiempo real/total de ejecución) 21m48.109s para el equipo PC1.
El equipo PC2 muestra un tiempo de 22m56.392s. Se puede observar esto en la figura 4.3.1.yy.

     Figura 4.3.1.yy.  Mostrar tiempo en figura.

Podemos observar que con un cambio en la arquitecura del procesador (PC1 con 4 cores reales, PC2 con 2 cores y 2 hilos de control por core) se incurre en una demora de 1m8s. Se tomó otra muestra con el equipo PC2 y se obtuvo un resultado similar, 23m1.628s por lo que podríamos indicar que la diferencia persiste y se mantiene dentro de ciertos parámetros. Esta diferencia observada se debe posiblemente a la mayor velocidad del procesador en PC1. Sería de interés investigar el uso de la jerarquía de memoria, especialmente de las caches, en ambos procesadores.

La ejecución genera todos los archivos utilizados para cálculos intermedios y resultados finales así como los temporales con los que el programa trabaja. 
La ejecución serial del programa original generó en ambos equipos la misma cantidad de archivos, 58 archivos entre los “.txt”, “.plt”, “.out” y los “.tmp”, esto es así por el determinismo del programa. No contamos el archivo ejecutable ni el de datos de ingreso “entvis2f.in”. 
El tamaño en disco ocupado tanto en PC1 como en PC2 por los archivos fue de 684 Mb, donde el mayor tamaño era ocupado por los archivos ocho archivos “.tmp”, de los cuales siete ocupan 96 Mb cada uno para un total de 672 Mb. 
Esto se puede observar en la figura 4.3.1.xx. (imagen del tamaño del dir y de los arch) 

      Figura 4.3.1.xx.  mostrar archivos (tamaño con du -sh) y en especial los tmp.

     (si hay mucha variación explicar el tamaño de bloque y el tipo de FS y dejar para estudio). 

     Agregar tabla 4.3.xx con cant archivos, espacio en disco y tiempos de cada equipo.

La cantidad de memoria consumida por el programa al iniciar en cada equipo es de 217 MB en PC1 y lo mismo en PC2. Cuando durante la ejecución la aplicación ingresa en la subrutina solgauss la memoria se incrementa a 255 MB. Y al salir de esta subrutina la memoria baja a 217 MB. Esto nuevamente en ambos equipos. La salida por pantalla de la aplicación nos permite saber en que subrutina se encuentra, por ello en tiempo de ejecución podemos determinar estos estados de la memoria. Justamente la rutina solgauss representa un pico en la cantidad de memoria consumida por la aplicación.
Estos datos se obtienen del comando pmap [referencia a man online?] aplicado sobre el proceso en ejecución, por ejemplo si la aplicación tiene PID 2228:

       $ pmap -x 2228

Esta información se puede observar en la tabla 4.3.yy. 
El comando “top” también permite observar el mismo valor que indica “pmap” en su columna VIRT.

      Agregar tabla 4.3.yy con info de pmap

Por último la CPU utilizada siempre fue una sola de las disponibles, ya que el programa es serial. Esto se puede observar en la figura 4.3.1.zzz, donde se ve el trabajo en uno de los momentos en que el programa está dentro de la subrutina estela.

      Agregar figura 4.3.1.zzz  con imagen de pc1 y pc2

Los datos vistos hasta el momento en el trabajo de tesis son la ejecución del programa original, las dos subsecciones siguientes mostraran como evolucionó con la optimización, teniendo como base los tiempos y tamaños obtenidos en esta primer etapa.

### 4.3.2 Optimización serial y mediciones intermedias
Luego de realizar la optimización serial se tomaron nuevamente mediciones. La compilación se realizó con el mismo comando ya que en esta etapa aún no tenemos la adición de ninguna optimización paralela.

      $ gfortran -o optserial invisidos2fin_optSerial.for

Y nuevamente para medir el tiempo del programa ejecutamos la aplicación con la instrucción time.

      $ time ./optserial

El tiempo obtenido en PC1 fue de 16m2.124s, lo que representa una ganancia de 5m36s aproximadamente sobre la versión serial original de la aplicación en el mismo equipo, teniendo entonces un factor de 1.35 de mejora en el tiempo.
En la computadora PC2 los tiempos obtenidos fueron de 17min 4.161seg. Se observa una mejora sobre la versión serial original de 5m 52s aproximadamente, o un factor de 1.34 X de mejora en el tiempo.
Se puede ver que el factor de mejora alcanzado entre el original serial y el optimizado es muy similar entre ambos equipos, con una diferencia de solo 0.01, y que es levemente mejor en PC1.
Estrictamente hablando del código optimizado serialmente, entre los equipos la diferencia observada es de 1m2s, nuevamente a favor de PC1.
Estos datos se pueden observar en la tabla 4.3.2.1.

      Agregar tabla 4.3.2.1

Al observar el directorio donde se ejecuta la aplicación, observamos que luego de la optimización serial han desaparecido los archivos “*.tmp”, ya que ahora lleva los cálculos intermedios en la memoria para poder mejorar los tiempos de acceso. El resto de archivos (50 en total) siguen creandose, pero al demorar la escritura de los archivos utilizados para ir mostrando y almacenando la salida por pantalla, tanto como los que obtienen los resultados finales, se logra evitar el acceso constante al disco a través de la ejecución de la aplicación para tener solo que hacerlo una vez por archivo al finalizar la ejecución del programa [ref al código??].
El tamaño ocupado por los archivos del programa ahora fue de 16 Mb tanto en PC1 como en PC2. Esto se puede observar en la figura 4.3.2.xx.

      Agregar figura 4.3.2.xx (du -sh y ls)

Observando la memoria en esta versión del programa obtenemos que consume 552 Mb mientras está en solgauss y 504MB el resto del tiempo, tanto en PC1 como PC2. Esto significa un incremento en la cantidad de memoria utilizada, en esta versión optimizada serialmente con respecto a la versión serial original, de 297MB cuando el programa está en la subrutina solgauss y de 287MB antes o después de dicha subrutina. Este incremento se debe a los archivos “*.tmp” que ya no utiliza más en disco y debe llevar en memoria como internal files. 
En la tabla 4.3.2.yy odemos observar estos datos.

      Agregar tabla 4.3.2.yy

Nuevamente en el caso de la CPU podemos observar que un solo procesador (o core) es el encargado de realizar la tarea ya que aún no se optimiza paralelamente. En la figura 4.3.2.zz podemos observar nuevamente la ejecución de la aplicación en PC1, optimizada serialmente, en el momento que está dentro de la subrutina estela.

      Agregar figura 4.3.2.zz.

### 4.3.3 Optimización Paralela y mediciones finales

Finalmente realizamos las pruebas con la versión optimizada paralelamente del programa. Para esta prueba cambiamos la forma de compilar el programa ya que se debe indicar que aprovechará las directivas de OpenMP, esto lo realizamos pasando el parámetro “-fopenmp” al comando de compilación, de la siguiente manera:

        $ gfortran -fopenmp -o paralelo invisidos2fin_optOMP.for

Al terminar tenemos un ejecutable listo para aprovechar la paralelización que brinda OpenMP. 
Nuevamente se ejecutó la aplicación con el comando time, de manera de obtener el tiempo de ejecución. La ejecución se hizo sin limitar la cantidad de threads creados en OpenMP, es decir que la aplicación se ejecutó aprovechando todos los threads disponibles por defecto, es decir uno por cada core disponible (cuatro threads en cada equipo). 

       $ time ./paralelo

Los resultados de time para PC1 indicaron un tiempo de ejecución de 6m5.294s. Al comparar con los 21m48.109s que tomó en su versión original podemos observar 15m42s de mejora aproximada, obteniendo un factor de 3.58 de mejora en el desempeño, lo cual es muy superior a la ganancia inicial con la optimización serial.
En PC2 obtuvimos 8m50.822s de tiempo de ejecución, mientras el programa original tomó 22m56.392s, es decir aproximadamente 14m6s más rápida la versión paralela, obteniendo un factor de 2.59 de mejora en el desempeño. Podemos observar los tiempos en la tabla 4.3.3.1
La diferencia de tiempo de ejecución entre la aplicación optimizada paralelamente en PC1 y PC2 es de 2m45s, observandose esta vez una diferencia de tiempo considerable.
Se podría investigar la incidencia de los 4 cores reales del procesador AMD en PC1 contra los 2 cores reales y 2 hilos de control por core en el procesador Intel de PC2. Ambos procesadores brindan a OpenMP cuatro hilos, pero los recursos son asignados de manera diferente.

       Agregar tabla 4.3.3.1

En el consumo de CPU esta vez podemos observar diferencia entre los programas seriales y uno paralelizado. Se han activado todos los cores disponibles en el equipo al momento de entrar en la zona de la subrutina estela, ya sean cores reales (PC1) o virtuales (PC2). Podemos observar esto en la figura 4.3.3.zz. 
Como ya indicamos, la activación de los cores no fue administrada de manera directa con directivas OpenMP por lo cual todos los cores disponibles fueron utilizados, pero como se indicaba en el capitulo 2 hay más directivas que pueden ser estudiadas de OpenMP que podrían ser utilizadas para disminuir o incrementar la cantidad de hilos generados en una región paralela y estudiar el impacto y la utilización de los recursos en el multiprocesador.

       Agregar figura 4.3.3.zz

El directorio de ejecución del programa queda igual que en la versión optimizada serialmente ya que en esta nueva versión se han agregado las directivas OpenMP utilizadas y no se ha tocado el código serial ni el tratamiento de los archivos.
El tamaño ocupado por los archivos en disco es de 16MB. Estos datos podemos verlos en la figura 4.3.3.xx.

       Agregar figura 4.3.3.xx  (el ls y el du -sh)

Observando la memoria el programa consume 516MB de RAM durante la subrutina solgauss y 468MB en el resto de su ejecución en ambos equipos. Con respecto al original esto indica un incremento de 261MB de memoria mientras está en solgauss y 251MB en el resto de la ejecución. Al comparar con la aplicación optimizada serialmente se observó que el consumo de memoria es menor en la versión con OpenMP. Ocupa 36MB menos durante la ejecución, tanto si se ejecuta en solgauss como en el resto del tiempo. 
Podría investigarse esta diferencias en la memoria en la optimización que realiza el compilador en el código para utilizar las directivas de OpenMP. 
Estos datos los observamos en la tabla 4.3.3.2.

      Agregar Tabla 4.3.3.2

## 4.4 Pruebas con 80x80 paneles
Para determinar la escalabilidad de la solución aplicada y como impacta en un equipo el cambio del tamaño de los datos para el cálculo, se realizaron en PC2 pruebas con el segundo tamaño de prueba provisto por el autor/usuario de la aplicación, 80x80 paneles.
Solo tenemos los resultados de salida de la ejecución del original utilizado por el usuario y se utilizaron para verificar los resultados de salida de las versiones utilizadas para la prueba, arrojando que todas dan una salida correcta de los datos.
Como indicamos en el capítulo 3, el archivo con los datos de entrada para la ejecución de la aplicación (entvis2f.in) posee una única modificación con respecto al de 50x50 y que es  nr = no = 80. Luego mediante el análisis de las diferencias entre los códigos de la versión de tamaño 50x50 contra la de 80x80, observamos que el código en los bloques common de Fortran indica lo siguiente:

       Para el caso 50x50
       parameter (maxir=51,maxio=51,…

       Para el caso 80x80
       parameter (maxir=81,maxio=81,…

Como indicamos en el capítulo 3, maxir y maxio son lo mismo que nr+1 o no+1, lo cual sería una manera más simple de definirlo. Debido a que está hardcodeado en todo el código como observamos, es que para las optimizaciones, serial y paralela, de la aplicación con tamaño de problema 80x80 se debe cambiar en todo el código estas definiciones de maxir y maxio.
Luego de adaptado esto procedimos a las pruebas en el mismo orden que antes, versión serial, versión optimizada serialmente, versión optimizada con OpenMP.

### 4.4.1 Perfilado de aplicación con tamaño 80x80
Previo a correr las pruebas de tiempo en el equipo PC2 realizamos un nuevo análisis de perfilado con la herramienta gprof sobre la aplicación adaptada a un tamaño distinto de problema, ya que esto puede afectar el comportamiento de las subrutinas.
Luego de compilar la aplicación con la opción “-pg” activada, la ejecutamos y obtenemos el archivo gmon.out de salida. Con esto podemos generar la información del perfilado, el cual indica que la subrutina estela es la que más porcentaje del tiempo se ejecuta seguida de solgauss, pero esta vez los porcentajes cambian completamente. Estela se ejecuta 46,42% del tiempo mientras que solgauss ahora ocupa un 43,09%, esto es mucho más que el 14,36% en PC1 o el 16,84% en PC2 obtenido por solgauss para la versión de 50x50. En la tabla 4.4.1.x se puede ver esta información.

Este cambio que se produce en la ejecución al agrandar el tamaño del problema, tendrá impacto en los tiempos de las distintas versiones de la aplicación.

           Agregar figura 4.4.1.x

### 4.4.2 Versión serial
La ejecución en el equipo PC2 arrojó un tiempo de ejecución de 225m43.721s, es decir 3h45m43s. El tamaño del problema se incrementa de 2500 paneles a 6400 paneles, un incremento de factor 2.56 veces, pero el tiempo se hace exponencial, en un factor de 9.78.

El espacio en disco utilizado fue de 4415MB o 4.3GB, siendo los archivos “.tmp” los que ocupaban 4375MB, siete de los ocho archivos pesando 625MB cada uno. En memoria RAM observamos que la aplicación llega a ocupar 1293MB o 1.26GB.

Podemos observar los datos en la imagen 4.4.1.1.

        Imagen 4.4.2.1 con todo lo indicado

### 4.4.3 Versión Optimizada Serialmente
Los tiempos observados en la versión optimizada del código serial son de 150m45.602s, es decir 2h30m45s. El factor de incremento esta vez es de 8.83 con respecto a la aplicación equivalente en el problema de menor tamaño. Por esto se observa una ganancia de tiempo con respecto a la aplicación serial de 75m aproximadamente, o un factor de 1.5, el cual es mejor que ante el problema de menor tamaño. Esto puede ser adjudicado a la mayor cantidad de datos en disco que utiliza la aplicación con este tamaño de disco, en comparación al tamaño 50x50, que ahora son accedidos en memoria. 

En disco se ve claramente el impacto de no utilizar los archivos “.tmp” al ocupar solo 40MB.

El incremento, como en la versión de menor tamaño, se ve en la memoria. Observamos que en ejecución la aplicación utiliza mientras está en solgauss 3483MB (3.4GB) y 3171 (3.09GB) en el resto de la ejecución. El equipo cuenta con 6GB de memoria RAM por lo que no fue necesario que realizara swapping en disco, lo que hubiera impactado en los tiempos.    

### 4.4.4 Versión con optimización paralela
Los tiempos obtenidos en la versión con OpenMP son de 130m39.169s. Se puede observar en las versiones optimizadas, principalmente por el perfilado con gprof ya mencionado y también siguiendo la salida que da el programa por pantalla, que la demora ahora se ubica en la subrutina solgauss. 

El tiempo obtenido nos da una mejora que no es igual a la observada en la versión de 50x50, esta vez representa solo una mejora en un factor de 1.73 sobre la aplicación original.

Si analizamos el tiempo teniendo en cuenta el resultado de gprof para este tamaño de problema (figura 4.4.1.x) y para gprof para el tamaño menor (imágenes 3.x y 3.x1) podemos ver que la paralelización impacta sobre un 30% menos de tiempo, limitando la mejora obtenida al incrementar el tamaño del problema.

El comportamiento en disco es exactamente el mismo que en la versión optimizada serialmente, con 40MB de archivos. 
En memoria ocurre igual que en la aplicación con tamaño 50x50, ocupando menos que en la versión optimizada serialmente, 3184MB (3.1GB) mientras está en solgauss y 2864MB (2.79GB) en el resto de la ejecución.


## 4.6 Conclusión  
En este capítulo hemos presentado distintas pruebas de ejecución de la aplicación bajo estudio durante el proceso de su optimización, distinguiendo tres etapas: aplicación original, aplicación optimizada serialmente, aplicación optimizada paralelamente. 
Además se utilizaron dos plataformas de hardware distintas para dar mayor amplitud a la prueba y poder observar el comportamiento de la aplicación con distinto hardware. 
También se realizó una prueba con un tamaño de problema mayor para ver el impacto de la paralelización y se pudo ver el impacto en la memoria RAM, además de encontrar un perfilado distinto que en la versión de tamaño de problema menor.
Se han podido tomar mediciones de tiempo y de recursos para presentar conclusiones en el siguiente capítulo del trabajo realizado.
