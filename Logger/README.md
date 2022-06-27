#  Logger

O Logger é uma framework utilitário, que entrega algumas facilidades para realizar logs.

## [LoggerLevel](LoggerLevel.swift)
Os níveis abaixo, são os níveis suportados na framework e estão listados pela ordem de precedência.
O Primeiro nível `debug` é o de menor precedência e o `none` o de maior. O nível é configurado em uma 
implementação do [Destination](Destination.swift), por padrão este frameword só implementa o [LoggerConsoleDestination](LoggerConsoleDestination.swift), 
que imprime as informações no console.  
- debug
- info
- warning
- error
- none
Ao configurar um nível de log, todos os níveis com precedência menor serão ignorados. Isso significa que ao configurar o nível
`warning` on logs de `debug` e `info` serão ignorados. 
