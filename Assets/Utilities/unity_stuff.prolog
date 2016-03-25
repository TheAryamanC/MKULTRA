%%%
%%% Code for talking to other parts of the C# code
%%%

:- public examination_content/2, pop_up_examination_content/1.

%% examination_content(+Object, -ContentComponent)
%  ContentComponent is the ExaminationContent component of the GameObject Object.
examination_content(Object, ContentComponent) :-
   is_class(Object, $'GameObject'),
   component_of_gameobject_with_type(ContentComponent, Object, $'ExaminationContent').

%% pop_up_examination_content(+ContentComponent)
%  IMPERATIVE
%  Tells the specified ExaminationContent component to display on the screen.
pop_up_examination_content(ContentComponent) :-
   call_method(ContentComponent, popup, _).

%% emit_grain(+SoundName, +Duration) is det
%  IMPERATIVE
%  Plays a grain of sound with the specified duration in ms.
emit_grain(Name, Duration) :-
   $this \= $me,
   $this.'EmitGrain'(Name, Duration),
   !.
emit_grain(_,_).

:- public activate_prop/1, deactivate_prop/1,
   prop_activated/1, turned_on/1.
%% activate_prop(+Prop)
%  Activates the Prop (e.g. turns on an appliance).
activate_prop(Prop) :-
   is_class(Prop, $'GameObject'),
   component_of_gameobject_with_type(PropComponent, Prop, $'PropInfo'),
   set_property(PropComponent, 'IsOn', true).

%% deactivate_prop(+Prop)
%  Activates the Prop (e.g. turns on an appliance).
deactivate_prop(Prop) :-
   is_class(Prop, $'GameObject'),
   component_of_gameobject_with_type(PropComponent, Prop, $'PropInfo'),
   set_property(PropComponent, 'IsOn', false).

prop_activated(Prop) :-
   is_class(Prop, $'GameObject'),
   component_of_gameobject_with_type(PropComponent, Prop, $'PropInfo'),
   PropComponent.'IsOn'.

set_prop_text(Prop, String) :-
   is_class(Prop, $'GameObject'),
   component_of_gameobject_with_type(PropComponent, Prop, $'PropInfo'),
   PropComponent.settext(String).

%% turned_on(+Appliance)
%  True is Appliance is turned on.
turned_on(Appliance) :-
   prop_activated(Appliance).
informed_about(_, turned_on(_)).
closed(turned_on(_)).

%% on_activation_changed(+Prop, +NewActivation)
%  Called by C# code when Prop's activation state changes.  Success is ignored.

:- external on_activation_changed/2.

on_activation_changed($radio, true) :-
   set_prop_text($radio, "On").
on_activation_changed($radio, false) :-
   set_prop_text($radio, "Off").

:- public fkey_command/1, fkey_command/2.
:- external fkey_command/2.

%% fkey_command(+FKeySymbol, Documentation)
%  Called by UI whenever a given F-key is pressed.

fkey_command(f1) :-
   generate_overlay("Debug commands",
		    clause(fkey_command(Key, Documentation), _),
		    line(Key, ":\t", Documentation)).
fkey_command(Key) :-
   fkey_command(Key, _).

fkey_command(alt-q, "Quit the game") :-
   call_method($'Application', quit, _).
% These are implemented in the C# code, so the handlers are here
% only to make sure the documentation appears in the help display.
fkey_command(f5, "Pause/unpause game").
fkey_command(f2, "Toggle Prolog window").

:- public display_as_overlay/1.

%% display_as_overlay(+StuffToDisplay)
%  IMPERATIVE
%  Pops up debug overlay and displays StuffToDisplay within it.
display_as_overlay(Stuff) :-
   begin(component_of_gameobject_with_type(Overlay, _, $'DebugOverlay'),
	 call_method(Overlay, updatetext(Stuff), _)).

%% hide_overlay
%  IMPERATIVE
%  Disappears the debug overlay.
hide_overlay :-
   begin(component_of_gameobject_with_type(Overlay, _, $'DebugOverlay'),
	 call_method(Overlay, hide, _)).

%% generate_overlay(+Title, :Generator, =Template)
%  IMPERATIVE
%  Finds all solutions to Generator, and for each, remembers Template.
%  Then displays all templates, sorted alphabetically, in an overlay named
%  Title.
:- higher_order generate_overlay(0, 1, 0).
generate_overlay(Title, Generator, Template) :-
   all(Template, Generator, Lines),
   display_as_overlay([size(30, line(Title)) | Lines]).

%% generate_overlay(+Title, :Generator, =Template)
%  IMPERATIVE
%  Finds all solutions to Generator, and for each, remembers Template.
%  Then displays all templates, in the order generated by Generator, 
%  in an overlay named Title.
:- higher_order generate_unsorted_overlay(0, 1, 0).
:- higher_order generate_unsorted_overlay(0,1,0,0).
generate_unsorted_overlay(Title, Generator, Template) :-
   findall(Template, Generator, Lines),
   display_as_overlay([size(30, line(Title)) | Lines]).
generate_unsorted_overlay(Title, Generator, Template, Default) :-
   findall(Template, Generator, Lines),
   (Lines = [] ->
    display_as_overlay([size(30, line(Title)), Default])
    ;
    display_as_overlay([size(30, line(Title)) | Lines])).

%% generate_character_debug_overlay(+Character)
%  IMPERATIVE
%  Pops up the standard character debug overlay information for Character.
%  Debug information can be added by adding rules for character_debug_display/2.
:- public character_debug_display/2, generate_character_debug_overlay/1.
generate_character_debug_overlay(Character) :-
   property_value(Character, given_name, Name),
   generate_overlay(Name,
		    character_debug_display(Character, Data),
		    Data).

%% character_debug_display(+Character, -Line) is nondet
%  When displaying character debug data for Character, display Line.
:- external character_debug_display/2.
 