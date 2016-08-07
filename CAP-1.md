
#Introducción

##Sistemas legacy o heredados
Todos los sistemas de software deben, eventualmente, dar respuesta a cambios ambientales. El desafío del cambio en los recursos de computación disponibles no solamente se presenta en forma de restricciones, sino que al contrario, más y mejores recursos disponibles comprometen la eficiencia de los sistemas, y ponen al descubierto limitaciones o vulnerabilidades de diseño que no eran evidentes en el momento en que se crearon.

Las aplicaciones legacy, o heredadas, debido al paso de una cierta cantidad de tiempo, enfrentan finalmente esta problemática en forma crítica, y alguien debe hacerse cargo de modernizarlas, o considerar dar por terminado su ciclo de vida y reemplazarlas. El trabajo de modernizar un sistema legacy puede tener una envergadura variable, dependiendo de la complejidad del sistema y del nuevo ambiente donde vaya a funcionar. La modernización de una aplicación legacy puede verse como un proceso de optimización de la aplicación, sólo que para una plataforma diferente de aquella para la cual fue construida.

##Aplicación seleccionada
Este trabajo de tesis aborda el problema de la modernización de una aplicación científica del campo de la Dinámica de Fluidos. La aplicación seleccionada es un programa creado y utilizado por un investigador de la Universidad Nacional del Comahue como culminación de una tesis de Doctorado. El programa analiza el comportamiento fluidodinámico de un tipo particular de turbomáquina, la turbina eólica de eje horizontal. Fue desarrollado a fines de la década de 1990, en un momento en el cual los recursos de computación eran restrictivos en comparación con los de hoy. Por otro lado, por el tipo de tarea que desarrolla, se encuentra entre las aplicaciones de la Computación de Altas Prestaciones (HPC, High Performance Computing); y, desde que fue escrita esta aplicación, las características del software y el hardware disponibles para esta clase de actividades han avanzado notablemente. 

Esta aplicación fue construida en su momento para la plataforma típica que estaba entonces al alcance de los pequeños grupos de investigación. Estos mismos grupos hoy ven la posibilidad de acceder a plataformas de características sumamente diferentes. Este trabajo intentará optimizar y modernizar la aplicación para que puedan ser aprovechados recursos que no estaban previstos en su diseño original, pero con los que hoy pueden contar sus usuarios. En especial nos referimos a las capacidades de multiprocesamiento de los equipos actuales, la mayor cantidad de memoria principal, y las nuevas capacidades de los compiladores que acompañan estos desarrollos arquitectónicos.

##Propuesta de modernización 
La aplicación está codificada en lenguaje Fortran, utilizando una estructura de programación secuencial y monolítica. El almacenamiento de datos temporales y resultados tanto parciales como finales se hace en archivos planos. Éstas son algunas respuestas de diseño a las restricciones presentadas por las plataformas de la época en que fue originalmente construida la aplicación; y son otros tantos interesantes puntos de intervención para adecuarla a las arquitecturas actuales, intentando mejorar sus prestaciones. 

La optimización buscada tiene en cuenta las nuevas arquitecturas paralelas, así como la mayor disponibilidad de memoria principal en las nuevas plataformas. Se propondrá una optimización del código secuencial y a continuación una solución de ejecución paralela. 

Se mantendrán las condiciones actuales de uso para el usuario. En particular, no se modificará el lenguaje de programación, de modo que el usuario y autor de la aplicación conserve la capacidad de mantenerla.


##Motivación de la tesis 
El autor de la tesis que se presenta es integrante del proyecto de investigación 04/F002, Computación de Altas Prestaciones, Parte II, dirigido por la Dra. Silvia Castro. La tesis ha sido desarrollada como aporte a los objetivos de dicho proyecto: 

* De formación de recursos humanos
    * Adquirir conocimientos teóricos y prácticos para el diseño, desarrollo, gestión y mejora de las tecnologías de hardware y software involucradas en la Computación de Altas Prestaciones y sus aplicaciones en Ciencia e Ingeniería Computacional. 
    * Formar experiencia directa en temas relacionados con Cómputo de Altas Prestaciones, en particular, optimización y paralelización de aplicaciones científicas.
* De transferencia
     * Relevar los requerimientos de Computación de Altas Prestaciones de otros investigadores en Ciencias e Ingeniería de Computadoras y
cooperar en su diagnóstico y/o resolución.
     * Detectar necesidades relacionadas con Computación de Altas Prestaciones en otras entidades del ámbito regional y plantear correspondientes actividades de transferencia.

##Organización de la Tesis 
A continuación se describe sintéticamente el contenido del resto de los capítulos comprendidos en esta Tesis.

* Capítulo 2

  Se presenta una revisión de los fundamentos y la aplicación de la Computación Paralela. Se presenta Fortran, el lenguaje de programación con el cual está implementada la aplicación seleccionada. Se describe la interfaz de programación paralela OpenMP utilizada para la solución propuesta. Se explica el proceso de optimización de una aplicación secuencial hacia una aplicación paralelizada, y por último se presenta brevemente la aplicación motivo de este trabajo de tesis.

* Capítulo 3

  Presenta el proceso de solución aplicado, dividido en dos etapas, la optimización del código Fortran y la paralelización aplicando OpenMP. Se presentan también los problemas encontrados en el proceso inherentes a la arquitectura de maquina y a la estructura de la aplicación seleccionada.

* Capítulo 4
 
  Se presentan ejemplos de ejecución de la solución propuesta en el capítulo 3 y comparaciones de resultados obtenidos.

* Capítulo 5
  
  Se presentan las conclusiones del trabajo, así como el análisis de los resultados obtenidos al aplicar la solución propuesta. Además se identifican posibles futuros trabajos derivados de esta tesis.



