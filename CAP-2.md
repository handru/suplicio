# Capitulo 2
* Computación Paralela
      * Definición
        * Computación secuencial vs. paralela
      * Campos de aplicación de la computación paralela
        * Robar de la descripcion del proyecto que estaba originalmente en cap 1
      * Plataformas de Computación Paralela
        * Clasificación de Flynn
        * Memoria compartida y distribuida
        * Cluster, multicore, GPU

* Fortran
      * Con esta seccion no creo que haya problemas
      * Agregaria fortran legacy apps (y definición de legacy apps) al principio. (a gpu approach...)

* OpenMP
      * Tampoco

* OpenMP en Fotran

* Optimización y paralelización de aplicaciones
      * Flujo de trabajo general de la optimización de aplicaciones
      * Tratamiento de Entrada/salida 

* Aplicación XXXX (tiene nombre?)
      * Descripción de la aplicación
      * Uso que hace actualmente el usuario

## Introducción.
En el pasado reciente, la herramienta más común para la solución de problemas de las ciencias computacionales fue la programación en lenguajes adaptados al cómputo científico, como FORTRAN. Cuando los recursos de computación (por ejemplo, con la aparición de la computadora personal) se hicieron accesibles a los investigadores individualmente, y a grupos de investigación de modestos presupuestos, esta herramienta se hizo popular y creó un modo de trabajo estándar de facto, ampliamente extendido, en las ciencias e ingenierías.  

Con frecuencia, las soluciones producidas por este modo de trabajo eran programas grandes, secuenciales y monolíticos. Los problemas abordados por esta clase de programas se caracterizan por grandes demandas de cómputo y de memoria, recursos especialmente escasos desde los comienzos de la computación. Las decisiones de programación no resultaban siempre eficientes, debido a que su autor no siempre era un profesional del área informática, sino el científico que necesitaba la solución. 
La evolución técnica y económica de los sistemas disponibles para los investigadores permitió la incorporación de plataformas paralelas, primero con la posibilidad de distribuir el cómputo entre varios equipos de computación a través de una red, luego con diferentes formas de arquitecturas paralelas de hardware. En estas plataformas, la multiplicidad de los recursos enfrenta al programador con un problema de programación y de administración de recursos aún más complejo.
En este capítulo se presenta el tratamiento de estos problemas mediante la utilización de programación paralela. En la sección 2.1 se explicará en qué consiste la programación paralela, explicando sintéticamente cómo funciona un programa paralelo, cuáles son las plataformas  más utilizadas de computación paralela y sus modelos de comunicación (memoria compartida, pasaje de mensajes). En la sección 2.2 se presentará brevemente el lenguaje de programación Fortran y se explicará su uso a nivel científico. En las secciones 2.3 y 2.4 se presentan la interfaz de programación de aplicaciones OpenMP y su implementación en Fortran respectivamente. En la sección 2.5 se mostrará en qué consiste el proceso de optimización para paralelizar una aplicación y por último en la sección 2.6 se presentará la aplicación cientifica núcleo de esta Tesis y se describirá muy brevemente el problema que resuelve.


## 2.1 Visión general del procesamiento paralelo

Lograr completar un trabajo mucho mas rápido al desempeñar múltiples tareas simultáneamente es la fuerza impulsora detrás del procesamiento paralelo.
Hace ya varios años, Michael Flynn propuso un modelo sencillo y común de categorizar todas las computadoras que continua siendo útil y aplicable. Las categorías son determinadas por el flujo de instrucciones y el flujo de datos que la computadora puede procesar en cualquier instante dado. Todas las computadoras pueden ser ubicadas en una de las siguientes cuatro categorías:

*Single Instruction, Single Data (SISD) – En español “una instrucción, un dato”. Esta es la computadora mas común en el mercado hoy en día, un sistema mono procesador con un flujo de instrucciones y un flujo de datos. Gran parte de las PCs caen en esta categoría.
*Multiple Instruction, Single Data (MISD) – “Múltiples instrucciones, un dato”. El mismo conjunto de datos es tratado por múltiples procesadores. No hay un sistema de este tipo que haya sido construido para venta al público o en otro ámbito.
*Single Instruction, Multiple Data (SIMD) – “Una instrucción, múltiples datos”. Varios flujos de datos son procesados por varios procesadores, donde cada uno de ellos ejecuta el mismo flujo de instrucciones. Maquinas de este tipo tienen un solo procesador que ejecuta el flujo único de instrucciones y despacha subconjuntos de esas instrucciones a todos los demás procesadores (que generalmente son de diseño mucho mas simple). Cada uno de estos procesadores “esclavos” ejecutan su propio flujo de datos. Este tipo de computadoras (SIMD) no son muy flexibles. Son buenas para aplicaciones que desempeñan las mismas operaciones en una gran cantidad de datos, como el álgebra lineal, pero no se desempeñan bien con flujos de instrucciones que tienen varias cantidades de ramificaciones (una descripción que se ajusta a la mayoría de las aplicaciones modernas).
*Multiple Instruction, Multiple Data (MIMD) – “Múltiples instrucciones, múltiples datos”. Esto aplica a máquinas que poseen múltiples procesadores los cuales son capaces de ejecutar flujos de instrucciones independientes usando flujos de datos propios y separados. Tales maquinas son mucho mas flexibles que los sistemas SIMD y en la actualidad hay cientos de diferentes maquinas MIMD disponibles.


### Modelos Paralelos

Desde la perspectiva del sistema operativo, hay dos medios importantes de conseguir procesamiento paralelo: múltiples procesos y múltiples hilos.

Cuando uno ejecuta un programa en una computadora, el sistema operativo crea una entidad llamada “proceso” la cual tiene un conjunto de recursos asociados. Estos recursos incluyen, pero no están limitados a, estructuras de datos con información del proceso, un espacio de direcciones virtuales el cual contiene las instrucciones del programa y datos, y al menos un hilo. 
¿Qué es un hilo? Un hilo es un flujo de control independiente dentro del proceso, compuesto de un contexto (el cual incluye un conjunto de registros) y una secuencia de instrucciones para ejecutar. Por flujo de control independiente, nos referimos a un camino de ejecución a través del programa.

Actualmente hay distintos niveles de paralelismo en los sistemas de computación. Por ejemplo los procesadores VLIW y los RISC superescalares, alcanzan paralelismo en el nivel de instrucción (ejecutar varías instrucciones de bajo nivel al mismo tiempo). Para este trabajo de tesis utilizamos el termino procesamiento paralelo para indicar que mas de un hilo de ejecución se está ejecutando en un único programa. Lo cual también permite que mas de un proceso pueda cumplir con procesamiento paralelo. Dicho esto podemos categorizar el procesamiento paralelo en tres categorías:

* Paralelismo de procesos: usar mas de un proceso para desempeñar un conjunto de tareas.
* Paralelismo de hilos: usar múltiples hilos dentro de un único proceso para ejecutar un conjunto de tareas.
* Paralelismo hibrido: usar múltiples procesos, donde al menos uno de ellos es un proceso paralelo con hilos, para desempeñar un conjunto de tareas.

¿Qué razones hay para utilizar paralelización con hilos si con múltiples procesos se puede conseguir paralelismo? Al menos existen dos razones potenciales: conservación de recursos del sistema y ejecución mas rápida.
Los hilos comparten acceso a los datos del proceso, archivos abiertos y otros atributos del proceso. Compartir datos e instrucciones puede disminuir dramáticamente los requerimientos de recursos para un trabajo en particular. En contraste, una colección de procesos a menudo deberá duplicar las áreas de datos e instrucciones en memoria para un trabajo.

#### Conceptos básicos de hilos

