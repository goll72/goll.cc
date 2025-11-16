#import "/lib/lib.typ": mono-diagram

#import "@preview/cetz:0.4.2"

#let s-definition = $ s = 2^(2k-2i-2) + sum_(m=0)^(i-1) q_(k-m-1) dot.c 2^(2k-i-m-1) $

#let s-binary-repr = {
  let dotdot0 = $ 0 thin dots.c thin 0 $
  let q_1_to_i = $ overbrace(q_(k-1) quad dots.c quad q_(k-i), i) $

  show grid.cell: it => {
    if it.y == 1 {
      v(4pt); it
    } else if it.y == 0 and it.x != 1 {
      v(12pt); it
    } else {
      it
    }
  }

  $
    #grid(align: center, columns: 7, rows: (22pt, 18pt, 14pt, 14pt), ..(
        dotdot0, grid.cell(x: 1, y: 0, colspan: 3, q_1_to_i), $ 0 $,           $ 1 $, dotdot0,

             [],         $ arrow.t $, [],        $ arrow.t $,    [],     $ arrow.t $,      [],
             [],   $ 2^(2k-2i+i-1) $, [],      $ 2^(2k-2i) $,    [], $ 2^(2k-2i-2) $,      [],
             [],       $ \(m = 0\) $, [],  $ \(m = i - 1\) $,    [],              [],      []
      )
    )
  $
}

#let n_i-definition = $ n_i = sum_(m=0)^(i-1) q_(k-m-1) dot.c 2^(k-m-1) + 1 $
#let s-as-sum-of-D = $ s = sum D(n_i, 2^(k-i-1)) $

#let sum-of-D-is-s = $ 
  sum D &= sum_(t=1)^(2^(k-i-1)) (2(n_i + t - 1) - 1) \
        &= 2 dot.c 2^(k-i-1) dot.c n_i + 2^(k-i-1) (2^(k-i-1) + 1) - 3 dot.c 2^(k-i-1) \
        &= 2^(2k-2i-2) + 2^(k-i) dot.c n_i - 2^(k-i) \
        &= 2^(2k-2i-2) + 2^(k-i) (sum_(m=0)^(i-1) q_(k-m-1) dot.c 2^(k-m-1) + 1) - 2^(k-i) \
        &= s
$

#let bdt = {
  show: mono-diagram
      
  cetz.canvas({
    import cetz.draw: *
    import cetz.tree: tree

    set-ctx(ctx => ctx + (dashed: true))

    tree(
      (
        $ 1 + 3 + 5 + 7 $,
        (
          $ 1 + 3 $,
          ($ 1 $,), ($ 5 $,)
        ),
        (
          $ 9 + 11 $,
          ($ 9 $,), ($ 13 $,)
        ),
      ),

      direction: "down",

      draw-edge: (from, to, ..) => {
        let (a, b) = (from + ".center", to + ".center")

        get-ctx(ctx => {
          line((a, .4, b), (b, .4, a),
            stroke: (dash: if ctx.dashed { "dashed" } else { "solid" })
          )
        })

        set-ctx(ctx => ctx + (dashed: not ctx.dashed))
      }
    )
  })
}
