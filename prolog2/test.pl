:- begin_tests(lists).
:- use_module(lib/lexer, [lex/2]).
:- use_module(lib/parser, [parse/2]).
:- use_module(lib/evaluator, [evaluate/2]).

test(lex_simple) :-
    test_lexer(`=+(){},;`, [assign, plus, lparen, rparen, lsquirly, rsquirly, comma, semicolon, eof]).

test(lex_full) :-
    test_lexer(`
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
          x + y;
      };
      let result = add(five, ten); `, [let, ident(five), assign, int(5), semicolon, let, ident(ten), assign, int(10), semicolon, let, ident(add), assign, function, lparen, ident(x), comma, ident(y), rparen, lsquirly, ident(x), plus, ident(y), semicolon, rsquirly, semicolon, let, ident(result), assign, ident(add), lparen, ident(five), comma, ident(ten), rparen, semicolon, eof]).

test(lex_fullest) :-
    test_lexer(`
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
          x + y;
      };

      let result = add(five, ten);
      !-/ *5;
      5 < 10 > 5;

      if (5 < 10) {
          return true;
      } else {
          return false;
      }

      10 == 100;
      10 != 9; `, [let, ident(five), assign, int(5), semicolon, let, ident(ten), assign, int(10), semicolon, let, ident(add), assign, function, lparen, ident(x), comma, ident(y), rparen, lsquirly, ident(x), plus, ident(y), semicolon, rsquirly, semicolon, let, ident(result), assign, ident(add), lparen, ident(five), comma, ident(ten), rparen, semicolon, bang, dash, fslash, asterisk, int(5), semicolon, int(5), lt, int(10), gt, int(5), semicolon, if, lparen, int(5), lt, int(10), rparen, lsquirly, return, true, semicolon, rsquirly, else, lsquirly, return, false, semicolon, rsquirly, int(10), eq, int(100), semicolon, int(10), neq, int(9), semicolon, eof]).

test(lex_fullestiest) :-
    test_lexer(`
      let five = 5;
      let ten = 10;
      let add = fn(x, y) {
          x + y;
      };

      let result = add(five, ten);
      !-/ *5;
      5 < 10 > 5;

      if (5 < 10) {
          return true;
      } else {
          return false;
      }

      10 == 100;
      10 != 9; 
      "foobar"
      "foo bar"
      [1, 2];`, [let, ident(five), assign, int(5), semicolon, let, ident(ten), assign, int(10), semicolon, let, ident(add), assign, function, lparen, ident(x), comma, ident(y), rparen, lsquirly, ident(x), plus, ident(y), semicolon, rsquirly, semicolon, let, ident(result), assign, ident(add), lparen, ident(five), comma, ident(ten), rparen, semicolon, bang, dash, fslash, asterisk, int(5), semicolon, int(5), lt, int(10), gt, int(5), semicolon, if, lparen, int(5), lt, int(10), rparen, lsquirly, return, true, semicolon, rsquirly, else, lsquirly, return, false, semicolon, rsquirly, int(10), eq, int(100), semicolon, int(10), neq, int(9), semicolon, string("foobar"), string("foo bar"), lbracket, int(1), comma, int(2), rbracket, semicolon, eof]).


test_lexer(StringCodes, Tokens) :-
    once(lex(StringCodes, Tokens)).

test(evaluate_integer) :-
    test_evaluator(`5`, 5),
    test_evaluator(`10`, 10).

test(evaluate_boolean) :-
    test_evaluator(`true`, true),
    test_evaluator(`false`, false).

test(evaluate_bang) :-
    test_evaluator(`!true`, false),
    test_evaluator(`!false`, true),
    test_evaluator(`!5`, false),
    test_evaluator(`!!true`, true),
    test_evaluator(`!!false`, false),
    test_evaluator(`!!5`, true).

test(evaluate_int_expr) :-
    test_evaluator(`5`, 5),
    test_evaluator(`10`, 10),
    test_evaluator(`-5`, -5),
    test_evaluator(`-10`, -10),
    test_evaluator(`5 + 5 + 5 + 5 - 10`, 10),
    test_evaluator(`2 * 2 * 2 * 2 * 2`, 32),
    test_evaluator(`-50 + 100 + -50`, 0),
    test_evaluator(`5 * 2 + 10`, 20),
    test_evaluator(`5 + 2 * 10`, 25),
    test_evaluator(`20 + 2 * -10`, 0),
    test_evaluator(`50 / 2 * 2 + 10`, 60),
    test_evaluator(`2 * (5 + 10)`, 30),
    test_evaluator(`3 * 3 * 3 + 10`, 37),
    test_evaluator(`3 * (3 * 3) + 10`, 37),
    test_evaluator(`(5 + 10 * 2 + 15 / 3) * 2 + -10`, 50).

test(evaluate_bool_exp) :-
    test_evaluator(`true`, true),
    test_evaluator(`false`, false),
    test_evaluator(`1 < 2`, true),
    test_evaluator(`1 > 2`, false),
    test_evaluator(`1 < 1`, false),
    test_evaluator(`1 > 1`, false),
    test_evaluator(`1 == 1`, true),
    test_evaluator(`1 != 1`, false),
    test_evaluator(`1 == 2`, false),
    test_evaluator(`1 != 2`, true),
    test_evaluator(`true == true`, true),
    test_evaluator(`false == false`, true),
    test_evaluator(`true == false`, false),
    test_evaluator(`true != false`, true),
    test_evaluator(`false != true`, true),
    test_evaluator(`(1 < 2) == true`, true),
    test_evaluator(`(1 < 2) == false`, false),
    test_evaluator(`(1 > 2) == true`, false),
    test_evaluator(`(1 > 2) == false`, true).