Un hilo es mas simple de administrar ya que no incluye todos los atributos de un proceso. Pueden ser creados y destruidos mucho más rápido que un proceso. Los hilos tienen otros atributos importantes, relacionados al desempeño.
Un hilo ocioso es uno que no tiene procesamiento para hacer y está esperando por su próximo conjunto de tareas. Por lo general el hilo es puesto en estado de espera (wait) al chequear una variable especial, que usualmente puede tener dos valores, bloqueado o desbloqueado, es decir que debe esperar o puede continuar procesando, respectivamente.
Los hilos ociosos pueden ser suspendidos o dejar en un giro de espera. Los hilos suspendidos liberan el procesador donde se estaban ejecutando. Los que están en giro de espera van a chequear repetidamente la variable para ver si ya están desbloqueados, sin liberar el procesador para otros procesos. Como resultado de esto el rendimiento del sistema puede degradarse drásticamente. Sin embargo, reiniciar un hilo suspendido puede llevar cientos, si no miles, de cliclos de procesador.
Otro atributo de los hilos es la afinidad. Esto es la práctica de al reiniciar un hilo mantenerlo en ejecución en el procesador donde se estaba ejecutando previamente, por la mayor cantidad de tiempo posible. Esto habilita al hilo a beneficiarse de los datos que habían sido puestos en cache durante su ejecución previa, si no debería cargar todos los datos necesarios para su ejecución desde la memoria a la cache del nuevo procesador.

#### Hilos POSIX

Recién en 1995 se establece un estándar para la programación de hilos, a pesar de que hacía décadas los fabricantes de computadoras venían implementando hilos en sus sistemas operativos. Es parte del estándar POSIX (Portable Operating System Interface), en particular la porción POSIX 1003.1c. Incluye las funciones y las Interfaces de Programación de Aplicación (APIs) que soportan múltiples flujos de control dentro de un proceso. Hilos creados y manipulados vía este estándar son generalmente indicados como pthreads. Previo al establecimiento de este estándar, las APIs de hilos eran especificas del fabricante del hardware, lo que hacía muy dificil la portabilidad de aplicaciones paralelas con hilos. Combinado con la complejidad de reescribir aplicaciones para utilizar y beneficiarse de control de hilos explicito, resultaba en muy pocas aplicaciones paralelas con hilos.

#### Directivas del compilador y OpenMP

El uso de directivas del compilador para conseguir paralelismo es un intento para aliviar la complejidad y problemas de portabilidad. En el paralelismo orientado a directivas se ponen la mayoría de las mecánicas paralelas a trabajar dentro del compilador (generar hilos, generar construcciones de sincronización, etc.). Es decir, el compilador traduce la directiva al compilador en las llamadas al sistema necesarias para la administración de los hilos y realizar cualquier reestructuración del código necesaria. Estas directivas proveen un medio simple para conseguir paralelismo.
Una  cosa que ha fomentado el uso de directivas es el estándar OpenMP para directivas de compilador paralelas. Antes de la aparición de este estándar, las directivas de compilador eran específicas del fabricante de hardware lo que dificultaba la portabilidad. 
Tanto la implementación de hilos paralelos explicita (por ej. pthreads) y paralelismo basado en directivas (por ej. OpenMP) se benefician de lo que nos referimos como “memoria compartida”.

#### Paralelismo de memoria compartida – El modelo fork/exec
Como resultado, el paralelismo de hilos depende de la existencia de la memoria compartida para la comunicación. Otro modelo paralelo mas antiguo, también utiliza memoria compartida, pero entre procesos. Generalmente se lo denomina paralelismo de procesos y típicamente alcanzado a través del uso de las llamadas al sistema fork() y exec()  (o sus análogas). Por ello se lo llama generalmente como el modelo fork/exec. La memoria es compartida entre los procesos en virtud de las llamadas al sistema mmap() (derivada de Berkeley UNIX) o shmget() (de System V UNIX).

#### Pasaje de Mensajes
El modelo fork/exec no implica la existencia de memoria compartida. Los procesos pueden comunicarse a través de interfaces de E/S tales como las llamadas al sistema read() y write(). Esto puede darse a través de un archivo normal o vía sockets.
La comunicación vía un archivo es conseguida fácilmente entre procesos que comparten un sistema de archivos. Y puede extenderse a varios sistemas utilizando un sistema de archivos compartido como NFS.
Los sockets son usualmente un medio de comunicación mas eficiente entre procesos ya que remueven mucho del costo inherente al realizar operaciones sobre un sistema de archivos.
Estas dos variaciones comunes dependen del proceso enviando el dato a ser comunicado a un archivo o socket. Este dato puede ser descrito como un mensaje, esto es, el proceso emisor está pasando un mensaje al proceso receptor. De ahí el nombre para este modelo.
Han existido diferentes implementaciones de librerías de pasaje de mensajes, como PAR-MACS (para macros paralelas) y PVM (Parallel Virtual Machine). Luego en 1994 surge MPI en un intento de brindar una API estándar de pasaje de mensajes, la cual pronto eclipsó a PVM y fue adoptando algunas de las ventajas de esta. Aún cuando fue pensada principalmente para maquinas de memoria distribuida, tiene la ventaja de que puede ser usada aplicaciones en maquinas de memoria compartida también. MPI está destinado a paralelismo de procesos, no paralelismo de hilos.

### Infraestructuras de Hardware para Paralelismo
Históricamente, las arquitecturas de computadoras paralelas han sido muy diversas. Existen aún diversas arquitecturas básicas disponibles comercialmente hoy en día. En las siguientes secciones se dará un panorama general de las arquitecturas paralelas.

#### Clusters
Un cluster es una colección interconectada de equipos independientes que son utilizadas como un solo recurso de computación. Un ejemplo común, pero extremo, de cluster es simplemente un grupo de diversas estaciones de trabajo ubicadas en un cuarto e interconectadas por Ethernet.
Definimos vagamente un nodo de computación como una colección de procesadores que comparten la latencia de memoria mas baja. Por su propia definición, un nodo de un cluster es un único equipo independiente. Una de las ventajas de un cluster es que cada nodo está bien balanceado en terminos de procesador, sistema de memoria y capacidades de E/S (porque cada nodo es una computadora). Otra ventaja es el costo; usualmente consiste de estaciones de trabajos individuales obtenidas directamente en una tienda. La tecnología de interconexión puede ser obtenida de la misma manera en la forma de Ethernet, FDDI, etc. Los clusters también son muy escalables ya que se puede seguir agregando nodos al sistema paralelo simplemente agregando otra estación de trabajo.
La capacidad y el desempeño de las interconexiones son dos desventajas de los clusters. Acceder a datos que residen en el mismo nodo donde está ejecutándose la aplicación será rápido (tanto como la estación de trabajo). Datos que existen en otros nodos es otro asunto. Ya que el otro nodo es una computadora completa, el dato deberá ser transferido vía una llamada al sistema de E/S como se indicaba en pasaje de mensajes. Esto significa que el dato deberá viajar a través del cable (y el protocolo) desde el nodo remoto al nodo donde es necesario. Esto puede ser muy lento.
Notemos que está el tema del espacio de direcciones para una aplicación. Los clusters tienen multiples, independientes espacios de direcciones para cada nodo.
La administración del sistema presenta otro problema. Sin software especial para esta tarea, es muy difícil administrar el sistema. El software debe instalarse en cada nodo individual lo cual puede ser un proceso muy lento y costoso (por ej. si se necesita una licencia por cada nodo).
Otro asunto es la falta de una imagen del sistema única. Nos referimos a la capacidad de que el cluster deba verse como un sistema solo y no como un conjunto de computadoras. Un usuario que ingresa en el sistema puede hacerlo siempre desde la misma estación de trabajo, con lo cual no verá diferencias, pero si lo realiza desde distintas estaciones puede ver un ambiente muy distinto al cambiar de equipo. Por lo general se busca mantener los archivos utilizados por el usuario disponibles cada vez que ingrese sin importar el equipo en el que esté, lo que trae mayor complejidad al cluster.

#### Multiprocesadores Simétricos (SMPs)
La mayoría de los fabricantes de hardware están tomando otra alternativa para evitar los problemas de los clusters. Se presenta la computadora multiprocesador en la cual todos los procesadores acceden a todos los recursos de la maquina. Cuando los procesadores son todos iguales y cada uno tiene acceso igualitario a los recursos de la computadora, i.e. es simétrico, el sistema se llama Multiprocesador Simetrico (SMP por las siglas en ingles).
Un equipo SMP debe ser capaz de que todos sus procesadores se ejecuten en modo kernel. El modo kernel es cuando un programa ejecuta alguna instrucción especial o procedimiento (i.e. una llamada al sistema) que requiere que el sistema operativo tome control sobre el hilo de ejecución del programa por un periodo de tiempo. Si solo una CPU a la vez puede ejecutarse en modo kernel, tenemos un cuello de botella que transformará nuestra computadora multiprocesador en un sistema de un solo procesador.
Al proveer un solo espacio de direcciones para las aplicaciones, un sistema SMP puede hacer el desarrollo de aplicaciones mas fácil que en un sistema con múltiples e independientes espacios de direcciones como un cluster.
Un sistema SMP tendrá múltiples procesadores pero en realidad no tiene múltiples sistemas de E/S o de memoria. Ya que en los SMP se tiene acceso igual o uniforme a la memoria se dice que son maquinas de Acceso de Memoria Uniforme (UMA – Uniform Memory Access). UMA implica que todos los procesadores pueden acceder a la memoria con la misma latencia.

