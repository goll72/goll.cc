---
script:
 - ./quiz.js
css:
 - /code.css
 - ./styles.css
 - ./cse-animation.css
description: Veja como um programa escrito em uma linguagem de alto nível é convertido em código de máquina
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

Qual das seguintes afirmatições sobre código e linguagem está correta?

 - [ ] As pessoas costumam escrever código que o computador já consegue processar.

   [O computador entende apenas código binário, enquanto as pessoas costumam escrever
   em uma linguagem mais natural e compreensível.]{.explanation}
       
 - [ ] As linguagens de programação são semelhantes às linguagens de máquina, de modo que é
       necessário apenas uma simples tradução entre as duas.

   [As linguagens de programação contém letras, palavras e diversas abstrações que auxiliam
   o programador, enquanto a linguagem de máquina consiste apenas de 0s e 1s. O processo
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
uma CPU e memória, que conversa com o mundo ao seu redor por meio de dispositivos de
entrada/saída. Conectividade com a internet, armazenamento, áudio, vídeo:
tudo isso e muito mais é realizado usando dispositivos de E/S.

Todo esse sistema deve seguir alguma especificação para que os componentes possam interagir
entre si. Em especial, a especificação da CPU quanto à sua estrutura e a estrutura dos
programas que a CPU é capaz de executar é chamada de arquitetura.

### Arquitetura de Computador

A arquitetura de um computador é como o projeto ou o manual que define como todas as partes do computador trabalham juntas.
Ela explica:

* como o processador (CPU) entende e executa comandos,

* como ele se comunica com a memória para buscar dados e instruções,

* como o computador se conecta com outros dispositivos, como teclado, mouse e tela.

Cada tipo de arquitetura tem um “jeito próprio” de organizar essas partes e um conjunto de instruções que o processador entende. É por isso que programas feitos para um tipo de processador nem sempre funcionam em outro sem adaptações.
Alguns exemplos de arquitetura como a x86, ARM ou RISC-V, cada uma com seus conjunto de instruções ou ISA — Instruction Set Architecture.

> Dá para pensar assim:
>
>    A arquitetura é como as regras e o idioma que o computador fala internamente.
>    Para o programa rodar direitinho, ele precisa ser traduzido para esse idioma específico que o processador entender.
>![](./assets/icons/chip0.svg){.inline-svg}

### A CPU

<!-- a separação entre as seções provalvemente não ficou muito clara após essa edição -->

A CPU se encarrega de executar os comandos, ou instruções, que fazem parte de um programa.
Para tal, deve decodificar a combinação única de bits que compõe uma instrução (definida pela
arquitetura), convertendo-os para sinais de controle na Unidade de Controle (UC), que
orquestra todo o comportamento da CPU.

Para executar as instruções, elas devem ser primeiro guardadas em algum lugar: a memória.
A execução é sequencial, na maior parte do tempo, ou seja, a próxima instrução a ser executada
corresponde à próxima posição da memória. Bem intuitivo, não?

Mas, se cada instrução é extremamente simples e a execução é sequencial, como é possível escrever
programas tão complexos? Isso se deve ao conceito de instruções de *branching* (saltos/desvios),
que permitem continuar a execução a partir de outra instrução, em vez da instrução seguinte na
memória. *Branches* podem ser condicionais ou não, sendo os *branches* condicionais essenciais
para implementar estruturas de controle e repetição, como if e while, enquanto as
incondicionais permitem reutilizar código, na forma de funções ou procedimentos.

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

### Registradores, memória e barramentos

Bem, já estabelecemos que um programa precisa ser armazenado de modo que suas instruções
possam ser buscadas eficientemente tanto de forma sequencial quanto ao usar saltos.
A memória, além de resolver esse problema, guarda dados e resultados de operações
realizadas pela ULA.

No entanto, a memória é lenta; por isso a CPU armazena internamente valores que estão
sendo usados em operações em um banco (conjunto) de registradores. Esses registradores,
além do PC e do IR (*Instruction Register*), que guarda a instrução sendo executada,
são denominados registradores de propósito geral (ou GPRs), sendo usados como operandos
e resultados de operações lógicas e aritméticas, bem como para endereçar a memória.

Para que os diversos componentes do computador possam interagir entre si, é necessário
que haja conexões entre eles, de modo a permitir a transmissão de informações. Essas
interconexões são chamadas de barramentos, que servem para transmitir dados, endereços
ou sinais de controle.

### Unidade de controle

A Unidade de Controle (UC) funciona como um maestro de uma orquestra, direcionando 
todas as instruções para suas devidas unidades, além de controlar o fluxo e 
temporização de controle

A ULA pode ser definida como um circuito digital que realiza operações matemáticas 
como (soma, subtração, divisão e multiplicação) além de operações logicas (and, or, xor)

::: {.quiz-question .multiple-choice}

Se você entendeu como funciona um computador, assinale quais das seguintes frases estão corretas!

 - [x] As três componentes básicas de um computador são a CPU, a memória e os dispositivos de E/S.

   [Tudo que um computador precisa para poder executar instruções é de uma CPU, onde está o processador,
   e da memória, onde estão os dados e instruções. Além disso, os dispositivos de entrada e saída são
   essenciais para o sistema se comunicar com o usuário.]{.explanation}

 - [x] O conjunto das especificações de como são as estruturas que funcionam com certa CPU, assim como
       as instruções que funcionam nela, são chamadas de arquitetura.

   [Diferentes computadores e processadores funcionam de modos diferentes e, assim, podem
   funcionar com apenas certos tipos de memória, barramentos e, especialmente, um conjunto de
   instruções específico.]{.explanation}

 - [x] Entre os componentes que estão na CPU, há a unidade de controle, a unidade de lógica e aritmética
       e os registradores.

   [Para efetivamente realizar a execução de um programa, a CPU conta com a UC, que decodifica as
   instruções e coordena os outros componentes, a ULA, que realiza operações matemáticas e relacionadas,
   e os registradores, uma memória interna à CPU que conectam-se diretamente à ULA.]{.explanation}
      
 - [ ] O processador recebe as instruções que ele deve executar da memória de maneira sequencial.

   [A unidade de controle (UC) realmente precisa receber instruções vindas da memória, que
   são sequenciais por padrão. Porém, as instruções de branch (desvio), que são comumente
   utilizadas permitem a execução não sequencial de um conjunto de instruções.]{.explanation}

:::

## Assembly

Assembly é nada mais que uma representação em forma de texto do código de máquina, uma 
forma mais simples e legível para nós humanos (ninguém merece ter que ler binário a
todo momento, né?). Veja o seguinte código em RISC-V, por exemplo:

```asm
lw t0, 0(t1)  # Escreve o valor de `t0` na posição de memória apontada por `t1` 
```

A representação dessa instrução em binário é:

```
10000011 00100010 00000011 00000000 00000000
```

Além de nos dar uma correspondência entre "mnemônicas", como `lw`, e uma sequência de
bits que pode ser interpretada pela CPU como uma instrução, o *assembly* permite que
*labels*, ou rótulos, sejam usados juntamente com instruções de *branch* a fim de
indicar para onde o desvio será realizado:

```asm
    li t2, 10
    li t0, 0
repeat:
    addi t0, t0, 1
    blt t0, t2, repeat
```

Além disso, também é possível guardar dados estáticos (que não mudam entre execuções do
mesmo programa), usando diretivas:

```asm
hi:
    .asciz "Olá mundo"
important:
    .word 42
```

Note que esse exemplo, além de diretivas, também usa *labels*, para que seja possível
usar esses dados no código, referindo-se a eles por meio do rótulo correspondente.

## Compilador

Podemos pensar, de maneira bem simplificada, que um compilador é um programa capaz
de transformar um outro programa de uma linguagem de programação mais abstrata e "intuitiva"
para uma linguagem mais próxima da linguagem de maquina ou do *assembly*.

A primeiras etapas para esse processo são a análise lexical e a análise sintática. A primeira é
responsável por remover "lixo" (tudo aquilo que não importa para o compilador), como comentários,
além de separar o código em *tokens* válidos para a linguagem, como `if`, `while`, operadores
matemáticos etc. Quando não é possível formar um *token*, temos um erro de análise lexical. Por
exemplo:

```c
int numero% = 5;
```

O erro nesse código está na presença do `%` no nome da variável, o que não é permitido pela linguagem C.

Após essa análise, é construída uma árvore de sintaxe abstrata, durante a fase de análise sintática.
Nessa fase, é analisada a sintaxe, ou seja, a relação entre os *tokens* e a ordem em que aparecem.
O código a seguir é um exemplo de erro sintático, uma vez que dois literais numéricos não constituem
uma sequência de *tokens* válida nesse contexto:

```c
//  identificador
//      vvv
    int num = 1 3;
//  ^^^     ^ ^ ^
//  tipo    | | |
//          | literais numéricos
//      operador
```

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

 - *Loop rolling*/*unrolling*: expande laços de repetição em um código que repete *n* vezes ou
   vice-versa

 - *Common subexpression elimination* (CSE): encontra subexpressões em comum sem efeitos
   colaterais, faz com que seu resultado seja calculado uma única vez e reutilizado

<!-- sinto muito -->

```{=html}
<div class="code-side-by-side" id="cse">
    <div><pre id="cse_before" class="sourceCode c"><code class="sourceCode c"><span class="dt">int</span> main<span class="op">(</span><span class="dt">void</span><span class="op">)</span> <span class="op">{</span><br>    <span class="dt">int</span> x <span class="op">=</span> <span class="y">y</span> <span class="op">+</span> z <span class="m_w"><span class="op">-</span> w</span><span class="op">;</span><br><br><br>    <span class="cf">if</span> <span class="op">(</span><span class="y_m_w">y <span class="op">-</span> w</span> <span class="op">></span> 0<span class="op">)</span><br>        fazer_algo<span class="op">(</span>x<span class="op">);</span><br><span class="op">}</span></code></pre></div>
    <div><pre id="cse_after" class="sourceCode c"><code class="sourceCode c"><span class="dt">int</span> main<span class="op">(</span><span class="dt">void</span><span class="op">)</span> <span class="op">{</span><br>    <span class="hidden"><span class="dt">int</span> t <span class="op">=</span> y <span class="op">-</span> w;</span><br>    <span class="dt">int</span> x <span class="op">=</span> <span class="hidden">t</span> <span class="op">+</span> z;<br><br>    <span class="cf">if</span> <span class="op">(</span><span class="hidden">t</span> <span class="op">></span> 0<span class="op">)</span><br>        fazer_algo<span class="op">(</span>x<span class="op">);</span><br>}</code></pre></div>
</div>
```

Posicione o cursor do mouse (ou o dedo) sobre o primeiro bloco de código para ver como
um compilador poderia reescrever esse código usando CSE.

Além das técnicas mostradas acimas, há outras, como *tail call optimization* (TCO)
e *inlining*. Alocação de registradores e reordenação do código também são tarefas
realizadas pelo compilador que têm grande impacto no desempenho dos programas gerados.
`gcc` e `clang` são exemplos de compiladores C e C++ capazes de aplicar essas otimizações,
bem como diversas outras.

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

Mesmo tendo o código de nossa aplicação próximo da linguagem de máquina por meio do *assembly*, ainda é
necessário fazer a conversão desse mesmo código para a sequência binária que um computador será capaz
de processar. Essa conversão é feita pelo montador, que pode gerar um arquivo objeto ou um *flat binary*.

A diferença entre um arquivo objeto e um *flat binary* é que o arquivo objeto é estruturado em seções,
contendo diversos metadados que se tornam necessários em um ambiente hospedado. Já um *flat
binary* é uma simples sequência de dados e instruções, cujo objetivo é ser gravado diretamente na
memória para que seja executado. *Flat binaries* são mais comumente usados em sistemas embarcados.

A tarefa de um montador é bem mais simples que a de um compilador: dado um arquivo *assembly*, o montador
deve percorrê-lo, identificando e processando:

 - *Labels*/rótulos: permitem dar um nome à posição de memória[^absolute-relative-remark] do que vier
   após a *label*

 - Diretivas: possuem várias finalidades, desde alterar o alinhamento usado para posicionar código e
   dados na memória, até mesmo definir dados estáticos ou metadados guardados nos arquivos objeto gerados

 - Comentários

 - Mnemônicas: o conjunto de mnemônica e operandos compõe uma instrução (definida pela arquitetura)
   ou uma pseudo-instrução (não existe de fato na arquitetura, é implementada em termos de uma ou mais
   instruções existentes)

[^absolute-relative-remark]: Embora tenhamos mencionado apenas "posições de memória", para simplificar
a explicação, é importante ressaltar que instruções de *branch* podem usar dois modos de endereçamento
de memória: absoluto (que foi abordado) ou relativo. No endereçamento relativo, o endereço é somado ao
conteúdo de outro registrador (geralmente o PC) antes de ser usado, permitindo que menos bits sejam
usados para representar um endereço.

Geralmente, não é necessário realizar análise léxica ou sintática no código *assembly*, pois sua estrutura
é muito rígida e não-ambígua. No entanto, deve-se considerar a possibilidade de usar uma *label* antes
que ela seja definida. Uma possível solução para esse problema é percorrer o arquivo *assembly* duas vezes,
uma vez apenas para calcular os endereços das *labels*, e outra para processá-lo de fato.

Já uma solução menos "gambiarrenta", porém mais complexa, envolve criar relocações ("buracos") no código,
preechendo-os quando necessário.

> ### Curiosidade sobre o Linker
> Um programa pode ser dependente de várias partes, 
> tanto de bibliotecas, como acessos a endereços de memória, e nosso código ou receita principal, logo, precisamos de uma pessoa que possa unir tudo isso e gerar um executável, esse trabalho fica com o Linker (ligador), que gera a nossa ./main

```
Resumo do que discutimos até o momento:
Codigo em C -> Compilador (gcc) -> Assembly (.s) -> Montador (as) -> Objeto (.o) -> Ligador (ld) -> Executável
```

> Uma dica de site para brincar: [Compiler Explorer](https://godbolt.org/)! Lá você pode digitar em C, e vê assembly sendo gerado na horinha, explicando esse caminho que discutimos ;-)


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
00000000 01110011 00000010 10110011
```

Formato de interpretação do binário:

```
0000000 | 00111 | 00110 | 000 | 00101 | 0110011
          ^^^^^   ~~~~~         -----
```

## Análise do código

O comando acima executa a função de pegar os valores dentro dos registradores x6 e x7,soma eles
e guarda o resultado em x5. Cada pedaço do código binário tem um significado que são importantes para o computador
entender o que deve fazer. 
Por exemplo as sequências `(-)`, `(~)` e `(^)` são as partes do código que representam
quais registradores devem ser utilizados. Se convertermos esses valores binários para decimal, obtemos:

 - `00101` = 5
 - `00110` = 6
 - `00111` = 7

Os demais números presentes na sequência servem para indicar ao computador que a instrução se trata
de uma soma entre registradores.

::: {.quiz-question .single-choice #compilador}

Selecione o processo de compilação correto:

 - [ ] Código intermediário -> linguagem de alto nível -> assembly -> código de máquina

   [O código intermediário é um produto da início do processo de compilação da linguagem de alto
   nível, quando ela está sendo processado em uma estrutura que é mais facilmente traduzida ao
   assembly. Ou seja, o intermediário é após a linguagem.]{.explanation}
       
 - [x] Linguagem de alto nível -> código intermediário -> assembly -> código de máquina.

   [Primeiramente, um programador escreve, em uma linguagem de programação (alto nível) o código.
   Então, no processo de compilação, ele passa por um código, ou representação, intermediário para
   se tornar assembly. Finalmente, o montador realiza os processos finais e gera o código binário
   de máquina.]{.explanation}

 - [ ] Linguagem de alto nível -> assembly -> código intermediário -> código de máquina

   [O código intermediário não está entre o assembly e o código de máquina, mas sim entre a
   linguagem e o assembly. Após o assembly, há apenas o código de máquina, não sendo
   necessário uma representação intermediária, já que os dois estão bem próximos.]{.explanation}

:::

## Quer saber mais?


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
