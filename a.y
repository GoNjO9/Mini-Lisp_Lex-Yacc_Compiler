%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int yylex(void); 
void yyerror(const char *message);

#define MAX_MAP_SIZE 100
#define MAX_STACK_SIZE 20

struct Node{
    char*   type;
    /*
    all possible types:
        stmts
        pn (printnum)
        pb (printbool)
        bool
        number
        add
        sub
        mul
        div
        mod
        >
        <
        equ
        neg (for equ negative)
        and
        or
        not
        if
        variable
        func
        func_call
        func_id
        null (do nothing with this node)
        string (only for creating node in lex)
    */
    int     value;
    char*   cval;
    struct Node* left;
    struct Node* middle;
    struct Node* right;
};

struct Map{
    char* key[MAX_MAP_SIZE];
    struct Node *nodes[MAX_MAP_SIZE];
    int length; 
};

/* function prototype */
int sp;
struct Node* createNode(struct Node*, struct Node*, char*);
struct Map* createMap();
void traverse(struct Node*);
void add(struct Map*, char*, int);
void addNode(struct Map*, char*, struct Node*);
int get(struct Map*, char*);
struct Node* getNode(struct Map*, char*);
void printMap(struct Map*, char*);
void freeMap(struct Map*);
void push(struct Map*);
struct Map* pop();

/* global variable */
struct Node *root=NULL;
struct Map *map=NULL;
struct Map *funcs=NULL;
struct Map* stack[MAX_STACK_SIZE];

%}
%union {
    int ival;
    char* word;
    struct Node* nd;
}

%token PRINTNUM PRINTBOOL
%token ADD SUB MUL DIV MOD GREATER SMALLER EQU
%token AND OR NOT 
%token DEF IF FUN
%token<ival> BOOL NUMBER
%token<nd> ID

%type<nd> var 
%type<nd> num_op add adds sub mul muls div mod 
%type<nd> greater smaller equ equs
%type<nd> logical_op and ands or ors not
%type<nd> prog stmts stmt print_stmt exp def_stmt
%type<nd> if_exp test_exp then_exp else_exp
%type<nd> fun_exp fun_id fun_ids fun_body 
%type<nd> fun_call param params fun_name 
%%
prog 
    : stmts         {root=$1;}
stmts
    : stmt stmts    {$$=createNode($1, $2, "stmts");}
    | stmt          {$$=$1;}
stmt 
    : exp           {$$=$1;}
    | print_stmt    {$$=$1;}
    | def_stmt      {$$=$1;}
    ;
print_stmt 
    : '(' PRINTNUM exp ')'      {$$=createNode($3, NULL, "pn");}
    | '(' PRINTBOOL exp ')'     {$$=createNode($3, NULL, "pb");
    add(map, "Alice", 25);
    add(map, "Bob", 30);
    add(map, "Charlie", 35);}
    ;
exp 
    : BOOL {
        $$=createNode(NULL, NULL, "bool");
        $$->value=$1;
    }
    | NUMBER {
        $$=createNode(NULL, NULL, "number");
        $$->value=$1;
    }
    | num_op        {$$=$1;}
    | logical_op    {$$=$1;}
    | if_exp        {$$=$1;}
    | var           {$$=$1; $$->type="variable"}
    | fun_exp       {$$=$1;}
    | fun_call      {$$=$1;}
    ;
num_op 
    : add       {$$=$1;}
    | sub       {$$=$1;}
    | mul       {$$=$1;}
    | div       {$$=$1;}
    | mod       {$$=$1;}
    | greater   {$$=$1;}
    | smaller   {$$=$1;}
    | equ       {$$=$1;}
    ;
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
mul 
    : '(' MUL muls ')' {
        $$=$3;
    }
muls
    : exp muls {
        $$=createNode($1, $2, "mul");
    }
    | exp {
        $$=$1;
    }
sub 
    : '(' SUB exp exp ')' {
        $$=createNode($3, $4, "sub");
    }
div 
    : '(' DIV exp exp ')' {
        $$=createNode($3, $4, "div");
    }
mod 
    : '(' MOD exp exp ')' {
        $$=createNode($3, $4, "mod");
    }
greater 
    : '(' GREATER exp exp ')' {
        $$=createNode($3, $4, ">");
    }
