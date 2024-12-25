# Mini-Lisp, Compiler Final Project
## Implement Approach

## Execute Command
```shel=
bison -d -o a.tab.c a.y
gcc -c -g -I.. a.tab.c
flex -o a.yy.c a.l 
gcc -c -g -I.. a.yy.c
gcc -o a a.tab.o a.yy.o -lfl
type data/01_1.lsp | .\a > test_output/a1_1.out
type data/01_2.lsp | .\a > test_output/a1_2.out
type data/02_1.lsp | .\a > test_output/a2_1.out
type data/02_2.lsp | .\a > test_output/a2_2.out
type data/03_1.lsp | .\a > test_output/a3_1.out
type data/03_2.lsp | .\a > test_output/a3_2.out
type data/04_1.lsp | .\a > test_output/a4_1.out
type data/04_2.lsp | .\a > test_output/a4_2.out
type data/05_1.lsp | .\a > test_output/a5_1.out
type data/05_2.lsp | .\a > test_output/a5_2.out
type data/06_1.lsp | .\a > test_output/a6_1.out
type data/06_2.lsp | .\a > test_output/a6_2.out
type data/07_1.lsp | .\a > test_output/a7_1.out
type data/07_2.lsp | .\a > test_output/a7_2.out
type data/08_1.lsp | .\a > test_output/a8_1.out
type data/08_2.lsp | .\a > test_output/a8_2.out
```
## reference
- [Github: flyotlin/mini-lisp](<https://github.com/flyotlin/mini-lisp/tree/master?tab=readme-ov-file#mini-lisp-final-project>)
- [Github: Zane2453/Mini-LISP-interpreter_Lex-Yacc](<https://github.com/Zane2453/Mini-LISP-interpreter_Lex-Yacc/tree/master>)
