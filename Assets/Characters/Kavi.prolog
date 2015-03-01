% Keep intruders out of bedroom
/goals/maintain/bedroom_empty.

% I know the secret location of the macguffin
/perception/location/ $macguffin : $bookshelf.

/pending_conversation_topics/ $bruce/"Sorry to hear your macguffin was stolen.".
/pending_conversation_topics/ $bruce/"Make yourself at home.".
/pending_conversation_topics/ $bruce/"But um.".
/pending_conversation_topics/ $bruce/"Stay out of my bedroom.".
/pending_conversation_topics/ $bruce/"It's a personal thing.".
/pending_conversation_topics/ $bruce/assert(/goals/pending_tasks/goto($'kitchen sink')).

% Monitor goals quickly
/parameters/poll_time:3.

% Don't admit you know where the macguffin is to anyone
% but other illuminati members
pretend_truth_value(Asker,
		    location($macguffin, Loc),
		    T) :-
   \+ related(Asker, member_of, illuminati),
   (var(Loc) -> T = unknown ; T = false).
pretend_truth_value(Asker,
		    contained_in($macguffin, Loc),
		    T) :-
   \+ related(Asker, member_of, illuminati),
   (var(Loc) -> T = unknown ; T = false).

% Don't admit to being an illuminati member to non-members
pretend_truth_value(Asker,
		    related($me, member_of, illuminati),
		    false) :-
   \+ related(Asker, member_of, illuminati).
   
:- public bedroom_empty/0.
bedroom_empty :-
   \+ intruder(_Intruder, $bedroom).

% An intruder is a person who isn't an illuminati member
intruder(Intruder, Room) :-
   location(Intruder, Room),
   is_a(Intruder, person),
   \+ related(Intruder, member_of, illuminati).

% Eat all intruders
personal_strategy(achieve(bedroom_empty),
		  ( ingest(Intruder),
		    discourse_increment($me, Intruder,
					["Stay out of my bedroom!"]) )) :-
   intruder(Intruder, $bedroom).