#### Buses y Crossbars
Un bus puede ser visto como un conjunto de cables que es utilizado para conectar varios periféricos de la computadora. La comunicación entre los recursos es comúnmente hecha con un bus. Generalmente hay dos grupos: Buses de E/S y de memoria. Los de E/S típicamente son largos, pueden tener diferentes tipos de dispositivos conectados y normalmente acatan un estándar. Por el otro lado, los buses de memoria son cortos, de alta velocidad y usualmente personalizados para el sistema de memoria así maximiza el desempeño entre el procesador y la memoria. Los buses son muy versátiles y rentables.
Otro método común de interconectar dispositivos es a través de crossbars. Un crossbar es como múltiples buses independientes que conectan cada uno de los módulos en el multiprocesador. El hardware es mucho más complicado de lo que parece. Esto es debido a que debe permitir tantas comunicaciones independientes como sea posible mientras arbitra los pedidos múltiples de acceso al mismo recurso, como un banco de memoria. Todos los posibles caminos no conflictivos pueden ser permitidos simultáneamente, pero esto supone más hardware.


## Computo de Altas Prestaciones
Luego de ver que es, las categorias y distintos modelos de la computación paralela, podemos definir lo que podríamos llamar una consecuencia de la evolución y el desarrollo de esta misma, el computo de altas prestaciones.
Un gran problema transversal a las Ciencias e Ingenierías Computacionales es la aplicación eficiente de modernas herramientas de cómputo paralelo y distribuido. La respuesta a este problema está condensada en el concepto de Computación de Altas Prestaciones (High Performance Computing, o HPC) que abarca todos aquellos principios, métodos y técnicas que permiten abordar problemas con estructuras de cómputo complejas y de altos requerimientos.
El objetivo del proyecto HPC en la FaI es adquirir conocimientos para el diseño, desarrollo, gestión y mejora de las tecnologías de hardware y software involucradas en la Computación de Altas Prestaciones (CAP) y sus aplicaciones en Ciencias e Ingeniería Computacional.

Tradicionalmente, el ámbito donde surgían los productos de la ciencia y de la ingeniería eran los laboratorios. Combinando la teoría y la experimentación, con cálculos hechos a mano o apoyándose en herramientas de cálculo rudimentarias, se aplicaba el conocimiento de la física, la matemática, la biología, para obtener y validar nuevos conocimientos. La aparición de las computadoras ofreció una nueva y potente forma de hacer ciencia e ingeniería: la ejecución de programas que utilizan modelos matemáticos y soluciones numéricas para resolver los problemas.

Así surgen herramientas como la simulación numérica, proceso de modelar matemáticamente un fenómeno de la realidad, y ejecutar experimentos virtuales a partir del modelo implementado en computador. En cada disciplina podemos encontrar experimentos que, por ser de alto costo, complejos, peligrosos o simplemente impracticables, hacen de la simulación numérica una herramienta de enorme valor. De la misma manera, las computadoras permiten la obtención de resultados concretos para problemas de cálculo imposibles de abordar en forma manual.

Hubo un tiempo cuando un analista numérico podía escribir código para implementar un algoritmo. El código era miope ya que era escrito solamente con la idea de implementar el algoritmo. Existía cierta consideración en la performance, pero generalmente era mas una idea de ahorrar la memoria de la computadora. La memoria era el comodity mas preciado en los albores de la computación. “Tunear” el código para la arquitectura subyacente no era una consideración de primer orden.
A medida que las arquitecturas de computadoras evolucionaron, la tarea de codificación tuvo que ser ampliada para abarcar la explotación de la arquitectura. Esto fue necesario con el fin de obtener el rendimiento que se exige de códigos de aplicación.

Los centros de computadoras de cada día mejoran los sistemas con mas procesadores y mas rápidos, mas memoria, y subsistemas de E/S mejorados, solo para descubrir que el rendimiento de la aplicación mejora un poco, si es que lo hace. Luego de algo de análisis por los vendedores de sistemas o software, encontraron que sus aplicaciones simplemente no estaban diseñadas para explotar las mejoras en la arquitectura de la computadora. A pesar de los desarrolladores haber leído textos sobre computación de alto desempeño y haber aprendido el significado de las palabras de moda, acrónimos, benchmarks y conceptos abstractos, nunca se les dieron los detalles sobre como diseñar o modificar realmente software que pueda beneficiarse de las mejoras en la arquitectura de la computadora.


### Ciencia e Ingeniería Computacional
La situación descripta en  los parrafos anteriores ha dado auge a un nuevo campo interdisciplinario denominado Ciencia e Ingeniería Computacional (Computational Science & Engineering, CSE), que es la intersección de tres dominios: matemática, ciencias de la computación, y las diferentes ramas de las ciencias o ingenierías. La Ciencia e Ingeniería Computacional usa herramientas de las ciencias de la computación y las matemáticas para estudiar problemas de las ciencias físicas, sociales, de la Tierra, de la vida, de las diferentes disciplinas ingenieriles, etc.

Durante la presente década, la Ciencia e Ingeniería Computacional ha visto un desarrollo espectacular. Puede decirse que las tecnologías de cómputo y de comunicaciones han modificado el campo científico de una manera que no admite el retroceso, sino que, al contrario, la superación y extensión de esas tecnologías resulta vital para poder seguir haciendo ciencias como las conocemos hoy.

Gracias a estos avances tecnológicos los científicos pueden trascender sus anteriores alcances, extender sus resultados y abordar nuevos problemas, antes intratables. Entre los métodos de la Ciencia e Ingeniería Computacional se incluyen:

* Simulaciones numéricas, con diferentes objetivos:
      * Reconstrucción y comprensión los eventos naturales conocidos: terremotos, incendios forestales, maremotos, etc.
      * Predicción del futuro o de situaciones inobservables: predicción del tiempo, comportamiento de partículas subatómicas.

* Ajustes de modelos y análisis de datos
      * Sintonización de modelos o resolución de ecuaciones para reflejar observaciones, sujetas a las limitaciones del modelo: prospección geofísica, lingüística computacional.
      * Modelado de redes, en particular aquellas que conectan individuos, organizaciones, o sitios web.
      * Procesamiento de imágenes, inferencia de conceptos y discriminantes: detección de características del terreno, de procesos climatológicos, reconocimiento de patrones gráficos

* Optimización
      * Análisis y mejoramiento de escenarios conocidos, como procesos técnicos y de manufactura.

A estos métodos, cuya aplicación hoy ya es corriente en las ciencias e ingenierías, se suman ciertos problemas, denominados "grandes desafíos", y cuya solución tiene amplio impacto sobre el desarrollo de esas disciplinas. Estos problemas pueden ser tratados por la aplicación de técnicas y recursos de Computación de Altas Prestaciones. Algunos de los campos donde aparecen estos problemas son:

* Dinámica de fluidos computacional, para el diseño de aeronaves, la predicción del tiempo a términos cortos o largos, para la recuperación eficiente de minerales, y muchas otras aplicaciones.
* Cálculos de estructuras electrónicas, para el diseño de nuevos materiales como catalíticos químicos, agentes inmunológicos, o superconductores.
* Cómputos que permitan comprender la naturaleza fundamental de la materia y de los procesos de la vida.
* Procesamiento simbólico, incluyendo reconocimiento del habla, visión por computadora, comprensión del lenguaje natural, razonamiento automatizado y herramientas varias para diseño, manufactura y simulación de sistemas complejos.

