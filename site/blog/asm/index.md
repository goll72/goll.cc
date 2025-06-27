---
script:
 - ./quiz.js
css:
 - /code.css
 - ./styles.css
---

# O caminho do código --- do C à máquina

Como um programa escrito em uma linguagem de alto nível, como C, é transformado em
algo que o computador entenda? Você pode não perceber, mas esse programa passa por
várias etapas até chegar nesse ponto. Explicaremos esse processo, mostrando algumas
das etapas envolvidas, usando a linguagem de programação C e a arquitetura RISC-V
para exemplificar.

## Linguagens de programação e linguagem de máquina

Bem, o que é um programa e como um computador interpreta um programa? Para que um
programa, que nada mais é que um conjunto de instruções para realizar uma determinada
tarefa, seja executado, ele deve ser antes convertido para linguagem de máquina, uma
sequência ordenada de bits (`0`s e `1`s) que recebem um significado especial,
representando o passo a passo dos comandos que devem ser executados.

Seria extremamente difícil e trabalhoso programar diretamente extensas sequências
binárias. Para isso foram criadas abstrações para essas instruções numéricas 
de forma a se assemelhar à linguagem humana. Esse conjunto de abstrações chama-se
linguagem de programação, e sua função principal é facilitar a criação de programas. 

Algumas das linguagens mais comuns atualmente são:

 * Python
 * Java
 * C++
 * Javascript

Após produzir o código em linguagem de alto nível que mais se encaixar com suas
necessidades, é necessário convertê-la para a linguagem de máquina para que possa ser
executada pelo computador. É justamente esse processo de conversão que será abordado.
No entanto, nem todas as linguagens de programação são necessariamente compiladas em um
código de máquina. Das linguagens listadas acima, C++ é a única que é geralmente
compilada para código de máquina antes de ser executada.

