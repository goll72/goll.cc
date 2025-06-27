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
das etapas envolvidas, usando C para exemplificar, uma vez que essa linguagem é tão
difundida na área de programação de sistemas de baixo nível.

## Linguagens de programação e linguagem de máquina

Bem, o que é um programa e como um computador interpreta um programa? Para que um
programa, que nada mais é que um conjunto de instruções para realizar uma determinada
tarefa, seja executado, ele deve ser antes convertido para linguagem de máquina, uma
sequência ordenada de bits (`0`s e `1`s) que recebem um significado especial,
representando o passo a passo dos comandos que devem ser executados.

Percebe-se que seria extremamente difícil e trabalhoso programar diretamente extensas
sequências binárias. Para isso foram criadas abstrações para essas instruções numéricas 
de forma a se assemelhar a linguagem humana. Esse conjunto de abstrações chama-se
linguagem de programação, e sua função principal é facilitar a criação de programas. 

Algumas das linguagens mais comuns atualmente são:

 * Python
 * Java
 * C++
 * Javascript

Após produzir o código em linguagem de alto nível que mais se encaixar com suas
necessidades, é necessário convertê-la para a linguagem de máquina para que possa ser
executada pelo computador. É justamente esse processo de conversão que será abordado.
No entanto, nem todas as linguagens de programação são compiladas em um código de
máquina. Das linguagens listadas acimas, C++ é a única que é geralmente compilada para
código de máquina antes de ser executada.

<!-- será que é muito relevante essa seção? -->

## O que é o computador? 

De forma simplificada, é possível definir um computador como um sistema composto de
uma CPU e memória e outros dispositivos, chamados de dispositivos de entrada/saída,
que o permite conversar com o mundo ao seu redor: internet, armazenamento, áudio,
vídeo, tudo isso é realizado usando dispositivos de E/S.

### A CPU

A CPU se encarrega de executar os comandos, ou instruções, que fazem parte de um prorgrama.
Para tal, deve decodificar a combinação unica de bits que compõe uma instrução, convertendo-os
para sinais de controle na Unidade de Controle (UC), que orquestra todo o comportamento da CPU.
Além disso, a Unidade Lógica e Aritmética (ULA) é um outro componente da CPU, utilizada para
realizar operações matemáticas.

Para executar as instruções, essas instruções devem ser primeiro guardadas em algum lugar:
a memória.

### Registradores, memória, barramentos

Nosso programa precisa ser armazenado em um ambiente no qual podemos acessar de forma 
sequencial e direta, nesse sentido temos a memória, que além de ser usada para guardar 
nossas instruções, podem guardar resultados de operações realizadas pela ULA.

Fazendo a interconexão entre a todos os dispotivos temos os barramentos, que ligam 
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

Logo, com Assembly é possível que possamos ter uma correspondência unica entre um comando
e seu respectivo valor binário, além de ser muito mais legível para nos humanos :-)

## Compilador

Podemos pensar, de maneira bem simplificada, que um compilador é um programa capaz
de transformar um outro programa de uma linguagem de programação , para uma linguagem
mais próxima da linguagem de maquina ou do nosso Assembly.

### Código intermediário

No meio do caminho entre a linguagem de alto nível e Assembly, o compilador pode transformar 
em vários códigos intermediários, e tentar fazer uma série de otimizações e melhorias durante 
esse processo

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
> Se houvesse um programa cujo objetivo fosse uma degustação culinária, o compilador seria um *chef*
> que prepara, planeja e analisa os pratos com antecedência, entregando-os na mesa para a refeição,
> enquanto um interpretador espera você pedir por um prato para prepará-lo a partir de uma receita.
>
> ![](./assets/icons/chip0.svg){.inline-svg}

## Montador
Mesmo que façamos o código de nossa aplicação próximo da linguagem de máquina por meio da 
linguagem Assembly, ainda é necessário fazer a conversão desse mesmo código para instruções binárias em 
que finalmente será possível ser executado pelo computador. Essa conversão é feita pelo montador.

### O que faz um assembler?
O Montador(também chamado de assembler), de acordo com as regras impostas pela arquitetura, consegue identificar
a correspondência de uma instrução em linguagem Assembly e sua respectiva equência binária. Assim, ao analisar
todo o código Assembly, o assembler irá produzir um arquivo binário correspondente o qual poderá ser executado pelo 
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
0000000 |  000111 | 00110 | 000 | 00101 | 0110011
```

## Análise do código

O comando acima executa a função de pegar os valores dentro dos registradores `x6` e `x7`,soma eles
e guarda o resultado em `x5`. Cada pedaço do código binário tem um significado que são importantes para o computador
entender o que deve fazer. 
Por exemplo a sequência de números: `00111`, `00110` e `00101` são as partes do código que representam quais registradores
devem ser utilizados.Se convertermos esses valores binários para decimais veremos que:

 - `00101 = 5`
 - `00110 = 6`
 - `00111 = 7`

Os demais números presentes na sequência servem para indicar ao computador que se trata de uma soma entre registradores.

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