smaller 
    : '(' SMALLER exp exp ')' {
        $$=createNode($3, $4, "<");
    }
equ 
    : '(' EQU equs ')' {
        $$=$3;
    }
equs
    : exp equs {
        $$=createNode($1, $2, "equ");
    }
    | exp {
        $$=$1;
    }
logical_op 
    : and {$$=$1;}
    | or  {$$=$1;}
    | not {$$=$1;}
    ;
and 
    : '(' AND ands ')' {
        $$=$3;
    }
ands
    : exp ands {
        $$=createNode($1, $2, "and");
    }
    | exp {
        $$=$1;
    }
or 
    : '(' OR ors ')' {
        $$=$3;
    }
ors
    : exp ors {
        $$=createNode($1, $2, "or");
    }
    | exp {
        $$=$1;
    }
not 
    : '(' NOT exp ')' {
        $$=createNode($3, NULL, "not")
    }
if_exp 
    : '(' IF test_exp then_exp else_exp ')' {
        $$ = createNode($4, $5, "if");
        $$->middle = $3;
    }
test_exp 
    : exp {$$=$1;}
then_exp 
    : exp {$$=$1;}
else_exp 
    : exp {$$=$1;}

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
var
    : ID {$$=$1;}

fun_call
    : '(' fun_exp params ')' {
        $$=createNode($2, $3, "func_call");
    }
    | '(' fun_name params ')' {
        $$=createNode(getNode(funcs, $2->cval), $3, "func_call");
    }
fun_exp 
    : '(' FUN fun_id fun_body ')' {
        $$=createNode($3, $4, "func");
    }
fun_id 
    : '(' fun_ids ')' {
        $$=$2;
    }
fun_ids
    : ID fun_ids {
        $$=createNode($1, $2, "func_id");
    }
    | /* empty */ {
        $$=NULL;
    }
fun_body 
    : exp {$$=$1;}
params
    : param params {
        $$=createNode($1, $2, "func_id");
    }
    | {
        $$=NULL;
    }
param   
    : exp {
        $$=$1;
    }
    
fun_name 
    : ID {$$=$1;}
