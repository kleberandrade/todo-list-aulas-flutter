# Revisão preparada para o Medium

Artigo próprio lido em 17/11/2026: [Criando uma Lista de Tarefas com Flutter](https://medium.com/flutter-comunidade-br/criando-uma-lista-de-tarefas-com-flutter-fc81fa2bac6a).
Link original preservado: http://bit.ly/2jXXU7Q.

**Situação editorial:** a aba deste projeto abriu o artigo completo, identificado como de Kleber Andrade. A interface mostra “Sign in”, “Sign up” e “Unknown user”; não há sessão editorial autorizada disponível. O acesso HTTP direto encontrou Cloudflare, mas a leitura normal pelo Chrome funcionou, sem contornar proteção. Nada foi publicado, nenhuma mensagem enviada e nenhuma inscrição efetuada. A revisão abaixo pode substituir as seções técnicas originais após autenticação do autor, preservando título, subtítulo, introdução histórica, créditos, URL e referências de terceiros. Os trechos de terceiros continuam apenas como referências.

---

# Criando uma Lista de Tarefas com Flutter

Notas de aula do prof. Kleber de Oliveira Andrade

## Atualização das notas de aula

O projeto de 2019 foi modernizado para Flutter 3.41.9 e Dart 3.11.5 com null safety. Vamos continuar trabalhando com uma lista de tarefas e armazenamento SQLite local. Não precisamos de servidor, cadastro ou autenticação para aprender esse fluxo.

A nova versão permite criar, editar, concluir, reabrir e excluir tarefas. Também traz prioridade de 1 a 5, busca por título ou descrição e filtros de tarefas pendentes e concluídas. A lista mostra pendentes primeiro, com a maior prioridade antes; os empates seguem o ID de criação. O progresso considera todas as tarefas, independentemente do filtro.

## Preparando o projeto

Para acompanhar o código final, clone o repositório e abra a pasta:

```sh
git clone https://github.com/kleberandrade/todo-list-aulas-flutter.git
cd todo-list-aulas-flutter
flutter --version
flutter pub get --enforce-lockfile
```

Use Flutter 3.41.9, que inclui Dart 3.11.5. O manifesto exige Dart `>=3.11.0 <4.0.0` e Flutter `>=3.41.0`. O arquivo `pubspec.lock` registra as versões efetivamente resolvidas. Não use mais a restrição Dart 2 do artigo original.

Para executar no Chrome, prepare os dois arquivos do adaptador SQLite Web:

```sh
dart run sqflite_common_ffi_web:setup
flutter run -d chrome --web-port 8765
```

Mantenha a mesma porta entre execuções: o banco Web pertence à origem do navegador. Os dados do navegador são independentes dos dados no Android, iOS e macOS. O adaptador Web é experimental; limpar os dados do site remove o banco. Os dados não são sincronizados com outros dispositivos.

No macOS, use `flutter run -d macos` para depuração. Com Flutter 3.41 e Xcode 27, o build release universal encontra um defeito conhecido do `lipo`; o README registra o comando de arquitetura única para Apple Silicon, sem modificar o SDK compartilhado. Android/iOS precisam das ferramentas e permissões correspondentes. Não há assinatura de distribuição configurada. No ambiente de modernização, as licenças Android ainda estavam pendentes; não confunda build Web ou macOS com teste em telefone.

## Dependências

As dependências principais no `pubspec.yaml` são:

```yaml
environment:
  sdk: '>=3.11.0 <4.0.0'
  flutter: '>=3.41.0'
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  path: ^1.9.1
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2
  sqflite_common: ^2.5.8
  sqflite_common_ffi_web: ^1.1.1
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  sqflite_common_ffi: ^2.4.0
```

`sqflite` mantém o banco nas plataformas nativas. `sqflite_common` oferece a interface do banco usada pelo repositório. `sqflite_common_ffi` permite testar um banco SQLite real no computador. `sqflite_common_ffi_web` adapta SQLite para WebAssembly/IndexedDB. `cupertino_icons` fornece os ícones de controles adaptativos do Flutter. `flutter_localizations` fornece os textos e controles de plataforma em português.

Não precisamos mais de `path_provider`, `flutter_slidable` ou `flushbar`. Ações explícitas com `IconButton` e uma `SnackBar` do próprio Flutter tornam editar, excluir e desfazer acessíveis também por mouse e teclado. `FlatButton` foi substituído pelos botões Material atuais. Não basta atualizar números das dependências: as APIs antigas também precisaram ser trocadas.

## Estrutura do projeto

```text
lib/
  main.dart
  models/task.dart
  data/task_repository.dart
  data/platform_native.dart
  data/platform_web.dart
  state/task_controller.dart
  views/home_page.dart
  views/task_dialog.dart
  views/task_card.dart
```

O modelo representa a tarefa; o repositório cuida do SQL; o controlador organiza o estado; os widgets apresentam os dados e recebem interações. A escolha de plataforma fica em um import condicional, para que o navegador não importe código nativo.

## Modelo Task e validação

Uma tarefa tem ID opcional enquanto ainda não foi salva, título obrigatório, descrição opcional, conclusão e prioridade. Os campos são imutáveis. Construímos outra tarefa ao editar, em vez de alterar o objeto já exibido antes de saber se a gravação funcionou.

O título passa por `trim`, não pode ficar vazio e aceita até 120 caracteres. A descrição aceita até 2000 caracteres e múltiplas linhas; a prioridade fica entre 1 e 5. O formulário mostra os erros, e o domínio valida novamente para que outra entrada também seja protegida.

```dart
final task = Task(
  title: 'Preparar a próxima aula',
  description: 'Revisar o exemplo.\nSeparar as dúvidas da turma.',
  priority: 5,
);
final completed = task.copyWith(isDone: true);
```

No SQLite, `isDone` continua sendo representado por 0 ou 1. A leitura trata títulos nulos ou vazios do banco antigo como “Tarefa sem título” e descrições nulas como texto vazio, sem excluir o registro. Valores antigos maiores que os limites continuam legíveis; para salvar uma edição, ajuste-os aos limites atuais.

Veja a implementação completa de [Task](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/models/task.dart) e os [testes do modelo](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/test/task_test.dart).

## Persistência e migração

O banco continua se chamando `todo_list.db`, a tabela continua `task` e os identificadores nativos do aplicativo foram preservados. Não desinstale o aplicativo para atualizar se quiser manter seus dados.

A versão 2 do esquema acrescenta `priority`, com valor padrão 3 e restrição entre 1 e 5. A migração é executada na transação de atualização do SQLite e preserva IDs, títulos, descrições e conclusão. A chave usa `AUTOINCREMENT` para que uma tarefa nova não reutilize o ID de uma tarefa excluída que ainda possa ser restaurada.

A interface do armazenamento é injetada no controlador. Não precisamos de singleton global para ter uma única instância: criamos o repositório na inicialização e passamos a mesma instância para quem precisa dela. Isso também permite substituir o armazenamento nos testes.

### Criar e editar

```dart
final saved = await repository.save(Task(title: 'Estudar SQLite'));
await repository.save(Task(
  id: saved.id,
  title: 'Estudar SQLite com Flutter',
  description: 'Praticar consultas parametrizadas.',
  priority: 4,
));
```

Ao inserir, o banco devolve o ID. Ao editar, usamos `update` com `where: 'id = ?'` e `whereArgs`. O repositório verifica se a linha realmente existe. As consultas não interpolam valores digitados pelo usuário no SQL.

### Ler e ordenar

```dart
final tasks = await repository.all();
```

A consulta usa a ordem `isDone ASC, priority DESC, id ASC`. O controlador combina essa ordem com os filtros e a busca. A busca encontra texto no título ou na descrição e ignora diferenças entre maiúsculas e minúsculas.

### Excluir e desfazer

```dart
await repository.delete(saved.id!);
await repository.restore(saved);
```

O método original de desfazer tentava executar `update` em uma linha que já não existia. Agora a restauração reinserta o registro com o mesmo ID; repetir a restauração não cria duplicatas. O botão fica disponível na `SnackBar` após a exclusão. Não há lixeira persistente: depois que o aviso é fechado ou o aplicativo reiniciado, esse desfazer deixa de estar disponível.

O SQL antigo `DELETE * from task` não é válido. A versão final não oferece exclusão em massa; cada tarefa pode ser excluída individualmente, com a possibilidade imediata de desfazer.

A implementação completa está em [TaskRepository](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/data/task_repository.dart). Os [testes de persistência](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/test/repository_test.dart) criam um banco na estrutura de 2019, aplicam a migração e verificam reabertura, ordem e restauração.

## Estado e falhas de armazenamento

[TaskController](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/state/task_controller.dart) informa carregamento, gravação em andamento e mensagens de erro. A interface aguarda a gravação antes de atualizar a lista. Enquanto há uma operação em andamento, novas gravações ficam bloqueadas. Se ocorrer um erro, o formulário mantém o rascunho para nova tentativa; a abertura do banco também pode ser tentada novamente.

Não mostramos sucesso antes da confirmação do armazenamento. Essa diferença é importante para que marcar uma tarefa na tela corresponda ao que será lido ao abrir o aplicativo novamente.

## Formulário e lista

[TaskDialog](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/views/task_dialog.dart) usa `Form`, `TextFormField`, validadores e controladores descartados em `dispose`. O título recebe foco inicial, a descrição aceita várias linhas e a prioridade usa `DropdownButtonFormField<int>`.

[HomePage](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/views/home_page.dart) apresenta o resumo de progresso, os filtros, a busca e uma lista de cartões com espaçamento consistente. [TaskCard](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/lib/views/task_card.dart) oferece checkbox de conclusão e botões com descrições para editar e excluir.

A interface usa Material 3, largura de leitura limitada em telas grandes, quebra de conteúdo em telas menores, contraste entre texto e fundo e indicadores textuais além das cores. Os exemplos locais só são adicionados quando a lista está vazia e o usuário escolhe “Experimentar exemplos”. Eles não substituem tarefas existentes.

## Testes e execução

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
dart run sqflite_common_ffi_web:setup
flutter build web --release --no-wasm-dry-run
```

Os testes cobrem validação, migração real de SQLite, reabertura, operações de tarefas, desfazer, filtros, ordem, falhas de gravação e fluxos de widgets. Também há verificação em largura de celular com texto ampliado. O workflow `Flutter` executa análise, testes e build Web; consulte o resultado da execução real no GitHub, sem confundir a existência do workflow com aprovação automática.

## Desafios para continuar a aula

Os desafios antigos de validação, descrição multilinha, prioridade e progresso já fazem parte da implementação. Para continuar praticando:

- Escreva um teste antes de adicionar uma ordenação alternativa.
- Proponha exportação/importação local sem apagar tarefas existentes.
- Estude como tornar o desfazer persistente, com uma lixeira e regras claras de recuperação.
- Compare o armazenamento Web experimental com o SQLite nativo e registre as diferenças de origem, limpeza e suporte.

## Créditos e referências

O projeto continua sob a licença MIT, com autoria de Kleber de Oliveira Andrade (2019). Preserve esses créditos ao reutilizar o código. Os exemplos e o visual novos pertencem ao projeto; as bibliotecas mantêm suas próprias licenças.

- [Código completo](https://github.com/kleberandrade/todo-list-aulas-flutter)
- [Persist data with SQLite — documentação Flutter](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [sqflite — documentação do pacote](https://pub.dev/packages/sqflite)
- [SQLite Web — documentação do adaptador](https://pub.dev/packages/sqflite_common_ffi_web)

Preserve também as referências históricas do artigo original, sem substituir ou editar o conteúdo de seus autores.