La resolución de estos problemas involucra conjuntos masivos de datos, una gran cantidad de variables y complejos procesos de cálculo; por otro lado, es de carácter abierto, en el sentido de que siempre aparecerán escenarios de mayor porte o mayor complejidad para cada problema. Estos métodos y sus técnicas particulares exigen la utilización de recursos de computación hasta hoy excepcionales, como lo han sido las supercomputadoras, los multiprocesadores y la colaboración de una gran cantidad de computadoras a través de las redes, en diferentes niveles de agregación como clusters, multiclusters y grids.


## 2.2 FORTRAN
El lenguaje de programación FORTRAN surge a mediados de la década de 1950, su creador fue John W. Backus junto con un grupo de desarrolladores. Fue desarrollado para aplicaciones científicas y de ingeniería, campos que dominó rápidamente, siendo durante todo este tiempo ampliamente utilizado en áreas de computo intensivo como análisis de elementos finitos, predicción numérica del clima, dinámica de fluidos computacional o física computacional.
Se lo clasifica como un lenguaje de programación de alto nivel (considerado el primero) y de proposito general, imperativo. La programación imperativa describe un programa en términos del estado del programa y sentencias que cambian dicho estado, como descripto por una maquina de Turing.

Ampliamente adoptado por científicos para escribir programas numéricamente intensivos, impulsó a los constructores de compiladores a a generar código mas rápido y eficiente. La inclusión de un tipo de dato complejo (COMPLEX) lo hizo especialmente apto para aplicaciones técnicas como la Ingeniería Eléctrica. 

Esta adopción por  áreas científicas, de cálculo intensivo, donde una vez un programa alcanza un estado de computación correcta (arroja resultados deseados), el cambio del código no es algo que se practique regularmente, lo que, en el caso de Fortran, derivo en la construcción de programas que permanecen vigentes tras 20, 30 y hasta 40 años. Estos son lo que denominamos Legacy Software. No existe una definición única de lo que es Legacy Software, pero podemos citar a) “Es software crítico que no puede ser modificado eficientemente” [N. E. Gold. The meaning of legacy systems. Univ. of Durham, Dept. of Computer Science, 1998.], b) “Cualquier sistema de información que significativamente resiste las modificaciones y la evolución para alcanzar requerimientos de negocio nuevos y constantemente cambiantes.” [M. L. Brodie and M. Stonebraker. Migrating legacy systems. Morgan Kaufmann Publishers, 1995.]. Algunas características de los sistemas legacy son:

* La resistencia al cambio del software.
* La complejidad inherente.
* La tarea crucial desempeñada por el software en la organización.
* El tamaño del sistema, generalmente mediano o grande.

Como indicábamos, en el caso de Fortran es software que ha estado ejecutándose en ambientes de producción por décadas. Durante ese periodo, el software se deteriora gradualmente y puede necesitar cambios de diferente tipo, como: mejoras, correcciones, adaptaciones y prevenciones. Para  todas estas tareas se necesita conocimiento y comprensión del sistema. En la era multi-core y muchos-core, los cambios de software se hacen mas y mas complejos.
Fortran es uno de los lenguajes de programación mas antiguos utilizado por científicos alrededor del mundo, muy popular en la programación científica y la computación de alto desempeño (HPC). Debido a que ha estado tantos años vigente, ha pasado por un proceso particular de estandarización en el cual cada versión previa del estándar cumple con el vigente. Este proceso de estandarización permite que un programa en FORTRAN 77 compile en los compiladores modernos de Fortran 2008. Gracias a estas características es que Fotran está, aún hoy y contrario a la creencia popular, en una posición solida y bien definida. Actualmente hay un gran conjunto de programas Fortran ejecutándose en ambientes productivos de Universidades, Compañias e instituciones de Gobierno. Algunos buenos ejemplos son programas de modelo climático, simulaciones de terremotos, simulaciones magnetohidrodinámicas, etc. La mayoría de estos programas han sido construidos años sino décadas atrás y sus usuarios necesitan que sean modernizados, mejorados y/o actualizados. Esto también implica que estos programas sean capaces de aprovechar las arquitecturas de procesadores modernas y, específicamente del equipamiento para procesamiento numérico.

