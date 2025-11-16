#import "/lib/lib.typ": *
#import "/lib/common/blog/restoring-sqrt.typ": *

#show: page
#show: article

= Raiz quadrada por restauração

Como o nome já diz, esse algoritmo pode ser usado para calcular a parte
inteira da raiz quadrada de um número inteiro. Funciona de forma similar
à divisão por restauração, de modo iterativo, onde cada iteração nos
deixa mais próximos do resultado final. Mas como e por quê esse algoritmo
funciona?

Essa é a pergunta que vamos responder hoje, especificamente para base 2 (binário).
De uma forma bem _peculiar_, talvez.

*P.S.* _A versão em inglês dessa página tem alguns links para páginas com mais explicações._

== Descrição

Dado um número $X$ representado em binário, podemos adicionar um zero à esquerda
se necessário, de modo que esse número tenha $2k$ dígitos, para algum inteiro $k$.
Após fazer isso, podemos considerar $Q$ e $R$ que satisfaçam $X = Q^2 + R$, de modo
que $R >= 0$ e $Q$ seja maximizado (essa é uma forma de definir a raiz quadrada para
inteiros). $Q$ terá $k$ dígitos:

$ X "é no máximo" 2^(2k) - 1 < 2^(2k) = (2^k)^2 $

Assim, $q+(k-1)$ é o bit mais significativo (MSB) na representação de binária de $Q$,
e $q_0$ é o menos significativo (LSB). O primeiro passo do algoritmo é dividir $X$ em
pares de bits. Começamos do par mais significativo e subtraimos 1. Se o resultado for
maior ou igual a $0$, então $q_(k-1) = 1$, caso contrário, $q_(k-1) = 0$ e o valor
anterior desse par é restaurado.

Daí, o resultado obtido é concatenado com o próximo par e tentamos subtrair
$overline(0q_(k-1)01)$ (a barra representa concatenação). O resultado irá determinar
$q_(k-2)$. O próximo passo seria agrupar novamente com o próximo par e subtrair
$overline(00 q_(k-1)q_(k-2) 01)$, encontrando $q_(k-3)$ etc. Esse processo é repetido
até que não haja mais pares. O resto da última subtração corresponde a $R$.

== Uma possível solução

Um fato curioso: todos os números quadrados podem ser expressos como uma soma de
números ímpares consecutivos, começando do 1.

$ sum_(n=1)^p (2n - 1) = p^2 $

Isso permite implementar uma solução bem simples, que consiste em subtrair ímpares
de $X$ sucessivamente, mantendo uma contagem de quantos ímpares foram subtraídos e
do valor de $X$. Ao final, quando não for mais possível subtrair, a quantidade de
ímpares subtraídos será $Q$ e o resto será $R$. Mas esse processo é bem ineficiente.
Dá pra melhorar bastante, e é isso que esse algoritmo faz: subtrai vários números
ímpares, em vez de apenas um, por vez.

== Uma demonstração

Vamos tentar entender o que está acontecendo em cada iteração. Assumindo que estamos
em uma determinada iteração e todos os bits de $Q$ determinados até então são $0$,
podemos concluir que o valor subtraído na iteração atual é uma potência de 4. No caso
base ($k = 1$), subtraímos $1$. Quando $k$ é incrementado, o valor sendo subtraído na
primeira iteração é deslocado para a esquerda em duas unidades, que é o mesmo que
multiplicar por $2^2 = 4$. E como $4^n = 2^(2n) = (2^n)^2$, o valor sendo subtraído
nesse caso é uma soma de números ímpares consecutivos, começando em $1$ (com $2^n$
termos).

Ou seja, isso nos mostra que a quantidade de números ímpares que compõem essa soma
é reduzida pela metade a cada iteração. Mas e se algum bit de $Q$ for diferente de $0$?
Isso implica que foi possível subtrair uma certa quantidade de números ímpares, logo,
devemos avançar na sequência de alguma forma (não começar mais no $1$), para que esses
números não sejam subtraídos novamente. Podemos mostrar que adicionar os bits de $Q$
ao subtraendo serve exatamente para resolver esse problema.

Considerando que estamos na $i$-ésima iteração (onde a primeira seria $0$ e a última
$k-1$), o valor sendo subtraído nessa iteração, que iremos chamar de $s$, será dado por:

#s-definition

O primeiro termo corresponde à constante $1$, enquanto o segundo corresponde aos
bits de $Q$ de iterações anteriores. A ilustração a seguir mostra a representação binária
de $s$:

#s-binary-repr

Vamos denotar por $D(n, m)$ o conjunto ou subsequência de números ímpares começando
no enésimo número com $m$ entradas. Para cada bit de $Q$ que for $1$, temos que pular
metade da quantidade de números ímpares subtraída na iteração correspondente. Podemos
deduzir, então, que o índice inicial $n_i$ (começando em $1$, pois usaremos números
ímpares da forma $2n - 1$) será:

#n_i-definition

E se assumirmos, por enquanto, que a quantidade de números ímpares subtraídos
sempre for reduzida pela metade a cada iteração, independentemente dos bits
anteriores de $Q$, então o valor subtraído na $i$-ésima iteração será dado por:

#s-as-sum-of-D

Podemos mostrar que vale a recíproca, ou seja, partindo de $sum D$, chegaremos a $s$,
na forma que foi definido anteriormente:

#sum-of-D-is-s

Mas por quê o algoritmo tem essa estrutura? Por que usamos binário? Embora outras bases
possam ser usadas, essa base deixa o algoritmo mais simples e é muito útil, ao permitir
seu uso em computadores. Note que $abs(D)$ é uma função exponencial de $i$: podemos
interpretar que esse algoritmo faz uma busca binária no espaço de valores possíveis
para $Q$, que pode assumir $2^k$ valores distintos, e cada um deles deve ser possível
de se alcançar partindo do ponto inicial. Dessa forma, a complexidade desse algoritmo é
$O(k)$.

#quote[
  === Curiosidade

  Como cada bit na representação binária de $Q$ é atribuído uma única vez, esse algoritmo
  pode ser implementado usando apenas circuitos combinacionais (que foi como eu descobri
  esse algoritmo originalmente)
]

O diagrama a seguir mostra uma árvore de decisão binária representando todas as escolhas
que o algoritmo pode tomar para $k = 3$, partindo do ponto inicial. Cada nível é uma
iteração. Uma linha pontilhada indica que a subtração resultou em um valor negativo e o
valor anterior foi restaurado. Cada nó mostra o valor subtraído naquela iteração, como
uma soma de ímpares consecutivos. Note que as folhas não são mostradas; seria possível
estender esse diagrama. Além disso, cada caminho da raiz até uma folha corresponde a um
valor diferente para $Q$.

#bdt
