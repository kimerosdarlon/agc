# Changelog
Esse documento contém as modificaçoes que foram realizadas em cada build

## [1.1.56] - 2020-24-09
### Changed
- Atualização da lib de SSO

## [1.1.55] - 2020-22-09
### Changed
- Modifica a url das políticas de privacidade 

## [1.1.54] - 2020-21-09
### Added
- Adiciona o link para as políticas de privacidade
### Changed
- Atualização da lib de SSO 

## [1.1.53] - 2020-21-09
### Fixed
- Correções de ortografia

## [1.1.52] - 2020-15-09
### Changed
- Modificaçao do ambiente de produção

## [1.1.51] - 2020-15-09
### Changed
- Mudança para o segurança do SERPRO

## [1.1.50] - 2020-26-08
### Added
- Adiciona o tratamento para chassi com menos de 17 caracteres 

## [1.1.49] - 2020-19-08
### Fixed
- Corrige máscaras do telefone e Timezone

## [1.1.47] - 2020-08-06
### Fixed
- Corrige o definitivamente o bug que fazia o app encerrar na tela de login

## [1.1.46] - 2020-08-06
### Fixed
- Corrige o problema de não carregar módulos para usuários sem autenticação em dois fatores.

## [1.1.45] - 2020-08-05
### Changed
- Muda o ambiente de segurança

## [1.1.43] - 2020-07-28
### Fixed
- Corrige o erro que fazia o app encerrar inesperadamente em alguns fluxos específicos

## [1.1.42] - 2020-07-27
### Fixed
- Corrige o erro que fazia o app encerrar inesperadamente

## [1.1.41] - 2020-07-24
### Added
- Mais ações de contexto em campos identificados como importante
- Adicionado testes no módulo de BO
### Fixed
- Ajustes finos de interface, principalmente na tela de BO
### Changed
- Atualização da lib de oauth

## [1.1.37] - 2020-07-07
### Added
- Tela de detalhes de BO completa
- Menus de contexto
- Notificação de novas versões
- Filtro por objeto na tela de boletim
- Melhoria na navegação dos filtros
### Changed
- Listagem de BO foi modificada para ficar mais fácil de ler

## [1.1.29] - 2020-06-26
### Fixed
- Corrige erro nos filtros de veículos
- Corrige os títulos nas telas de configurações
### Changed
- Organicação de arquivos
- Remoção do módulo de UI, deixando tudo no módulo Common [ Evita reference cycle ]
- Modificação visual do filtro de BO por cod. estadual

## [1.1.25] - 2020-06-25
### Fixed
- Corrige a validaçõa nos filtros de envolvidos
- Corrige espaçamento superior na tela de filtros de mandados

## [1.1.25] - 2020-06-25
### Fixed
- Scroll na tela de filtros

## [1.1.24] - 2020-06-22
### Added
- Adicionado o filtro por código estadual e código nacional

## [1.1.23] - 2020-06-19
### Fixed
- Corrigido a fonte de dados que estava fixa

## [1.1.22] - 2020-06-19
### Added
- Salvando buscar de filtros em recentes
- Mostra string de busca espandida na listagem de detalhes
### Fixed
- Estratégia de mostrar data no header de alerta do veículo
### Changed
- Reorganização dos dados de veículos
- Só mostra o possuidor caso seja diferente do proprietátio

## [1.1.16] - 2020-06-13
### Fixed
- Correção do modelo de BO
### Changed
- Criação e separação do projeto em módulos. Feito com o objetivo de facilar manutenção futuras.

## [1.1.15] - 2020-06-11
### Changed
- Header de alerta de veículos, foram adicionadas novas informações e modificação do design

## [1.1.14] - 2020-06-10
### Added
- Codigo de migração do banco de dados
### Fixed
- Corrige as seções na tabela de buscas recentes

## [1.1.13] - 2020-06-09
### Changed
- Navegação para a tela de detalhes de veículos.
- Seleção do tipo de de cpf para busca [ Proprietário, Locatário, Possuidor]
### Fixed
- Corrige o filtro por data de nascimento dos boletins de ocorrência.

