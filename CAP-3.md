# CAPITULO 3

Optimización e implementación de multiprocesamiento con OpenMP en Fortran para una aplicación legacy de Dinámica de Fluidos.

##3.1 Introducción

En los capítulos anteriores presentamos la problemática por la cual surge la idea y la necesidad de paralelizar la programación, así como las herramientas a utilizar, en nuestro caso OpenMP bajo Fortran. La elección del lenguaje Fortran se debe a que el usuario de la aplicación utilizada es también su creador, de manera que, para hacer el cambio lo más transparente posible, se decide no alterar este aspecto del programa.
Con Fortran como base, y teniendo en cuenta la estructura del programa con un análisis inicial del mismo, debido a las características de programa estructurado, monolítico y no modularizado, se elige orientar la solución a aplicar concurrencia en un entorno de Memoria Compartida y dejar habilitada la ejecución paralela en un equipo multiprocesador.

La aplicación bajo estudio utiliza archivos de datos en disco para guardar resultados, tanto parciales como finales. Esta actividad de entrada/salida introduce importantes demoras en el tiempo de respuesta, que necesitamos considerar. En este capítulo describiremos el proceso seguido para la optimización del código Fortran en lo relacionado con el manejo de los archivos en memoria. Esta primera fase de optimización permitirá la paralelización de segmentos de código.
También realizaremos un análisis del perfil de ejecución de la aplicación con una herramienta de perfilado  que permitirá identificar qué rutinas son las que más tiempo consumen y cuáles son las más indicadas para aplicar la paralelización.
Por último veremos la forma como se ha aplicado OpenMP a las partes seleccionadas de la aplicación. Explicaremos por qué han sido seleccionadas ciertas construcciones especificas del código y las razones de modificar algunas estructuras de control para hacer  más eficiente la utilización de la memoria y de la CPU.


## 3.2 Análisis de la aplicación.
Primero se analizó la aplicación para poder proceder con su optimización y paralelización. Como se explicó  en la sección 2.5, determinamos la plataforma en que debería ejecutarse la aplicación, determinando versión de sistema operativo  y arquitectura. La aplicación recibida fue utilizada por su programador, en arquitectura x86 de 32 bits, bajo sistema operativo  GNU/Linux, específicamente con la distribución CentOS. 
Lo primero fue obtener resultados base de ejecuciones de la aplicación bajo ese entorno, para tener una referencia para la comparación de resultados. El autor de la aplicación nos indicó que la misma es totalmente determinística, con lo cual la aplicación, con los mismos datos de entrada provistos, debe dar los mismos resultados en todas las ejecuciones. 
Para llevar a cabo el trabajo de la Tesis se seleccionó el entorno GNU/Linux, con la distribución Slackware de 64 bits como base, a la cual no fue necesario agregar componentes ni realizar ninguna compilación especial. Se verificó que la aplicación entregada por el usuario compilara correctamente sin ninguna modificación en esta plataforma y arrojara, para los datos de entrada, exactamente los mismos resultados que en su entorno original. Con esto ya verificado se avanzó en el trabajo de Tesis hacia el análisis propiamente dicho de la aplicación. 
Como vimos en el capítulo anterior, lo primero antes de optimizar es tener una aplicación que produzca resultados correctos. En nuestro caso se nos presentó una aplicación ya depurada y funcionando correctamente, por lo cual no debimos preocuparnos por esta parte, así que pasamos a la parte de optimización, donde se deben seleccionar previamente los casos de test para validar que la optimización sigue produciendo resultados correctos.
Contamos con dos casos de test provistos por el creador de la aplicación, los cuales se identifican por dos parámetros (nr y no) que definen, respectivamente, la cantidad total de palas y nodos sobre los cuales se va a realizar la simulación. Con estos parámetros se definen los casos de test, con valores iguales para ambos datos: nr = no = 50 en el primer caso de test, y nr = no = 80 en el segundo caso.
Estos valores también definen unas variables globales comunes de la aplicación llamadas “maxir” y “maxio” que se fijan a nr+1 y no+1 respectivamente. Los valores están codificados directamente en la aplicación y no se utiliza ningún tipo de constante que los defina, algo que sería mas adecuado para el tratamiento de dichos valores y para tener un código más limpio; esto no se modificó y se mantuvo el tratamiento original de los valores para alterar lo menos posible el código. 
Por el mismo motivo, tampoco se modificó la obtención de los valores de entrada para las simulaciones a partir de un archivo de texto.

### 3.2.1 Análisis de perfilado
Como paso preliminar de la optimización realizamos análisis de la aplicación con la herramienta de perfilado gprof, para poder comparar los principales puntos de consumo de tiempo con anterioridad a la optimización y luego de la misma. De esta forma se pretende seleccionar una o varias rutinas para la paralelización y observar de qué manera cambia el comportamiento de la aplicación con la optimización.
Los datos obtenidos por gprof en esta etapa muestran que la rutina estela() resulta ser la que consume el mayor porcentaje, 79,83% del tiempo de ejecución de la aplicación. Le sigue la rutina solgauss() con un 14,36%. Estos datos se pueden observar en la figura 3.x

                Agregar imagen 3.x (Dropbox/Tesis/andres_scripts/tesis/oso_fortran/salida.gprof)
                --explicar los datos y luego apuntar al gráfico y no al reves--

