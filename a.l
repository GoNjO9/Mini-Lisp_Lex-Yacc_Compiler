%{
#include "a.tab.h"
struct Node{
    char*   type;
    int     value;
    char*   cval;
    struct Node* left;
    struct Node* middle;
    struct Node* right;
};
struct Node* createNodeLex(struct Node* pLeft, struct Node* pRight, char* node_type) {
    struct Node *node = (struct Node *) malloc( sizeof(struct Node) );
    node->type = node_type;
    node->left = pLeft;
    node->right = pRight;
    node->middle = NULL;
    node->value = 0;
    node->cval = "";
    return node;
}
%}
digit		[0-9]
letter		[a-z]
num 		0|[1-9]{digit}*|-[1-9]{digit}*
id			{letter}({letter}|{digit}|-)*
bTrue		#t
bFalse      #f
%%

"print-num"     {return(PRINTNUM);}
"print-bool"    {return(PRINTBOOL);}

"and"	        {return AND;}
"or"	        {return OR;}
"not"	        {return NOT;}

"define"	    {return DEF;}
"fun"	        {return FUN;}
"if"	        {return IF;}

"+"	            {return ADD;}
"-"	            {return SUB;}
"*"	            {return MUL;}
"/"	            {return DIV;}
"mod"	        {return MOD;}
">"	            {return GREATER;}
"<"	            {return SMALLER;}
"="	            {return EQU;}

{bTrue}         {yylval.ival=1; return(BOOL);}
{bFalse}        {yylval.ival=0; return(BOOL);}
{num}           {yylval.ival=atoi(yytext); return(NUMBER);}
{id}	        {   /* IDENTIFIER */
    yylval.nd = createNodeLex(NULL, NULL, "string");
    yylval.nd->cval = strdup(yytext);
    return ID;
}

"("|")"	                    {return yytext[0];}
.|"\t"|"\n"|"\r"|" "	    {/* do nothing */}

%%

