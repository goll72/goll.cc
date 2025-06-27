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

Podemos definir um Assembly como uma linguagem de montagem, como se fosse uma notação 
mais simples e legível para nós humanos (porque ninguém merece ter que ler binário em 
todo momento né) por exemplo:

MOV A0, 1       ; Move o valor 1 para o espaço de memória A0
isso é análogo em escrever:
10111000 00000001 00000000 00000000 00000000

Logo, com Assembly é possível que possamos ter uma correspondência unica entre um comando
e seu respectivo valor binário, além de ser muito mais legível para nos humanos :-)

## Compilador

Podemos pensar de maneira bem simplificada que um compilador é um transformador de uma 
linguagem de programação que é mais textualmente entendida, por uma linguagem mais próxima 
da linguagem de maquina ou do nosso Assembly.

### Código intermediário

No meio do caminho entre a linguagem de alto nível e Assembly, o compilador pode transformar 
em vários códigos intermediários, e tentar fazer uma série de otimizações e melhorias durante 
esse processo

### Geração de código assembly

Por fim, nosso compiladar alcança seu grande objetivo de transformar a linguagem de alto nível 
no último estágio antes do código binária, o código Assembly

### Compiladores *vs.* interpretadores

Uma curiosidade que pode aparecer é a diferença entre dois grandes rivais, Compilador contra 
interpretador. De forma bem resumida também podemos pensar que o compilador é como se fosse um engenheiro 
que projeta e entrega um prédio pronto, com o cliente apenas para usar, ou seja, o compilador 
faz todo o processo por trás e entrega o resultado depois de tudo feito, enquanto o interpretador 
é como se fosse um mestre de obras que vai construindo o prédio passo a passo com o cliente 
assistindo, logo, o interpretador vai executando linha por linha de forma imediata e executando

Sobre quem é o melhor, vai depender de vários contextos e seus objetivos

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