Con estos resultados se pudo inferir en esta primer revisión que estas dos rutinas son las candidatas a ser optimizadas con procesamiento paralelo.
Para las pruebas se utilizaron dos computadoras de escritorio distintas, ambas con multiprocesadores. El primer equipo posee un procesador AMD Phenom II con 4 nucleos y 4Gb de memoria RAM. El segundo equipo consta de un procesador Intel Core i3 con 2 nucleos (2 hilos cada procesador) y 6 Gb de RAM. Las especificaciones completas son provistas en el Capítulo 4 donde se analizan los resultados obtenidos.
La salida de la imagen 3.x fue obtenida en el primer equipo.
Realizamos el mismo análisis de perfilado sobre el segundo equipo, y observamos que la mayor porción del tiempo sigue siendo consumida por la rutina estela() seguida por solgauss() casi en los mismos porcentajes, 74,26% y 16,84% respectivamente. También es de notar la mejoría en los tiempos de ejecución. Esto se puede observar en la figura 3.x1:

                Agregar imagen 3.x1 (tesis/oldone/omg2k14gprof)


Según Garg y Sharapov tendríamos “código correcto no optimizado” (Unoptimized Correct Code)[ref Techniques for Optimizing Apps: HPC] , así que siguiendo las etapas del proceso de optimización visto en el capítulo 2 debemos realizar una optimización serial para obtener código optimizado, y luego de esto pasamos a la etapa de “Optimización Paralela”, donde aplicamos paralelización al código para obtener justamente código paralelo optimizado. Esto se puede ver en la imagen 3.y.
En las siguientes secciones veremos como realizamos estas dos etapas del proceso para obtener nuestra aplicación de estudio optimizada paralelamente.

                imagen 3.y del pdf de estos muchachos (figura 1-1, hoja 51 del pdf)

## 3.3 Optimización Serial del código Fortran. 
Como indican Garg y Sharapov [ref Techniques for Optimizing Apps: HPC] “la optimización serial es un proceso iterativo que involucra medir repetidamente un programa seguido de optimizar sus porciones críticas”. Con esto hecho debemos optimizar las opciones de compilación y luego linkear librerías optimizadas. En el trabajo de tesis intentamos reducir al mínimo las modificaciones al código por lo cual las opciones que se utilizaran para el compilador, ya sea directivas u opciones por linea de comando, serán solo las de OpenMP; además la aplicación no hace uso de ninguna librería externa expresamente, solo las que utiliza el compilador. Como buscamos observar el impacto de optimizar serialmente el código y aplicar paralelización, no se utilizan librerías que pudieran optimizar otras partes del programa, entendiendo/suponiendo además que las librerías propias del compilador están  optimizadas para la plataforma donde se ejecuta.

### 3.3.1 Análisis del acceso a datos de la aplicación
Al analizar los resultados que arroja la aplicación luego de ser ejecutada observamos que maneja muchos archivos en disco, tanto de texto como binarios (temporales). Con la simple ejecución de un comando “ls” en el directorio de la aplicación podemos ver que aparecen 34 archivos TXT, 9 archivos PLT, 5 archivos OUT y por ultimo 8 archivos TMP; no contamos el archivo fuente .for, el ejecutable invisidosExe, el archivo con los datos de entrada entvis2f.in, ni el que utilizamos para almacenar los datos de gprof, invisidosExegprof.

        h4ndr3s@gondolin:~/pruebas/oldone$ ls
        alfa.txt    	cp2.txt      	integ1.txt         		vel02int.txt
        arco.txt    	cpei.plt     	integ2.txt         		vel02pvn.txt
        cindg.tmp   	cpei.txt     	invisidos2fin.for  	velcapae.txt
        circo.txt   	cr.txt       	invisidosExe*           	velcapai.txt
        cix1.tmp    	entvis2f.in  	invisidosExegprof     	velindad.plt
        cix2.tmp    	estel1.txt   	palas.plt          		velindad.txt
        ciy1.tmp    	estel2.txt   	palest.plt         		velpotad.txt
        ciy2.tmp    	estel3.txt   	panel.plt          		velresad.plt
        ciz1.tmp    	fuerza.plt   	panel.txt          		veltotal.txt
        ciz2.tmp    	fzas.txt     	pres.plt           		velxyz.txt
        co.txt      	gama.txt     	salida2.out        		vix.txt
        coefg.tmp   	gdifo.out    	subr.out           		viy.txt
        coefp.txt   	gdifr.out    	vector.plt         		viz.txt
        coord.txt   	gmon.out     	vel01ext.txt       		vn.txt
        cp075c.txt  	go.out       	vel01int.txt
        cp1.txt     	gr.out       	vel02ext.txt

Los archivos en su mayoría tienen tamaños que van desde 8 Kb hasta 2 Mb, pero los archivos TMP pueden pesar varios Mb dependiendo el File System utilizado por el sistema operativo y su configuración particular (tamaño de bloques), viendose 96 Mb en algunos y hasta 192 Mb o mas de 200 Mb en otros. Esto indica un gran volumen de datos que son escritos a, y leidos desde disco por la aplicación.
Al hacer la aplicación un uso grande de archivos en disco, para comprender mejor que se necesita optimizar, registramos la correspondencia entre archivo y subrutina que accede al mismo, indicando si escribe, lee, hace ambas cosas o hace rewind. De dicho registro podemos obtener los archivos que son escritos a disco unicamente y cuales además son leídos por la misma u otras subrutinas.
En la tabla 3.y podemos ver esta correspondencia.

			Agregar Tabla 3.y de archivos y subrutinas y sus operaciones

