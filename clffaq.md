# Frequently Asked Questions for [comp.lang.functional](news:comp.lang.functional)


Edited by [Graham Hutton](http://www.cs.nott.ac.uk/~gmh), University of Nottingham

Version of November 2002
(This document is no longer being updated)

1. This document
2. General topics
2.1. Functional languages 
2.2. History and motivation 
2.3. Textbooks 
2.4. Journals and conferences 
2.5. Schools and workshops 
2.6. Education
3. Technical topics
3.1. Purity 
3.2. Currying 
3.3. Monads 
3.4. Parsers 
3.5. Strictness 
3.6. Performance 
3.7. Applications
4. Other resources
4.1. Web pages 
4.2. Research groups 
4.3. Newsgroups 
4.4. Bibliographies 
4.5. Translators
5. Languages
5.1. ASpecT 
5.2. Caml 
5.3. Clean 
5.4. Erlang 
5.5. FP 
5.6. Gofer 
5.7. Haskell 
5.8. Hope 
5.9. Hugs 
5.10. Id 
5.11. J 
5.12. Miranda 
5.13. Mercury 
5.14. ML 
5.15. NESL 
5.16. OPAL 
5.17. Oz 
5.18. Pizza 
5.19. Scheme 
5.20. Sisal

## この文書について

Comp.lang.functional は関数型言語に関するデザイン、応用、理論的基礎、実装を含めた
全ての事に関する議論を行う管理者のいない [usetnet ニュース](http://ja.wikipedia.org/wiki/%E3%83%8D%E3%83%83%E3%83%88%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9)グループである。
このグループでの議論は(他のグループの記録と共に)次のサイトに保存されている:

> http://www.dejanews.com/.

この文書は comp.lang.functional の「良く聞かれる質問 (FAQ)」の一つであり、
関数型言語に関して良く聞かれる疑問に対して簡単な回答、もしくは他情報源へのポインタや
関係する文書、インターネット情報を紹介する。
この文書の最も新しいバージョンは、

> http://www.cs.nott.ac.uk/~gmh/faq.html

から入手可能である。

この文書の多くの情報は公共の情報源、主に comp.lang.functional に投稿された記事、
からとられている。そのような編集経緯から、この文書の作成に協力した事になる人々のリストは存在しない。
この文書に書かれた意見はこれら個人の協力者の物であり、編集者や、他の関数型プログラミング
コミュニティメンバーの意見を代表するものではない場合もある。この文書の内容はできるだけ正しく、
また最新であるように注意が払われているが、それはここで提供される情報の正しさを保証するものではない。
あなたの問題指摘と協力が求められている!

このFAQリストの初期のバージョンは Mark P. Jones によって編纂された。
現在の版に対する全ての疑問、コメント、修正、提案は現在の編者である Graham Hutton に連絡されたい。

## 一般的なトピック

このセクションでは関数型プログラミングに対する一般的な疑問に簡単に答え、
関連する書籍やネット情報を提供する。

### 関数型言語

What is a "functional programming language"?

Opinions differ, even within the functional programming community, on the precise definition of what constitutes a functional programming language. However, here is a definition that, broadly speaking, represents the kind of languages that are discussed in comp.lang.functional:

Functional programming is a style of programming that emphasizes the evaluation of expressions, rather than execution of commands. The expressions in these language are formed by using functions to combine basic values. A functional language is a language that supports and encourages programming in a functional style.
For example, consider the task of calculating the sum of the integers from 1 to 10. In an imperative language such as C, this might be expressed using a simple loop, repeatedly updating the values held in an accumulator variable total and a counter variable i:

total = 0;
for (i=1; i<=10; ++i)
   total += i;
In a functional language, the same program would be expressed without any variable updates. For example, in Haskell, the result can be calculated by evaluating the expression:

sum [1..10]
Here, [1..10] is an expression that represents the list of integers from 1 to 10, while sum is a function that can be used to calculate the sum of an arbitrary list of values.

The same idea could also be used in (strict) functional languages such as SML or Scheme, but it is more common to find such programs written with an explicit loop, often expressed recursively. Nevertheless, there is still no need to update the values of the variables involved:

SML:
let fun sum i tot = if i=0 then tot else sum (i-1) (tot+i)
in sum 10 0
end
Scheme:
(define sum
   (lambda (from total)
       (if (= 0 from)
           total
           (sum (- from 1) (+ total from)))))
(sum 10 0)
It is often possible to write functional-style programs in an imperative language, and vice versa. It is then a matter of opinion whether a particular language can be described as functional or not.


2.2. History and motivation

Where can I find out more about the history and motivation for functional programming?

Here are two useful references:

"Conception, Evolution, and Application of Functional Programming Languages", Paul Hudak, ACM Computing Surveys, Volume 21, Number 3, pp.359-411, 1989.
"Why functional programming matters", John Hughes, The Computer Journal, Volume 32, Number 2, April 1989. Available on the web from:
http://www.cs.chalmers.se/~rjmh/Papers/whyfp.html.

2.3. Textbooks

Are there any textbooks about functional programming?

Yes, here are a selection:

Programming:

"Introduction to functional programming using Haskell", 2nd edition, Richard Bird, Prentice Hall Europe, 1998. ISBN 0-13-484346-0.
"The Haskell school of expression: Learning functional programming through multimedia", Paul Hudak, Cambridge University Press, 2000. ISBN 0-521-64338-4. Further information is available on the web from:
http://haskell.org/soe.
"Haskell: The craft of functional programming", 2nd edition, Simon Thompson, Addison-Wesley, 1999. ISBN 0-201-34275-8. Further information is available on the web from:
http://www.cs.ukc.ac.uk/people/staff/sjt/craft2e.
"ML for the working programmer", 2nd Edition, L.C. Paulson, Cambridge University Press, 1996. ISBN 0-521-56543-X. Further information is available on the web from:
http://www.cl.cam.ac.uk/users/lcp/MLbook/.
Algorithms and data structures:

"Purely functional data structures", Chris Okasaki, Cambridge University Press, 1998. ISBN 0-521-63124-6.
"Algorithms: A functional programming approach", Fethi Rabhi and Guy Lapalme, Addison-Wesley, 1999. ISBN 0-201-59604-0. Further information is available on the web from:
http://www.iro.umontreal.ca/~lapalme/Algorithms-functional.html.
Implementation:

"The implementation of functional programming languages", Simon Peyton Jones, Prentice Hall, 1987. ISBN 0-13-453333-X.
"Compiling with continuations", Andrew Appel, Cambridge University Press, 1992. ISBN 0-521-41695-7. Further information is available on the web from:
http://www.cup.org/Titles/416/0521416957.html.
There are several other textbooks available, particularly in the programming and implementation categories. A comparison of a number of functional programming textbooks is made in the following article:

"Comparative review of functional programming textbooks (Bailey, Bird and Wadler, Holyer, Paulson, Reade, Sokoloski, Wikstrom)", Simon Thompson, Computing Reviews, May 1992 (CR number 9205-0262).

2.4. Journals and conferences

Are there any journals and conferences about functional programming?

Yes, here are a selection:

Journals:

The Journal of Functional Programming (JFP), published by Cambridge University Press. Further information is available on the web from:
http://www.dcs.gla.ac.uk/jfp/.
The Journal of Functional and Logic Programming (JFLP), an electronic journal published by MIT Press, and available on the web from:
http://www.cs.tu-berlin.de/journal/jflp/.
Lisp and Symbolic Computation, published by Kluwer.
Conferences:

The International Conference on Functional Programming (ICFP). This conference combines and replaces the earlier conferences on Lisp and Functional Programming (LFP), and Functional Programming Languages and Computer Architecture (FPCA). Further information about the next ICFP conference (October 2002 at the time of writing) is available on the web from:
http://icfp2002.cs.brown.edu/.
Mathematics of Program Construction (MPC). Further information about the most recent MPC conference (July 2000 at the time of writing) is available on the web from:
http://seide.di.uminho.pt/~mpc2000/.
Principles of Programming Languages (POPL). Further information about the next POPL conference (January 2001 at the time of writing) is available on the web from:
http://www.daimi.au.dk/~popl01/.
European Symposium on Programming (ESOP). Further information about the next ESOP conference (April 2001 at the time of writing) is available on the web from:
http://www.md.chalmers.se/~dave/esop/.
Most of these conferences have proceedings published by the ACM press, or in the Springer Verlag LNCS (Lecture Notes in Computer Science) series.

In addition to the above, Philip Wadler edits a column on functional programming for the Formal Aspects of Computer Science Newsletter, which is published by the British Computing Society Formal Aspects of Computing group and Formal Methods Europe.


2.5. Schools and workshops

Are there any schools and workshops on functional programming?

Yes, here are a selection:

Schools:

Summer School and Workshop on Advanced Functional Programming, August 19-24, 2002, Oxford, England. Further information is available on the web from:
http://www.functional-programming.org/afp/.
The Third International Summer School on Advanced Functional Programming Techniques, September 12-19, 1998, Braga, Portugal. Further information is available on the web from:
http://www.di.uminho.pt/~afp.
Spring School on Advanced Functional Programming Techniques, May 24-31, 1995, Baastad, Sweden. The proceedings of the school were published in the Springer Verlag LNCS (Lecture Notes in Computer Science) series, number 925.
The Second International Summer School on Advanced Functional Programming Techniques, August 25-30, 1996, Washington, USA. The proceedings of the school were published in the Springer Verlag LNCS (Lecture Notes in Computer Science) series, number 1129. Further information is available on the web from:
http://www.cse.ogi.edu/PacSoft/summerschool96.html.
Workshops:

Haskell Workshop, September 2, 2001, Florence, Italy. Held in conjunction with PLI 2001. Further information is available on the web from:
http://www.cs.uu.nl/people/ralf/hw2001.html
Haskell Workshop, September 17, 2000, Montreal, Canada. Held in conjunction with PLI 2000. Further information is available on the web from:
http://www.cs.nott.ac.uk/~gmh/hw00.html
Third Haskell Workshop, October 1, 1999, Paris, France. Held in conjunction with ICFP'99. Further information is available on the web from:
http://www.haskell.org/HaskellWorkshop.html
Workshop on Algorithmic Aspects of Advanced Programming Languages, September 29-30, 1999, Paris, France. Further information is available on the web from:
http://www.cs.columbia.edu/~cdo/waaapl.html.
1st Scottish Functional Programming Workshop, August 29-September 1, 1999, Stirling, Scotland. Further information is available on the web from:
http://www.cee.hw.ac.uk/~gjm/sfp/.
From 1988 to 1998 the Glasgow functional programming group organised a yearly workshop in Scotland. Further information is available on the web from:
http://www.dcs.gla.ac.uk/fp/workshops/.
The 9th International Workshop on the Implementation of Functional Languages, Sept 10-12, 1997, St. Andrews, Scotland. Further information is available on the web from:
http://www.dcs.st-and.ac.uk/~ifl97.
The Haskell Workshop, June 7, 1997, Amsterdam, The Netherlands. Held is conjunction with ICFP'97. Further information is available on the web from:
http://www.cse.ogi.edu/~jl/ACM/Haskell.html.
The 2nd Fuji International Workshop on Functional and Logic Programming, November 1-4, 1996, Shonan Village, Japan. Further information is available on the web from:
http://www.kurims.kyoto-u.ac.jp/~ohori/fuji96.html.
The 1st Workshop on Functional Programming in Argentina, September 12, 1996, Buenos Aires, Argentina. Further information is available on the web from:
http://www-lifia.info.unlp.edu.ar/~lambda/first/english/.

2.6. Education

Are functional programming languages useful in education?

Functional languages are gathering momentum in education because they facilitate the expression of concepts and structures at a high level of abstraction. Many university computing science departments now make use of functional programming in their undergraduate courses; indeed, a number of departments teach a functional language as their first programming language. Further information about the use of functional programming languages in education (including links to relevant conferences and workshops) is available on the web from:

http://www.cs.kun.nl/fple/.

3. Technical topics

This section gives brief answers to a number of technical questions concerning functional programming languages, and some pointers to relevant literature and internet resources.


3.1. Purity

What is a "purely functional" programming language?

This question has been the subject of some debate in the functional programming community. It is widely agreed that languages such as Haskell and Miranda are "purely functional", while SML and Scheme are not. However, there are some small differences of opinion about the precise technical motivation for this distinction. One definition that has been suggested is as follows:

The term "purely functional" is often used to describe languages that perform all their computations via function application. This is in contrast to languages, such as Scheme and Standard ML, that are predominantly functional but also allow `side effects' (computational effects caused by expression evaluation that persist after the evaluation is completed).
Sometimes, the term "purely functional" is also used in a broader sense to mean languages that might incorporate computational effects, but without altering the notion of `function' (as evidenced by the fact that the essential properties of functions are preserved.) Typically, the evaluation of an expression can yield a `task', which is then executed separately to cause computational effects. The evaluation and execution phases are separated in such a way that the evaluation phase does not compromise the standard properties of expressions and functions. The input/output mechanisms of Haskell, for example, are of this kind.

See also:
"What is a purely functional language", Amr Sabry, Journal of Functional Programming, 8(1):1-22, Cambridge University Press, January 1998.

3.2. Currying

What is "currying", and where does it come from?

Currying has its origins in the mathematical study of functions. It was observed by Frege in 1893 that it suffices to restrict attention to functions of a single argument. For example, for any two parameter function f(x,y), there is a one parameter function f' such that f'(x) is a function that can be applied to y to give (f'(x))(y) = f (x,y). This corresponds to the well known fact that the sets (AxB -> C) and (A -> (B -> C)) are isomorphic, where "x" is cartesian product and "->" is function space. In functional programming, function application is denoted by juxtaposition, and assumed to associate to the left, so that the equation above becomes f' x y = f(x,y).

Apparently, Frege did not pursue the idea further. It was rediscovered independently by Schoenfinkel, together with the result that all functions having to do with the structure of functions can be built up out of only two basic combinators, K and S. About a decade later, this sparked off the subject of combinatory logic, invented by Haskell Curry. The term "currying" honours him; the function f' in the example above is called the "curried" form of the function f. From a functional programming perspective, currying can be described by a function:

curry : ((a,b) -> c) -> (a -> b -> c)
The inverse operation is, unsurprisingly, refered to as uncurrying:

uncurry : (a -> b -> c) -> ((a,b) -> c)
For further reading, see:

"Highlights of the history of the lambda-calculus", J. Barkley Rosser, ACM Lisp and Functional Programming, 1982.
"Ueber die Bausteine der mathematischen Logik", Moses Sch\"onfinkel, Mathematische Annalen, 92, 1924. An English translation, "On the building blocks of mathematical logic", appears in "From Frege to G\"odel", Jean van Heijenoort, Harvard University Press, Cambridge, 1967.
"Combinatory logic", Haskell B. Curry and Robert Feys, North-Holland, 1958. This work also contains many references to earlier work by Curry, Church, and others.

3.3. Monads

What is a "monad", and what are they used for?

The concept of a monad comes from category theory; full details can be found in any standard textbook on the subject. Much of the interest in monads in functional programming is the result of recent papers that show how monads can be used to describe all kinds of different programming language features (for example, I/O, manipulation of state, continuations and exceptions) in purely functional languages such as Haskell:

"Comprehending monads", Philip Wadler, Mathematical Structures in Computer Science, Special issue of selected papers from 6th Conference on Lisp and Functional Programming, 1992. Available on the web from:
http://www.cs.bell-labs.com/~wadler/topics/monads.html#monads
"The essence of functional programming", Philip Wadler, Invited talk, 19th Symposium on Principles of Programming Languages, ACM Press, Albuquerque, January 1992. Available on the web from:
http://www.cs.bell-labs.com/~wadler/topics/monads.html#essence
"Imperative functional programming", Simon Peyton Jones and Philip Wadler, 20th Symposium on Principles of Programming Languages, ACM Press, Charlotte, North Carolina, January 1993. Available on the web from:
http://www.cs.bell-labs.com/~wadler/topics/monads.html#imperative
"How to declare an imperative", Philip Wadler, ACM Computing Surveys, to appear. Available on the web from:
http://www.cs.bell-labs.com/~wadler/topics/monads.html#monadsdeclare

3.4. Parsers

How can I write a "parser" in a functional programming language?

A parser is a program that converts a list of input tokens, usually characters, into a value of the appropriate type. A simple example might be a function to find the integer value represented by a string of digits. A more complex example might be to translate programs written in a particular concrete syntax into a suitable abstract syntax as the first stage in the implementation of a compiler or interpreter. There are two common ways to write a parser in a functional language:

Using a parser generator tool. Some functional language implementations support tools that generate a parser automatically from a specification of the grammar. See:
Happy: a parser generator system for Haskell and Gofer, similar to the tool `yacc' for C. Available on the web from:
http://www.dcs.gla.ac.uk/fp/software/happy/.
Ratatosk: a parser and scanner generator for Gofer. Available by ftp from:
Host:	ftp.diku.dk;
Directory:	 /pub/diku/dists.
ML-Yacc and ML-Lex: an LALR parser generator and a lexical analyser generator for Standard ML. Included with SML/NJ, available by ftp from:
Host:	ftp.research.bell-labs.com;
Directory:	 /dist/smlnj.
Using combinator parsing. Parsers are represented by functions and combined with a small set of combinators, leading to parsers that closely resemble the grammar of the language being read. Parsers written in this way can use backtracking. See:
"How to replace failure with a list of successes", Philip Wadler, FPCA '85, Springer Verlag LNCS 201, 1985.
"Higher-order functions for parsing", Graham Hutton, Journal of Functional Programming, Volume 2, Number 3, July 1992. Available on the web from:
http://www.cs.nott.ac.uk/~gmh/bib.html#parsing.

3.5. Strictness

What does it mean to say that a functional programming language is "strict" or "non-strict"?

Here's one (operational) way to explain the difference:

In a strict language, the arguments to a function are always evaluated before it is invoked. As a result, if the evaluation of an expression exp does not terminate properly (for example, because it generates a run-time error or enters an infinite loop), then neither will an expression of the form f(exp). ML and Scheme are both examples of this.
In a non-strict language, the arguments to a function are not evaluated until their values are actually required. For example, evaluating an expression of the form f(exp) may still terminate properly, even if evaluation of exp would not, if the value of the parameter is not used in the body of f. Miranda and Haskell are examples of this approach.
There is much debate in the functional programming community about the relative merits of strict and non-strict languages. It is possible, however, to support a mixture of these two approaches; for example, some versions of the functional language Hope do this.


3.6. Performance

What is the performance of functional programs like?

In some circles, programs written in functional languages have obtained a reputation for lack of performance. Part of this results from the high-level of abstraction that is common in such programs and from powerful features such as higher-order functions, automatic storage management, etc. Of course, the performance of interpreters and compilers for functional languages keeps improving with new technological developments.

Here are a selection of references for further reading:

Over 25 implementations of different functional languages have been compared using a single program, the "Pseudoknot" benchmark, which is a floating-point intensive application taken from molecular biology. See:
"Benchmarking implementations of functional languages with 'Pseudoknot', a float-intensive benchmark", Pieter H. Hartel et al, Journal of Functional Programming, 6(4):621-655, July 1996. Available on the web from:
ftp://ftp.fwi.uva.nl/pub/computer-systems/functional/reports/.
The paper below compares five implementations of lazy functional languages:
"Benchmarking implementations of lazy functional languages", P.H. Hartel and K.G. Langendoen, FPCA 93, ACM, pp 341-349. Available by ftp from:
Host:	ftp.fwi.uva.nl;
Directory:	 pub/functional/reports.
Experiments with a heavily optimising compiler for Sisal, a strict functional language, show that functional programs can be faster than Fortran. See:
"Retire FORTRAN? A debate rekindled", D.C. Cann, Communications of the ACM, 35(8), pp. 81-89, August 1992.
Postscript versions of a number of papers from the 1995 conference on High Performance Functional Computing (HPFC) are available on the web from:
ftp://sisal.llnl.gov/pub/hpfc/index.html.

3.7. Applications

Where can I find out about applications of functional programming?

Here are a selection of places to look:

"Special issue on state-of-the-art applications of pure functional programming languages", edited by Pieter Hartel and Rinus Plasmeijer, Journal of Functional Programming, Volume 5, Number 3, July 1995.
"Applications of functional programming", edited by Colin Runciman and David Wakeling, UCL Press, 1995. ISBN 1-85728-377-5.
An online list of real-world applications of functional programming is maintained, which includes programs written in several different functional languages. The main criterion for being considered a real-world application is that the program was written primarily to perform some task, rather than to experiment with functional programming.
Further details are available on the web from:

http://www.cs.bell-labs.com/~wadler/realworld/.

4. Other resources

This section gives some pointers to other internet resources on functional programming.


4.1. Web pages

Philip Wadler's guide to functional programming on the web:
http://cm.bell-labs.com/cm/cs/who/wadler/guide.html.
Philip Wadler's list of real-world application of functional programming:
http://www.cs.bell-labs.com/~wadler/realworld/.
The SEL-HPC WWW functional programming archive:
http://hypatia.dcs.qmw.ac.uk/SEL-HPC/Articles/FuncArchive.html.
Jon Mountjoy's functional languages page:
http://carol.wins.uva.nl/~jon/func.html.
Claus Reinke's functional programming bookmarks:
http://website.lineone.net/~claus_reinke/FP.html.

4.2. Research groups

The Chalmers functional programming group:
http://www.md.chalmers.se/Cs/Research/Functional/.
The Glasgow functional programming group:
http://www.dcs.gla.ac.uk/fp.
The Nijmegen functional programming group:
http://www.cs.kun.nl/~clean.
The Nottingham foundations of programming group:
http://www.cs.nott.ac.uk/Research/fop/index.html.
The St Andrews functional programming group:
http://www-fp.dcs.st-and.ac.uk/.
The Yale functional programming group:
http://www.cs.yale.edu/HTML/YALE/CS/haskell/yale-fp.html.
The York functional programming group:
http://www.cs.york.ac.uk/fp/.

4.3. Newsgroups

For discussion about ML:
comp.lang.ml.
For discussion about Scheme:
comp.lang.scheme.
For discussion about Lisp:
comp.lang.lisp.
For discussion about APL, J, etc:
comp.lang.apl.

4.4. Bibliographies

Mike Joy's bibliography on functional programming languages, in refer(1) format:
Host:	ftp.dcs.warwick.ac.uk;
Directory:	 /pub/biblio.
Tony Davie's bibliography of over 2,600 papers, articles and books on functional programming, available as a text file or a hypercard stack by ftp from:
Host:	tamdhu.dcs.st-and.ac.uk;
Directory:	 /pub/staple.
"State in functional programming: an annotated bibliography", edited by P. Hudak and D. Rabin, available as a dvi or postscript file by ftp from:
Host:	nebula.cs.yale.edu;
Directory:	 /pub/yale-fp/papers.
Wolfgang Schreiner's annotated bibliography of over 350 publications on parallel functional programming (most with abstracts), available on the web from:
http://www.risc.uni-linz.ac.at/people/schreine/papers/pfpbib.ps.gz.

4.5. Translators

The smugweb system for typesetting Haskell code in TeX, available from:
http://www5.informatik.uni-jena.de/~joe/smugweb.html.
The miratex package for typesetting Miranda(TM) code in TeX, available from:
http://www.cs.tcd.ie/www/jgllgher/miratex/index.html.
Denis Howe's translators from Miranda(TM) to LML and Haskell, available from:
http://wombat.doc.ic.ac.uk/pub/mira2lml;
http://wombat.doc.ic.ac.uk/pub/mira2hs.

5. Languages

This section gives a brief overview of a number of programming languages that support aspects of the functional paradigm, and some pointers to relevant literature and internet resources. The table below classifies the languages into strict/non-strict and sequential/concurrent, and may be useful when searching for suitable languages for particular applications. Some of the languages have multiple versions with different classifications (see the language overviews for further details), but for simplicity only the most common version of each language is considered in the table.

Sequential:	Concurrent:
Strict:	ASpecT 
Caml 
FP 
J 
Mercury 
ML 
OPAL 
Scheme	Erlang 
NESL 
Oz 
Pizza 
Sisal
Non-strict:	Gofer 
Haskell 
Hope 
Hugs 
Miranda	Clean 
Id

5.1. ASpecT

ASpecT is a strict functional language, developed at the University of Bremen, originally intended as an attempt to provide an implementation for (a subset of) Algebraic Specifications of Abstract Datatypes. The system was designed to be as user-friendly as possible, including overloading facilities and a source-level debugger. For reasons of efficiency, the system uses call-by-value evaluation and reference counting memory management.

Over the years more and more features have been added, including subsorting, functionals, and restricted polymorphism. The ASpecT compiler translates the functional source code to C, resulting in fast and efficient binaries. ASpecT has been ported to many different platforms, including Sun3, Sun4, Dec VAX, IBM RS6000, NeXT, Apple A/UX, PC (OS/2, Linux), Amiga and Atari ST/TT. The ASpecT compiler is available by ftp from:

Host:	ftp.Uni-Bremen.DE;
Directory:	 /pub/programming/languages/ASpecT.
The most important application of ASpecT to date is the interactive graph visualization system daVinci; currently (September '96), version 2.0.x is composed of 34.000 lines of ASpecT code, 12.000 lines of C code and 8000 lines of Tcl/Tk code. daVinci is an X11 program, and is available for UNIX workstations from Sun, HP, IBM, DEC, SGI, and for Intel PCs with a UNIX operating system. Further information about daVinci is available on the web from:

http://www.Informatik.Uni-Bremen.DE/~davinci.

5.2. Caml

Caml is a dialect of the ML language developed at INRIA that does not comply to the Standard, but actually tries to go beyond the Standard, in particular in the areas of separate compilation, modules, and objects. Two implementations of Caml are available:

The older implementation, Caml Light, is distinguished by its small size, modest memory requirements, availability on microcomputers, simple separate compilation, interface with C, and portable graphics functions. It runs on most Unix machines, on the Macintosh and on PCs under Ms Windows and MSDOS. The current version at the time of writing is 0.71.
A more ambitious implementation, Objective Caml (formerly known as Caml Special Light), is also available. It adds the following extensions to Caml Light:
Full support for objects and classes, here combined for the first time with ML-style type reconstruction;
A powerful module calculus in the style of Standard ML, but providing better support for separate compilation;
A high-performance native code compiler, in addition to a Caml Light-style bytecode compiler.
Objective Caml is available for Unix and Windows 95/NT, with the native-code compiler supporting the following processors: Alpha, Sparc, Pentium, Mips, Power, HPPA.

Both implementations of Caml are available by ftp from:

Host:	ftp.inria.fr;
Directory:	 /lang/caml-light.
Further information about Caml is available on the web from:

http://pauillac.inria.fr/caml/index-eng.html (English);
http://pauillac.inria.fr/caml/index-fra.html (French).


5.3. Clean

The Concurrent Clean system is a programming environment for the functional language Concurrent Clean, developed at the University of Nijmegen in The Netherlands. The system is one of the fastest implementations of functional languages available at the time of writing. Through the use of uniqueness typing, it is possible to write purely functional interactive programs, including windows, menus, dialogs, etc. It is also possible to develop real-life applications that interface with non-functional systems. With version 1.0, the language emerged from an intermediate language to a proper programming language. Features provided by the language include:

Lazy evaluation;
Modern input/output;
Annotations for parallelism;
Automatic strictness analysis;
Annotations for evaluation order;
Inferred polymorphic uniqueness types;
Records, mutable arrays, module structure;
Existential types, type classes, constructor classes;
Strong typing, based on the Milner/Mycroft scheme.
Concurrent Clean is available for PCs (Microsoft Windows, Linux), Macintoshes (Motorola, PowerPC), and Sun4s (Solaris, SunOS). The system is available by ftp from:

Host:	ftp.cs.kun.nl;
Directory:	/pub/Clean.
Further information about Concurrent Clean is available on the web from:

http://www.cs.kun.nl/~clean.
A book describing the background and implementation of Concurrent Clean is also available:

"Functional programming and parallel graph rewriting", Rinus Plasmeijer and Marko van Eekelen, Addison Wesley, International Computer Science Series. ISBN 0-201-41663-8

5.4. Erlang

Erlang is a dynamically typed concurrent functional programming language for large industrial real-time systems. Features of Erlang include:

Modules;
Recursion equations;
Explicit concurrency;
Pattern matching syntax;
Dynamic code replacement;
Foreign language interface;
Real-time garbage collection;
Asynchronous message passing;
Relative freedom from side effects;
Transparent cross-platform distribution;
Primitives for detecting run-time errors.
Erlang is freely available on the web from:

http://www.erlang.org.
Erlang is distributed together with full source code for a number of applications, including:

Inets - HTTP 1.0 server and FTP client;
Orber - CORBA v2.0 Object Request Broker (ORB);
ASN.1 - compile-time and runtime package for ASN.1;
SNMP - extensible SNMP v1/v2 agent and MIB compiler;
Mnesia - distributed real-time database for Erlang;
Mnemosyne - optional query language for Mnesia.
See also:

"Concurrent programming in Erlang" (second edition), J. Armstrong, M. Williams, R. Virding, and Claes Wikström, Prentice Hall, 1996. ISBN 0-13-508301-X.

5.5. FP

FP is a side-effect free, combinator style language, described in:

"Can programming be liberated from the von Neumann style?", John Backus, Communications of the ACM, 21, 8, pp.613-641, 1978.
A interpreter and a compiler (to C) for FP are available by ftp from:

Host:	gatekeeper.dec.com;
Directory:	 pub/usenet/comp.sources.unix/volume13/funcproglang;
Directory:	 pub/usenet/comp.sources.unix/volume20/fpc.
The Illinois FP system supports a modified version of FP that has a more Algol-like syntax and structure, and is described in the following article:

"The Illinois functional programming interpreter", Arch D. Robison, Proceedings of the SIGPLAN '87 Symposium on Interpreters and Interpretive Techniques, SIGPLAN notices, Volume 22, Number 7, July 1987.

5.6. Gofer

The Gofer system provides an interpreter for a small language based closely on the current version of the Haskell report. In particular, Gofer supports lazy evaluation, higher-order functions, polymorphic typing, pattern-matching, support for overloading, etc.

The most recent version of Gofer, 2.30a, is available by ftp from:

Host:	ftp.cs.nott.ac.uk;
Directory:	 /nott-fp/languages/gofer.
Gofer runs on a wide range of machines including PCs, Ataris, Amigas, etc. as well as larger Unix-based systems. A version for the Apple Macintosh is also available, by ftp from:

Host:	ftp.dcs.glasgow.ac.uk;
Directory:	 /pub/haskell/gofer/macgofer.
Please note the spelling of Gofer, derived from the notion that functional languages are GO(od) F(or) E(quational) R(easoning). This is not to be confused with `Gopher', the widely used internet distributed information delivery system.


5.7. Haskell

In the mid-1980s, there was no "standard" non-strict, purely-functional programming language. A language-design committee was set up in 1987, and the Haskell language is the result. At the time of writing, Haskell 98 is the latest version of the language. Further information about Haskell, including the latest version of the Haskell report, is available on the web from:

http://www.haskell.org/;
http://www-i2.informatik.rwth-aachen.de/Forschung/FP/Haskell/.

At the time of writing, there are three different Haskell systems available, developed by groups at Chalmers, Glasgow and Yale. These systems are available by ftp from the following sites:

Host:	ftp.cs.chalmers.se;
Directory:	 /pub/haskell.
Host:	ftp.dcs.glasgow.ac.uk;
Directory:	 /pub/haskell.
Host:	haskell.cs.yale.edu;
Directory:	 /pub/haskell.
Host:	ftp.cs.nott.ac.uk;
Directory:	 /haskell.
Host:	src.doc.ic.ac.uk;
Directory:	 /pub/computing/programming/languages/haskell.
You can join the Haskell mailing list by emailing majordomo@dcs.gla.ac.uk, with a message body of the form: subscribe haskell Forename Surname <email@address>.


5.8. Hope

Hope is a small polymorphically-typed functional language, and was the first language to use call-by-pattern. Hope was originally strict, but there are versions with lazy lists, or with lazy constructors but strict functions. Further information is available on the web from:

http://www.soi.city.ac.uk/~ross/Hope/.

5.9. Hugs

Hugs, the Haskell User's Gofer System, is an interpreted implementation of Haskell with an interactive development environment much like that of Gofer. Further information about Hugs is available on the web from:

http://www.haskell.org/hugs/

5.10. Id

Id is a dataflow programming language, whose core is a non-strict functional language with implicit parallelism. It has the usual features of many modern functional programming languages, including a Hindley/Milner type inference system, algebraic types and definitions with clauses and pattern matching, and list comprehensions.


5.11. J

J was designed and developed by Ken Iverson and Roger Hui. It is similar to the language APL, departing from APL in using using the ASCII alphabet exclusively, but employing a spelling scheme that retains the advantages of the special alphabet required by APL. It has added features and control structures that extend its power beyond standard APL. Although it can be used as a conventional procedural programming language, it can also be used as a pure functional programming language. Further information about J is available on the web from:

http://www.jsoftware.com.

5.12. Miranda

Miranda was designed in 1985-6 by David Turner with the aim of providing a standard non-strict purely functional language, and is described in the following articles:

"Miranda: a non-strict functional language with polymorphic types", D.A. Turner, Proceedings FPLCA, Nancy, France, September 1985 (Springer LNCS vol 201, pp 1-16).
"An overview of Miranda", D.A. Turner, SIGPLAN Notices, vol 21, no 12, pp 158-166, December 1986.
Miranda was the first widely disseminated language with non-strict semantics and polymorphic strong typing, and is running at over 600 sites, including 250 universities. It is widely used for teaching, often in conjunction with "Introduction to Functional Programming", by Bird and Wadler, which uses a notation closely based on Miranda. It has also had a strong influence on the subsequent development of the field, and provided one of the main inputs for the design of Haskell.

The Miranda™ system is a commercial product of Research Software Limited. Miranda release two (the current version at the time of writing) supports unbounded precision integers and has a module system with provision for parameterized modules and a built in "make" facility. The compiler works in conjunction with a screen editor and programs are automatically recompiled after edits. There is also an online reference manual.

Further information about Miranda is available on the web from:

http://miranda.org.uk
Miranda is not in the public domain but is free for personal and educational use.


5.13. Mercury

Mercury is a logic/functional programming language, which combines the clarity and expressiveness of declarative programming with advanced static analysis and error detection facilities. It has a strong type system, a module system (allowing separate compilation), a mode system, algebraic data types, parametric polymorphism, support for higher-order programming, and a determinism system --- all of which are aimed at both reducing programming errors and providing useful information for programmers and compilers.

The Mercury compiler is written in Mercury itself, and compiles to C. The compiler is available for a variety of platforms running Unix and Microsoft operating systems.

Further information about Mercury is available on the web from:

http://www.cs.mu.oz.au/mercury.

5.14. ML

ML stands for meta-language, and is a family of advanced programming languages with (usually) functional control structures, strict semantics, a strict polymorphic type system, and parameterized modules. It includes Standard ML, Lazy ML, CAML, CAML Light, and various research languages. Implementations are available on many platforms, including PCs, mainframes, most models of workstation, multi-processors and supercomputers. ML has many thousands of users, and is taught to undergraduates at many universities.

There is a moderated usenet newsgroup, comp.lang.ml, for discussion of topics related to ML. A list of frequently asked questions for this newsgroup (which includes pointers to many of the different implementations and variants of ML) is available by ftp from:

Host:	pop.cs.cmu.edu;
Directory:	 /usr/rowan/sml-archive/.
The Standard ML language is formally defined by:

"The Definition of Standard ML - Revised", Robin Milner, Mads Tofte, Robert Harper, and David MacQueen, MIT, 1997. ISBN 0-262-63181-4.
Further information is available on the web from:

http://mitpress.mit.edu/promotions/books/MILDPRF97.
"Commentary on Standard ML", Robin Milner and Mads Tofte, MIT, 1990. ISBN 0-262-63137-7. Further information is available on the web from:
http://mitpress.mit.edu/promotions/books/MILCPF90.
There is now a revised version of Standard ML, sometimes referred to as "Standard ML '97" to distinguish it from the original 1990 version. The new version combines modest changes in the language with a major revision and expansion of the SML Basis Library. Further details about Standard ML '97 are available on the web from:

http://cm.bell-labs.com/cm/cs/what/smlnj/sml97.html.

5.15. NESL

NESL is a fine-grained, functional, nested data-parallel language, loosly based on ML. It includes a built-in parallel data-type, sequences, and parallel operations on sequences (the element type of a sequence can be any type, not just scalars). It is based on eager evaluation, and supports polymorphism, type inference and a limited use of higher-order functions. Currently, it does not have support for modules and its datatype definition is limited. Except for I/O and some system utilities it is purely functional (it does not support reference cells or call/cc).

The NESL compiler is based on delayed compilation and compiles separate code for each type a function is used with (compiled code is monomorphic). The implementation therefore requires no type bits, and can do some important data-layout optimizations (for example, double-precision floats do not need to be boxed, and nested sequences can be laid out efficiently across multiple processors.) For several small benchmark applications on irregular and/or dynamic data (for example, graphs and sparse matrices) it generates code comparable in efficiency to machine-specific low-level code (for example, Fortran or C.)

The current implementation of NESL runs on workstations, the Connection Machines CM2 and CM5, the Cray Y-MP and the MasPar MP2.

Further information about NESL is available on the web from:

http://www.cs.cmu.edu/afs/cs.cmu.edu/project/scandal/public/www/nesl.html
or by ftp from:

Host:	nesl.scandal.cs.cmu.edu;
Directory:	 nesl.
You can join to the NESL mailing list by emailing nesl-request@cs.cmu.edu.


5.16. OPAL

The language OPAL has been designed as a testbed for the development of functional programs. Opal molds concepts from Algebraic Specification and Functional Programming, which shall favor the formal development of large production-quality software that is written in a purely functional style. The core of OPAL is a strongly typed, higher-order, strict applicative language that belongs to the tradition of Hope and ML. The algebraic flavour of OPAL shows up in the syntactical appearance and in the preference of parameterization to polymorphism.

OPAL is used for research on the highly optimizing compilation of applicative languages. This has resulted in a compiler which produces very efficient code. The OPAL compiler itself is entirely written in OPAL. Installation is straightforward and has been successfully performed for SPARCs, DECstations, NeXTs, and PCs running LINUX.

Further information about OPAL is available by ftp from:

Host:	ftp.cs.tu-berlin.de;
Directory:	 /pub/local/uebb/.

5.17. Oz

Oz is a concurrent constraint programming language designed for applications that require complex symbolic computations, organization into multiple agents, and soft real-time control. It is based on a new computation model providing a uniform foundation for higher-order functional programming, constraint logic programming, and concurrent objects with multiple inheritance. From functional languages Oz inherits full compositionality, and from logic languages Oz inherits logic variables and constraints (including feature and finite domain constraints.) Search in Oz is encapsulated (no backtracking) and includes one, best and all solution strategies.

DFKI Oz is an interactive implementation of Oz featuring am Emacs programming interface, a concurrent browser, an object-oriented interface to Tcl/Tk, powerful interoperability features (sockets, C, C++), an incremental compiler, a garbage collector, and support for stand-alone applications. Performance is competitive with commercial Prolog and Lisp systems. DFKI Oz is available for many platforms running Unix/X, including Sparcs and 486 PCs, and has been used for applications including simulations, multi-agent systems, natural language processing, virtual reality, graphical user interfaces, scheduling, placement problems, and configuration.

Further information about Oz is available on the web from:

http://www.ps.uni-sb.de/oz/
or by ftp from:

Host:	ftp.ps.uni-sb.de;
Directory:	 /pub/oz.
Specific questions on Oz may be emailed oz@ps.uni-sb.de. You can join the Oz users mailing list by emailing oz-users-request@ps.uni-sb.de.


5.18. Pizza

Pizza is a strict superset of Java that incorporates three ideas from functional programming:

Parametric polymorphism;
Higher-order functions;
Algebraic data types.
Pizza is defined by translation into Java and compiles into the Java Virtual Machine, requirements which strongly constrain the design space. Thus Pizza programs interface easily with Java libraries, and programs first developed in Pizza may be automatically converted to Java for ease of maintenance. The Pizza compiler is itself written in Pizza, and may be used as a replacement for Sun's Java compiler (except that the Pizza compiler runs faster).

Pizza was designed by Martin Odersky and Philip Wadler, and implemented by Odersky. The design is described in the following paper:

"Pizza into Java: translating theory into practice", Martin Odersky and Philip Wadler, 24th ACM Symposium on Principles of Programming Languages, Paris, January 1997.
The paper, downloads, and other information on Pizza is available on the web from any of the following locations (which mirror each other):

http://www.cis.unisa.edu.au/~pizza;
http://cm.bell-labs.com/cm/cs/who/wadler/pizza/welcome.html;

http://wwwipd.ira.uka.de/~pizza;

http://www.math.luc.edu/pizza/;

ftp://ftp.eecs.tulane.edu/pub/maraist/pizza/welcome.html.

Pizza has received a `cool' award from Gamelan ( http://www-c.gamelan.com/.)


5.19. Scheme

Scheme is a dialect of Lisp that stresses conceptual elegance and simplicity. It is specified in R4RS and IEEE standard P1178. Scheme is much smaller than Common Lisp; the specification is about 50 pages. Scheme is often used in computer science curricula and programming language research, due to its ability to simply represent many programming abstractions.

Further information about Scheme is available on the web from:

http://www.schemers.org.
There is an unmoderated usenet newsgroup, comp.lang.scheme, for the discussion of topics related to Scheme. A list of frequently asked questions (which includes details of the many books and papers concerned with Scheme) for this newsgroup is available by ftp from:

Host:	ftp.think.com;
Directory:	 /public/think/lisp/.

5.20. Sisal

Sisal (Streams and Iteration in a Single Assignment Language) is a functional language designed with several goals in mind: to support clear, efficient expression of scientific programs; to free application programmers from details irrelevant to their endeavors; and, to allow automatic detection and exploitation of the parallelism expressed in source programs.

Sisal syntax is modern and easy to read; Sisal code looks similar to Pascal, Modula, or Ada, with modern constructs and long identifiers. The major difference between Sisal and more conventional languages is that it does not express explicit program control flow.

Sisal semantics are mathematically sound. Programs consist of function definitions and invocations. Functions have no side effects, taking as inputs only explicitly passed arguments, and producing only explicitly returned results. There is no concept of state in Sisal. Identifiers are used, rather than variables, to denote values, rather than memory locations.

The Sisal language currently exists for several shared memory and vector systems that run Berkeley Unix(tm), including the Sequent Balance and Symmetry, the Alliant, the Cray X/MP and Y/MP, Cray 2, and a few other less well-known ones. Sisal is available on sequential machines such as Sparc, RS/6000, and HP. Sisal also runs under MS-DOS and Macintosh Unix (A/UX). It's been shown to be fairly easy to port the entire language system to new machines.

Further information about Sisal is available on the web from:

http://www.llnl.gov/sisal/SisalHomePage.html.
The original version of this Frequently Asked Questions list (FAQ) was compiled and edited by Mark P. Jones. All questions, comments, corrections, and suggestions regarding this document should be addressed to the current editor, Graham Hutton.