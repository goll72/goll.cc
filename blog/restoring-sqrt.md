---
title: Understanding the Restoring Square Root
description: How the restoring integer square root circuit works
date: 2024-06-16
tags:
    - post
    - latex
---

# Understanding the Restoring Square Root

You may have heard of the restoring integer square root circuit/algorithm before:
I certainly have. And I became puzzled trying to understand how it works.
Even though it's conceptually simple, made up of only subtractor units and
restoring units, it's not really obvious at first sight what it's doing (at
least it wasn't for me). For some reason, this seems to be one of those topics
where if you just try to look it up you will get stuff that will either fly
over your head or be so dumbed down and lackluster, without any explanations,
that it might as well be useless.

Maybe I just don't know how to use a search engine. Anyway, I believe to have found
an intuitive explanation for how and why this circuit works, and now I'd like to
present it to anyone who might be interested. Keep in mind that this is just one
explanation, it doesn't mean there aren't other ways of conceptualizing it.

## What it does

Given a number $ X $, the circuit outputs $ Q $ and $ R $ satisfying the
relation $ X = Q^{2} + R, ~ ~ X, Q, R \in \mathbb{N_{0}} $, where $ Q $ is
maximized. To do so, it works with pairs of bits at a time, so $ X $ must
be a $ 2k $-digit binary number. We start with the most significant pair
and try to subtract 1 from it. If the subtraction leaves a positive result,
then we know that $ q_{k - 1} $, the most significant digit of $ Q $, is 1,
otherwise it's 0 and the previous value is restored. Then, we take that
result, concatenate it with the next pair and try to subtract
$ \overline{0q_{k-1} ~ 01} $ from it. The result determines $ q_{k - 2} $. On
the next layer, we try to subtract $ \overline{00 ~ q_{k-1}q_{k-2} ~ 01} $ and so
on. After we've dealt with the last pair, the remainder of the last
subtraction is $ R $.

## How it works

Note that I will be treating subtractions as operations that affect the
entirety of their operands (as they do), even though in the actual circuit
implementation subtraction is only done starting from the least significant
set bit, as subtracting zero doesn't affect the result.

If you play around with a sufficiently small version of the circuit, for
instance, when $ k = 3 $, you may find an interesting pattern across the
numbers that are being subtracted: if you consider $ Q = 0 $, then these
numbers always have the form $ 4^{t} $. One interesting property about
numbers of that form is that they can always be written as a sum of the
first $ 2^t $ odd numbers. This follows directly from

$$ 0^2 = 0 $$
$$ (n + 1)^2 = n^2 + 2n +  1 $$

i.e. all perfect squares can be expressed as a sum of consecutive odd numbers,
starting from $ 1 $. In fact:

$$ \sum_{n = 1}^{p} \left(2n - 1\right) = 2\frac{p(p + 1)}{2} - p = p^{2} $$

From there we can derive a trivial but inefficient approach to finding the
integer square root: just subtract consecutive odd numbers from $ X $, while
incrementing a counter for $ Q $ until the number you're left with is smaller
than the next odd number. That will be $ R $. The approach used by the
restoring method is a bit more sophisticated, but not much different. At its
core, it subtracts consecutive odd numbers from $ X $, but rather than
doing it one a time, it does it in groups, while still allowing for $ Q $
and $ R $ to be uniquely determined.

Playing around with the circuit once again, you could show that, for a set
value of $ k $, all paths (taking into account all possible intermediate
values of $ Q $) would uniquely determine a sequence of consecutive odd
numbers.

## Modeling the problem

This will just be a walkthrough on my thought process and methods used, as well
as to show (in a more precise albeit still very handwavy way) what I've stated.

Firstly, let
$ \mathcal{O_{k}} = \left\lbrace ~ 2n - 1 ~ ~ \middle| ~ ~ 1 \leq n \leq 2^{k} ~ \right\rbrace $.
$ \mathcal{O_{k}} $ has all odd numbers that the circuit could ever subtract, as
$ \sum_{n = 1}^{2^{k}} (2n - 1) = 2^{2k} $, while $ 2^{2k} - 1 $  is the largest possible
value for $ X $.

Then, consider

$$ T_{A} = \sum_{a \in A} 2^{k - a - 1} $$
$$ \mathcal{P}\_{i, A}(\mathcal{O}\_{k}) = \left\lbrace ~ \mathcal{o} \in \mathcal{O}\_{k} ~ ~ \middle| ~ ~ 2\left(T_{A} + 1 \right) - 1 \leq \mathcal{o} \leq 2\left(T\_{A} + 2^{k - i - 1} \right) - 1 ~ \right\rbrace $$

where $ i \in \\{ ~ 0, ~ \mathellipsis, ~ k - 1 ~ \\} $ corresponds to the current
layer, starting from $ 0 $, and $ A $ is such that $ i > a ~ ~  \forall a \in A $
and $ a \in A \Leftrightarrow q_{k - 1 - a} = 1 $, that is, $ A $ represents all
previous layers where the subtraction succeeded or, equivalently, resulted in a
positive number. $ \mathcal{P}\_{i, A}(\mathcal{O}\_{k}) $ contains all consecutive
odd numbers that have been "grouped" to be subtracted in the current layer. This
definition of $ \mathcal{P} $ can be intuitively understood by verifying that
when $ A = \varnothing $ and $ i = 0 $ we get the first $ \frac{2^{k}}{2} $
odd numbers and that this value is halved each time if $ A $ is fixed and $ i $
is incremented until we get to $ i = k - 1 $, suggesting that this method employs
a divide-and-conquer technique in a way that relates to powers of two. At the
same time, it's possible to realize that $ T_{A} $ simply serves to offset the
sequence to account for the odd numbers that have been subtracted already.

By our definition, $ \sum\_{\mathcal{P}\_{i, A}(\mathcal{O}\_{k})} $ must be equal
to the number being subtracted in the current layer. Let's show that, in fact, it is.

Since we have a sum over an arbitrary consecutive sequence of odd numbers, say,
$ n $th to $ m $th first odd numbers, we can rewrite it as a sum from $ 1 $st
to $ m $th minus the sum from $ 1 $st to $ (n - 1) $st. Note that $ \mathcal{P} $
is given by its bounds as $ 2n - 1 $ and $ 2m - 1 $, and we need $ N = n - 1 $ and
$ M = m $. Conveniently:

$$ M = 2^{k - 1} \left( \sum\_{a \in A} \frac{1}{2^{a}} + \frac{1}{2^i} \right) $$
$$ N = 2^{k - 1} \sum_{a \in A} \frac{1}{2^{a}} $$
$$
\begin{split}
 \sum\_{\mathcal{P}\_{i, A}(\mathcal{O}\_{k})}
 ~ &= ~
 \sum\_{n = 1}^{M} (2n - 1)  - \sum\_{n = 1}^{N} (2n - 1)
 \newline
 ~ &= ~
  M^{2} - N^{2}
 \newline
 ~ &= ~
 \cancel{\left(2^{k - 1} \sum\_{a \in A} \frac{1}{2^{a}} \right)^{2}} +
 2 \cdot 2^{k - 1 - i} \cdot 2^{k - 1} \sum\_{a \in A} \frac{1}{2^{a}} +
 \left(2^{k - 1 - i}\right)^{2} -
 \cancel{\left(2^{k - 1} \sum\_{a \in A} \frac{1}{2^{a}}\right)^{2}}
 \newline
 ~ &= ~
 2^{2k - i - 1} \sum\_{a \in A} \frac{1}{2^{a}} + 2^{2k - 2i - 2}
 \newline
 ~ &= ~
 2^{2(k - i - 1)} \left(2^{i + 1} \sum\_{a \in A} \frac{1}{2^{a}} + 1\right)
 \newline
 ~ &= ~
  2^{2(k - i - 1)} \left(\sum\_{a \in A} 2^{i - a + 1} + 1\right)
\end{split}
$$

This is exactly what we were looking for, i.e. a "canonical" or "direct"
representation of the number that is subtracted at each step.
Note that when $ i = 0 $ (and consequently $ A = \varnothing $), we get
$ 2^{2k - 2} $, which is the value that gets subtracted at the first step. In
other words, the $ 1 $ corresponds to the bit that is always set when
subtracting.
Each term of the sum corresponds directly to $ q_{k - a - 1} $.
As $ i $ is incremented, each term of the sum that was already present for
the previous value of $ i $ is multiplied by 2, which can be visualized as the
left shift performed by the circuit to each $ q_{n} $ when comparing
the previous layer to the current one.

Next, consider $ S_{k} \subset \left\lbrace ~ 0, \dotsc, k -  1 ~ \right\rbrace $
s.t. $ s \in S_{k} \Leftrightarrow q_{k - s - 1} = 1 $. By our definition of $ Q $,
$ Q = \sum\_{s \in S_{k}} 2^{k - s - 1} $. Consider also
$ A^{\*}\_{s} = \left\lbrace ~ s^{\prime} \in S_{k} ~ ~ \middle| ~ ~ s^{\prime} < s ~ \right\rbrace $.
We will show that
$ \sum\_{s \in S_{k}} \left(\sum\_{\mathcal{P}\_{s, A^{\*}\_{s}}(\mathcal{O_{k}})} \right)  = Q^{2} $
, that is, the sum of all the numbers subtracted by the circuit is equal to $ Q^{2} $.

$$
\begin{split}
 \sum\_{\mathcal{P}\_{s, A^{\*}\_{s}}(\mathcal{O_{k}})}
 ~ &= ~
 2^{2(k - s - 1)} \left(\sum\_{a \in A^{\*}_{s}} 2^{s - a + 1} + 1\right)
 \newline
 ~ &= ~
 2^{2(k - 1)} \cdot 2^{-2s} \left( \sum\_{a \in A^{\*}\_{s}} 2^{s - a + 1} + 1 \right)
 \newline
 ~ &= ~
 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \left( \sum\_{a \in A^{\*}\_{s}} \frac{2}{2^{a}} + \frac{1}{2^{s}} \right)
 \newline
 ~ &= ~
 2 \cdot 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \left( \sum\_{a \in A^{\*}\_{s}} \frac{1}{2^{a}} + \frac{1}{2^{s + 1}} \right)
\end{split}
$$

As such,

$$
\begin{align*}
 \sum\_{s \in S_{k}} \left(\sum\_{\mathcal{P}\_{s, A^{\*}\_{s}}(\mathcal{O_{k}})} \right)
 ~ &= ~
 \sum\_{s \in S_{k}} \left[ 2 \cdot 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \left( \sum\_{a \in A^{\*}\_{s}} \frac{1}{2^{a}} + \frac{1}{2^{s + 1}} \right) \right] \nonumber
 \newline
 ~ &= ~
 \sum\_{s \in S_{k}} \left[ 2 \cdot 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \left( \sum\_{a \in A^{\*}\_{s}} \frac{1}{2^{a}} \right) + 2 \cdot 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \cdot \frac{1}{2^{s + 1}} \right] \nonumber
 \newline
 ~ &= ~
 2 \sum\_{s \in S_{k}} \left[ 2^{2(k - 1)} \cdot \frac{1}{2^{s}} \left( \sum\_{a \in A^{\*}\_{s}} \frac{1}{2^{a}} \right) \right] + \sum\_{s \in S_{k}} \left(2^{k - 1} \cdot \frac{1}{2^{s}}\right)^{2} \tag{1}
 \newline
 ~ &= ~
 \left( 2^{k - 1} \sum\_{s \in S_{k}} \frac{1}{2^{s}} \right)^{2} \tag{2}
 \newline
 ~ &= ~
 Q^{2} \nonumber
\end{align*}
$$

Note that from $ (1) $ to $ (2) $, we use the fact that
$ (a + b + c + \dots)^{2} = a^{2} + b^{2} + c^{2} + \dots + 2ab + 2ac + \dots + 2bc + \dots $

## Conclusions

From the derivations shown above, we can conclude that $ Q $ and $ R $, as
obtained at the end of the procedure performed by the restoring integer square
root circuit, satisfy the relation $ X = Q^{2} + R $. Note, however, that I
haven't proven that $ Q $ is maximized or that $ Q $ and $ R $ are uniquely
determined. That will be left as an exercise to the reader 😃