Para Fortran los archivos escritos en disco son External Files, pero también podemos llevar la misma información en Internal Files, que son cadenas de caracteres o arreglos de cadenas de caracteres que en Fortran poseen las mismas características de los archivos comunes (i.e. se pueden manejar con las mismas funciones) solo que son ubicados en memoria RAM. En este caso la decisión se basa en que la velocidad ganada al acceder a la información en memoria RAM en lugar de en disco es grande (por ejemplo, la latencia en memoria se mide en nanosegundos y en disco en milisegundos), por lo cual al manejar archivos en memoria para lectura y escritura conseguimos mejorar la performance de la aplicación.

### 3.3.2 Optimización por adaptación de archivos externos a internos

La primera decisión tomada en cuanto a la optimización del código es hacer desaparecer del código, o demorar su utilización, la mayor cantidad de archivos que son tanto escritos como leídos en disco por la aplicación durante su instancia de ejecución, de lo cual se desprende que no haremos ningún cambio sobre los archivos que son unicamente escritos por las subrutinas con unas excepciones, el archivo salida2.out y subr.out que guardan resultados de la ejecución a medida que avanza y lo mostrado en salida estándar respectivamente. Estos archivos se guardaran en Internal Files de Fortran y su escritura se demorara hasta el fin del programa.
Luego todo archivo o External File que es escrito y leído durante la ejecución de la aplicación será mantenido por un Internal File, donde solo deberemos cambiar en cada “write”, “read” y “rewind” las referencias al primero por el segundo, como por ejemplo vemos en la imagen 3.xxx el código previo a la modificación y en la 3.xxy el código ya modificado.

    Imagen 3.xxx mostraría:
      open(unit=15,file='subr.out')
      ...
      write(15,1)
      write(6,1)

    Imagen 3.xxy mostraría:
      character subrout(500)*60   ! definición del Internal File
      ...
      write(subrout(nsubr),1)
      nsubr=nsubr+1
    !      write(15,1)
      write(6,1)

Como se ve, reemplazamos el archivo “subr.out” representado por el identificador de unidad 15 por el Internal File denominado subrout.
Un par de aclaraciones sobre las imagenes, como dijimos el External File subr.out sería manejado con un Internal File que como vemos en la declaración de la imagen 3.xxy es un arreglo de 500 cadenas de 60 caracteres como máximo. Todos nuestros Internal Files como se había explicado en parrafos previos son arreglos de cadenas de caracteres. La variable nsubr mantiene la posición en el internal file a ser escrita, y el “1” en los comandos write es un formato de escritura definido dentro del programa como se explicaba en el capitulo anterior.
En la tabla 3.yy vemos como quedan las equivalencias de los External Files y su correspondiente cambio a Internal File.

		Tabla 3.yy con tabla de External a Internal file

El proceso fue realizado primero en la subrutina Estela, buscando mejorar sus tiempos al convertir el manejo de los archivos integ1.txt e integ2.txt en internal files, retrasando la escritura en disco de los datos hasta el final de la subrutina. Lo primero observado en este cambio es un incremento comprensible del uso de memoria de la aplicación, pasando de un uso originalmente de 200 a 202Mb sin aplicar ningún cambio, a utilizar 205Mb con el cambio en el tratamiento de los archivos indicados. Es un cambio mínimo, pero con los cambios sucesivos se verá el impacto en la utilización de memoria.
De acuerdo a la tabla de funciones y archivos, y al análisis de gprof realizado, procedimos a modificar las subrutinas Solgauss y Circulac que son las que leen y escriben los archivos TMP respectivamente, archivos que consumen la mayor cantidad de espacio en disco de los utilizados por la aplicación.
Antes de realizar el cambio directamente, analizamos que estructura sería la mas adecuada para llevar los resultados, ya que los archivos TMP eran binarios y sin formato, llevando valores calculados de una subrutina a otra.

Seleccionamos primero los archivos coefg.tmp y cindg.tmp (definidos como units 40 y 41 respectivamente al principio de la aplicación original) ya que eran los de menor tamaño de todos los archivos tipo TMP. Como observamos en la tabla 3.y los archivos mencionados son escritos en la subrutina “circulac” y leidos en “solgauss” (además de los rewind).
La subrutina circulac, como indica en sus comentarios realiza el “calculo de la circulación asociada a la estela y a cada anillo vorticoso”. Está dividida en tres partes, siendo la primer parte la que realiza la escritura de los archivos coefg.tmp y cindg.tmp, y donde para estos cálculos lee los archivos tmp cix2.tmp, ciy2.tmp y ciz2.tmp, los cuales no son modificados en esta etapa. La segunda parte realiza la resolución de un sistema de npa*npa ecuaciones algebraicas y lo hace llamando a la subrutina solgauss que veremos a continuación. En la tercer parte con los resultados obtenidos se calculan otros valores que se escriben en otros archivos de resultados.
Como la subrutina “circulac” es la que crea los archivos coefg.tmp y cindg.tmp analizamos las estructuras de control utilizadas para generar dichos archivos. 

El bucle externo controlado por el “do 1” realiza el equivalente a npan iteraciones, con lo cual podemos concluir que el archivo determinado por la unit 41 (lo sabemos por el write(41)), es decir cindg.tmp, almacena un total de npan resultados. El bucle interno controlado por el “do 2” realiza npan*npan iteraciones, por lo tanto el archivo determinado por la unit 40 (write(40)), i.e. coefg.tmp, almacena npan*npan resultados. 
Analizado esto podemos definir que el tamaño de nuestros internal files para dichos archivos serán de npan y npan*npan. Luego podemos ver que las variables coefg y cindg que almacenan los resultados para escribir en los archivos no están tipificadas explicitamente en el código, con lo cual observamos en el bloque common de toda la aplicación (repetido en cada subrutina) que se realiza la siguiente declaración:

      implicit real*8 (a-h,o-z)

