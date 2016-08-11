# Capitulo 5
En el trabajo de tesis, como primer instancia, se realizó un analisis de la aplicación de estudio, para poder encarar el trabajo de optimización adecuadamente.
Tomamos el programa original, con tamaño del problema de 50x50, para obtener mediciones que dieran la base de comparación para las etapas de optimización. 
Luego se aplicó la optimización como se indicó en el capítulo 3, optimización del código serial primero, y luego paralelización de una porción del código, lo cual es realizado aplicando las directivas de OpenMP a la subrutina estela.
En la primer etapa de optimización serial se pudo observar una mejora en el tiempo de ejecución, aunque no era lo suficientemente amplia (solo un factor de 1.34 de mejora). Al realizar la optimización paralela observamos una mejora mayor (un factor de 3.58 en un equipo y 2.59 en el otro), lo cual era esperable al impactar una subrutina que consumía entre un 74% y un 79% del tiempo de ejecución.
En la parte de disco y memoria se observó que el impacto de pasar los archivos desde el FS, para acceso en disco, a la memoria RAM para un acceso mas rápido, no tuvo un impacto muy grande, se duplicó aproximadamente la utilización de memoria RAM, pero esto no significaba niveles críticos para los equipos utilizados, y en equipos con 1GB de RAM (en la actualidad lo normal son 2GB o más) tendría memoria suficiente para ejecutarse.
Por último, sobre uno de los equipos se realizaron pruebas con un tamaño de problema mayor (80x80). Primero se hizo un perfilado, donde se pudo observar que los porcentajes de tiempo de las subrutinas estela y solgauss casi se habían equiparado (46% y 43% respectivamente). 
En las pruebas esto mostró que la mejora de tiempo al paralelizar no fue tan grande como con el tamaño de problema menor, lo cual lleva a la necesidad de paralelizar solgauss para poder obtener mayor mejora en tamaños más grandes de problema para la aplicación.
También podemos concluir que claramente el incremento de tamaño del problema y la optimización impactan en la memoria del sistema y debe tenerse en cuenta la cantidad de RAM disponible si el usuario quisiera incrementar aún mas el tamaño del problema.




     Trabajos futuros: paralelizar solgauss y analizar si la ganancia vale la pena o no; recodificar para poder obtener aún mas performance; optimizar utilizando hibrido entre openmp y MPI. En una futura versión con la subrutina solgauss paralelizada debería poder utilizarse alguna herramienta de perfilado para aplicaciones paralelas, como ompp