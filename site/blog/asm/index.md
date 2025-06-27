---
script:
 - ./quiz.js
css:
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
 * JavaScript

Após produzir o código em linguagem de alto nível que mais se encaixar com suas
necessidades, é necessário convertê-la para a linguagem de máquina para que possa ser
executada pelo computador. É justamente esse processo de conversão que iremos nos aprofundar.

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

## Como um computador funciona 

Em bem mais alto nível podemos definir um computador composto pela CPU, memória, e 
 de Entrada e Saída, sendo tais componentes interconectado entre si por barramentos.

### CPU e seu papel na execução de instruções
A CPU possui como principal funcionamento decodificar a combinação unica de bits que 
carregam uma instrução, em sinais de controle na Unidade de Controle (UC), que orquestram 
todo o comportamento da CPU. Além disso no interior da CPU, temos a Unidade Logica Aritmetica 
(ULA), utilizada para realizar operações matemáticas, e por fim a memória para guardar dados 
de tais operações.

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

## Compilador

### As várias análises

### Código intermediário

### Otimização

### Geração de código assembly

> ### Compiladores *vs.* interpretadores
> 
> 

## Montador

### O que faz um assembler?

### Tabela de símbolos

## Linguagem de máquina

### Formato

## Análise do código

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