la que indica que cualquier variable no tipificada definida en el código cuyo nombre comience con una letra entre los rangos indicados (a-h y o-z) será declarada, implicitamente, como real*8, por lo cual podemos asegurar que coefg y cindg son de tipo real*8. Con esto determinado podemos declarar internal files de tipo real*8 de tamaños npan y npan*npan para reemplazar a cindg.tmp y coefg.tmp respectivamente:

      real*8 cindgtmp(npan),coefgtmp(npan*npan)

siendo cindgtmp el internal file para cindg.tmp y coefgtmp el internal file para coefg.tmp.
Ahora debemos reemplazar las escrituras de los archivos binarios en disco con los internal files de la siguiente manera, donde existían las siguientes escrituras:

     write(40)coefg
     write(41)cindg

reemplazamos con el siguiente código:

     coefgtmp(incoefg)=coefg
     cindgtmp(npa)=cindg

respectivamente. 
La variable “incoefg” es utilizada para marcar la posición en el array de npan*npan elementos, internal file coefgtmp, por cada vez que entramos en el bucle interior, como es un array de una dimensión (igual al archivo binario que reemplaza) es necesario tener guardada la ultima posición por cada iteración del bucle externo. Para el internal file cindgtmp que reemplaza a cindg.tmp con utilizar la variable “npa” es suficiente, ya que lleva exactamente la posición en el array por cada iteración (es la variable de control del bucle).
En el siguiente extracto de código observamos las estructuras DO mencionadas que aparecen al principio de “circulac” [Prado2005 – lineas 2806-2841]:

      do 1 npa=1,npan
      do 2 nv =1,npan  
      [...]
      coefg= sumbcx*vnx(npa)+sumbcy*vny(npa)+sumbcz*vnz(npa) 
      write(40)coefg
    2 continue 
      [...]      
      cindg= (-1.)*(vtgx(npa,1)*vnx(npa)+vtgy(npa,1)*vny(npa)+
     &              UU*vnz(npa))
      write(41)cindg
    1 continue

Como explicabamos, la segunda parte de “circulac” llama a la subrutina “solgauss”, y previo a esto habiamos dicho que los archivos cindg.tmp y coefg.tmp que estamos reemplazando son escritos por la primera y leidos por la segunda. En “solgauss” el cambio es simple, tenemos dos bucles anidados que iteran de la misma manera que en “circulac” solo que leen los datos almacenados en los archivos TMP. Luego de esto hacen rewind de los archivos para que vuelvan a quedar disponibles para lectura al principio de los mismos. A continuación podemos ver el código original:

      m=npan+1

      do 1 i=1,npan 
      do 2 j=1,npan 
      read(40)cfg  
      coefg(i,j)=cfg
    2 continue
      read(41)cig
      coefg(i,m)=cig
    1 continue  

      rewind(40) 
      rewind(41)

Como vemos aquí se leen ambos archivos para armar una matriz con la variable denominada coefg, la cual tiene npan filas y npan+1 columnas, realizando lo siguiente, en cada fila almacena en los primeros npan valores, o primeras npan columnas, los datos obtenidos de coefg.tmp, y en último lugar, columna npan+1, el dato obtenido de cindg.tmp.

Para permitir que “solgauss” pueda trabajar con el cambio que introdujimos es necesario que reciba de alguna manera las referencias a los internal files. Esto lo conseguimos simplemente pasando por parámetro los mismos. El cambio en el código sería el siguiente:

    Código original definición de subrutina
        subroutine solgauss(npan,gama)
        ...

    Código modificado
        subroutine solgauss(npan,gama,tmpcoefg,tmpcindg)
        …
        real*8 tmpcoefg(mxro*mxro),tmpcindg(mxro)

Aquí tmpcoefg y tmpcindg son los nombres como identifica la subrutina a los Internal Files, y ambos arrays deben ser declarados explícitamente en la sección correspondiente.
Luego que solgauss conoce la existencia de los internal files necesarios, modificamos los bucles de control para que los utilicen.
El código visto previamente de solgauss quedó de la siguiente manera:

      m=npan+1                                                     
      incfg=1                                                      

      	do 1 i=1,npan
      	do 2 j=1,npan                                                
      	!read(40)cfg
      	incfg=((i-1)*npan)+j                                         
      	cfg=tmpcoefg(incfg)                                            
      	coefg(i,j)=cfg                                               
      	incfg=incfg+1                                                
    2 continue
      	!read(41)cig                                                 
      	cig=tmpcindg(i)                                                
      	coefg(i,m)=cig                                               
    1 continue                                                     

      !rewind(40)                                                  
      !rewind(41)

Como indicábamos, el cambio no es complicado, lo primero que hicimos fue la inclusión de una variable de control “incfg” inicializada en 1 (uno) con la cual mantener la posición de la cual debe leerse desde tmpcoefg (que reemplaza a coefg.tmp) la próxima vez que se ingresa al bucle de control; luego cambiamos los read en disco de los archivos de texto por el acceso a los internal files (en memoria), utilizando una variable auxiliar extra para leer el dato y luego ingresarlo en la matriz “coefg”. La variable auxiliar es utilizada para salvar errores aleatorios encontrados en los datos asignados al utilizar una asignación directa del internal file a la matriz “coefg”. La variable “incfg” es utilizada para seguir la posición del internal file “tmpcoefg”, ya que la posición del internal file “tmpcindg” puede ser llevada utilizando la variable de control del bucle, en este caso “i”.

