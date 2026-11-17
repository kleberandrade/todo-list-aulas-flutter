# Flutter To-Do List

[![Language: Dart](https://img.shields.io/badge/Language-Dart-0175C2)](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/pubspec.yaml)
[![Framework: Flutter](https://img.shields.io/badge/Framework-Flutter-02569B)](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/pubspec.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-555555)](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/LICENSE)

Flutter classroom app for managing everyday tasks.

## Getting started

- Select a Flutter release whose bundled Dart SDK satisfies the manifest constraint, then run the commands below from the repository root.

```sh
flutter pub get
flutter run
```

- If the app depends on Firebase or another external service, configure your own service project using the dependencies and original notes; credentials are not supplied by this guide.

## Recorded requirements

- Dart SDK constraint from [`pubspec.yaml`](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/pubspec.yaml): `>=2.1.0 <3.0.0`.

## Repository map

- [lib](https://github.com/kleberandrade/todo-list-aulas-flutter/tree/master/lib)
- [android](https://github.com/kleberandrade/todo-list-aulas-flutter/tree/master/android)
- [ios](https://github.com/kleberandrade/todo-list-aulas-flutter/tree/master/ios)

## Validation status

This update documents the tracked source and project metadata. It does not certify a successful build, device test or compatibility with a current toolchain. Follow any project-specific validation instructions in the original material.

## License and attribution

See [LICENSE](https://github.com/kleberandrade/todo-list-aulas-flutter/blob/master/LICENSE) and any notices accompanying third-party code and assets. This documentation update does not change licensing or authorship.

---

## Original project material

# Lista de Tarefas

Aplicativo para gerenciar as tarefas do dia-a-dia criado para disciplina de Programação Mobile.

Tutorial de criação deste app: http://bit.ly/2jXXU7Q

<p align="center">
    <img src="https://miro.medium.com/max/1440/1*oUhhTFGunBMuh4Av-7rR7A.png" width="800"/>
</p>

## Como clonar e importar

-   Faça um fork do projeto
-   Abra o terminal do Visual Studio Code
-   Digite (troque kleberandrade pelo nome do seu usuários): git clone https://github.com/kleberandrade/todo-list-aulas-flutter todo_list

## Desafios

-   Na lista de tarefas, adicionar divisões entre as linhas (use [ListView.separated](https://api.flutter.dev/flutter/widgets/ListView/ListView.separated.html))
-   Adicionar validações no cadastro de uma atividade (lembre-se que é preciso utilizar o widget [TextFormField](https://api.flutter.dev/flutter/material/TextFormField-class.html) para isso)
-   Campo descrição precisar aceitar múltiplas linhas
-   Criar um campo para nível de prioridades que aceita valores entre 1 (baixa prioridade) e 5 (alta prioridade). Representar isso no card da forma como achar mais interessante.
-   Adicionar um [PercentIndicator](https://pub.dev/packages/percent_indicator) circular na barra de navegação para indicar a porcentagem de tarefas concluídas

## Licença

    Copyright 2019 Kleber de Oliveira Andrade
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