## [1.1.12] - 2020-06-02
### Added
- Adiciona a tela de filtros na tela de boletins
- EmptyView na tela de boletins
- Validação de campos na tela de filtros envolvidos
- EmptyView na tela de mandados
- Adiciona o botão de filtros nas telas de listagem
### Changed
- Modificação no fluxo de navegação, remoção do padrão de modal para navigation
### Fixed
- Estado da tela de filtros
- Mensagem de erro 
- Executar a ação de busca na tela de filtros com o enter do teclado. 

## [1.1.8] - 2020-05-29
### Added
- Adiciona o filtro na tela de listagem de veículos
- EmptyView na tela de veículos quando não encontrado 
### Fixed
- Corrige o erro que não conseguia formatar a data quando vinha com milissegundos
- Corrige o problema na expansão das células
- Corrige a exibição dos nomes dos filtros
### Changed
- Não exibir delegacias repetidas na tela de listagem de boletins
- Mostrar traços para campos vazios no alerta de veículos

## [1.1.7] - 2020-05-26
### Added
- Validação dos campos do filtro de boletins de ocorrência
-  informação de versão na tela de configurações

### Fixed
- Corrige o errro que não exibia o mapa e os numero do boletim de ocorrência na tela de detalhes de veículos 

## [1.0.14] - 2020-05-23
### Added
- Appcenter
### Fixed
- corrige o bug na busca de CPF através dos filtros
- adiciona o scroll na tela de filtros de envolvidos
- melhorias de interface

## [1.0.13] - 2020-05-23
### Fixed
- Corrige o bug que fazia o app encerrar após o login

## [1.0.12] - 2020-05-22
### Fixed
- Tela de listagem de BO
- Tela de  filtro de BO 

## [1.0.11] - 2020-05-21
### Added
- Melhorias de arquitetura 
### Fixed
- aljustes finos de interface

## [1.0.10] - 2020-05-18
### Added
-  Módulo de mandados
### Fixed
- corrige a navegação ao buscar por veículos
- fix footer vehicle detail
- adiciona unidades de medidas nos itens faltantes
### Changed
- mostrando mapa somente para veículos com alertas
- mostrando o mapa de acordo com a permissão

## [1.0.9]- 2020-05-14
### Added
- salvando recentes no banco de dados local

## [1.0.8] - 2020-05-11
### Added
- add pins ordered
### Fixed
- fix footer recents button and add delete feature
- fix placeholders

## [1.0.7] - 2020-05-06
### Added
- Adicona touch id como opcional
- Possibilita a configuração de seguranças no app podendo modificar preferências do login.
- Suporte ao Face ID
### Fixed
- Corrige algumas interações na biblioteca de login
- Corrige esquema de cores (dark/light) mode
- Redireciona para o login para respostas com código 401
- Correçoes de texto
- Melhoria nas transições de login e logout
### Changed
- Coloca 3 iféns nos campos vazios de detalhes do veículo e coloca o texto centralizado, antes ficava em branco
- Sugestão de copiar o código no próprio teclado, antes só era possível no o botão no TextField
- Possibilita que o usuário entre com o touch id mesmo quando cancelou a operação anteriormente
- Tira o suporte a orientação  landscape.
- reduz o limite de pesquisa recentes

## [1.0.6] - 2020-05-05
### Added
-  Tela de detalhes de veículos com o mapa e lista 

## [1.0.5] - 2020-05-04
### Added
- Header de Alerta do veículo com interação de expanção  
- Adiciona configuração de login
### Fixed
- Corrige cores

## [1.0.4] - 2020-05-01
### Added
-  Tela de detalhes de veículos somente o header 

## [1.0.3] - 2020-04-30
### Added
- Tela de filtros de veículos
### Changed
- Esconde o header na tela de listagem de veículos quando não tem proprietário

## [1.0.2] - 2020-04-27
### Added
- Barra de busca com sugestões dos módulos

## [1.0.1] - 2020-04-23
### Added
- Tela de configurações e adicionado a classe de cores do app
- Modificação do template para os modos [escuro, claro e do sistema]
- Tela de inicio 

## [1.0.0] - 2020-04-22
### Added
- Fluxo  de login
- configuração inicial do projeto 