Estos cambios y ajustes para el recambio de archivos de texto por archivos internos (arrays en memoria) se realizó por cada uno de los archivos indicados en la tabla 3.yy. 
En su mayoría el cambio es simple y consiste en cambiar unas lineas de código, como por ejemplo los que mantienen los archivos subr.out y salida2.out para postergar la escritura en disco de dichos archivos. Esos archivos internos son subrout y salida2out respectivamente, para los cuales agregamos la siguiente definición en el bloque “common”:

    character salida2out(102)*95, subrout(500)*60

Y luego al utilizarlos llevar junto con ellos un contador que lleve la posición siguiente para escribir, al cual llamamos nsubr para subrout:

    write(subrout(nsubr),1)
    nsubr=nsubr+1

y nsld2 para salida2out:

    write(salida2out(nsld2),21)indice,ncapa
    write(salida2out(nsld2+1),'(a1)') ""
    nsld2=nsld2+2

En estos ejemplos, recordamos del capítulo 2 que el número ubicado en el comando “write” al lado del archivo interno es una etiqueta de formato. La cantidad de elementos de estos arrays corresponde con la cantidad de lineas que genera el archivo en disco.
En el resto del código el tratamiento de estos archivos es similar, variando solamente de acuerdo a que datos deben ser escritos en el mismo, como observamos en los archivos internos que vimos previamente, los que reemplazan a coefg.tmp y cindg.tmp.
Un caso especial son los archivos internos cix1tmp, cix2.tmp, ciy1tmp, ciy2.tmp, ciz1tmp y ciz2.tmp, para los cuales sus homonimos archivos en disco (cix1.tmp, cix2.tmp, y así sucesivamente) son definidos en el programa original como “unformatted”, i.e., sin formato, con lo cual se generan archivos en disco de tipo binario. Para obtener el mismo comportamiento en nuestros archivos internos debimos tener el cuidado de escribir en ellos sin dar formato a lo ingresado, i.e., los valores ingresan tal cual son generados por el programa. Veamos un ejemplo con cix1tmp. 

El código para escribir los valores en el programa original es el siguiente:

	do 114 npa=1,npan
	do 113 nv=1,npan

	write(42)cix(npa,nv)
	…
    113 continue
    114 continue

La apertura del archivo cix1.tmp le asigna al principio del programa la unidad 42 para referencia posterior en el programa y de ahí el descriptor utilizado por el write, mientras que la matriz “cix” es generada por calculos previos. Al asígnar directamente y no dar un formato a utilizar en el comando write, estamos escribiendo los valores “crudos” para ser almacenados.

El código en el programa optimizado es:

        common  … cix1tmp(maxro*maxro), …
        …
	kon=1
	do 114 npa=1,npan
	do 113 nv=1,npan

	cix1tmp(kon)=cix(npa,nv)
	…
	kon=kon+1
    113 continue
    114 continue

Aquí referenciamos primero la definición del archivo interno cix1tmp, y no se define un tipo por defecto, por lo que como explicamos en parrafos anteriores, toma el tipo implicito real*8 definido en el bloque “common” de cada subrutina. 
El tamaño del archivo interno en su definición (maxro*maxro) lo define el mismo bucle que lo genera, que itera desde 1 a “npan” dentro de otro bucle que itera la misma cantidad de veces, i.e., genera npan*npan elementos en cix1tmp. La variable maxro definida “common” y con valor previamente asignado es equivalente a npan, y maxro es preferida a esta ya que en el bloque de definición npan aún no tiene asignado su valor. 
Por último la variable “kon” oficia de contador de posiciones para el archivo interno.
Luego de igual manera modificamos el código donde el archivo interno es leido por su equivalente interno. 
El código original sería:

    read(42)cinfx

Optimizado con archivo interno:

    cinfx=cix1tmp(kon)

Donde nuevamente la variable “kon” lleva la posición dentro del archivo interno.

De igual manera son manejados los demás archivos externos binarios como archivos internos, los cuales mantienen la información necesaria en memoria y no en disco. El tiempo de lectura y escritura de dichos archivos se disminuye considerablemente, pasando de tiempos de acceso medidos en milisegundos para un disco rigido, a tiempos de acceso en nanosegundos para la memoria RAM, lo cual implica un aumento de velocidad en un orden de 1000 veces, al menos en teoría. 
Obviamente esto trae aparejado una necesidad mayor de memoria RAM para el proceso ya que debe ser capaz de contener la totalidad de los datos temporales que antes se contenían en disco, creciendo dicha necesidad proporcionalmente con el tamaño del problema calculado. Por ello inferimos que es posible que ante un tamaño suficientemente grande del problema, el calculo del mismo no sea viable en ciertos equipos. Se amplía sobre este tema en el capítulo 5.

Debido a lo indicado en el párrafo anterior es que en el trabajo de optimización se decidió no pasar la totalidad de los archivos externos a archivos internos y no diferir su escritura al final de la ejecución del programa, sino que se seleccionaron los mas críticos a efectos del cálculo, aquellos que eran escritos y leídos durante la ejecución del programa, y manteniendo como archivos externos todo aquel que solo era escrito o leído, no ambas.
Podemos observar en la tabla 3.3.2.yy cuales son los archivos que se decidió manejar mediante un archivo interno y el motivo de dicha decisión:

Tabla 3.3.2.yy con los archivos modificados con archivos internos.
Tendra archivo externo – archivo interno – tipo de cambio/observaciones: ej, solo utilizado en memoria, o escritura diferida

Una vez realizados los cambios indicados, verificamos que los resultados siguieran siendo correctos. Luego de verificado esto continuamos a la siguiente etapa de optimización.


## 3.4 Optimización Paralela para Multiprocesamiento

