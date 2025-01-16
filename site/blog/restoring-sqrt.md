---
date: 2024-06-16
description: How the restoring integer square root algorithm works
---

# Restoring Integer Square Root Explained (in binary)

In case you've never heard of it, the restoring integer square root
algorithm allows one to calculate the integer portion of the square
root of a given integer, i.e. it's equivalent to the floor of the
regular square root. Much like restoring division, it works by
analyzing pieces of the input number at a time, subtracting a given
value from each, and acting upon the result, *restoring* the previous
value if the subtraction would result in a negative number.

But *how* and *why* exactly does it work? This is the question I've
sought out to answer, and, although I was able to derive an
explanation that seems sensible, if incomplete, you might want to
check out [other] [people's] [perspective] on the matter.

[other]: https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)
[people's]: https://www.reddit.com/r/math/comments/tc7lur/computing_square_roots_in_binary_by_hand_is/
[perspective]: https://www.cantorsparadise.com/the-square-root-algorithm-f97ab5c29d6d

## Description

For the following description and later sections, we will consider
a number $X$ and $Q = \sum_{i} q_i \cdot 2^i$, and consider $k$ so
that $X$ has $2k$ digits (we may add a leading zero if needed),
$q_{k - 1}$ will then be the most significant bit in the binary
representation of $Q$, and $q_0$ the least significant bit (LSB).

Given a number $X$, the algorithm outputs $Q$ and $R$ satisfying
$X = Q^2 + R, \, X,Q,R \in \mathbb{N_0}$, such that $Q$ is maximized. 
First, we take the binary representation of $X$ and split it up into 
pairs of bits. We start with the most significant pair and subtract
1 from it. If the result is $\geq 0$, then we know the MSB in the
binary representation of $Q$ is 1. Otherwise (if the result is 
negative) then the result is "restored" to the previous value, 
and the MSB of $Q$ will be zero.

Then, we take that result, concatenate it with the next pair and
subtract $\overline{0q_{k-1}01}$ from it (the overline denotes
concatenation). The result will determine $q_{k-2}$, in the same
way as before. On the next step, we would group the current result
with the next pair and subtract $\overline{00 ~ q_{k-1}q_{k-2} ~ 01}$,
determining $q_{k - 3}$. This procedure is iterated until running
out of pairs. The remainder of the last subtraction is $R$.

## An idea for a solution

An interesting fact: all perfect squares can be written as a sum
of consecutive odd numbers, starting at 1.

$$
\sum_{n=1}^p \left(2n - 1\right) = p^2
$$

That allows us to derive a simple but inefficient approach to
calculate the integer square root: subtract consecutive odd
numbers from $X$, keeping track of the result and incrementing
$Q$ until the result is less than the next odd number.
The remainder of the last subtraction will be $R$.

It turns out the way the restoring algorithm works is very
similar, it just subtracts a set of consecutive odd numbers
at once rather than one at a time, while narrowing down on the
result at each iteration.

## Working it out

We should note that if all the previous bits of $Q$ are zero,
then we will be subtracting a power of 4 on the current
iteration. Since $4^t = (2^t)^2$, a power of 4 can always be
written as a sum of consecutive odd numbers, starting from 1.

A peculiar sequence of sets of consecutive odd numbers is formed
if you execute the algorithm on the value 1, extended to $n$
binary digits. For instance, for $n = 6$, we would first subtract
$10000_2 = 1 + 3 + 5 + 7$, then $100_2 = 1 + 3$, and, finally, 1.

Note also that if any of the previous bits of $Q$ are not zero,
then we can reason that some of the past subtractions "succeeded"
(resulted in a positive number). That means we were able to
subtract a set of consecutive odd numbers, starting at 1, from
the initial value. Anything we subtract from now on should be
"offset" to account for that, i.e., we should now subtract a set
of consecutive odd numbers that starts at the smallest odd number
not in any of the previous sets. We can show that including
the bits of $Q$ in the terms being subtracted does exactly that.

To that end, let's consider that we are at the $i$th iteration
(where the first iteration would be 0 and the last $k - 1$). The
number being subtracted at that iteration, $s_i$, is given by:

$$
s_i = 2^{2k-2i-2} + \sum_{m = 0}^{i - 1} q_{k-m-1} \cdot 2^{2k-i-m-1}
$$

The first term corresponds to the constant "1", while the second
corresponds to the previous bits of $Q$ that are added to the
term being subtracted. To make more sense of it, see the following
illustration, showing the binary representation of $s_i$:

$$
0 \, \cdots \, 0 ~ \overbrace{
    \underset{\substack{\uparrow \\ 2^{2k-2i+i-1} \\ (m = 0)}}{q_{k-1}}
    \cdots
    \underset{\substack{\uparrow \\ 2^{2k-2i} \\ (m = i - 1)}}{q_{k-i}}
}^{i}
~ 0
\underset{\substack{\uparrow \\ 2^{2k-2i-2}}}{1_{}}
~ 0 \, \cdots \, 0
$$

Meanwhile, we know that $s_i$ must be equal to the sum of a certain
set of consecutive odd numbers. Rather than focusing on the numbers
themselves, let's denote by $O(n, m)$ the set of consecutive odd
numbers starting at the $n$th odd number with $m$ elements. Thus:

$$
n_i = \sum_{m = 0}^{i - 1} q_{k-m-1} \cdot 2^{k-m-1} + 1
$$

$$
O_i = O\left(n_i, \, 2^{k-i-1}\right)
$$

$n_i$ can be derived by realizing that if all the previous bits of
$Q$ are zero, then we have to start at the first odd number (1),
and that the amount of odd numbers subtracted (initially $2^{k - 1}$)
is halved at each iteration.

Now, we can show that $s_i$, the number subtracted at iteration $i$, is equal 
to the sum of the elements of $O_i$. For that, let's start with $O_i$:

$$
\begin{aligned}
\textstyle \sum O_i &= \sum_{t=1}^{2^{k-i-1}} \left[2(n_i + t - 1) - 1\right] \\
           &= 2 \cdot 2^{k-i-1} \cdot n_i + 2^{k-i-1}(2^{k-i-1} + 1) - 3 \cdot 2^{k-i-1} \\
           &= 2^{2k-2i-2} + 2^{k-i} \cdot n_i - 2^{k-i} \\
           &= 2^{2k-2i-2} + 2^{k-i}\left(\sum_{m = 0}^{i - 1} q_{k-m-1} \cdot 2^{k-m-1} + 1\right) - 2^{k-i} \\
           &= s_i
\end{aligned}
$$

But why this particular arrangement? Why is $|O_i|$ a power of 2? While it would 
be possible to adapt this algorithm to use other bases, sticking to base 2 gives
us simpler rules and turns out to be very useful, as it allows for a fast 
implementation on modern computers and other digital electronic systems. 
However, the fact that the size of $O_i$ is an exponential function of $i$ is 
fundamental to guarantee this algorithm's performance.

If we consider the input size of the algorithm to be the number of digits of $X$ 
($2k$), then, as already mentioned, $Q$ will have $k$ digits, at most, since 
$\log \sqrt{X} = \log X^{1/2} = 1/2 \log X$. There are $2^k$ possible values for 
$Q$, and each one must be reachable from the starting point of the algorithm. 
If a linear function of $i$ were used for the size of $O_i$, the computational 
complexity would inevitably devolve to $O(2^{k/2})$, which is almost as bad as 
the [naïve repeated subtraction method](#an-idea-for-a-solution), since a sum of
linear functions of $n$ is $O(n^2)$. However, using an exponential function for the 
size brings the computational complexity down to $O(k)$, or $O(\log X)$[^complexity-note].

[^complexity-note]: Only valid if we assume that a subtraction can be performed in
constant time, i.e. $O(1)$, which is not true in general.

> ### Fun fact
> 
> Since each bit in the binary representation of $Q$ is set only once, this algorithm
> can be implemented using combinational logic circuits (in fact, this is how I 
> originally found out about it in the first place).

The following diagram depicts a binary decision tree representing all possible choices 
the algorithm could take for $k = 3$, where each level corresponds to an iteration. 
A dashed edge means that the subtraction resulted in a negative number and the previous 
value had to be restored, while a solid edge means that the subtraction resulted in a 
number $\geq 0$. Each node shows the value subtracted at that iteration, as a sum of
consecutive odd numbers. While only four leaf nodes are drawn, each leaf node could
have a dashed and a solid edge out of it, each destination node would then represent a
unique value for $Q$.

```{.pikchr width="400" style="max-width: 100%;" caption="Decision tree showing all possible values the algorithm may subtract, for 6 digits"}
Q_x00: box "1 + 3 + 5 + 7" width 2.1cm


dx = 0.7
dy = 0.7

off = 0.12

boxht = 1cm
boxwid = 1.2cm


Q_0x0: box "1 + 3" at Q_x00 - (dx, dy)
Q_1x0: box "9 + 11" at Q_x00 + (dx, -dy)

line from Q_x00.sw + (off, 0) to Q_0x0.n dashed
line from Q_x00.se - (off, 0) to Q_1x0.n


dx *= 0.6
dy *= 0.8

off -= 0.03

boxht = 0.85cm
boxwid = 0.85cm


Q_00x: box "1" at Q_0x0 - (dx, dy)
Q_01x: box "5" at Q_0x0 + (dx, -dy)

Q_10x: box "9" at Q_1x0 - (dx, dy)
Q_11x: box "13" at Q_1x0 + (dx, -dy)

line from Q_0x0.sw + (off, 0) to Q_00x.n dashed
line from Q_0x0.se - (off, 0) to Q_01x.n

line from Q_1x0.sw + (off, 0) to Q_10x.n dashed
line from Q_1x0.se - (off, 0) to Q_11x.n
```

## Addendum

It is also possible to show, given all $s_i$ and $Q$ for a given run
of the algorithm, that:

$$
\sum_{i = 0}^{k - 1} s_i = \left(\sum_{i = 0}^{k - 1} q_i \cdot 2^i \right)^2 = Q^2
$$

Though that will be left as an exercise to the reader.