test(evaluate_if_expr) :-
    test_evaluator(`if (true) { 10 }`, 10),
    test_evaluator(`if (false) { 10 }`, nil),
    test_evaluator(`if (1) { 10 }`, 10),
    test_evaluator(`if (1 < 2) { 10 }`, 10),
    test_evaluator(`if (1 > 2) { 10 }`, nil),
    test_evaluator(`if (1 > 2) { 10 } else { 20 }`, 20),
    test_evaluator(`if (1 < 2) { 10 } else { 20 }`, 10).

test(evaluate_return) :-
    test_evaluator(`return 10;`, 10),
    test_evaluator(`return 10; 9;`, 10),
    test_evaluator(`return 2 * 5; 9;`, 10),
    test_evaluator(`9; return 2 * 5; 9;`, 10),
    test_evaluator(
      `if (10 > 1) {
         if (10 > 1) {
           return 10;
         }
         return 1;
       }`, 10),
    test_evaluator(
      `if (10 > 1) {
         if (10 > 1) {
           
         }
         return 1;
       }`, 1).

test(evaluate_assignment) :-
    test_evaluator(`let a = 5; a;`, 5),
    test_evaluator(`let a = 5 * 5; a;`, 25),
    test_evaluator(`let a = 5; let b = a; b;`, 5),
    test_evaluator(`let a = 5; let b = a; let c = a + b + 5; c;`, 15).

test(evaluate_function) :-
    test_evaluator(`let identity = fn(x) { x; }; identity(5);`, 5),
    test_evaluator(`let identity = fn(x) { return x; }; identity(5);`, 5),
    test_evaluator(`let double = fn(x) { x * 2; }; double(5);`, 10),
    test_evaluator(`let add = fn(x, y) { x + y; }; add(5, 5);`, 10),
    test_evaluator(`let add = fn(x, y) { x + y; }; add(5 + 5, add(5, 5));`, 20),
    test_evaluator(`fn(x) { x; }(5)`, 5),
    test_evaluator(`
      let newAdder = fn(x) {
         fn(y) { x + y };
      };
      let addTwo = newAdder(2);
      addTwo(2);`, 4),
    test_evaluator(`
      let newAdder = fn(x) {
         fn(y) { x + y };
      };
      let addTwo = newAdder(2);
      let x = 3;
      addTwo(2);`, 4),
    test_evaluator(`
      let newAdder = fn(x) {
         fn(y) { x + y };
      };
      let addTwo = newAdder(2);
      let x = 3;
      addTwo(2);
      return x;`, 3),
    test_evaluator(`
      let counter = fn(x) {
        if (x > 100) {
          return true;
        } else {
          let foobar = 9999;
          counter(x + 1);
        }
      };
      counter(0);`, true).

test(evaluate_string) :-
    test_evaluator(`
      let makeGreeter = fn(greeting) { fn(name) { greeting + " " + name + "!" } }; 
      let hello = makeGreeter("Hello"); 
      hello("Thorsten");`, "Hello Thorsten!").

test(evaluate_string_builtin) :-
    test_evaluator(`len("")`, 0),
    test_evaluator(`len("four")`, 4),
    test_evaluator(`len("hello world")`, 11).

test(evaluate_list_index) :-
    test_evaluator(`[1, 2, 3][0]`, 1),
    test_evaluator(`[1, 2, 3][1]`, 2),
    test_evaluator(`[1, 2, 3][2]`, 3),
    test_evaluator(`let i = 0; [1][i];`, 1),
    test_evaluator(`[1, 2, 3][1 + 1];`, 3),
    test_evaluator(`let mylist = [1, 2, 3]; mylist[2];`, 3),
    test_evaluator(`let mylist = [1, 2, 3]; mylist[0] + mylist[1] + mylist[2];`, 6),
    test_evaluator(`let mylist = [1, 2, 3]; let i = mylist[0]; mylist[i]`, 2),
    test_evaluator(`[1, 2, 3][3]`, nil),
    test_evaluator(`[1, 2, 3][-1]`, nil).

test(evaluate_list_builtin) :-
    test_evaluator(`let a = [1, 2, 3, 4]; rest(a)`, [2, 3, 4]),
    test_evaluator(`let a = [1, 2, 3, 4]; first(rest(a))`, 2),
    test_evaluator(`let a = [1, 2, 3, 4]; rest(rest(a))`, [3, 4]),
    test_evaluator(`let a = [1, 2, 3, 4]; rest(rest(rest(a)))`, [4]),
    test_evaluator(`let a = [1, 2, 3, 4]; rest(rest(rest(rest(a))))`, []),
    test_evaluator(`let a = [1, 2, 3, 4]; rest(rest(rest(rest(rest(a)))))`, nil).

test(evaluate_hash_index) :-
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash["one"]`, 1), 
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash["two"]`, 2), 
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash["three"]`, 3), 
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash[4]`, 4), 
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash[true]`, 5), 
    test_evaluator(`
      let two = "two";
      let hash = { "one": 10 - 9, two: 1 + 1, "thr" + "ee": 6 / 2, 4: 4, true: 5, false: 6 }
      hash[false]`, 6), 
    test_evaluator(`{"foo": 5}["foo"]`, 5),
    test_evaluator(`{"foo": 5}["bar"]`, nil),
    test_evaluator(`let key = "foo"; {"foo": 5}[key]`, 5),
    test_evaluator(`{}["foo"]`, nil),
    test_evaluator(`{5: 5}[5]`, 5),
    test_evaluator(`{true: 5}[true]`, 5),
    test_evaluator(`{false: 5}[false]`, 5).

test_evaluator(StringCodes, Value) :-
    once(lex(StringCodes, Token)), 
    once(parse(Token, Ast)), 
    once(evaluate(Ast, Value)).

:- end_tests(lists).
