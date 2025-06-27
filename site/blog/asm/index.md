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

Percebe-se que seria extremamente difícil

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
 - [x] Correct answer
 - [x] Correct answer
 - [ ] Wrong answer

:::

::: {.quiz-question .single-choice #bar}

Lorem ipsum.

 - [x] Correct answer
 - [ ] Wrong answer
 - [ ] Wrong answer

:::

<!-- não há necessidade de uma seção dedicada para referências (use footnotes Markdown) -->