### Evolución del lenguaje
Fortran ha evolucionado de una release inicial con 32 sentencias para la IBM 704, entre los que estaban el condicional IF y el IF aritmético de 3 vías, el salto GO TO, el bucle DO, comandos para E/S tanto formateada como sin formato (FORMAT, READ, WRITE, PRINT, READ TAPE, READ DRUM, etc), y de control del programa (PAUSE, STOP, CONTINUE), y tipos de datos todos numéricos, hasta llegar al último estandar Fortran, ISO/IEC 1539-1:2010, conocido informalmente como Fortran 2008, donde fueron incorporándose características como tipos de datos CHARACTER, definición de arrays, subrutinas, funciones, recursividad, modularidad, hasta nuevas sentencias que soportan la ejecución de alta performance como DO CONCURRENT, coarrays (un modelo de ejecución paralela). Si se desea ahondar en la definición del estándar Fortran el mismo puede encontrarse en el sitio de NAG (The Numerical Algorithms Group) quienes alojan el home oficial para los estándares de Fortran [referencia al sitio http://www.nag.co.uk/sc22wg5/] [estándares http://www.nag.co.uk/sc22wg5/links.html].

El lenguaje utilizado en el programa de estudio de este trabajo de tesis está basado en el estándar Fortran 77. Se presentan a continuación algunas de las sentencias de Fortran mas utilizadas en la aplicación de estudio de esta tesis como referencia para el capitulo siguiente.

#### Manejo de archivos  
(voy a explicarlo mejor, en parrafos onda subsecciones, por ahora lo dejo así)

* open(lista de especificadores): En nuestro caso nos interesan los siguientes especificadores
     * [unit=]u
         * “unit=” es opcional
         * “u” es un número de identificador de unidad entre 1-99 para el archivo. Debe ser único.
         * file=nombrearchivo
         * El archivo a ser abierto por el programa.
     * status= new|old|scratch|unknown
     * form= formatted|unformatted
         * unformatted indica que tendremos un archivo binario.
     * Ejemplo: open(unit=5, file=’entvis2f.in’)
* close(lista de especificadores): nos interesa lo siguiente
     * [unit=]u
         * igual que en open. No define “file=”.
     * Ejemplo:  close(5)
* read()
* write()

#### Estructuras de control
* do etiq  varcontrol,incremento
* go to
* continue

#### Otros
* Format()
* ¿?



## 2.3 OpenMP
--https://computing.llnl.gov/tutorials/openMP/--
OpenMP es una Interfaz de Programación de Aplicaciones, o API por sus siglas en Ingles, la cual provee un modelo portable y escalable para el desarrollo de aplicaciones paralelas de memoria compartida. La API soporta C/C++ y Fortran en una gran variedad de arquitecturas. Es utilizada para de manera directa aplicar multihilos en memoria compartida.
--f95_openmpv1_v2.pdf
La especificación de OpenMP pertenece, es escrita y mantenida por la OpenMP Architecture Review Board, que es la unión de las compañías que tienen participación activa en el desarrollo del estándar para la interfaz de programación en memoria compartida. Mas información en www.openmp.org.
--Using OpenMP-oct2007--
No es un nuevo lenguaje de programación, sino que es una notación que puede ser agregada a un programa secuencial en Fortran, C o C++ para describir como el trabajo debe ser compartido entre los hilos que se ejecutaran en diferentes procesadores o núcleos y para organizar el acceso a los datos compartidos cuando sea necesario.
La inserción apropiada de las características de OpenMP en un programa secuencial permitirá a muchas, sino a la mayoría, de las aplicaciones beneficiarse de una arquitectura de memoria compartida, a menudo con mínimas modificaciones al código.
Uno de los factores del éxito de OpenMP es que es comparativamente sencillo de usar, ya que el trabajo mas complicado de armar los detalles del programa paralelo son dejados para el compilador. Tiene además la gran ventaja de ser ampliamente adoptado, de manera que una aplicación OpenMP va a poder ejecutarse en muchas plataformas diferentes.

Las directivas de OpenMP permiten al usuario indicarle al compilador que instrucciones ejecutar en paralelo y como distribuir las mismas entre los hilos que van a ejecutar el código.
Una de estas directivas es una instrucción en un formato especial que es entendido por compiladores OpenMP solamente. De hecho luce como un comentario para un compilador Fortran regular, o una diretiva pragma para un compilador C/C++, de manera que el programa puede ejecutarse como lo hacía previamente si el compilador no conoce OpenMP.
Generalmente se puede rápida y fácilmente crear programas paralelos confiando en la implementación para que trabaje los detalles de la ejecución paralela. Pero no siempre es posible obtener alta performance con una inserción sencilla, incremental de directivas OpenMP en un código secuencial. Por esta razón OpenMP incluye varias características que habilitan al programador a especificar mas detalle en el código paralelo.

### La idea de OpenMP
Un hilo es una entidad en tiempo de ejecución que es capaz de ejecutar independientemente un flujo de instrucciones. OpenMP trabaja en un cuerpo mas grande de trabajo que soporta la especificación de programas para ser ejecutados por una colección de hilos cooperativos. El sistema operativo crea un proceso para ejecutar un programa: reservará algunos recursos para este proceso, incluyendo páginas de memoria y registros para almacenar valores de objetos. Si multiples hilos colaboran para ejecutar un programan, compartirán los recursos, incluyendo el espacio de direcciones, del correspondiente proceso. Los hilos individuales necesitan muy pocos recursos por si mismos: un contador de programa y un área de memoria para guardar variables especificas del hilo (incluyendo registros y una pila).
OpenMP intenta proveer facilidad de programación y ayudar al usuario a evitar un número de potenciales errores de programación, ofreciendo un enfoque estructurado para la programación multihilo. Soporta el modelo de programación llamado fork-join, el cual podemos ver en la figura 2.3.1.aa.

    Figura 2.1 de pag 49 – using openmp

Bajo este enfoque, el programa inicia como un solo hilo de ejecución (denominado hilo inicial), igual que un programa secuencial. Siempre que se encuentre una construcción paralela de OpenMP por el hilo mientras ejecuta su programa, se crea un equipo de hilos (esta es la parte fork), se convierte en el maestro del equipo, y colabora con los otros miembros del equipo para ejecutar el código dinámicamente encerrado por la construcción. Al final de la construcción, solo el hilo original, o maestro del equipo, continua; todos los demás terminan (esta es la parte join). Cada porción del código encerrada por una construcción paralela es llamada una región paralela.

### Conjunto de construcciones paralelas
La API OpenMP comprende un conjunto de directivas del compilador, rutinas de bibliotecas de tiempo de ejecución, y variables de ambiente para especificar paralelismo de memoria compartida. Muchas de las directivas son aplicadas a un bloque estructurado de código, una secuencia de sentencias ejecutables con una sola entrada en la parte superior y una sola salida en la parte inferior en los programas Fortran, y una sentencia ejecutable en C/C++ (que puede ser una composición de sentencias con una sola entrada y una sola salida). En otras palabras, el programa no puede ramificarse dentro o fuera de los bloques de código asociados con directivas. En Fortran el inicio y el final del bloque aplicable de código son marcados explícitamente por una directiva OpenMP.

#### Crear equipos de Hilos
Un equipo de hilos es creado para ejecutar el código en una región paralela de un programa OpenMP. El programador simplemente especifica la región paralela insertando una directiva parallel inmediatamente antes del código que debe ser ejecutado en paralelo para marcar su inicio; en los programas Fortran el final también es indicado por una directiva end parallel. Información adicional puede ser provista junto con la diretiva parallel, como habilitar a los hilos a tener copias privadas de algún dato por la duración de la región paralela. El final de una región paralela es una barrera de sincronización implícita: esto significa que ningún hilo puede progresar hasta que todos los demás hilos del equipo hayan alcanzado este punto del programa. Es posible realizar anidado de regiones paralelas.

#### Compartir trabajo entre Hilos
Si el programador no especifica como se compartirá el trabajo en una región paralela, todos los hilos ejecutarán el código completo redundantemente, sin mejorar los tiempos del programa. Para ello OpenMP cuenta con directivas para compartir trabajo que permiten indicar como se distribuirá el computo en un bloque de código estructurado entre los hilos. A menos que el programador lo indique explícitamente, una barrera de sincronización existe implícitamente al final de las construcciones de trabajo compartido.

Probablemente el método mas común de trabajo compartido es distribuir el trabajo en un bucle DO (Fortran) o for (C/C++) entre los distintos hilos de un equipo. El programador inserta la directiva apropiada inmediatamente antes de los bucles que vayan a ser compartidos entre los hilos dentro de una región paralela.
Todas las estrategias de OpenMP para compartir el trabajo en un bucle asignan uno o mas conjuntos disjuntos de iteraciones a cada hilo. El programador puede, si así lo desea, especificar el método para particionar el conjunto de iteración.

#### Modelo de memoria de OpenMP
OpenMP se basa en el modelo de memoria compartida, por ello, por defecto los datos son compartidos por todos los hilos y son visibles para todos. A veces es necesario tener variables que tienen valores específicos por hilo. Cuando cada hilo tiene una copia propia de una variable, donde potencialmente tenga valores distintos en cada uno de ellos, decimos que la variable es privada. Por ejemplo, cuando un equipo de hilos ejecuta un bucle paralelo  cada hilo necesita su propio valor de la variable de control de iteración. Este caso es tan importante que el propio compilador fuerza que así sea; en otros casos el programador es quien debe determinar cuales variables son compartidas y cuales privadas.

#### Sincronización de Hilos
Sincronizar los hilos es necesario en ocasiones para asegurar el acceso en orden a los datos compartidos y prevenir corrupción de datos. Asegurar la coordinación de hilos necesaria es uno de los desafíos mas fuertes de la programación de memoria compartida. OpenMP provee, por defecto, sincronización implícita haciendo que los hilos esperen al final de una construcción de trabajo compartido o región paralela hasta que todos los hilos en el equipo terminan su porción de trabajo. A esto se lo conoce como una barrera. Mas difícil de conseguir en OpenMP es coordinar las acciones de un subconjunto de los hilos ya que no hay soporte explicito para esto.
Otras veces es necesario asegurar que solo un hilo a la vez trabaja en un bloque de código. OpenMP  tiene varios mecanismos que soportan este tipo de sincronización.

#### Otras caracteristicas
Subrutinas y funciones pueden complicar la utilización de APIs de Programación Paralela. Una de las características innovativas de OpenMP es el hecho de que las directivas pueden ser insertadas dentro de procedimientos que son invocados desde dentro de una región paralela.
Para algunas aplicaciones puede ser necesario controlar el número de hilos que ejecutan la región paralela. OpenMP permite al programador especificar este número previo a la ejecución del programa a través de una variable de ambiente, luego de que el cómputo a iniciado a través de una librería de rutinas, o al comienzo de regiones paralelas. Si no se hace esto, la implementación de OpenMP utilizada elegirá el número de hilos a utilizar.


## 2.4 OpenMP en Fortran
--F95_OpenMPv1_v2
Fueron presentados Fotran y OpenMP, en esta sección se ve como se complementan, mostrando cuales es el formato de las directivas de OpenMP en Fortran.

### Centinelas para directivas de OpenMP y compilación condicional.

El estándar OpenMP ofrece la posibilidad de usar el mismo código fuente con un compilador que implementa OpenMP como con uno normal. Para ello debe ocultar las directivas y comandos de una manera que un compilador normal no pueda verlas. Para ello existen las siguientes directivas sentinelas:

	!$OMP

	!$

Como el primer caracter es un signo de exclamación “!”, un compilador normal va a interpretar las lineas como comentarios y va a ignorar su contenido. Pero un compilador compatible con OpenMP identificará la sentencia y procederá como sigue:

* !$OMP : el compilador compatible con OpenMP sabe que la información que sigue en la linea es una directiva OpenMP. Se puede extender una directiva en varias lineas utilizando el mismo centinela frente a las siguientes lineas y usando el método estándar de Fortran para partir lineas de código:

        !$OMP PARALLEL DEFAULT(NONE) SHARED(A, B) &
        !$OMP REDUCTION(+:A)

Es obligatorio incluir un espacio en blanco entre la directiva centinela y la directiva OpenMP que le sigue, sino la linea será interpretada como un comentario.

* !$ : la linea correspondiente se dice que está afectada por una compilación condicional. Quiere decir que su contenido estará disponible para el compilador en caso de que sea compatible con OpenMP. Si esto ocurre, los dos caracteres del centinela son reemplazados por dos espacios en blanco para que el compilador tenga en cuenta la linea. Como en el caso anterior podemos extender la linea en varias lineas como sigue:

	!$ interval = L * OMP_get_thread_num() / &
	!$                       (OMP_get_num_threads() - 1)

Nuevamente el espacio en blanco es obligatorio entre la directiva de compilación condicional y el código fuente que le sigue.

### El constructor de región paralela
La directiva mas importante en OpenMP es la que define las llamadas regiones paralelas. Ya que la región paralela necesita ser creada/abierta y destruida/cerrada, dos directivas son necesarias en Fotran: !$OMP PARALLEL / !$OMP END PARALLEL.
Un ejemplo de su uso:

	!$OMP PARALLEL 
		write(*,*) “Hola”
	!$OMP END PARALLEL

	--Agregar figura 1.1 de F95_OpenMPv1v2 donde muestra la representación de la región.

Como el código entre las dos directivas es ejecutado por cada hilo, el mensaje Hola aparece en la pantalla tantas veces como hilos estén siendo usados en la región paralela.
Al comienzo de la región paralela es posible imponer clausulas que fijan ciertos aspectos de la manera en que la región paralela va a trabajar, por ejemplo el alcance de las variables, el número de hilos, etc. La sintaxis a usar es la siguiente:

	!$OMP PARALLEL  clausula1 clausula2 …
	…
	!$OMP END PARALLEL
Las clausulas permitidas en la directiva de apertura !$OMP PARALLEL son las siguientes:

* PRIVATE(lista)
* SHARED(lista)
* DEFAULT( PRIVATE | SHARED | NONE )
* FIRSTPRIVATE(lista)
* COPYIN(lista)
* REDUCTION(operador:lista)
* IF(expresión_escalar_lógica)
* NUM_THREADS(expresión_escalar_entera)

La directiva !$OMP END PARALLEL indica el final de la región paralela, la barrera mencionada antes en el capitulo. En este punto es donde ocurre la sincronización entre el equipo de hilos y son terminados todos excepto el hilo maestro que continua con la ejecución del programa.

### Directiva !$OMP DO
Es una directiva de trabajo compartido, por lo cual el trabajo es distribuido en un equipo de hilos al encontrar el código esta directiva. Debe ser ubicada dentro del alcance de una región paralela para ser efectiva, si no, la directiva aún funcionará pero el equipo será de un solo hilo. Esto se debe a que la creación de nuevos hilos es una tarea reservada a la directiva de creación de la región paralela.
Esta directiva hace que el bucle Do inmediato sea ejecutado en paralelo.
Por ejemplo:

	!$OMP DO
		do 1   i = 1, 1000
		...
	  1 continue
	!$OMP END DO

distribuye el bucle do entre los diferentes hilos, cada hilo computa una parte de las iteraciones.
Por ejemplo si usamos 10 hilos, entonces generalmente cada hilo computa 100 iteraciones del bucle do. El hilo 0 desde 1 a 100, el hilo 1 desde 101 a 200 y así sucesivamente. Podemos ver esto en la figura 2.4.3.1 (figura 2.1 de f95_openmpv1_v2).
Dentro del trabajo de esta tesis es la directiva principal al tratarse los bucles do de una de las principales construcciones utilizadas en el programa estudiado.

La directiva !$OMP DO tiene asociadas clausulas al igual que la directiva parallel, que permiten indicar el comportamiento de la construcción de trabajo compartido. La sintaxis es similar:

	!$OMP DO clausula1 clausula2 …
	…
	!$OMP END DO clausula_de_fin

Las clausulas de inicio pueden ser cualquiera de las siguientes:

* PRIVATE(lista)
* FIRSTPRIVATE(lista)
* LASTPRIVATE(lista)
* REDUCTION(operador:lista)
* SCHEDULE(tipo, pedazo)
* ORDERED

Adicionalmente a estas clausulas de inicio, se puede agregar a la directiva de cierre la clausula NOWAIT para evitar la sincronización implícita. También se evita el refresco de las variables compartidas, implícito en la directiva de cierre, por lo que se debe tener cuidado de cuando utilizar la clausula NOWAIT. Se pueden evitar problemas con la directiva de OpenMP !$OMP FLUSH que fuerza el refresco de las variables compartidas en memoria por los hilos.

### Clausulas Atributo de Alcance de Datos

#### PRIVATE(lista)

A veces ciertas variables van a tener valores diferentes en cada hilo. Esto solo es posible si cada Hilo tiene su propia copia de la variable. Esta clausula fija que variables van a ser consideradas variables locales de cada hilo. Por ejemplo:

	!$OMP PARALLEL PRIVATE(a, b)

indica que las variables a y b tendrán diferentes valores en cada hilo, serán locales a cada hilo.
Cuando una variable se declara como privada, un nuevo objeto del mismo tipo es declarado por cada hilo del equipo y usado por cada hilo dentro del alcance de la directiva que lo declare (la región paralela en el ejemplo anterior) en lugar de la variable original. (figura para mostrar esto? Figura 3.1 del pdf)
El hecho de que un nuevo objeto es creado por cada hilo puede ser algo que genere mucho consumo de recursos. Por ejemplo, si se utiliza un array de 5Gb (algo común en simulaciones numéricas directas y otras) y es declarado como privado en una región paralela con un equipo de 10 hilos, entonces el requerimiento de memoria será de 55Gb, algo no disponible en todas las maquinas SMP.
Las variables utilizadas como contadores en los bucles do o comandos forall, o son declaradas THREADPRIVATE, se convierten automáticamente en privadas para cada hilo, aún cuando no hayan sido declaradas en un clausula PRIVATE.

####  SHARED(lista)

Contrario a lo visto en la situación previa, a veces hay variables que deben estar disponibles para todos los hilos dentro del alcance de una directiva, debido a que su valor es necesario para todos los hilos o porque todos los hilos deben actualizar su valor. Por ejemplo:

	!$OMP PARALLEL SHARED(c, d)

indica que las variables c y d son vistas por todos los hilos en el alcance de las directivas !$OMP PARALLEL / !$OMP END PARALLEL. (mostrar gráficamente con figura 3.2 del pdf?)
Una variable declarada como compartida (shared) no consume recursos extras, ya que no se reserva nueva memoria y su valor antes de la directiva inicial es conservado. Es decir que todos los hilos acceden a la misma ubicación de memoria para leer y escribir la variable.
Debido a que mas de un hilo puede escribir en la misma ubicación de memoria al mismo tiempo, resulta en un valor indefinido de la variable. A esto se lo llama una condición de carrera, y debe ser siempre evitado por el programador. 


####  DEFAULT ( PRIVATE | SHARED | NONE )
Cuando la mayoría de las variables dentro del alcance de una directiva va a ser privada o compartida, entonces sería engorroso incluir todas ellas en una de las clausulas previas. Para evitar esto, es posible especificar que hará OpenMP cuando no se especifica nada sobre una variable, es posible especificar un comportamiento por defecto. Por ejemplo:

	!$OMP PARALLEL DEFAULT(PRIVATE) SHARED(a)

indica que todas las variables excepto “a” van a ser privadas, mientras que “a” será compartida por todos los hilos dentro del alcance de la región paralela. Si no se especifica ninguna clausula DEFAULT, el comportamiento por defecto es como si DEFAULT(SHARED) fuera especificado. Como veremos en el capitulo 3 de este trabajo de tesis, esto puede variar en implementaciones y debe ser investigado mas a fondo.
A las opciones PRIVATE y SHARED se le agrega una tercera: NONE. Especificando DEFAULT(NONE) requiere que cada variable en el alcance de la directiva debe ser explicitamente listada en una de las clausulas PRIVATE o SHARED al principio del alcance de la directiva (exceptuando variables declaradas THREADPRIVATE o los contadores de los bucles).

####  FIRSTPRIVATE(lista)
Como mencionamos previamente, las variables privadas tienen un valor indefinido al comienzo del alcance de un par de directivas de inicio y cierre. Pero a veces es de interés que esas variables locales tengan el valor de la variable original antes de la directiva de inicio. Esto se consigue incluyendo la variable en una clausula FIRSTPRIVATE como:

	a = 2
	b = 1
	!OMP PARALLEL PRIVATE(a) FIRSTPRIVATE(b)

En este ejemplo, la variable “a” tiene un valor indefinido al inicio de la región paralela, mientras que “b” tiene el valor especificado en la región serial precedente, es decir “b = 1”. Podemos ver este ejemplo en la figura 2.4.4.4.1  (figura 3.4 del pdf)
Al incluir la variable en una clausula FIRSTPRIVATE al inicio del alcance de una directiva toma automáticamente el estatus de PRIVATE en dicho alcance y no es necesario incluirla en una clausula PRIVATE explicitamente.
Al igual que con las variables PRIVATE debe tenerse en cuenta el costo de la operación desde el punto de vista computacional, al realizarse una copia de la variable y transferir la información almacenada a la nueva variable.

### Otras Construcciones y Clausulas

Existen mas construcciones de trabajo compartido, de sincronización y de ambiente de datos, y mas clausulas en OpenMP, las cuales exceden el alcance de este trabajo de tesis y que pueden ser consultadas en el estandar OpenMP [referencia] o en libros como Parallel Programming in Fortran 95 using OpenMP [referencia a F95_openmpv1_v2].


## 2.5 Proceso de optimización
Dependiendo del propósito de una aplicación, y de la forma como será utilizada, suelen considerarse tres principios de optimización del desempeño [REF GySh]:

* Resolver el problema más rápido
* Resolver un problema más grande en el mismo tiempo
* Resolver el mismo problema en el mismo tiempo, pero utilizando una cantidad menor de recursos del sistema

En aplicaciones de HPC, obtener resultados más rápido es crucial para los usuarios. Por ejemplo, para un ingeniero representa una diferencia considerable si puede repetir una simulación en el transcurso de una noche en lugar de esperar varios días para que la simulación termine, tiempo que puede ser aprovechado para modificar el diseño.

Por otro lado, la meta puede ser resolver un problema más grande en el mismo tiempo. Por ejemplo, un meteorólogo necesita completar simulaciones de sus modelos de clima en un tiempo especificado. La mejora del desempeño puede permitirle al meteorólogo usar conjuntos de datos más grandes en el mismo tiempo de ejecución, para obtener previsiones del clima más precisas; y en el caso de que tanto el tamaño del problema como el tiempo de ejecución se deban mantener constantes, una aplicación optimizada consumirá menos recursos para completar su ejecución.

El proceso de optimización tiene algunas etapas fundamentales: desarrollo de la aplicación (programación y portabilidad), optimización serial, y optimización paralela (Fig. XX [REF G y Sh]).

    Figura 2.5.aa (pag 51 garg y sharapov)

La primer etapa abarca el desarrollo de la aplicación, es decir, elección de algoritmos y estructuras de datos para resolver el problema. En el caso de este trabajo de Tesis esa etapa fue llevada a cabo por el autor de la aplicación en que basamos nuestro estudio. Las etapas de optimización serial y optimización paralela son las que serán explicadas brevemente en esta subsección.

Una decisión importante que se debe tomar al optimizar, es contemplar en qué plataforma o conjunto de ellas se implementará la aplicación. Esta decisión incluye seleccionar la versión de Sistema Operativo y determinar si la aplicación correrá en modo de 32-bit o 64-bit. Mientras más puntuales sean nuestras decisiones, más focalizada será la optimización, limitando el rango de plataformas en las cuales el programa puede ejecutarse. Una vez que el programa produce resultados correctos, está listo para ser optimizado. Se seleccionarán un conjunto de casos de test para validar que el programa continúe arrojando resultados correctos y se los utilizará repetidamente en el transcurso de la optimización.

También se debe seleccionar un conjunto de casos para llevar a cabo pruebas de tiempo. Puede ser necesario que este conjunto sea diferente a los utilizados para validar el programa. Los casos de test para el cronometraje de tiempo podrían ser varios benchmarks que representan adecuadamente el uso del programa. Utilizamos estos benchmarks para medir el desempeño de la linea de base, de manera de disponer de datos fiables para utilizar mas tarde en las comparaciones de código optimizado y código original. De esta manera, el efecto de la optimización se puede medir.

### 2.5.1 Optimización Serial
La Optimización Serial es un proceso iterativo que involucra medir repetidamente un programa seguido por la optimización de sus partes críticas de rendimiento. La figura 3.bb  resume las tareas de optimización y da un diagrama de flujo simplificado para el proceso de optimización serial.

	Figura 2.5.bb (pag 52 garg y sharapov)

Una vez que las mediciones de rendimiento de la linea de base se han obtenido, el esfuerzo de optimización debe iniciarse mediante la compilación de todo el programa con opciones seguras. Siguiente, linkear librerías optimizadas. (Este linkeo es una manera sencilla de llevar implementaciones altamente optimizadas de operaciones estandar en un programa)
Luego de esto se debe verificar que los resultados preservan la correctitud del programa. Este paso incluye verificar que el programa realiza llamadas a las Interfaces de Programación de Aplicación (APIs sus siglas en Ingles) adecuadas en las librerías optimizadas. Además, es recomendable que sea medido el desempeño del programa para verificar que ha mejorado.

El siguiente paso es identificar partes de desempeño críticas en el código. El perfilado (profiling en Ingles) del código fuente puede ser usado para determinar cuales partes del código son las que toman mas tiempo para ejecutarse. Las partes identificadas son excelentes objetivos para enfocar el esfuerzo de optimización, y las mejoras resultantes de desempeño pueden ser significativas. Otra técnica muy útil para identificar estas partes de código críticas es el monitoreo de la actividad del sistema y el uso de los recursos del sistema. 

#### Metodología de medición
Al trabajar en optimizar la performance de una aplicación, es esencial usar varias herramientas y técnicas que sugieran que partes del programa necesitan ser optimizadas, comparar el desempeño antes y luego de la optimización y mostrar que tan eficiente los recursos del sistema han sido utilizados por el código optimizado.

El primer paso en el proceso de afinación de la aplicación es cuantificar su desempeño. Este paso es alcanzado usualmente estableciendo un desempeño base y fijando expectativas apropiadas de cuanta mejora en el desempeño es razonable alcanzar.
Para programas cientificos, la métricas de mayor interés son usualmente el tiempo reloj (tiempo de respuesta) de un solo trabajo y aquellos que relacionan el desempeño de la aplicación a picos teóricos de desempeño de la CPU.
A traves de benchmarks es que podemos realizar análisis de la performance de la aplicación. Una guía importante a seguir es que las mediciones deben ser reproducibles dentro de un rango de tolerancia esperado. Con esto en mente se definen las siguientes reglas generales:

* Seleccionar cuidadosamente los conjuntos de datos a utilizar. Deben representar adecuadamente el uso de la aplicación.
* Al igual que en las mediciones en otros campos de la ingeniería, la incertidumbre también se aplica a las mediciones de desempeño de programas de computadora. El simple hecho de tratar de medir un programa se entromete en su ejecución y posiblemente lo afecta de manera incierta.
* Siempre que sea posible, ejecutar los benchmarks desde un sistema de archivos tipo tmpfs (/tmp) o algún sistema de archivos montado localmente. Ejecutar una aplicación desde un sistema de archivos montado por red introduce efectos de red irreproducibles en el tiempo de ejecución.
* Actividades de paginado y swapeo deben ser monitoreadas mientras se ejecuta el benchmark, ya que estas pueden desvirtuar completamente la medición.
* Las mediciones de “respuesta del programa” deben ser desempeñadas en una manera dedicada, sin otros programas o aplicaciones ejecutandose.
* Las caracteristicas del sistema deben ser registradas y guardadas.

#### Herramientas de medición
Antes de analizar el desempeño de la aplicación, uno debe identificar los parametros que deben ser medidos y elegir herramientas acordes a las mediciones.
Las herramientas de medición de desempeño pueden ser divididas en tres grupos basados en su función:

* Herramientas de temporizador, que miden el tiempo utilizado por un programa de usuario o sus partes. Pueden ser herramientas de linea de comando o funciones dentro del programa.
* Herramientas de perfilado, que utilizan resultados de tiempo para identificar las partes de mayor utilización de una aplicación.
* Herramientas de monitoreo, que miden la utilización de varios recursos del sistema para identificar “cuellos de botella” que ocurren durante la ejecución.

Existen otras formas de categorizar estas herramientas, como puede ser basados en los requerimientos para su uso (herramientas que operan con binarios optimizados, o que requieren insertarse en el código fuente, etc), o incluso dividirlas en dos grupos:

* Herramientas de medición de desempeño lineal
* Herramientas de medición de desempeño paralelo.

#### Herramientas de medición de tiempo

El paso fundamental para evaluar comparativamente y poner a punto el desempeño de un programa es medir con precisión la cantidad de tiempo utilizado ejecutando el código. Generalmente uno está interesado en el tiempo total utilizado para correr un programa, así como en el tiempo utilizado en porciones del programa.
Para medir el programa completo es necesario usar herramientas que midan con precisión el tiempo transcurrido desde el comienzo de la ejecución del programa. En GNU/Linux utilizamos la herramienta “time” para dicho propósito. La forma de utilizar time es ejecutarlo desde una terminal de GNU/Linux pasando como parámetro el comando que debe medir tal cual como el comando es ejecutado normalmente. Por ejemplo:

	$ time  find / -name “syslog”

El comando siendo medido realiza su ejecución normalmente. Al finalizar su ejecución, el comando time muestra por salida estándar tres valores:
* “real”: el tiempo real transcurrido entre el inicio y la finalización de la ejecución.
* “user”: el tiempo de usuario del procesador.
* “sys”: el tiempo de sistema del procesador.

Podemos ver en la figura 2.5.1.3.x un ejemplo de ejecución del comando time.

#### Herramientas de perfilado de programa

El perfilado muestra cuales funciones son las mas costosas en las ejecuciones de una aplicación. Es necesario utilizar para la medición casos de test representativos y multiples, de manera de obtener resultados significativos.
En GNU/Linux se cuenta con la herramienta “gprof” para realizar perfilado de aplicaciones. Para utilizarla un programa debe estar compilada con la opción “-pg”. Luego se ejecuta el programa una vez y genera un archivo llamado gmon.out en el directorio de ejecución el cual es utilizado por el comando gprof para generar el reporte de perfilado para esa ejecución. La sintaxis de gprof es:

	$ gprof  <programa_ejecutable>  [<ruta_a_gmon.out>]

Si no se le pasa la ruta a gmon.out, por defecto utiliza el directorio desde donde es invocado gprof.
Un ejemplo de este proceso puede verse en la figura 2.5.1.4.x 

    figura 2.5.1.4.x
    $ gfortra -pg foo.for -o foo
    $ foo
    $ gprof foo

La salida de gprof es por salida estándar y bastante extensa, por lo cual es aconsejable redirigirla a un archivo. Consta de tres partes: la primera parte lista las funciones ordenadas de acuerdo al tiempo que consumen, junto con sus descendientes (tiempo inclusivo). La segunda parte lista el tiempo exclusivo para las funciones (tiempo empleado ejecutando la función) junto con los porcentajes de tiempo total de ejecución y número de llamadas. La última parte da un índice de todas las llamadas realizadas en la ejecución.

### 2.5.2 Optimización Paralela
Luego de que la aplicación está optimizada para procesamiento serial, su tiempo de ejecución puede ser  reducido aún mas permitiendo que se ejecute en varios procesadores. Las técnicas mas usadas comunmente para paralelización son el hilado explicito, las directivas al compilador y el pasaje de mensajes. En la figura 3.cc se vé ilustrado el proceso de optimización paralela.

	Figura 3.cc (garg & sharapov pag 55)

El primer paso es elegir un modelo, identificar que partes del programa deben ser paralelizadas y determinar como dividir la carga de trabajo computacional entre los diferentes procesadores. Dividir la carga de trabajo computacional es crucial para el desempeño, ya que determina los gastos generales de comunicación, sincronización y de desequilibrios de carga resultantes en un programa paralelizado. Generalmente, una división de trabajo de “nivel grueso” es recomendada debido a que minimiza la comunicación entre las tareas paralelas, pero en algunos casos, un enfoque de este tipo lleva a balanceo de carga muy pobre; un nivel mas fino en el particionamiento de la carga de trabajo puede llevar a un mejor balanceo de carga y desempeño de la aplicación.

Luego de seleccionado un modelo de paralelización e implementado, lo siguiente es optimizar su desempeño. Similar a la optimización serial, este proceso es iterativo e involucra mediciones repetidas seguidas de aplicar una o mas técnicas de optimización para mejorar el desempeño del programa. Las aplicaciones paralelas, sin importar el modelo utilizado, necesitan que exista comunicación entre los procesos o hilos concurrentes. Se debe tener cuidado de minimizar los gastos extras en comunicación y asegurar una sincronización eficiente en la implementación; Minimizar el desequilibrio de cargas entre las tareas paralelas, ya que esto degrada la escalabilidad del programa. También se debe considerar temas como migración y programación de procesos, y coherencia de cache. Las librerías del compilador pueden ser utilizadas para implementar versiones paralelas de funciones usadas comunmente, tanto en aplicaciones multihilo como multiproceso.

Los cuellos de botella de un programa paralelo pueden ser muy diferentes de los presentes en una versión serial del mismo programa. Además de gastos extras específicos de la paralelización, las porciones lineales (o seriales) de un programa paralelo pueden limitar severamente la ganancia de velocidad de la paralelización. En tales situaciones , hay que prestar atención a esas porciones lineales para mejorar el desempeño total de la aplicación paralela. Por ejemplo, consideremos la solución directa de N ecuaciones lineales. El costo computacional escala en el orden de O(N^3) en la etapa de descomposición de la matriz y en el orden de O(N^2) en la etapa de sustitución adelante-atrás. En consecuencia, la etapa de sustitución adelante-atrás apenas se nota en el programa serial, y el desarrollador paralelizando el programa justificadamente se enfoca en la etapa de descomposición de la matriz. Posiblemente, como resultado del trabajo de paralelización, la etapa de descomposición de la matriz se vuelve mas eficiente que la etapa de sustitución adelante-atrás. El desempeño total y velocidad del programa de resolución directa ahora está limitado por el desempeño de la etapa de sustitución adelante-atrás. Para mejorar aún mas el desempeño, la etapa de sustitución adelante-atrás debería convertirse en el foco de optimización y posiblemente un trabajo de paralelización.

## 2.6 Caso de Estudio: Aplicación para Modelización del Flujo Inviscido con el método de los paneles
* Buscar definición y tratar de explicar lo que resuelve el programa: Integración numérica por Simpson de la ley de Biot-Savart. Prado pag 79 en adelante.

El programa objeto de optimización de esta tesis es autoría de Ricardo A. Prado, y es utilizado para obtener resultados en su trabajo de tesis de Doctorado [Prado, mayo 2007] en la Universidad de Buenos Aires en el área de Ingeniería. En dicho trabajo se explica que la “tesis analiza el comportamiento fluidodinámico de una turbomáquina particular: la turbina eólica”. Luego explica que “debido a la complejidad de las ecuaciones de gobierno en ambas zonas del campo fluidodinámico, como así también de la geometría de la turbina y de sus condiciones de operación, se requiere de proceso de resolución numérica adecuados, los cuales se incorporaron en los códigos computacionales que se desarrollaron a tal efecto.”.
El programa indica en su cabecera que realiza el cálculo “integración por Simpson de la ley de Biot-Savart”. La regla o método de Simpson es un método de integración numérica que se utiliza para obtener la aproximación de una integral en un intervalo definido, al dividir ese intervalo en subintervalos y aproximar cada subintervalo con un polinomio de segundo grado. 
La ley de Biot-Savart indica el campo magnético creado por corrientes eléctricas estacionarias. Es una de las leyes fundamentales de la magnetoestática. En particular en el trabajo de Prado, uno de sus capítulos realiza una modelización del flujo invíscido (de viscosidad despreciable, casi nula) alrededor de la pala, y formula el modelo numérico a través del método de los paneles. En particular la aplicación de la ley de Biot-Savart es para el calculo de las velocidades inducidas en un punto para cada panel de la pala.

