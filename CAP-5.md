# Capitulo 5
## Conclusiones y Trabajos Futuros

En este capítulo se presentan las principales conclusiones de esta tesis obtenidas a partir de este trabajo. En la última sección se presentan las potenciales líneas futuras de acción que puedan complementar el trabajo desarrollado.


## 5.1 Conclusiones

La paralelización de una aplicación legacy no es un trabajo simple, se deben realizar varias etapas incrementales que van impactando en mayor o menor medida en la performance. Además debe decidir si se busca mejorar la performance, la utilización de recursos, la calidad de los resultados, etc. En este trabajo de tesis se realizó un trabajo de mejora de utilización de recursos, etapa de optimización serial, y en la performance, etapa de optimización paralela; esto no quita que en ambas etapas obtuvieramos mejoras en performance y recursos.

Para poder realizar el trabajo de tesis fue necesario estudiar y aprender el lenguaje Fortran, luego estudiar el código de la aplicación objeto de estudio para comprender la forma de trabajar de la misma y luego poder realizar los cambios necesarios sin modificar substancialmente el código. Además de esto se adquirieron conocimientos en el estandar OpenMP y en la optimización de aplicaciones para Computación de Altas Prestaciones.

En el trabajo de tesis, como primer instancia, se realizó un analisis de la aplicación de estudio, para poder encarar el trabajo de optimización adecuadamente. Tomamos el programa original, con tamaño del problema de 50x50, para obtener mediciones que dieran la base de comparación para las etapas de optimización. Luego se aplicó la optimización como se indicó en el capítulo 3, optimización del código serial primero, y luego paralelización de una porción del código, lo cual es realizado aplicando las directivas de OpenMP a la subrutina estela.

En la primer etapa de optimización serial se pudo observar una mejora en el tiempo de ejecución, aunque no era lo suficientemente amplia (solo un factor de 1.34 de mejora). Al realizar la optimización paralela observamos una mejora mayor (un factor de 3.58 en un equipo y 2.59 en el otro), lo cual era esperable al impactar una subrutina que consumía entre un 74% y un 79% del tiempo de ejecución.

En la parte de disco y memoria se observó que el impacto de pasar los archivos desde el FS, para acceso en disco, a la memoria RAM para un acceso mas rápido, no tuvo un impacto muy grande, se duplicó aproximadamente la utilización de memoria RAM, pero esto no significaba niveles críticos para los equipos utilizados, y en equipos con 1GB de RAM (en la actualidad lo normal son 2GB o más) tendría memoria suficiente para ejecutarse.

Por último, sobre uno de los equipos se realizaron pruebas con un tamaño de problema mayor (80x80). Primero se hizo un perfilado, donde se pudo observar que los porcentajes de tiempo de las subrutinas estela y solgauss casi se habían equiparado (46% y 43% respectivamente). En las pruebas esto mostró que la mejora de tiempo al paralelizar no fue tan grande como con el tamaño de problema menor, lo cual lleva a la necesidad de paralelizar solgauss para poder obtener mayor mejora en tamaños más grandes de problema para la aplicación. También podemos concluir que claramente el incremento de tamaño del problema y la optimización impactan en la memoria del sistema y debe tenerse en cuenta la cantidad de RAM disponible si el usuario quisiera incrementar aún mas el tamaño del problema.



## 5.2 Trabajos Futuros

En función del trabajo de tesis se identificaron algunos aspectos que permitirían extender el trabajo realizado. Estos aspectos se detallan a continuación:

* Analizar si al aumentar aún mas el tamaño del problema, con perfilado de la aplicación original, siguen invirtiendose los tiempos de las subrutinas, y ver si es necesario optimizar de otra manera. También utilizar herramientas de perfilado de aplicaciones paralelas con OpenMP, como "ompp".
* Otra linea de trabajo podría ser proponer una recodificación de la aplicación para aprovechar mejoras en el lenguaje Fortran y otras librerias existentes para la realización de los cálculos.
* Se podría paralelizar la subrutina solgauss y analizar si es necesario recodificar la subrutina o si se puede optimizar en su estado original. Además analizar si la ganancia en performance en el tamaño de problema menor es o no despreciable, y si en tamaños de problema mayor, en que factor mejoran los resultados obtenidos en este trabajo de tesis.
* Realizar la optimización utilizando conjuntamente OpenMP y la API MPI, y analizar la posibilidad de utilizar un cluster para la ejecución de la aplicación aprovechando la capacidad de cómputo de varios nodos.
