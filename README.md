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
> *For most types of node the middle pointer is point to NULL, used by if statement only (need to handle `test`, `then`, `else`)*

---

### Node Type
Not all types of nodes will be processed during traversal, some node types are created to distinguish different functionalities in the code. (for better understanding the AST)
    
**Pure value types**

- *string* => ID only
- *bool* => 1 or 0
- *number*
    
**Numerical/Logical operators**
- *add* 
- *sub*
- *mul*
- *div*
- *mod*
- *>*
- *<*
- *equ* => equal
- *neg* => node with type **equ** change to **neg** if left != right
- *and*
- *or*
- *not* => needs/accepts only one `exp` to operate, `left` is always NULL

**others**
- *stmts*
- *pn* => print-num
- *pb* => print-bool
    > these 2 types of nodes can be easily distinguished during traversal to determine whether to output a boolean or an integer.
- *if* 
- *variable* => get variable value by mapping
- *func* => function "root", we can map `func_name` to **func_node**
- *func_call*
- *func_id* => it's actually the node of parameters.
- *null* => only used when creating an empty map (`char*` => `Node*`)

    
    
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


---

### Numerical/Logical Operations

use some "train-like" structure to handle operators with variable number of operands
```yacc=
add 
    : '(' ADD adds ')' {
        $$=$3;
    }
adds
    : exp adds {
        $$=createNode($1, $2, "add");
    }
    | exp {
        $$=$1;
    }
```
I feel smart by just using `value*(-1)+1` to implement the not operator.
```C=
void traverse(struct Node* root) {
    ...
    if(root->type=="not") {
        root->value=root->left->value*(-1)+1;
    }
...
}
```
Just like other operators with only one operand, we place the value to be "not"-ed on the left of the not_node.


---

### print-bool

Because I did some strange thing on `equ_node`, it has to be check separately (type `equ` and `neg`).
```C=
void traverse(struct Node* root) {
    ...
    if(root->type=="pb") {
        if(root->left->type=="neg") {
            printf("#f\n");
        } else if(root->left->type=="equ") {
            printf("#t\n");
        } else if(root->left->value==0) {
            printf("#f\n");
        } else printf("#t\n");
    }
...
}
```

---

### if Expression

**middle pointer**
```yacc=
if_exp 
    : '(' IF test_exp then_exp else_exp ')' {
        $$ = createNode($4, $5, "if");
        $$->middle = $3;
    }
```
You can place any part *(test, then, else)* on the middle pointer, and later during traversal, simply traverse the middle node independently.
```C=
void traverse(struct Node* root) {
    ...
    if(root->type=="if") {
        traverse(root->middle);
        if(root->middle->value==1){ //if node getting "then" value
            root->value = root->left->value;
        } else { //if node getting "else" value
            root->value = root->right->value;
        }
    }
...
}
```
This map is <char* => Node*>. When accessing values only, you can use `get`.

---

### map in C
Since C does not have a map-like data structure, I writes a simple working map with struct and some functions.
```C=
struct Map{
    char* key[MAX_MAP_SIZE];
    struct Node *nodes[MAX_MAP_SIZE];
    int length; 
};

/* map functions */
void add(struct Map*, char*, int);
void addNode(struct Map*, char*, struct Node*);
int get(struct Map*, char*);
struct Node* getNode(struct Map*, char*);
void printMap(struct Map*, char*);
void freeMap(struct Map*);

/* map stack functions */
void push(struct Map*);
struct Map* pop();

/* stack of map */
struct Map* stack[MAX_STACK_SIZE];
```
The stack is an array of `struct Map*`.

The maps stored on the stack can be used to store local variables within a function. When the function terminates, its corresponding map is popped off the stack.

This approach allows variable access to be handled as follows:

1. Check whether the stack contains any elements to determine if the program is currently within a function.
2. If the variable is not found in the map on the stack-top, the global map is checked to determine if the variable is a **global variable**.
3. If a variable is found in the maps on the stack-top, the variable is a local variable and will not affect a global variable with the same name (because they reside in different maps).

---

