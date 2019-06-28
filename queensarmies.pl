% use_module(library(clpfd)), use_module(library(lists)).

qa0(A,1,0).
qa0(A,2,0).
qa0(A,D,N):-
	D > 2,

	L is D*D,
	length(Sol1, L),
	N#> 0, N#< L/4,
	
	domain(Sol1, -1,1),
	list_to_matrix(Sol1, D, A),
	global_cardinality(Sol1, [-1-N, 1-N, 0-_]),
	
	check_rows_a(A), 
	transpose(A, B), check_rows_a(B),
	diag2list_a(A, X1, D), check_rows_a(X1),
	matrix_reverse(A, C),
	diag2list_a(C, X2, D), check_rows_a(X2),
	
	labeling([maximize(N), ffc],Sol1).


qa1(A,1,0).
qa1(A,2,0).	
qa1(A,D,N):-
	D > 2,
	
	L is D*D,
	length(Sol1, L),
	N#> 0, N#< L/4,
	
	domain(Sol1, -1,1),
	list_to_matrix(Sol1, D, A),
	
	row(A, 1, Row1),
	domain(Row1, -1, 0),
	
	global_cardinality(Sol1, [-1-N, 1-N, 0-_]),
	
	check_rows_a(A), 
	transpose(A, B), check_rows_a(B),
	diag2list_a(A, X1, D), check_rows_a(X1),
	matrix_reverse(A, C),
	diag2list_a(C, X2, D), check_rows_a(X2),
	
	labeling([maximize(N), ffc],Sol1).


qa1_extended(A,1,0).
qa1_extended(A,2,0).	
qa1_extended(A,D,N):-
	D > 2,
	
	L is D*D,
	length(Sol1, L),
	N#> 0, N#< L/4,
	
	domain(Sol1, -1,1),
	list_to_matrix(Sol1, D, A),
	
	row(A, 1, Row1),
	domain(Row1, -1, 0),

	column(A, 1, Col1), domain(Col1, -1, 0),
	row(A, D, RowD), column(A, D, ColD), diagos(A, Diag, 0, D),
	domain(RowD, 0, 1), domain(ColD, 0, 1), domain(Diag, 0, 1),
	nth1(D, RowD, LastElLastRow), LastElLastRow is 1,
	
	global_cardinality(Sol1, [-1-N, 1-N, 0-_]),
	
	check_rows_a(A), 
	transpose(A, B), check_rows_a(B),
	diag2list_a(A, X1, D), check_rows_a(X1),
	matrix_reverse(A, C),
	diag2list_a(C, X2, D), check_rows_a(X2),
	
	labeling([maximize(N), ffc],Sol1).
	
	
qa1_rec(A,1,0).
qa1_rec(A,2,0).
qa1_rec(A,D,N):-
	D > 0,
	D1 is D-1,
	qa1_rec(A1,D1,N1),
	
	L is D*D,
	length(Sol1, L),
	N#>= N1, N#< L/4,
	
	domain(Sol1, -1,1),
	list_to_matrix(Sol1, D, A),
	
	row(A, 1, Row1),
	domain(Row1, -1, 0),
	
	global_cardinality(Sol1, [-1-N, 1-N, 0-_]),
	
	check_rows_a(A), 
	transpose(A, B), check_rows_a(B),
	
	diag2list_a(A, X1, D), check_rows_a(X1),
	matrix_reverse(A, C),
	diag2list_a(C, X2, D), check_rows_a(X2),
	
	labeling([maximize(N), ffc],Sol1).


%checks global_cardinality conditions for each list in the list 
check_rows_a([]).
check_rows_a([H | T]) :- global_cardinality(H, [1-N1,0-_,-1-N2]), (N1#=0 #\/ N2#=0), check_rows_a(T).
	
%Transforms a list to a matrix
list_to_matrix([], _, []).
list_to_matrix(List, Size, [Row|Matrix]):-
	list_to_matrix_row(List, Size, Row, Tail),
	list_to_matrix(Tail, Size, Matrix).
list_to_matrix_row(Tail, 0, [], Tail).
list_to_matrix_row([Item|List], Size, [Item|Row], Tail):-
	NSize is Size-1,
	list_to_matrix_row(List, NSize, Row, Tail).
	
%Outputs a list of lists with the diagonals from upper left to bottom right
diag2list_a(M, X, D) :- 
	transpose(M, T),
	diag2list(M, X1, 0, D),
	diag2list(T, X2, 0, D),
	concat(X1, X2, X3),
	removehead(X3, X).

removehead([H | T], T).
getfirstelement([H |  T], H).

diag2list([],[],_,_).
diag2list([H | T], X, Z, D) :-
	Z1 is Z+1,
	(Z < D -> diagos([H | T], X1, Z, D)), 
	(Z1 < D-1 -> diag2list([H | T], X2, Z1, D); concat([], [], X2)),
	concat([X1], X2, X).

%Outputs a list with the diagonal (starting with the Zth element from the first row) from upper left to bottom right
diagos([],[],_,_).	
diagos([H | T], X, Z, D) :-
	Z1 is Z+1,
	(Z < D -> nth0(Z, H, A)),
	(Z1 < D -> diagos(T, Y, Z1, D); concat([], [], Y)),
	concat([A], Y, X).

%mirrors the matrix in the middle (1th column <-> nth column, 2th column <-> n-1th column)
matrix_reverse(Y, X) :- transpose(Y,W), revert1(W,V), transpose(V,X).

concat([],L,L).
concat([H|T],L2,[H|NewT]):- concat(T,L2,NewT).

revert1(List,Rev):- rev(List,[],Rev).
rev([],L,L).
rev([H|T],Acc,Rev):- rev(T,[H|Acc],Rev).

row(M, N, Row) :- nth1(N, M, Row).
column(M, N, Col) :- transpose(M, MT), row(MT, N, Col).
