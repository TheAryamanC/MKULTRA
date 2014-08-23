%%%
%%%                  Noun Phrases
%%%

test_file(generate(np, _), "NL/np_tests").
test_file(parse(np, _), "NL/np_tests").

%:- randomizable np/7.

%% np(?Meaning, ?Case, Agreement, +GapIn, -GapOut)
%  Noun phrases

% Gaps
np((X^S)^S, _C, _Agreement, np(X), nogap) -->
   [ ].

% Pronouns
np(NP, Case, Agreement, Gap, Gap) -->
   pronoun(Case, Agreement, NP).

% Proper nouns
np(NP, _C, third:Number, Gap, Gap) -->
   proper_noun(Number, NP).

% PARSE/COMPLETE ONLY
% "a KIND" from unbound variables with declared types
np(LF, _, third:singular, Gap, Gap) -->
   { var(LF) }, 
   [a, Singular],
   { kind_noun(Kind, Singular, _),
     LF = ((X^S)^(S, is_a(X, Kind))) }.

% GENERATE ONLY
% "a KIND" from unbound variables with declared types
np((X^S)^S, _, third:singular, Gap, Gap) -->
   { var(X) },
   [a, Singular],
   { discourse_variable_type(X, Kind),
     kind_noun(Kind, Singular, _) }.

% PARSE ONLY
% "the NOUN"
np((X^S)^S, _C, third:singular, Gap, Gap) -->
   [ the, Noun ],
   { nonvar(Noun),
     noun(Noun, _, X^P),
     atomic(Noun),
     resolve_definite_description(X, P) }.

% GENERATE ONLY
% "the NOUN"
np((X^S)^S, _C, third:singular, Gap, Gap) -->
   { nonvar(X),
     \+ proper_noun(_, X),
     is_a(X, Kind),
     leaf_kind(Kind),
     kind_noun(Kind, Singular, _) },
   [the, Singular].

np((X^S)^S, _C, third:singular, Gap, Gap) -->
   [ the, N1, N2 ],
   { (nonvar(N1) ; nonvar(X)),
     noun([N1, N2], _, X^P),
     resolve_definite_description(X, P) }.

% GENERATE ONLY
% Fixed strings.
np((String^S)^S, _, _, Gap, Gap) -->
   {string(String)},
   [String].

% GENERATE ONLY
% Numbers.
np((Number^S)^S, _, _, Gap, Gap) -->
   {number(Number)},
   [Number].

resolve_definite_description(X, Constraint) :-
   nonvar(X),
   !,
   Constraint.
resolve_definite_description(Object, is_a(Object, Kind)) :-
   kind_of(Kind, room),
   !,
   is_a(Object, Kind).
resolve_definite_description(Object, Constraint) :-
   % This rule will fail in the test suite b/c the global environment has no gameobject.
   \+ running_tests,
   % Pick the nearest one, if it's something that nearest works on.
   nearest(Object, Constraint),
   !.
resolve_definite_description(_Object, Constraint) :-
   % Punt, and choose whatever Prolog gives us first.
   Constraint.