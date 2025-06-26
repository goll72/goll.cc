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

Updated upstream
## Como um computador funciona 
=======
## Visão Geral da Arquitetura de Computadores 
Em bem mais alto nível podemos definir um computador composto pela CPU, memória, e dispositivos de Entrada e Saída, sendo tais componentes interconectado entre si
>>>>>>> Stashed changes

### CPU e seu papel na execução de instruções
A CPU possui como principal funcionamento decodificar o opcode (combinação unica de bits que carregam uma instrução) em sinais de controle na Unidade de Controle (UC), que orquestram todo o comportamento da CPU. Além disso no interior da CPU temos a Unidade Logica Aritmetica (ULA), utilizada para realizar operações matemáticas, além da memória para guardar dados de tais operações.

 Updated upstream
### Registradores, memória, barramentos

Nossa programa precisa ser armazenado em um ambiente no qual podemos acessar de forma sequencial e direta, nesse sentido temos a memória, que além de ser usada para guardar nossas instruções, podem guardar resultados de operações realizadas pela ULA.

Fazendo a interconexão entre a todos os dispotivos temos os barramentos, que levam dados 

### Unidade de controle

A Unidade de Controle (UC) funciona como um maestro de uma orquestra, no caso, ela direciona todas as instruções para todas as unidades de um computador, além de controlar o fluxo e temporização de controle

A ULA pode ser definida como um circuito digital que realiza operações matemáticas como (soma, subtração, divisão e multiplicação) além de operações logicas (and, or, xor)

=======
### Conceito de memória, barramentos
Nossa programa precisa ser armazenado em um ambiente no qual podemos acessar de forma sequencial e direta, nesse sentido temos a memória, que além de ser usada para guardar nossas instruções, podem guardar resultados de operações realizadas pela ULA.

Fazendo a interconexão entre a todos os dispotivos temos os barramentos, que levam dados 

### Unidade de controle (UC) e unidade lógica e aritmética (ULA)

A Unidade de Controle (UC) funciona como um maestro de uma orquestra, no caso, ela direciona todas as instruções para todas as unidades de um computador, além de controlar o fluxo e temporização de controle

A ULA pode ser definida como um circuito digital que realiza operações matemáticas como (soma, subtração, divisão e multiplicação) além de operações logicas (and, or, xor)
>>>>>>> Stashed changes

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

<!-- disassemblers (ex: objdump, Ghidra) -->

 *    *    *

Updated upstream
<!-- considerações finais (importância para a sociedade(?), programadores, etc.) -->

## Quer saber mais?
=======
### Exemplos

### Quiz Codigo Binário

## Exemplos e Feramentas práticas

### Como usar um desassemblador (ex: objdump, Ghidra)

### Como compilar um programa em C para gerar o .s (assembly) e .o (binário)

### Análise de um trecho de código em todas as camadas

### Quiz Ferramentas práticas

## Considerações finais e importância do tema para nossa sociedade

### A importância desse conhecimento para programadores

### Impacto em performance e segurança

### Possibilidades de aprofundamento (compiladores, arquitetura, engenharia reversa)

### Quiz revisão geral

## Referência
Vozes da minha cabeça
>>>>>>> Stashed changes

<!-- compiladores, arquitetura, engenharia reversa… -->
