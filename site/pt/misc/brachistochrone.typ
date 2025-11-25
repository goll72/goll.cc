#import "/lib/lib.typ": *

#import "@preview/zero:0.5.0": zi

#let m = zi.declare("m")
#let s = zi.declare("s")
#let m-s2 = zi.declare("m/s^2")
#let kg = zi.declare("kg")

#show: page
#show: article

= Demonstração --- Curva braquistócrona

A curva braquistócrona é a curva que reduz o tempo necessário para
um corpo se deslocar de um ponto a outro sob influência da gravidade.

Clique #link("./brachistochrone/demo")[aqui] para ver uma simulação física dessa curva,
que permite comparar o tempo que uma bola com raio $r = 1/(2 sqrt(pi)) #m()$
e densidade $mu = 4$ (ou seja, massa $m = #kg(1)$) leva para realizar
uma trajetória seguindo uma curva braquistócrona e uma linha reta.

#quote[
  Nas condições ideais, considerando $m = #kg(1)$ e $g = #m-s2(9.81)$, o tempo que uma
  massa puntiforme levaria para ir de $(0, 10)$ até $(10, 0)$ (parâmetros usados por padrão
  na simulação) é de aproximadamente #s(1.84). O tempo medido pela simulação certamente será
  maior por diversas razões, a mais notória sendo o fato de uma massa puntiforme não estar sendo
  usada.
]

A simulação foi feita em Rust, usando Bevy e Rapier, implementando um algoritmo
baseado em Programação Dinâmica para aproximar a curva braquistócrona. O
código fonte da simulação pode ser acessado clicando
#link("https://github.com/goll72/brachistochrone")[aqui].
É necessário usar um navegador com suporte a JavaScript, WebAssembly e WebGL para
rodar a simulação.
