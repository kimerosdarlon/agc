#  Sinesp Agente de Campo
[![Build status](https://build.appcenter.ms/v0.1/apps/5b92ad16-b353-45f3-9d08-5305fc7b1a2f/branches/feature%2Ftest_app_center/badge)](https://appcenter.ms)

## Rodar o projeto
Este projeto utiliza cocoa `pods` para fazer o gerenciamento das dependência, e estamos utilizando além de depências públicas, 
uma dependência privada, que é a lib de SSO. Isso faz com que alguns passos a mais sejam necessários para rodar o projeto.
Devemos adicionar um `repo` que aponte para a url do repositório git onde se encontra a lib de SSO.

```bash
pod repo add REPO_NAME SOURCE_URL
```
- REPO_NAME: O nome que você dará ao seu repositório, pode ser qualquer nome que seja fácil de identificar a qual repositório ele se refere.
- SOURCE_URL: Url do repositório git onde o código está hospedade.

O comando será algo do tipo:

```bash
pod repo add seguranca https://gitlab.com/projeto-senasp-mj/sinesp-seguranca-oauth2-ios/
```
Feito isso, agora ;e necessário baixar as dependências do projeto, para isso execute o comando `pod install` na raiz do projeto. 
Caso você não esteja familiarizado com o cocoa pods eu aconselho a leitura da documentação neste [link](https://cocoapods.org).

Depois que estes passos forem executados, abra o arquivo `SinespAgenteCampo.xcworkspace`, você pode fazer isso manualmente ou executando a linha de comando `open SinespAgenteCampo.xcworkspace`. 

## Módulos
Esse projeto está dividido em alguns módulos:
- [Logger](Logger): Responsável por fazer os logs do projeto.
- [RestClient](RestClient): Responsável pela camada de requisição, assim como realizar a transformação de Objeto para JSON e virse versa. 
- [AgenteDeCampoModule](AgenteDeCampoModule): Define as interfaces que um módulo precisa ter para ser suportado pelo projeto raiz
- [UIAgenteDeCampo](UIAgenteDeCampo): Definição dos elementos de interface, como Cores, Fonts e Components compartilhados
- [AgenteDeCampoCommon](AgenteDeCampoCommon): Aqui se encontra regras que são inerentes ao projeto como um todo
- [CoreDataModels](CoreDataModels): Todos os modelos suportados pelo CoreData, assim como o CoreDataManager 
- [Vehicle](Vehicle): Módulo de veículos
- [Warrant](Warrant): Módulo de Mandados
- [OcurrencyBulletin](OcurrencyBulletin): Módulo de BO

## Adicionar um novo módulo

Todo módulo é deve implementar o protocolo `Module` .  Foi optado que os módulos seriam [Framework](https://www.raywenderlich.com/5109-creating-a-framework-for-ios)

```swift
public protocol Module {

    /// Nome do módulo, este é o nome que aparece na collection que fica na tela de Home
    var name: String { get }

    /// Um array com os patterns que o módulo aceita. Ex placa ["^[a-zA-Z]{3}\\D{0,3}\\d{4}$", "^[a-zA-Z]{3}\\D{0,3}\\d\\w\\d{2}$"]
    var patterns: [String] { get }

    /// O nome da imagem queirá aparecer na tela de home. A imagem deve está no Assets
    var imageName: String { get }

    /// Permissão necessária para acessar o módulo
    var role: String { get }

    /// O Controller que deve ser apresentado quando o item da search for selecionado
    var controller: SearchApiResultController.Type { get }

    /// O controller que é deve ser apresentado quando um item da collection for selecionado
    var filterController: ModuleFilterViewControllerProtocol.Type? { get }

    /// Você pode usar essa flag para desabilitar o módulo quando este ainda está em desenvolvimento, utilize a classe FeatureFlag para isso
    var isEnable: Bool { get }


    /// Deve retornar o dicionário de parâmetros de busca no servidor, dado um determinado texto de busca
    /// - Parameter text: O texto em que o usuário digitou na search bar
    func getParamsFor(text: String) -> [String: Any]


    /// Retorna as informações que serão mostradas na parte superior da tela de filtros. Esse método é invocado em dois momentos distintos.
    /// Sendo um quando o o usuário faz a busca na search ou na tela de filtros e o outro quando o usuário seleciona algum item do histórico
    /// - Parameters:
    ///   - text: O texto em que o usuário digitou na search bar
    ///   - query:
    func getInfoFor(text: String, query: [String: Any]?) -> [String: String]

    /// Retorna true se o texto passado casa com algum valor de regex retornado pelo `patterns`.
    /// Não é necessário implementar este método, a não ser que seja detectado alguma inconsistência na implementação.
    /// - Parameter text: texto digitado pelo usuário na search bar
    func matches(in text: String) -> Bool


    /// Retorna um array de ações que podem ser executadas em um context menu.
    /// - Parameters:
    ///   - text: Texto selecionado para executar a ação
    ///   - names: um array com os nomes dos módulos que devem desconsiderar a criação da ação.
    func getActionsFor(text: String, exceptedModuleNames names: [String] ) -> [UIAction]

}
```