### Variable Definition
```C=
void traverse(struct Node* root) {
    ...
    if(root->type=="variable") {
        if(sp==0) /* map stack is empty */ {
            if(get(map, root->cval)!=-1048576) {
                root->value = get(map, root->cval);
            }
        } else {
            struct Map* local_var = stack[sp-1];
            if(get(local_var, root->cval)!=-1048576) {
                root->value = get(local_var, root->cval);
            } else {
                if(get(map, root->cval)!=-1048576) {
                    root->value = get(map, root->cval);
                }
            }
        }
    }
...
}
```

As above mentioned, when a variable is accessed during traversal, it undergoes these checks to determine whether it is a local variable (found in the stack's map) or a global variable (found in the global map).

---

### Function

Basically combines every parts above.
```C=
void traverse(struct Node* root) {
    ...
    if(root->type=="func_call") {
        struct Map* func_map = createMap();
        struct Node* funId = root->left->left;
        struct Node* parameter = root->right;
        while(funId!=NULL&&parameter!=NULL) {
            add(func_map, funId->left->cval, parameter->left->value);
            funId = funId->right;
            parameter = parameter->right;
        }
        push(func_map);
        traverse(root->left->right);
        root->value = root->left->right->value;
        freeMap(pop());
        return;
    }
...
}
```
I drew my envisioned AST (by the way yacc do the parsing). Then, I wrote a loop to traverse top `fun_ids` (`root->left->left`) and top `params` (`root->right`) simultaneously, and the assign the arguments to local variables.

![image](https://hackmd.io/_uploads/ByH4MoKBJl.png)

---

### Named Function

I create another map to store `<func_name=>func_exp>`, just in case.
Since the map's values are of type `Node*`, we can easily translate a `func_name` into its corresponding `func_exp`.
```yacc=
def_stmt
    : '(' DEF var exp')' {
        if($4->type!="func") {
            traverse($4);
            addNode(map, $3->cval, $4);
            $$=$4;
        } else {
            addNode(funcs, $3->cval, $4);
            $$=$4;
        }
    }
    ;
```
I use the same rule from *variable define*. Map the `func_name` to the `func_exp` here.
```yacc=
fun_call
    : '(' fun_exp params ')' {
        $$=createNode($2, $3, "func_call");
    }
    | '(' fun_name params ')' { // this part
        $$=createNode(getNode(funcs, $2->cval), $3, "func_call");
    }
```
Now we can create the same AST structure as above.

## Execute Command (Powershell)
```shel=
bison -d -o a.tab.c a.y
gcc -c -g -I.. a.tab.c
flex -o a.yy.c a.l 
gcc -c -g -I.. a.yy.c
gcc -o a a.tab.o a.yy.o -lfl
type test_data/01_1.lsp | .\a > test_output/a1_1.out
type test_data/01_2.lsp | .\a > test_output/a1_2.out
type test_data/02_1.lsp | .\a > test_output/a2_1.out
type test_data/02_2.lsp | .\a > test_output/a2_2.out
type test_data/03_1.lsp | .\a > test_output/a3_1.out
type test_data/03_2.lsp | .\a > test_output/a3_2.out
type test_data/04_1.lsp | .\a > test_output/a4_1.out
type test_data/04_2.lsp | .\a > test_output/a4_2.out
type test_data/05_1.lsp | .\a > test_output/a5_1.out
type test_data/05_2.lsp | .\a > test_output/a5_2.out
type test_data/06_1.lsp | .\a > test_output/a6_1.out
type test_data/06_2.lsp | .\a > test_output/a6_2.out
type test_data/07_1.lsp | .\a > test_output/a7_1.out
type test_data/07_2.lsp | .\a > test_output/a7_2.out
type test_data/08_1.lsp | .\a > test_output/a8_1.out
type test_data/08_2.lsp | .\a > test_output/a8_2.out
```


## reference
- [Github: flyotlin/mini-lisp](<https://github.com/flyotlin/mini-lisp/tree/master?tab=readme-ov-file#mini-lisp-final-project>)
- [Github: Zane2453/Mini-LISP-interpreter_Lex-Yacc](<https://github.com/Zane2453/Mini-LISP-interpreter_Lex-Yacc/tree/master>)