%%
void traverse(struct Node* root) {
    if(root==NULL) return;
    /* printf("visiting %s, %d\n", root->type, root->value); */
    /* printf("go to visit(left)\n"); */
    traverse(root->left);
    /* printf("go to visit(right)\n"); */
    traverse(root->right);
    /* printf(">>>%s: ", root->type); */
    /* printf("%d\n", root->value); */
    if(root->type=="func_call") {
        struct Map* func_map = createMap();
        struct Node* funId = root->left->left;
        struct Node* parameter = root->right;
        while(funId!=NULL&&parameter!=NULL) {
            add(func_map, funId->left->cval, parameter->left->value);
            funId = funId->right;
            parameter = parameter->right;
        }
        /* printMap(func_map, "func"); */
        /* printMap(funcs, "funcs set"); */
        push(func_map);
        traverse(root->left->right);
        root->value = root->left->right->value;
        freeMap(pop());
        return;
    }
    if(root->type=="pn") {
        printf("%d\n", root->left->value);
    }
    if(root->type=="pb") {
        if(root->left->type=="neg") {
            printf("#f\n");
        } else if(root->left->type=="equ") {
            printf("#t\n");
        } else if(root->left->value==0) {
            printf("#f\n");
        } else printf("#t\n");
    }
    if(root->type=="add") {
        root->value = root->left->value + root->right->value;
    }
    if(root->type=="sub") {
        root->value = root->left->value - root->right->value;
    }
    if(root->type=="mul") {
        root->value = root->left->value * root->right->value;
    }
    if(root->type=="div") {
        root->value = root->left->value / root->right->value;
    }
    if(root->type=="mod") {
        root->value = root->left->value % root->right->value;
    }
    if(root->type==">") {
        if (root->left->value > root->right->value) {
            root->value=1;
        }
        else root->value=0;
    }
    if(root->type=="<") {
        if (root->left->value < root->right->value) {
            root->value=1;
        }
        else root->value=0;
    }
    if(root->type=="equ") {
        if (root->left->value == root->right->value && root->right->type!="neg" && root->left->type!="neg") {
            root->value = root->left->value;
        }
        else {
            root->value=0;
            root->type="neg";
        }
    }
    if(root->type=="and") {
        if (root->left->value!=0 && root->right->value!=0) {
            root->value=1;
        }
        else root->value=0;
    }
    if(root->type=="or") {
        if (root->left->value!=0 || root->right->value!=0) {
            root->value=1;
        }
        else root->value=0;
    }
    if(root->type=="not") {
        root->value=root->left->value*(-1)+1;
    }
    if(root->type=="if") {
        traverse(root->middle);
        if(root->middle->value==1){
            root->value = root->left->value;
        } else {
            root->value = root->right->value;
        }
    }
    if(root->type=="variable") {
        if(sp==0) /* function Stack is empty */ {
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
    return;

}
struct Node* createNode(struct Node* pLeft, struct Node* pRight, char* node_type) {
    struct Node *node = (struct Node *) malloc( sizeof(struct Node) );
    node->type = node_type;
    node->left = pLeft;
    node->right = pRight;
    node->middle = NULL;
    node->value = 0;
    node->cval = "";
    return node;
}
struct Map* createMap() {
    struct Map *map = (struct Map *) malloc( sizeof(struct Map) );
    for (int i = 0; i < MAX_MAP_SIZE; i++) {
        map->nodes[i] = createNode(NULL, NULL, "null"); // Initialize all node pointers to NULL
    }
    map->length=0;
    return map;
}
void add(struct Map *map, char *key, int value) {
    for (int i = 0; i < map->length; i++) {
        if (strcmp(map->key[i], key) == 0) {
            map->nodes[i]->value = value; // Update value if key exists
            return;
        }
    }

    if (map->length < MAX_MAP_SIZE) {
        map->key[map->length] = strdup(key); // Copy key to map
        map->nodes[map->length]->value = value;
        map->length++;
    } else {
        printf("Error: Map is full\n");
    }
}
void addNode(struct Map *map, char *key, struct Node* node) {
    for (int i = 0; i < map->length; i++) {
        if (strcmp(map->key[i], key) == 0) {
            map->nodes[i] = node; // Update value if key exists
            return;
        }
    }

    if (map->length < MAX_MAP_SIZE) {
        map->key[map->length] = strdup(key); // Copy key to map
        map->nodes[map->length] = node;
        map->length++;
    } else {
        printf("Error: Map is full\n");
    }
}
int get(struct Map *map, char *key) {
    for (int i = 0; i < map->length; i++) {
        if (strcmp(map->key[i], key) == 0) {
            return map->nodes[i]->value;
        }
    }
    return -1048576; // Return a special value to indicate key not found
}
struct Node* getNode(struct Map *map, char *key) {
    for (int i = 0; i < map->length; i++) {
        if (strcmp(map->key[i], key) == 0) {
            return map->nodes[i];
        }
    }
    return NULL; // Return a special value to indicate key not found
}
void printMap(struct Map *map, char* name) {
    printf("%-20s------------------\n", name);
    for (int i = 0; i < map->length; i++) {
        printf("%-10s: %-5d     type=%s\n", map->key[i], map->nodes[i]->value, map->nodes[i]->type);
    }
    printf("--------------------------------------\n\n");
}
void freeMap(struct Map *map) {
    for (int i = 0; i < map->length; i++) {
        free(map->key[i]); // Free each key
    }
    free(map); // Free the map itself
}
void push(struct Map *val) {
    if(sp < MAX_STACK_SIZE) {
        stack[sp++] = createMap();
        stack[sp++] = val;
    }
    else {printf("Stack overflow\n");}
}
struct Map* pop() {
    if(sp>0) return stack[--sp];
    else { 
        printf("There is nothing in stack\n");
        exit(0);
    }
}
void yyerror (const char *message) {
    printf ("syntax error\n");
}
int main(int argc, char *argv[]) {
    map = createMap();
    funcs = createMap();
    yyparse();
    /* fprintf (stderr, "parse done\n"); */
    traverse(root);
    /* fprintf (stderr, "traverse done\n"); */
    /* printMap(map, "public variable"); */
    freeMap(map);
    freeMap(funcs);
    return(0);
}