::: {.quiz-question .single-choice #linguagens}

Qual das seguintes afirmativas está correta?

 - [ ] As pessoas costumam escrever código que o computador já consegue processar.

   [O computador entende apenas código binário, enquanto as pessoas costumam escrever
   em uma linguagem mais natural e compreensível.]{.explanation}
       
 - [ ] As linguagens de programação são semelhantes às linguagens de máquina, de modo que é
 necessário apenas uma simples tradução entre as duas.

   [As linguagens de programação contém letras, palavras e diversas abstrações que auxiliam
   o programador, enquanto a linguagem de máquina consiste apenas de `0`s e `1`s. O processo
   de tradução da linguagem de alto nível para de máquina é muito complexo.]{.explanation}

 - [x] São necessárias diversas etapas para converter o código escrito por humanos para o
 código que o computador entende.

   [Os programadores preferem utilizar linguagens de programação, que são mais próximas da
   linguagem falada, porém computadores apenas processam código binário. Diversas ferramentas
   são utilizadas para converter entre os dois.]{.explanation}

:::

<!-- será que é muito relevante essa seção? -->

## O que é o computador? 

De forma simplificada, é possível definir um computador como um sistema composto de
uma CPU e memória e outros dispositivos, chamados de dispositivos de entrada/saída,
que o permite conversar com o mundo ao seu redor: internet, armazenamento, áudio,
vídeo, tudo isso é realizado usando dispositivos de E/S.

Todo esse sistema deve seguir alguma especificação para que os componentes possam interagir
entre si: em especial, a especificação da CPU quanto à sua estrutura e a estrutura dos
programas que a CPU é capaz de executar é chamada de arquitetura.

### A CPU

<!-- a separação entre as seções provalvemente não ficou muito clara após essa edição -->

A CPU se encarrega de executar os comandos, ou instruções, que fazem parte de um programa.
Para tal, deve decodificar a combinação única de bits que compõe uma instrução (definida pela
arquitetura), convertendo-os para sinais de controle na Unidade de Controle (UC), que
orquestra todo o comportamento da CPU.

Para executar as instruções, essas instruções devem ser primeiro guardadas em algum lugar:
a memória. As instruções podem ser dispostas aleatoriamente na memória, no entanto, sua
execução é sequencial, na maior parte do tempo. Afinal, isso faz mais sentido. Você não
começaria uma receita de bolo no final, né?

Mas, se cada instrução é extremamente simples, como é possível escrever programas tão complexos?
Isso se deve ao conceito de instruções de *branching* (saltos/desvios), que são instruções
especiais que permitem usar uma outra instrução como a próxima instrução a ser executada, em vez
da instrução seguinte na memória. *Branches* podem ser condicionais ou não. *Branches* condicionais
são essenciais para implementar estruturas de controle e repetição, como `if` e `while`, enquanto
as incondicionais permitem reutilizar código, na forma de funções ou procedimentos.

> ### CPUs bizarras
>
> A execução de instruções de modo sequencial é possível graças ao PC (*Program Counter*),
> um registrador que guarda a posição da próxima instrução a ser executada e é incrementado
> periodicamente.
>
> Mas será que o PC é realmente necessário? Se você quisesse construir uma CPU do zero,
> reduzindo ao máximo a quantidade de transistores usada, você poderia usar um LFSR
> (*Linear Feedback Shift Register*), em vez de um somador para obter a posição da
> próxima instrução. A execução deixaria de ser sequencial, passando a ser
> aparentemente aleatória, mas ainda assim previsível.
>
> Na verdade, [já fizeram isso](https://github.com/howerj/lfsr-vhdl)!
>
> ![](./assets/icons/chip0.svg){.inline-svg}

### Registradores, memória, barramentos

Bem, já estabelecemos que um programa precisa ser armazenado de modo que suas instruções
possam ser buscadas eficientemente não apenas de modo sequencial, mas também aleatório:
a memória, além de resolver esse problema, guarda dados e resultados de operações
realizadas pela ULA.

Fazendo a interconexão entre a todos os dispositivos temos os barramentos, que ligam 
fisicamente todos os dispositivos, permitindo a interconexão

### Unidade de controle

A Unidade de Controle (UC) funciona como um maestro de uma orquestra, direcionando 
todas as instruções para suas devidas unidades, além de controlar o fluxo e 
temporização de controle

A ULA pode ser definida como um circuito digital que realiza operações matemáticas 
como (soma, subtração, divisão e multiplicação) além de operações logicas (and, or, xor)

## Assembly: uma receita bem minuciosa

Assembly é nada mais que uma representação em forma de texto do código de máquina, uma 
forma mais simples e legível para nós humanos (ninguém merece ter que ler binário a
todo momento, né?). Por exemplo:

<!-- que arquitetura é essa? -->

```asm
mov a0, 1       ; Move o valor 1 para o espaço de memória A0
```

Isso é análogo a escrever:

```
10111000 00000001 00000000 00000000 00000000
```

Logo, com assembly é possível que possamos ter uma correspondência unica entre um comando
e seu respectivo valor binário, além de ser muito mais legível para nos humanos :-)

## Compilador

Podemos pensar, de maneira bem simplificada, que um compilador é um programa capaz
de transformar um outro programa de uma linguagem de programação mais abstrata e "intuitiva"
para uma linguagem mais próxima da linguagem de maquina ou do nosso Assembly.

### Código intermediário

<!-- muito texto, talvez -->

No meio do caminho entre uma linguagem de alto nível e assembly, o compilador pode emitir
várias representações intermediárias do código, ou seja, converter o código em uma representação
intermediária antes de chegar no código de máquina. Desse modo, é possível realizar uma série
de análises e otimizações do código. Algumas dessas representações intermediárias são:

 - Árvore de Sintaxe Abstrata (em inglês, AST): quebra o código em pedaços, agrupando-os
   de modo que possam ser manipulados facilmente pelo compilador

 - SSA (*Single Static Assignment*): reescreve o código para que toda variável seja
   atribuída uma única vez

Existem diversas otimizações que podem ser aplicadas em um determinado código. Entre elas,
temos:

 - *Constant folding*: substitui expressões constantes, como `2 + 3 * 4`, por seu resultado
   (nesse caso, `14`)

 - Loop rolling/unrolling: expande laços de repetição em um código que repete *n* vezes ou
   vice-versa

 - *Common subexpression elimination* (CSE): encontra subexpressões em comum sem efeitos
   colaterais, calcula seu resultado uma única vez e o reutiliza

Além disso, há outras técnicas como *tail call optimization* (TCO) e *inlining*.
Alocação de registradores e reordenação do código também são tarefas realizadas
pelo compilador, que têm grande impacto no desempenho dos programas gerados.

### Geração de código assembly

<!-- compiladar binária??? -->

Por fim, nosso compiladar alcança seu grande objetivo de transformar a linguagem de alto nível 
no último estágio antes do código binária, o código Assembly

> ### Compiladores *vs.* interpretadores
>
> Como já foi mencionado, compilar não é a única forma de executar um programa (fazer algo útil
> com o seu computador). É possível também "interpretar": nesse caso, não é gerado código de máquina;
> o código do programa a ser interpretado é lido e a conversão para instruções em linguagem de máquina
> é feita na hora de executá-lo. Um programa que interpreta outro programa é chamado de interpretador.
>
> <!-- a analogia do engenheiro ficou legal também, mas talvez não muito realista -->
> <!-- já essa pode ter ficado meio confusa -->
>
> Se houvesse um programa cujo objetivo fosse uma degustação culinária, o compilador seria um *chef*
> que prepara, planeja e analisa os pratos com antecedência, entregando-os na mesa para a refeição,
> enquanto um interpretador espera você pedir por um prato para prepará-lo a partir de uma receita.
>
> ![](./assets/icons/chip0.svg){.inline-svg}

## Montador

Mesmo tendo o código de nossa aplicação próximo da linguagem de máquina por meio do assembly, ainda é
necessário fazer a conversão desse mesmo código para a sequência binária que um computador será capaz
de processar. Essa conversão é feita pelo montador.

### O que faz um assembler?

O montador (também chamado de *assembler*), de acordo com as regras impostas pela arquitetura, consegue
identificar a correspondência de uma instrução em linguagem assembly e sua respectiva sequência binária.
Assim, ao analisar todo o código Assembly, o assembler irá produzir um arquivo binário correspondente o qual poderá ser executado pelo 
computador.

## Linguagem de máquina

Mas porquê a linguagem de máquina é tão importante e necessária? Bom, isso ocorre devido ao funcionamentos dos
circuitos eletrônicos presentes no computador. Os circuitos podem ter apenas dois estados:

1. Sem corrente elétrica(0)
2. Com corrente elétrica(1)

Com isso é muito benéfico representar esses estados com os valores 0 e 1. Por isso que a única linguagem que o
computador entende é o binário, que vai indicar onde deve interromper a corrente e onde deve passar corrente nos
componentes do computador. Essa sequencia de 0´s e 1´s que indicam a execução de um programa é chamado de
linguagem de máquina

### Formato

Vamos ver alguns formatos de instruções presentes em uma arquitetura conhecida chamada RISC-V:

```asm
add x5, x6, x7   # x5 = x6 + x7
```

Transformando em binário:

```
00000000011100110000001010110011
```

Formato de interpretação do binário:

```
0000000 | 00111 | 00110 | 000 | 00101 | 0110011
          ^^^^^   ~~~~~         -----
```

## Análise do código

O comando acima executa a função de pegar os valores dentro dos registradores `x6` e `x7`,soma eles
e guarda o resultado em `x5`. Cada pedaço do código binário tem um significado que são importantes para o computador
entender o que deve fazer. 
Por exemplo as sequências `(-)`, `(~)` e `(^)` são as partes do código que representam
quais registradores devem ser utilizados. Se convertermos esses valores binários para decimal, obtemos:

 - `00101` = 5
 - `00110` = 6
 - `00111` = 7

Os demais números presentes na sequência servem para indicar ao computador que a instrução se trata
de uma soma entre registradores.

## Quer saber mais?

::: {.quiz-question .multiple-choice}

Lorem ipsum dolor sit amet. Consectetur adipising elit.

 - [ ] Wrong answer

   [Você está errado porque eu estou correto]{.explanation}

 - [x] Correct answer

   [Tá certo. Fonte: vozes da minha cabeça]{.explanation}

 - [x] Correct answer

   [Tá certo. Fonte: vozes da minha cabeça]{.explanation}
      
 - [ ] Wrong answer

   [Você não sabe o algoritmo]{.explanation}

:::

::: {.quiz-question .single-choice #bar}

Lorem ipsum.

 - [x] Correct answer

   [vvvvvv]{.explanation}
       
 - [ ] Wrong answer

   [xxxxxx]{.explanation}

 - [ ] Wrong answer

   [aaaaaa]{.explanation}

:::

<!-- não há necessidade de uma seção dedicada para referências (use footnotes Markdown) -->