Con el primer paso de optimización realizado es posible llevar a cabo la optimización paralela del código con el modelo seleccionado, como se explicó en el capítulo 2, OpenMP.
Como vimos en la sección 3.2.1, de acuerdo al resultado de la herramienta gprof, el código candidato para ser optimizado en ese primer momento era principalmente la subrutina “estela”, seguida de “solgauss”.
Si compilamos nuestro programa nuevamente con el profiler de GNU (gprof), pero con la optimización de los archivos internos, obtenemos que la subrutina “estela” sigue siendo la mas pesada, seguida de solgauss, incluso por porcentajes casí similares a los obtenidos en el programa original. Podemos ver esto en la imagen 3.4.x, 

    Imagen 3.4.x (pruebas/newone/estela_intfiles)

### 3.4.1 Análisis de la subrutina Estela

En su definición la subrutina “estela” indica que realizá “Calculo de los coeficientes de influencia de los hilos libres”. Los calculos realizados dentro de la subrutina son numerosos y complejos, por lo cual utilizaremos un pseudocódigo para poder observar los puntos mas importantes dentro de la subrutina que pueden ser candidatos de ser paralelizados. En la imagen 3.4.xx podemos observar la subrutina estela.

    Imagen 3.4.1.xx

    subrutina estela()
    definicion variables globales y constantes;

    begin
	Do de i=1 a 2500
	Do de j=1 a 51
		ciex(i,j) = 0
		ciey(i,j) = 0
		ciez(i,j) = 0
	end do
	end do
	calculos parciales
	ib = 1

    Do de ir=1 a 2500
    Do de npa=1 a 51
	Do de ik=1 a 2001
		genera fx(ik), fy(ik), fz(ik), dista(ik), denom(ik)
	end do

    ## sumatoria terminos impares six, siy, siz
	six,siy,siz = 0
	Do de ik=2 a 2000
		six = six + fx(ik)/denom(ik)
		siy = siy + fy(ik)/denom(ik)
		siz = siz + fz(ik)/denom(ik)
		ik = ik +2
	end do
    ## sumatoria terminos pares spx, spy, spz
	spx,spy,spz = 0
	Do de ik=3 a 2000
		spx = spx + fx(ik)/denom(ik)
		spy = spy + fy(ik)/denom(ik)
		spz = spz + fz(ik)/denom(ik)
		ik = ik +2
	end do
	calculo ciex(ir,npa), ciey(ir,npa), ciez(ir,npa)
	if (indice = 1) and (ib = 1) then  ## se ejecuta solo 1 vez
	## calculo coeficientes de la estela x, y, z
		if (i = nr) and (j = nr/2) then  
		## calculo para i=50 y j=25 (nr depende del tamaño del problema,
		## en este caso el tamaño es 50)
			inicializa valx,valy,valz
			Do de ik=1 a 2001
				escribe archivo integ1.txt con varios valores incluyendo valx,valy,valz
				if (ik =/= 2001) then
					const=1
					if (ik == 2000) then
						const=0.5
					endif
					valx = valx + fx(ik+1)/denom(ik+1)*otros valores
					valy = valy + fy(ik+1)/denom(ik+1)*otros valores
					valz = valz + fz(ik+1)/denom(ik+1)*otros valores
				else 
					escribe integ1.txt con varios valores sin valx,valy,valz pero con ciex,ciey,ciez(i,j)
				endif
		else
			if (i = nr/2) and (j = nr+1) then 
			## Luego (si no entró en el anterior if) el calculo es para i = 25 y j=51
				Repite mismo trabajo pero escribiendo integ2.txt
			endif
		endif
	endif
    end do
    end do
    end

Analizando el pseudocódigo podemos observar que la subrutina tiene partes bien diferenciadas. Un inicio con seteo de valores iniciales y calculos parciales, y luego vemos un bloque conformado por dos bucles principales; dentro de ellos es donde se encuentran las estructuras que pueden ser paralelizadas.
Inicia con un bucle que calcula los datos en fx, fy, fz, denom y dista; luego calcula terminos pares e impares; finaliza con el denominado calculo de coeficientes de la estela x,y,z. 

El calculo de coeficientes parece ser el mas complejo de los puntos indicados, pero si observamos bien solo se ejecuta una vez en todo el programa, cuando “indice” es igual a uno (la variable “ib” siempre tiene valor uno, por lo cual no la contamos). Dicha variable “indice” es global al programa y controla las etapas por las que pasa, toma valores de uno a diez y no repite los valores.
Por otra parte, el calculo de coeficientes se hace sobre los valores valx, valy y valz, realizando sobre ellos una sumatoria, con lo cual se crea una dependencia de datos entre el calculo de un valor y los cálculos previos (capítulo 2 – openmp), ya que para obtener el valor de valx en un momento, debo tener el valor previo de valx. Si realizamos una paralelización del código tendríamos un problema en los limites de los distintos threads, por ejemplo al dividirlos en porciones de 100 elementos el thread calculando los valores 101 a 200 de un bucle necesita conocer el valor de la sumatoria en el valor 100 para poder iniciar con valores correctos su calculo, y dicho valor 100 puede no existir aún en el momento que lo necesita (porque el thread encargado de su calculo puede no haber finalizado o siquiera iniciado).

Si observamos bien el calculo de los terminos pares e impares, se presenta el mismo problema de dependencias de datos que aparece en el calculo de coeficientes. Cuando calculamos por ejemplo six, necesitamos conocer el valor previo de six en ese momento.

