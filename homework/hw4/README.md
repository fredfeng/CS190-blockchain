# Homework Assignment 4

- Due: 11:59pm on Friday, June 14, 2024 (Pacific Time)
  - Late Submission Due: 11:59pm on Sunday, June 16, 2024 (Pacific Time)
- Submit via Gradescope (Course Entry Code: 3PEP34)
- Starter Code: [hw4-starter.zip](./hw4-starter.zip)
  - Python 3.10+ is required in order to build, run and test the code if you built on top of the starter code.

- Contact *Yanju Chen* on slack if you have any questions.

## Overview and Getting Started

In this homework assignment, you will be implementing a compiler that translates a zero-knowledge program into its finite field arithmetization (aka constraints), but in a much simplified way. To do this, we first introduce a very simple programming languages for constructing zero-knowledge circuits, which we call Simple Circuit Language (SCL). You can find its syntax below:

```
<circuit>  ::= (circuit <stmt>*)
<stmt>     ::= <decl> | <assign> | <eq>
<decl>     ::= <signal> | <var>
<signal>   ::= (signal <sym>*)
<var>      ::= (var <sym>*)
<assign>   ::= (:= <sym> <expr>)
<eq>       ::= (eq <expr> <expr>)
<expr>     ::= <int> | <sym> | (<op2> <expr> <expr>) | (<op3> <expr> <expr> <expr>)
<op2>      ::= + | - | * | /
<op3>      ::= ite
```

An SCL program is written in s-expression and starts with the `<circuit>` rule. It provides basic arithmetic operations and branching. There are two kinds of registers in SCL: signals and variables. Similar to the Circom programming language, in SCL:

- Signals refer to those registers that should be provided by the users when doing proof generation. When assigned, a signal is then read-only.
- Variables refer to those registers that stores temporary results of computation. A variable can be assigned multiple times, thus has versioning.

You may find some SCL examples in the "Examples" section.

To have a more structured output, we also define a language for structurally store the target constraint system, which we refer to as Finite Field Constraint Language (FFL). You can find its syntax below:

```
<block>    ::= <equation>*
<equation> ::= <expr> = <expr>
<expr>     ::= <int> | <sym> | signal() | var() 
             | <expr> + <expr> | <expr> - <expr> | <expr> * <expr>
```

For simplicity, we omit the modulo operation in finite field here, but you can always add it back in real-world practice. The top-level of an FFL program is a `<block>` that stores a list of `<equation>`s (aka constraints). In finite field arithmetics that FFL models, one can only use addition and multiplication. In addition, we allow it to express subtraction since a constraint that contains subtraction in finite field can be easily converted to addition.

*The goal of this project is to design a compilation procedure that translates an SCL program into an FFL program.*

You are provided a template in the starter pack, where the `compile` procedure performs a post-order traversal on the SCL syntax tree. Child nodes are visited from left to right. The `compile` procedure eventually returns an FFL program that corresponds to the given SCL program's arithmetization (constraints).

To get started with, you can use the `run.py` in starter pack by providing it with SCL program (find it in `examples/` folder):

```bash
python ./run.py ./examples/add.scl
```

This will load and parse the provided SCL program, call the `compile` function and print the compiled FFL program in human-readable form. As of now, you will only see the following output:

```
l = signal()
r = signal()
out = signal()
```

This is because some of the critical parts of the `compile` function is not yet implemented, and you will be completing it. Please do check out the "Examples" section and the "Hints" section, as they provide useful information for you to get started with.

## Examples

Here are some examples showing each step of arithmetization during the translation from SCL to FFL. You can find more examples in `examples/` folder. As shown below, some examples will create different versions of a variable, as well as helper variables. So make sure you create them with the same order and naming convention, and we've provided utility functions to help do that; check out the "Hints" section at the end for more details.

### Simple Addition Circuit (add.scl)

```lisp
; ===========
; SCL Program
; ===========
(circuit
  (signal l r out)
  (eq out (+ l r))
)

; ===========
; FFL Program
; ===========
; (signal l r out)
l = signal()
r = signal()
out = signal()
; (eq out (+ l r))
  ; (+ 1 r) --> _expr$0
  _expr$0 = var()
  _expr$0 = l + r
  ; (eq out _expr$0)
  out = _expr$0
```

