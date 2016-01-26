%token WORD
%token START

%start <int> statement

%%

statement:
  | START sequence { $2 }
  ;

sequence:
  | /* empty */ { 0 }
  | maybeword { $1 }
  | sequence WORD { $1 + $2 }
  ;

maybeword:
  | /* empty */ { 0 }
  | WORD { 1 }
  | START { -1 }
  ;

%%