Existen técnicas y formas de transformar el código que permiten en algunos casos poder reprogramar una porción de código para que pueda ser paralelizable a pesar de tener estas dependencias de datos. Debido al potencial gran cambio necesario en el código para subsanar el problema de la dependencia de datos y a el requisito de no modificar el código de maneras que pueda tornarse ilegible para el usuario es que no se avanzó sobre estas áreas de la subrutina. La solución a este problema puede ser motivo de un trabajo futuro que se pondrá a consideración en el capitulo 5.

Luego de descartar estos puntos como las zonas a paralelizar en la subrutina “estela” nos quedamos con el bucle de la figura 3.4.1.xx que genera los arrays fx, fy, fz, denom y dista, ya que cada valor generado de estos arrays no depende de otros previos dentro de los arrays.

### 3.4.2 Optimización con OpenMP de subrutina Estela

Seleccionado el bucle a paralelizar hicimos un análisis de los datos que intervienen para poder realizar una optimización correcta. Realizamos varias pruebas para definir las directivas OpenMP correctas, quedando definido un conjunto de datos que debe ser compartido por cada thread lanzado por OpenMP y ciertas variables que deben ser privadas de cada uno de ellos.

El bloque de código seleccionado para optimizar es el siguiente (ha sido abreviado):

    1        do 3 ik=1,kult
    2        fx(ik)=[calculo con valores de varias matrices]
    3        fy(ik)=[calculo con valores de varias matrices]
    4        fz(ik)=[calculo con valores de varias matrices]
    5        fz(ik)=(-1.)*fz(ik)
    6        dist2=[calculo con valores de varias matrices]
    7        dista(ik)=dsqrt(dist2)                                  
    8        denom(ik)=dista(ik)**3                   
    9     3 continue

Este bucle es el primer bucle interno de dos iteraciones mayores que incluyen mas cálculos con otras estructuras, las cuales dependen de los resultados obtenidos en este primer bucle.
Se calculan tres arrays llamados fx, fy y fz, un valor dist2, y dos arrays mas basados en el valor de dist2, llamados dista y denom.
Los cálculos de los tres primeros arrays y del valor dist2 dependen de varios otros arrays ya calculados previamente y que la subrutina obtiene por el área de datos común con el resto de partes del programa Fortran, además de utilizar funciones propias del lenguaje.
En un primer análisis del bloque de código observamos una posible dependencia de datos en las lineas (5) y (8) de la fig. 3.4.2.xx. En la primera el calculo de fz(ik) depende de si mismo y en la segunda el valor de denom(ik) depende del valor de dista(ik) que depende de dist2. Si bien es posible que no surgieran problemas con estos valores, para evitar resultados inesperados, decidimos analizar y modificar si fuera necesario para evitar la dependencia, siempre que el cambio no fuera significativo, como reescribir la estructura de control completa o varias lineas con nuevas instrucciones.
La dependencia de datos en la linea (5) fue posible solucionarla rápida y elegantemente. La linea lo que hace es al valor en fz(ik) multiplicarlo por -1, por lo cual es posible este cálculo agregarlo al final de la linea (4) quedando la linea de la siguiente manera:

        fz(ik)=([calculo con valores de varias matrices])*(-1.)

En el caso de la linea (8) el análisis es distinto, la dependencia se encuentra en el valor de dista(ik) el cual es calculado en el paso previo y depende del cálculo del valor dist2, además es un calculo simple con una función interna del lenguaje Fortran. Se podría utilizar un calculo intermedio y luego asignar el resultado a dista(ik) y denom(ik), por ej:

    var_aux = dsqrt(dist2)
    dista(ik) = var_aux
    denom(ik) = var_aux**3

Pero enfrentamos la indeterminación del valor inicial de var_aux y como afecta a cada bloque paralelo cuando realicemos la optimización con OpenMP. Se puede resolver llevando un control de la variable en el bloque declarativo de OpenMP e inicializando la variable cada vez que es utilizada, lo que agrega carga de control al bloque de código (tanto en OpenMP como en el código Fortran normal). Si el cálculo a realizar con dist2 fuera de mayor complejidad podría justificarse la utilización de una variable auxiliar intermedia, pero como es un calculo sencillo que utiliza una función interna de Fortran a la cual se le envía un solo valor, se puede resolver de la siguiente manera:

    dista(ik) = dsqrt(dist2)
    denom(ik) = (dsqrt(dist2))**3

Se puede entender mejor la dependencia de datos y la necesidad de controlar ciertas variables en los bloques paralelizados al observar un problema importante que surgió durante el trabajo de tesis, el cual incluso no estaba a simple vista. 
Al realizar la optimización paralela los resultados del programa eran distintos a los de la ejecución normal. Los resultados deben ser iguales, el programa es totalmente determinístico, por lo cual se buscaron muchas formas diferentes con directivas de OpenMP de controlar la ejecución de los threads en este bloque seleccionado para optimización, para que los datos no se contaminaran, pero siempre arribando al mismo resultado erróneo. 
El problema se encontró en otra porción de código que parecía bastante simple de paralelizar y sin necesidad de control alguno. Al iniciar, la subrutina estela utiliza dos estructuras DO anidadas que inicializan con valor 0 tres arrays (ciex, ciey y ciez), por lo cual con una estructura OMP PARALLEL DO de OpenMP debería bastar para paralelizar el calculo y obtener una ganancia en performance, mínima pero una ganancia al fin.
El problema surge porque la inicialización a 0 se realiza a través de una variable llamada “cero” definida en otra parte del código con el valor 0. Al lanzarse los threads de OpenMP dicha variable pasó a tener un valor indeterminado para cada thread, trayendo consigo datos espurios a los cálculos siguientes donde los arrays intervienen. Al comentar las directivas OpenMP que encerraban dichos bloques DO los resultados del programa volvieron a ser correctos.
Si bien el comportamiento por defecto de OpenMP debería ser compartir entre todos los threads las variables en memoria del programa principal, no ocurre en este caso con la variable “cero”. Investigar estas particularidades, como una implementación del estándar OpenMP difiere de otras y que problemas trae, puede ser motivo de una extensión futura de este trabajo de tesis.