### Simple Division Circuit (div.scl)

```lisp
; ===========
; SCL Program
; ===========
(circuit
  (signal l r out) 
  (eq out (/ l r))
)

; ===========
; FFL Program
; ===========
; (signal l r out)
l = signal()
r = signal()
out = signal()
; (eq out (/ l r))
  ; (/ l r) --> _expr$0
  _expr$0 = var()
  l = _expr$0 * r
  ; (eq out _expr$0)
  out = _expr$0
```

### Basic Arithmetic #0 (basic0.scl)

```lisp
; ===========
; SCL Program
; ===========
(circuit
  (signal l r out)
  (var tmp)
  (:= tmp (* (+ l r) (- l r)))
  (eq out tmp)
)
 
; ===========
; FFL Program
; ===========
; (signal l r out)
l = signal()
r = signal()
out = signal()
; (:= tmp (* (+ l r) (- l r)))
  ; (+ l r) --> _expr$0
  _expr$0 = var()
  _expr$0 = l + r
  ; (- l r) --> _expr$1
  _expr$1 = var()
  _expr$1 = l - r
  ; (* _expr$0 _expr$1) --> _expr$2
  _expr$2 = var()
  _expr$2 = _expr$0 * _expr$1
  ; (:= tmp _expr$2)
  tmp$0 = var()
  tmp$0 = _expr$2
; (eq out tmp)
out = tmp$0
```

### IsZero Circuit (iszero.scl)

```lisp
; ===========
; SCL Program
; ===========
(circuit
  (signal in out)
  (eq out (ite in 1 0))
)

; ===========
; FFL Program
; ===========
; (signal in out)
in = signal()
out = signal()
; (eq out (ite in 1 0))
  ; evaluate (in == 0) and store in _expr$0
  _inv$0 = var()
  _expr$0 = var()
  in * _inv$0 = 1 - _expr$0
  in * _expr$0 = 0
  ; evaluate the branch
  _expr$1 = var()
  _expr$1 = _expr$0 * 1 + (1 - _expr$0) * 0
	; constrain ite result to out
	out = _expr$1
```

## Hints and Useful Resources

- I've already implemented some helpful utility functions for you. For example, `fresh_var`, `fresh_signal`, `curr_sym` and `reset_symbols` for maintaining variable and signal versioning.
- For the IsZero circuit, I've already implemented a template function for you `compile_zero`. Just provide the input, and it will return the expression that stores the result, together with a set of corresponding constraints for you.
- You can print an SCL/FFL program directly in Python. As they have properly implemented their `__str__` method, you will see the ZK program/constraint in humna-readable way.

## Submission and Evaluation

You will be submitting only the `compile.py` file via Gradescope. You can build upon the provided template in the starter pack, and test locally using before you submit. Note that building on top of the provided template is optional, and you can build on your own, as long as you keep the same function signature of `compile` and it eventually returns a `Fflblock` to the caller.

The maximum points you can get is 100 pts, which come from a total of 10 problems (8 of them are included in the starter pack together with expected outputs available, and 2 of them are hold-out test cases). Different problems have different scores (5pts/10pts/20pts). The score you get for each problem is given by: Total Score = Score A (70% or 60%) + Score B (30% or 40%), where Score A is computed from the number of equations matched with the ground truth output, and Score B is added when your output matches exactly (including names of helper variables and their version numbers) with the ground truth output.

Note that:

- The points you get will be converted to percentage when computing score of this homework towards your final grade. For example, if you get 100/100 pts, you get 100% of the homework score, and if you get 30/100 pts, you'll get 30% of the homework score, etc.
- There's a grace period of 1 hour after the regular deadline. Note that the grace period is intended for you to wrap up and save your unfinished work for submission at the last minute, and if you could not catch that, your subsequent submissions will be marked as late submissions.
- Points earned from late submission will be discounted by 50%. Late submission is due on the last weekend of the quarter. Subsequent submissions after the late submission deadline will not be considered and receive 0 point. There's no grace period of late submission deadline.

## Academic Integrity

Please refer to UCSB's adacemic integrity guidance ([here](https://studentconduct.sa.ucsb.edu/academic-integrity)) if you have any questions.