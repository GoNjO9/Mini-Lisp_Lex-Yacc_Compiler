# Mini-Lisp, Compiler Final Project
## Implement Approach
### Main Idea
Build an AST while parsing and traverse the AST in pos-order.

---

### Node stucture
```C=
struct Node{
    char*   type;
    int     value;
    char*   cval;
    struct Node* left;
    struct Node* middle;
    struct Node* right;
};
```
`type` is used to specify node
`value` store integer value (e.g. the operation result)
`cval` store string value (e.g. function/variable name)
`left` / `right` / `middle` pointer to node's children
> For most types of node the middle pointer is point to NULL, used by if statement only (need to handle `test`, `then`, `else`)

- Node Type
    Not all types of nodes will be processed during traversal, some node types are created to distinguish different functionalities in the code. (for better understanding the AST)
    
    **All the types**
    ```
    stmts
    pn         //printnum
    pb         //printbool
    bool       
    number
    add        
    sub
    mul
    div
    mod
    >
    <
    equ        //equal
    neg        //equ->neg if left!=right
    and
    or
    not
    if
    variable
    func
    func_call
    func_id
    null
    string     //for creating node in lex side
    ```
    
---

### Syntax Validation
just print "Syntax error" at `yyerror` .

---

### print-num
`print-num` itself is a **node**, and its **left** point to the number (can also be some numerical operations), **right** point to NULL.

If the syntax is correct, we can make sure `print-num` always have a child on its `left`.



```C=
void traverse(struct Node* root) {
...
    if(root->type=="pn") /* print-num */ {
        printf("%d\n", root->left->value);
    }
...
}
```
... And we just need to print `root->left->value`.

- **AST structure**
    ![image](<https://imgur.com/FmCKBAo> -40%x)



---

### Numerical Operations

---

### Logical Operations

---

### if Expression

---

### Variable Definition

---

### Function

---

### Named Function

## Execute Command (Powershell)
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