Con las modificaciones indicadas el bucle ya estaba en condiciones de ser paralelizado con OpenMP.
Lo primero que realizamos, como vimos en el capitulo 2, es indicar el comienzo de la región paralela y su final:

    !$OMP PARALLEL
    [bucle paralelizado]
    !$OMP END PARALLEL

Ahora debíamos agregar las directivas para indicar que la región paralela debía ser una estructura DO, por lo que agregamos las directivas DO de OpenMP:

    !$OMP PARALLEL
    !$OMP DO

    [bucle paralelizado]

    !$OMP END DO
    !$OMP END PARALLEL

Al realizar estos cambios en el código para el bloque indicado, conseguimos una gran mejoría en el tiempo empleado, pero los resultados aún no eran correctos. Teniendo en cuenta esto debemos realizar un análisis de que variables son compartidas por los distintos threads del proceso y cual es su alcance para evitar discrepancias en los resultados, ya que como indicamos el programa debía ser totalmente determinístico.

En el bloque de código observamos que para realizar el calculo de los arrays son necesarios varios otros arrays y variables los que ya poseen valores previos. Podemos ver en la figura 3.4.2.yy cuales son:

    arrays:
    pcx, pcy, pcz, xe, ye, ze, re, fi
    Variable:
    c0

Además utiliza las variables de control ir y npa de los bloques DO exteriores donde está anidado nuestro bloque de código, utilizadas para recorrer los arrays indicados en la figura 3.4.1.yy.

El primer interrogante era saber si los datos se deben compartir entre todos los threads o deben ser privados. Si observamos todos los arrays y variables externos que se utilizan para el cálculo, los threads deben compartir su valor, si los definiéramos como PRIVATE su valor sería indefinido para cada thread, y si fuera como FIRSTPRIVATE por mas que los valores fueran correctos, la cantidad de recursos necesarios para la ejecución se multiplicaría por la cantidad de threads que estuvieran en ejecución ya que cada uno tendría una copia de cada variable. 

Luego, los arrays modificados dentro del bloque son escritos por cada thread, pero cada thread accede a las posiciones definidas por la variable de control del bloque DO que estamos paralelizando, ik, la cual tendrá un valor para cada thread específico; por ejemplo si dividimos un DO de 100 iteraciones en 2 threads, la variable de control ik tendrá valor inicial de 0 para un thread y 50 para el otro.
Esto nos lleva a que los arrays modificados dentro del bloque también puedan ser compartidos por todos los threads, ya que solo son accedidos indexados por la variable ik la cual como indicamos será distinta para cada thread, con lo cual cada uno accederá a modificar posiciones de los arrays distintas.
Por todo esto, concluimos que la gran mayoría de arrays y variables son compartidas por todos los threads, y la dependencia de datos entre estos es inexistente (los arrays escritos no son leidos, los arrays y variables leídas no son modificadas), con lo cual definimos en la instrucción OpenMP de inicio del bloque paralelo como DEFAULT(SHARED) para todas las variables utilizadas dentro (si bien es el comportamiento por defecto que el estándar OpenMP toma, lo dejamos declarado explícitamente, no solo por legibilidad, sino para evitar que una implementación extraña de OpenMP de un compilador genere resultados incorrectos, por ejemplo con la variable “cero” que vimos en el problema explicado previamente en esta misma sección).

    !$OMP PARALLEL DEFAULT(SHARED)
    !$OMP DO

    [bucle paralelizado]

    !$OMP END DO
    !$OMP END PARALLEL

Con esta definición tenemos que todas las variables (arrays y variables comunes) serán compartidas por todos los threads. 
Analizando mas fino, vemos que hay variables que necesitan definirse privadas de cada thread, principalmente la variable dist2 que es calculada dentro de cada thread en cada una de las iteraciones. Si fuera una variable compartida todos los threads escribirían en ella en cualquier orden llevando a resultados erróneos. Solo para ejemplificar supongamos que el thread 1 calcula la variable dist2 en una iteración, luego escribe el valor de dista(ik) con dist2, en ese momento el thread 4 calcula y escribe dist2, cuando el thread 1 va a escribir el valor de denom(ik), dist2 ya tiene un valor completamente distinto al que había calculado el thread 1 previamente. Por esto declaramos a dist2 como PRIVATE.
Para evitar un problema similar al de la variable “cero” decidimos declarar las variables de control ir y npa, y la variable ncapa como FIRSTPRIVATE, de manera que sean privadas de cada thread y tengan desde el principio su valor original.
El código queda como vemos en la figura 3.4.2.zz

    !$OMP PARALLEL DEFAULT(SHARED)
    !$OMP DO FIRSTPRIVATE(ir,npa,ncapa) PRIVATE(dist2)

    [bucle paralelizado]

    !$OMP END DO
    !$OMP END PARALLEL

Luego de estos cambios, la ejecución del nuevo código dio resultados correctos comparados con la ejecución original. De esta manera paralelizamos parte del bloque de código que más tiempo consumía de toda la aplicación. En el capitulo 4 podremos ver la comparativa de tiempos de cada uno de los códigos.

