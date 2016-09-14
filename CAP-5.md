# Capitulo 5
## Conclusiones y Trabajos Futuros

En este capítulo se presentan las principales conclusiones de esta tesis. En la última sección se presentan las potenciales líneas futuras de acción que puedan complementar el trabajo desarrollado.


## 5.1 Conclusiones

La paralelización de una aplicación legacy es una tarea compleja con muchos aspectos. Se realiza en varias etapas incrementales que van impactando en mayor o menor medida en los resultados. La finalidad de la paralelización puede ser buscar mejorar la performance, la utilización de recursos, la calidad de los resultados, etc. El presente trabajo se enfocó en la mejora de utilización de recursos, en la etapa de optimización serial, y de la performance, en la etapa de optimización paralela. Sin embargo, en ambas etapas se obtuvieron mejoras parciales en ambos aspectos.

Para poder realizar el trabajo de tesis fue necesario estudiar y aprender el lenguaje Fortran; luego, estudiar el código de la aplicación objeto de estudio para comprender su forma de trabajar, y luego poder realizar los cambios necesarios sin modificar substancialmente el código. Recorriendo este camino se adquirieron conocimientos sobre el estándar OpenMP y sobre la optimización de aplicaciones para Computación de Altas Prestaciones.

Para poder enfrentar el trabajo de optimización adecuadamente fue necesario un análisis de la aplicación bajo estudio. Tomamos el programa original, ejecutándolo con un tamaño del problema de 50x50, para obtener mediciones que dieran la base de comparación para las etapas de optimización. Luego se aplicó la optimización tal como se describió en el capítulo 3: optimización del código serial en primer lugar, y paralelización de una porción del código posteriormente. Esta paralelización se realizó aplicando las directivas de OpenMP a la subrutina estela.

Luego de la primera etapa, de optimización serial, se logró una mejora en el tiempo de ejecución, aunque todavía reducida (factor de mejora o speedup de 1.34). Al realizar la optimización paralela obtuvimos un mayor speedup (con valores de 3.58 en un equipo de pruebas y 2.59 en otro). Estos factores de mejora estaban más de acuerdo con la intuición, ya que la optimización afectaba a una subrutina que consumía entre un 74% y un 79% del tiempo de ejecución original.

Al ocuparnos del uso de discos y memoria, trasladamos los archivos desde el filesystem, residente en disco, a la memoria RAM para un acceso mas rápido. Sin embargo esta modificación no tuvo un impacto tan notable como se esperaba. Se duplicó aproximadamente la utilización de memoria RAM, sin que esto representara un inconveniente dados los equipos utilizados. En equipos con 1 GB de RAM (en la actualidad es habitual contar con 2 GB o más) el programa seguiría teniendo memoria suficiente para ejecutarse. %OSO para qué tamaños de problema?

%OSO en el párrafo que sigue, las pruebas con tamaño de problema mayor, son despues de todo el proceso de optimización?
Por último, sobre uno de los equipos se llevaron a cabo pruebas con un tamaño de problema mayor (80x80). Primero se realizó un perfilado, donde se pudo observar que los porcentajes de tiempo de las subrutinas estela y solgauss casi se habían equiparado (46% y 43% respectivamente). En las pruebas esto mostró que la mejora de tiempo al paralelizar no fue tan grande como con el tamaño de problema menor, lo cual lleva a la necesidad de paralelizar solgauss para poder obtener mayor mejora en tamaños más grandes de problema para la aplicación. También podemos concluir que claramente el incremento de tamaño del problema y la optimización impactan en la memoria del sistema y debe tenerse en cuenta la cantidad de RAM disponible si el usuario quisiera incrementar aún más el tamaño del problema.



## 5.2 Trabajos Futuros

En función del trabajo de tesis se identificaron algunos aspectos que permitirían extender el trabajo realizado. Estos aspectos se detallan a continuación:

* Analizar si al aumentar aún mas el tamaño del problema, con perfilado de la aplicación original, siguen invirtiéndose los tiempos de las subrutinas, y ver si es necesario optimizar de otra manera. También utilizar herramientas de perfilado de aplicaciones paralelas con OpenMP, como "ompp".
* Otra línea de trabajo podría ser proponer una recodificación de la aplicación para aprovechar mejoras en el lenguaje Fortran y otras bibliotecas existentes para la realización de los cálculos.
* Se podría paralelizar la subrutina solgauss y analizar si es necesario recodificar la subrutina o si se puede optimizar en su estado original. Además analizar si la ganancia en performance en el tamaño de problema menor es o no despreciable; y, en problemas de mayor tamaño, qué speedup puede obtenerse.
* Realizar la optimización utilizando conjuntamente OpenMP y la API MPI, y analizar la posibilidad de utilizar un cluster para la ejecución de la aplicación aprovechando la capacidad de cómputo de varios nodos.
* Investigar cómo una implementación del estándar OpenMP difiere de otras y qué problemas se presentan, teniendo en cuenta el problema visto en el cap 3 con la inicialización en cero de arrays utilizando OpenMP.
