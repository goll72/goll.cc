#import "/lib/lib.typ": *
#import "/lib/common/blog/restoring-sqrt.typ": *

#show: page
#show: article

= Restoring Square Root Explained

As the name implies, this algorithm can be used to calculate the integer
square root of a given integer, i.e. the equivalent to the floor of the
regular (real) square root. Much like restoring division, it is an
iterative algorithm, where each iteration applied gets us closer to the
final answer. But how does it do that? And why does it work?

#{
  let wikipedia = "https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Binary_numeral_system_(base_2)"
  let reddit = "https://www.reddit.com/r/math/comments/tc7lur/computing_square_roots_in_binary_by_hand_is/"
  let cp = "https://www.cantorsparadise.com/the-square-root-algorithm-f97ab5c29d6d"

  [
    This is what I've sought out to answer. The following page demonstrates
    the validity of this algorithm from a very particular point of view and,
    particularly, for base 2 (binary). You might be interested in
    #link(wikipedia)[other] #link(reddit)[people's] #link(cp)[perspectives].
  ]
}

== Description

Given a number $X$ represented in binary, we can add a leading zero if needed
so that it has $2k$ digits, for a given integer $k$. Having done that, we may
consider $Q$ and $R$ satisfying $X = Q^2 + R$, such that $R >= 0$ and $Q$ is
maximized. As such, $Q$ will be a $k$-digit number:

$ X "is at most" 2^(2k) - 1 < 2^(2k) = (2^k)^2 $

Thus, $q_(k-1)$ is the most significant bit (MSB) in the binary representation
of $Q$, while $q_0$ is the least (LSB). The first step is to take the binary
representation of $X$ and split it up into pairs of bits. We start from the
most significant pair and subtract 1 from it. if the result is $>= 0$, then
$q_(k-1) = 1$, otherwise, it's $0$ and we "restore" the previous value of the
pair (before the subtraction).

Then, we take the result (which may or may not have been restored), concatenate
it with the next pair and subtract $overline(0q_(k-1)01)$ from it (the overline
denotes concatenation). The result will determine $q_(k-2)$, in the same way
as before. On the next step, we would group the result with the next pair and
subtract $overline(00 q_(k-1)q_(k-2) 01)$ from it, determining $q_(k-3)$, and
so on. This process is repeated until there are no more pairs. The remainder of
the last subtraction is $R$.

== An idea for a solution

An interesting fact: all square numbers can be written as a sum of consecutive
odd numbers, starting at 1.

$ sum_(n=1)^p (2n - 1) = p^2 $

This allows for a simple but inefficient approach to calculating the square root:
subtract consecutive odd numbers from $X$, keeping track of the new value after the
subtraction and how many odd numbers were used. At the end, the amount of odd numbers
used will be $Q$ and the remainder will be $R$.

But adding up all odd numbers like this takes some time. Can we do better? As it
turns out, we can. And the restoring square root algorithm is quite similar in
principle; it's just subtracting many odd numbers at once rather than one at a time.

== A demonstration

Let's try to understand what is happening at each iteration. Assume we are at a given
iteration and all the bits of $Q$ we've found on previous iterations are $0$. Then,
the value being subtracted on the current iteration is always a power of 4. In the
base case ($k = 1$), $1$ is subtracted. When $k$ is incremented, the value being
subtracted at the first iteration is shifted left by two units, which is the same as
multiplying by $2^2 = 4$. And since $4^n = 2^(2n) = (2^n)^2$, we can conclude that
the value subtracted on the current iteration is a sum of consecutive odd numbers,
starting at $1$ ($2^n$ many of them, in fact).

This, in turn, means that the amount of odd numbers subtracted is halved at each
iteration, compared to the previous one. But what if some bit of $Q$ wasn't $0$?
That implies that we were able to subtract some odd numbers from the intermediate
result, and we shouldn't try to subtract them again (we should "advance" in the
sequence somehow). Let's see how adding previous bits of $Q$ to the subtrahend
does just that.

Let's consider we are at the $i$th iteration, where the first would be $0$ and the
last $k-1$. The value being subtracted at that iteration, which we'll call $s$, is
given by:

#s-definition

The first term corresponds to the constant $1$, while the second accounts for the
bits of $Q$ from previous iterations that are added back in. The following
illustration shows the binary representation of $s$:

#s-binary-repr

Let's denote by $D(n, m)$ the set of odd numbers starting at the $n$th element
with $m$ elements. Since for each bit of $Q$ that is set we have to skip half of
however many odd numbers we subtracted in the previous iteration, we can
deduce that the index of the starting number in the sequence (starting at
$1$, as we will write odd numbers as $2n - 1$) is of the form:

#n_i-definition

Meanwhile, if we assume, for now, that the amount of odd numbers subtracted
at each iteration should always be halved, regardless of the previous bits
of $Q$, then the value subtracted at the $i$th iteration will be given by:

#s-as-sum-of-D

Starting from the right-hand side:

#sum-of-D-is-s

But why this particular arrangement? Why is $abs(D)$ a power of 2? While it would 
be possible to adapt this algorithm to use other bases, sticking to base 2 gives
us simpler rules and turns out to be very useful, as it allows for a fast 
implementation on modern computers and other digital electronic systems.
However, the fact that $abs(D)$ is an exponential function of $i$ is
fundamental to guarantee this algorithm's performance, and it derives naturally
from the fact that it traverses the input number's bits at each iteration.
There are $2^k$ possible values for $Q$, and each one must be reachable from the
starting point. In effect, the algorithm is doing a binary search on the space of
possible values for $Q$.

#quote[
  === Fun fact

  Since each bit in the binary representation of $Q$ is set only once, this algorithm
  can be implemented using combinational logic circuits (in fact, this is how I 
  originally found out about it in the first place).
]

The following diagram depicts a binary decision tree representing all possible choices 
the algorithm could take for $k = 3$, where each level corresponds to an iteration. 
A dashed edge means that the subtraction resulted in a negative number and the previous 
value had to be restored, while a solid edge means that the subtraction resulted in a 
number $>= 0$. Each node shows the value subtracted at that iteration, as a sum of
consecutive odd numbers. While only four leaf nodes are drawn, each leaf node should
have additional edges going out, each destination node would then represent a unique
value for $Q$.

#bdt
