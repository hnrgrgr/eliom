(*zap* *)
{shared{
  let (>>=) = Lwt.(>>=)
  let (>|=) = Lwt.(>|=)
}}


(* *zap*)
(*zap*
   This is the Eliom documentation.
   You can find a more readable version of comments on http://www.ocsigen.org
*zap*)
(*wiki*
%<||1>%
%<div class='leftcol'|%<leftcoldoc version="dev">%>%
      %<div class="colprincipale"|
        ==4. Using Eliom client side

//Warning: Features presented here are experimental.
We have been working on them for more than two years and
they will be released very soon.
Use it if you want to test,
but syntax and interfaces will change a lot during the next weeks,
as we are currently working on simplifying the syntax and
uniformizing server and client sides.//

//The manual is very basic for now.
Turn back in a few days for a more complete manual!//

This part of the manuel describes how to use Eliom for mixing client side
and server side programming.
Eliom allows to write the client and server parts of a Web application
fully in Objectice Caml.
Running OCaml in the client's browser is acheived by compiling OCaml bytecode
into Javascript. Check the [[wiki(30):/|js_of_ocaml]] project for news and
information.


===@@id="p4basics"@@

====Your first client-server application
        %<div class="onecol"|

First, I need to create my Eliom application, by applying the functor
{{{Eliom_predefmod.Eliom_appl}}}. You can define here what will be
the default title for pages belonging to this application, the
default container for pages, the default stylesheets you want for your
whole application.

*wiki*)
(****** open on both side *******)
{shared{
open XHTML.M
}}
(****** server only *******)
{server{ (* note that {server{ ... }} is optionnal. *)
open Eliom_parameters
open Eliom_predefmod.Xhtmlcompact
open Eliom_services
}}

(* for client side only, one can use : {client{ ... }} *)

(* This is server only because there are no delimiters. *)
module Eliom_appl =
  Eliom_predefmod.Eliom_appl (
    struct
      let application_name = "tutoeliom_ocsigen2_client"
      let params =
        {Eliom_predefmod.default_appl_params with
           Eliom_predefmod.ap_title = "Eliom application example";
           Eliom_predefmod.ap_headers =
            [XHTML.M.style ~contenttype:"text/css"
               [XHTML.M.pcdata ".clickable {color: #111188; cursor: pointer;}"]];
           Eliom_predefmod.ap_container =
            Some (None,
                  fun div -> [h1 [pcdata "Eliom application"];
                              p [pcdata "Random value in the container: ";
                                 pcdata (string_of_int (Random.int 1000))];
                              div ])
        }
    end)
(*wiki* Now I can define my first service belonging to that application: *wiki*)

let eliomclient1 =
  Eliom_appl.register_new_service
    ~path:["eliomclient1"]
    ~get_params:unit
    (fun sp () () ->
      Lwt.return
        [p ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
                        (* with {{ expr }}, the expression is executed by the client. *)
                        a_onclick {{Dom_html.window##alert(Js.string "clicked!") ; Lwt.return ()}}]
           [pcdata "I am a clickable paragraph"];

        ])
(*wiki*
All services belonging to the application will be entry points to the
application. It means that if you call such a service, the client side
code will be sent to the browser, and the client side execution will
start, //and will not stop if you go to another service belonging to
the same application!//

====Compiling
//soon (have a look at Ocsigen source for now -- //examples// directory)//

====Using a distant Eliom service in client side code

For now, the syntax extension has not been implemented, thus the syntax
is somewhat more complicated. Here are some examples of what you can do:
*wiki*)
let eliomclient2 = new_service ~path:["eliomclient2"] ~get_params:unit ()

let myblockservice =
  Eliom_predefmod.Blocks.register_new_post_coservice
    ~fallback:eliomclient2
    ~post_params:unit
    (fun _ () () ->
       Lwt.return
         [p [pcdata ("I come from a distant service! Here is a random value: "^
                       string_of_int (Random.int 100))]])

;; (* This ";;" is necessary in order to have the "shared" following entry being
      parsed as "str_item" (instead of "expr"). This is Camlp4 related, it may
      evolve.
    *)

{shared{
let item () = li [pcdata Sys.ocaml_version]
}} ;;

let _ =
  Eliom_appl.register
    eliomclient2
    (fun sp () () ->
      Lwt.return
        [
(*wiki*
  The following example shows how to go to another service,
  exactly like pressing a link (here a service that do not belong to
  the application):
*wiki*)
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick
                {{Eliom_client.exit_to
                    ~sp:\sp(sp) (* Here [sp] is sent by the server *)
                    ~service:\magic(Tutoeliom.coucou) (* just as [coucou] *)
                    () ()
                }}
            ]
            [pcdata "Click here to go to another page."];

(*wiki*
To use server values inside client code one should use the syntax {{{ \k(e) }}}
where {{{k}}} is the wrapper keyword and {{{e}}} the sent expression. Note that
{{{e}}} is evaluated by the server and the resulting value is send to the
client at loading time.
*wiki*)

(*zap* *)
(*wiki*
  The following examples shows how to do a request to a service,
  and use the content:
*wiki*)
(*
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick
                ((fun.client
                    (sp : Eliom_client_types.server_params Eliom_client_types.data_key)
                    (myblockservice : (unit, unit, 'c, 'd, 'e, 'f, 'g, Eliom_services.http) Eliom_services.service) ->
                      let sp = Eliommod_client.unwrap_sp sp in
                      let body = Dom_html.document##body in
                      (*Js_old.get_element_by_id "bodyid"*)
                      Eliom_client.call_service
                        ~sp ~service:myblockservice () () >>= fun s ->
                      (try
                         let l = Js_old.Node.children (Js_old.dom_of_xml s) in
                         List.iter (Js_old.Node.append body) l
                       with e -> Js_old.alert (Printexc.to_string e));
(* does not work with chrome. A solution is probably to use set "innerHTML". *)
                       Lwt.return ()
                 ) (Eliom_client.wrap_sp sp) myblockservice)
            ]
            [pcdata "Click here to add content from the server."];
 *)
(* *zap*)

(*wiki*
  The following examples shows how to change the URL.
  This is a low level function and is usually not to be used directly.
  As browsers do not not allow to change the URL,
  we write the new URL in the fragment part of the URL.
  A script must do the redirection if there is something in the fragment
  while the page is loading.
*wiki*)
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.change_url
                  ~sp:\sp(sp)
                  ~service:\magic(Tutoeliom.coucou)
                  () ()
              }}
            ]
            [pcdata "Click here to change the URL."];

(*wiki*
  The following examples shows how to change the current page,
  without stopping the client side program.
*wiki*)
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick
                {{Eliom_client.change_page
                    ~sp:\sp(sp)
                    ~service:\magic(eliomclient1)
                    () ()
                }}
            ]
            [pcdata "Click here to change the page without stopping the program."];

(*wiki* Actually the usual {{{a}}} function to create link will
  use {{{change_page}}} if you do a link inside the same application.
  The latter example is equivalent to the following. *wiki*)
          p [a (*zap* *) ~a:[a_class ["clickable"]](* *zap*)
               ~sp
               ~service:eliomclient1
               [pcdata "Click here to change the page without stopping the program (with ";
                code [pcdata "a"];
                pcdata ")."]
               ()];
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick{{
                Eliom_client.change_page ~sp:\sp(sp) ~service:\magic(Tutoeliom.coucou)
                  () ()
              }}
            ]
            [pcdata "Click here to go to a page outside the application, using ";
             code [pcdata "change_page"];
             pcdata "."];
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.exit_to ~sp:\sp(sp) ~service:\magic(eliomclient2) () ()
              }}
            ]
            [pcdata "Click here to relaunch the program by reloading the page."];
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.change_page ~sp:\sp(sp) ~service:\magic(eliomclient1)
                  () ()
              }}
            ]
            [pcdata "A generic client-side function for calling ";
             code [pcdata "change_page"];
             pcdata "."];

(*wiki*
  The following examples shows how to get a subpage from the server,
  and put it inside your page.
*wiki*)
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.get_subpage ~sp:\sp(sp) ~service:\magic(eliomclient1)
                  () () >|= fun blocks ->
                List.iter
                  (Dom.appendChild Dom_html.document##body)
                  (XHTML.M.toeltl blocks)
              }}
            ]
            [pcdata "Click here to get a subpage from server."];


(*wiki*
====Refering to parts of the page in client side code
*wiki*)

          (let container = ul (item ()) [ item () ; item ()] in
           div [p ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
                               a_onclick {{
                                 Dom.appendChild
                                   \node(container) (* node is the wrapper keyword for XHTML.M nodes. *)
                                   (XHTML.M.toelt (item ()))
                               }}
                  ]
                  [pcdata "Click here to add an item below with the current version of OCaml."];
                container]);

(*wiki*
====Refering to server side data in client side code
  In the case you want to send some server side value with your page,
  just do:
*wiki*)

          (let my_value = 1.12345 in
           p ~a:[(*zap* *)a_class ["clickable"];(* *zap*)a_onclick
                {{ Dom_html.window##alert
                     (Js.string (string_of_float \(my_value:float))) ;
                   Lwt.return ()
                }}
                ]
             [pcdata "Click here to see a server side value sent with the page."]);



(*wiki*
====Other tests
  *wiki*)

          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                (Dom.appendChild
                   (Dom_html.document##body)
                   (XHTML.M.toelt
                      (p [Eliom_predefmod.Xhtml.a
                            ~sp:\sp(sp) ~service:\magic(Tutoeliom.coucou)
                            [pcdata "An external link generated client side"]
                            ();
                          pcdata " and ";
                          Eliom_predefmod.Xhtml.a
                            (*zap* *)~a:[a_class ["clickable"]](* *zap*)
                            ~sp:\sp(sp) ~service:\magic(eliomclient1)
                            [pcdata "another, inside the application."]
                            ()
                         ]
                      ))
                );
                Lwt.return ()
              }}
            ]
            [pcdata "Click here to add client side generated links."];



        ])
(*wiki*
====Using OCaml values as service parameters
It is now possible to send OCaml values to services.
To do that, use the {{{Eliom_parameters.caml}}} function:
*wiki*)
let eliomclient3' =
  Eliom_appl.register_new_post_coservice'
    ~post_params:(caml "isb")
    (fun sp () (i, s, l) ->
      Lwt.return
        [p (pcdata (Printf.sprintf "i = %d, s = %s" i s)::
              List.map (fun a -> pcdata a) l
           )])



let eliomclient3 =
  Eliom_appl.register_new_service
    ~path:["eliomclient3"]
    ~get_params:unit
    (fun sp () () ->
      Lwt.return
        [p ~a:[(*zap* *)a_class ["clickable"];(* *zap*)a_onclick
                {{ Eliom_client.change_page
                     ~sp:\sp(sp) ~service:\magic(eliomclient3')
                     () (22, "oo", ["a";"b";"c"])
                }}
              ]
           [pcdata "Click to send Ocaml data"]
        ])
(*wiki*
====Sending OCaml values using services
It is possible to do services that send any caml value. For example:
*wiki*)
let eliomclient4' =
  Eliom_predefmod.Caml.register_new_post_coservice'
    ~post_params:unit
    (fun sp () () -> Lwt.return [1; 2; 3])

let eliomclient4 =
  Eliom_appl.register_new_service
    ~path:["eliomclient4"]
    ~get_params:unit
    (fun sp () () ->
      Lwt.return
        [p ~a:[(*zap* *)a_class ["clickable"];(* *zap*)a_onclick
                 {{let body = Dom_html.document##body in
                   Eliom_client.call_caml_service
                     ~sp:\sp(sp) ~service:\magic(eliomclient4')
                     () () >|=
                   List.iter
                     (fun i -> Dom.appendChild body
                                 (Dom_html.document##createTextNode
                                    (Js.string (string_of_int i))))
                 }}
              ]
           [pcdata "Click to receive Ocaml data"]
        ])
(*wiki*
====Other tests:
*wiki*)
let withoutclient =
  Eliom_services.new_service
    ~path:["withoutclient"]
    ~get_params:unit
    ()

let gotowithoutclient =
  Eliom_services.new_service
    ~path:["gotowithoutclient"]
    ~get_params:unit
    ()


let _ =
  Eliom_appl.register
    ~options:true
    ~service:withoutclient
    (fun sp () () ->
       Lwt.return
         [p [pcdata "If the application was not launched before coming here (or if you reload), this page will not launch it. But if it was launched before, it is still running."];
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.change_page
                  ~sp:\sp(sp) ~service:\magic(gotowithoutclient)
                  () ()
              }}
            ]
            [pcdata "Click here to go to a page that launches the application every time (this link does not work if the appl is not launched)."];
          p [a (*zap* *)~a:[a_class ["clickable"]](* *zap*) ~sp ~service:gotowithoutclient
               [pcdata "Same link with ";
                code [pcdata "a"]; pcdata "."] ()];
         ]);
  Eliom_appl.register
    ~service:gotowithoutclient
    (fun sp () () ->
       Lwt.return
         [p [pcdata "The application is launched."];
          p
            ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
              a_onclick {{
                Eliom_client.change_page
                  ~sp:\sp(sp) ~service:\magic(withoutclient)
                  () ()
              }}
            ]
            [pcdata "Click here to see the page that does not launch the application."];
          p [a (*zap* *)~a:[a_class ["clickable"]](* *zap*) ~sp ~service:withoutclient
               [pcdata "Same link with ";
                code [pcdata "a"]; pcdata "."] ()];
         ])



(*wiki*
====Implicit registration of services to implement distant function calls
*wiki*)
(*wiki*
*wiki*)
(*wiki*
*wiki*)
(*wiki*
        >% <<|onecol>>
      >% <<|colprincipale>>
*wiki*)
(*wiki*
%<||2>%
*wiki*)


(*wiki*
====Comet programming
The first example demonstrate server-to-client channel communication. Channels
are wrapped and sent to the client. A second example uses channels to transmit
occurrences of an event.
 *wiki*)

(* create a communication channel. Because it is public, we give an explicit
* name for it. *)
let (c1, write_c1) =
  let (e, push_e) = React.E.create () in
  (Eliom_comet.Channels.create ~name:"comet1_public_channel" e, push_e)

(* randomly write on the channel *)
let rec rand_tick () =
  Lwt_unix.sleep (float_of_int (5 + (Random.int 5))) >>= fun () ->
  write_c1 (Random.int 99) ; rand_tick ()
let _ = rand_tick ()


let comet1 =
  Eliom_appl.register_new_service
    ~path:["comet1"]
    ~get_params:unit
    (fun sp () () ->
       let (c2_pre, write_c2) = React.E.create () in
       let c2 = Eliom_comet.Dlisted_channels.create
                  ~max_size:6
                  ~timer:16.
                  c2_pre
       in
       let t2 = ref 0 in
       let rec tick_2 () =
         Lwt_unix.sleep (float_of_int (6 + (Random.int 6))) >>= fun () ->
         write_c2 !t2 ; incr t2 ; Lwt.pause () >>= fun () ->
         write_c2 !t2 ; incr t2 ; write_c2 !t2 ; incr t2 ; tick_2 ()
       in
       let t = tick_2 () in
       let `R _ = React.E.retain c2_pre (fun () -> ignore t; ignore c2) in
       Lwt.return
         [
           div
             [pcdata "To fully understand the meaning of the public channel, \
                      use a couple browsers on this page."] ;
           div
             ~a:[a_onclick{{
                   Eliom_client_comet.Channels.register \channel(c1)
                     (fun i ->
                        Dom.appendChild (Dom_html.document##body)
                          (Dom_html.document##createTextNode
                             (Js.string ("public: "^ string_of_int i ^";  "))) ;
                        Lwt.return ()
                     )
                }} ]
             [pcdata "Click here to start public channel listening"] ;
           div
             ~a:[a_onclick{{
                   Eliom_client_comet.Dlisted_channels.register \buffchan(c2)
                     (fun i ->
                        Dom.appendChild (Dom_html.document##body)
                          (Dom_html.document##createTextNode
                             (Js.string ("private: "^ string_of_int i ^"; "))) ;
                        Lwt.return ()
                     )
                }} ]
             [pcdata "Click here to start private buffered channel listening"] ;
         ]
    )

(*wiki*
This second example involves client-to-server and server to client event
propagation. There is no manual handling of channel, only events are used.
 *wiki*)


let comet2 =
  Eliom_appl.register_new_service
    ~path:["comet2"]
    ~get_params:unit
    (fun sp () () ->
       (* First create a server-readable client-writable event AKA up event AKA
          client-to-server asynchronous edge *)
       let e_up = Eliom_event.Up.create ~sp (string "letter") in
       let e_up_real = Eliom_event.Up.react_event_of_up_event e_up in
       let e_down = React.E.map
                      (function "A" -> "alpha" | "B" -> "beta" | _ -> "what ?")
                      e_up_real
       in
       let `R _ = React.E.retain e_up_real (fun () -> ignore e_down) in

       (* We can send the page *)
       Lwt.return [
         h2 [pcdata "Dual events"] ;
         div (* There's a start "button" right now, but it's gonna change *)
           ~a:[a_onclick {{
                React.E.map
                  (fun s -> Dom_html.window##alert (Js.string s))
                  \down_event(e_down)
           }}
              ]
           [pcdata "START"] ;
         div (* This div is for pushing "A" to the server side event *)
           (*TODO: fix client side sp and simplify up_event unwrapping *)
           ~a:[a_onclick {{ let sp = \sp(sp) in \up_event(e_up) "A" }} ]
           [pcdata "Push A"] ;
         div (* This one is for pushing "B" *)
           ~a:[a_onclick {{ let sp = \sp(sp) in \up_event(e_up) "B" }} ]
           [pcdata "Push B"] ;
       ]
    )

(*wiki*
 This third example demonstrates the capacity for simultaneous server push.
 *wiki*)


let comet3 =
  Eliom_appl.register_new_service
    ~path:["comet3"]
    ~get_params:unit
    (fun sp () () ->
       (* First create a server-readable client-writable event AKA up event AKA
          client-to-server asynchronous edge *)
       let e_up = Eliom_event.Up.create ~sp (string "double") in
       let e_up_real = Eliom_event.Up.react_event_of_up_event e_up in
       let e_down_1 =
         Lwt_event.limit (*TODO: integrate throttling to events*)
           (fun () -> Lwt_unix.sleep 3.)
           (React.E.map
              (let i = ref 0 in fun _ -> incr i ; !i)
              e_up_real
           )
       in
       let e_down_2 = React.E.map (fun _ -> "haha") e_up_real in
       let `R _ = React.E.retain e_up_real
                    (fun () -> ignore e_down_1 ; ignore e_down_2)
       in

       (* We can send the page *)
       Lwt.return [
         h2 [pcdata "Simultaneous events"] ;
         div (* There's a start "button" right now, but it's gonna change *)
           ~a:[a_onclick {{
                React.E.map
                  (fun s -> Dom_html.window##alert (Js.string s))
                  (React.E.merge
                     (^) ""
                     [ React.E.map string_of_int \down_event(e_down_1) ;
                       \down_event(e_down_2) ;
                     ]
                  )
           }}
              ]
           [pcdata "START"] ;
         div (*TODO: fix client side sp and simplify up_event unwrapping *)
           ~a:[
             (*zap* *)a_class ["clickable"];(* *zap*)
             a_onclick {{ let sp = \sp(sp) in \up_event(e_up) "" }} ]
           [pcdata "Send me two values from different events !"] ;
         div [pcdata "Note that one of the two events has a greater rate limit \
                      (using throttle control). Hence you might receive only \
                      one if you click with high frequency."] ;
       ]
    )


(*wiki*
 Here is the code for a small minimalist message board.
 *wiki*)

(* First is the event on the server corresponding to a new message. *)
let message_up = Eliom_event.Up.create (string "content")

(* Then is the page hosting the board *)
let comet_message_board =
  Eliom_appl.register_new_service
    ~path:["message_board"]
    ~get_params:unit
    (fun sp () () ->
       let message_down =
         React.E.map (fun x -> x)
         (Eliom_event.Up.react_event_of_up_event message_up)
       in

       Lwt.return (
         let container = ul (li [pcdata "This is the message board"]) [] in
         let field = input ~a:[a_id "msg"; a_input_type `Text; a_name "message"] () in
         let go =
           div
             ~a:[(*zap* *)a_class ["clickable"];(* *zap*)
                  a_onclick {{
                    let sp = \sp(sp) in
                    let field =
                        (Js.Opt.get
                           (Dom_html.CoerceTo.input
                              (Js.Opt.get
                                 (Dom_html.document##getElementById (Js.string "msg"))
                                 (fun () -> failwith "No field found")
                              )
                           )
                           (fun () -> failwith "No field found")
                        )
                    in
                    let v = Js.to_string field##value in
                    field##value <- Js.string "" ;
                    \up_event(message_up) v
                  }}
             ]
             [pcdata "send"]
         in

         [ h2 [pcdata "Message board"];
           div
             ~a:[ (*zap* *)a_class ["clickable"];(* *zap*)
                  a_onclick {{
                    ignore (
                      React.E.map
                        (fun msg ->
                            Dom.appendChild \node(container)
                              (XHTML.M.toelt (li [pcdata msg]))
                        )
                        \down_event(message_down)
                    ) ;
                    Eliom_client_comet.Engine.start ()
                  }}
                ]
             [pcdata "Go online"];
           div
             ~a:[ (*zap* *)a_class ["clickable"];(* *zap*)
                  a_onclick {{ Eliom_client_comet.Engine.stop () }}
                ]
             [pcdata "Go offline"];
           form (uri_of_string "") (div [field; go]) [];
           container;
         ])
    )

(*wiki*

===Tab sessions

  *wiki*)


open Lwt

(************************************************************)
(************ Connection of users, version 1 ****************)
(************************************************************)

(*zap* *)
let session_name = "tsession_data"
(* *zap*)

(* "my_table" will be the structure used to store
   the session data (namely the login name): *)

let my_table = Eliom_sessions.create_volatile_table ()


(* -------------------------------------------------------- *)
(* Create services, but do not register them yet:           *)

let tsession_data_example =
  Eliom_services.new_service
    ~path:["tsessdata"]
    ~get_params:Eliom_parameters.unit
    ()

let tsession_data_example_with_post_params =
  Eliom_services.new_post_service
    ~fallback:tsession_data_example
    ~post_params:(Eliom_parameters.string "login")
    ()

let tsession_data_example_close =
  Eliom_services.new_service
    ~path:["tclose"]
    ~get_params:Eliom_parameters.unit
    ()



(* -------------------------------------------------------- *)
(* Handler for the "tsession_data_example" service:          *)

let tsession_data_example_handler sp _ _  =
  let sessdat = 
    Eliom_sessions.get_volatile_session_data
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~table:my_table ~sp () in
  return
    [
      match sessdat with
        | Eliom_sessions.Data name ->
          p [pcdata ("Hello "^name);
             br ();
             Eliom_predefmod.Xhtml.a
               tsession_data_example_close
               sp [pcdata "close session"] ()]
        | Eliom_sessions.Data_session_expired
        | Eliom_sessions.No_data ->
          Eliom_predefmod.Xhtml.post_form
            tsession_data_example_with_post_params
            sp
            (fun login ->
              [p [pcdata "login: ";
                  Eliom_predefmod.Xhtml.string_input
                    ~input_type:`Text ~name:login ()]]) ()
    ]

(* -------------------------------------------------------- *)
(* Handler for the "tsession_data_example_with_post_params"  *)
(* service with POST params:                                *)

let tsession_data_example_with_post_params_handler sp _ login =
  Eliom_sessions.close_session
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~sp () >>= fun () ->
  Eliom_sessions.set_volatile_session_data
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~table:my_table ~sp login;
  return
    [p [pcdata ("Welcome " ^ login ^ ". You are now connected.");
        br ();
        Eliom_predefmod.Xhtml.a tsession_data_example sp [pcdata "Try again"] ()
       ]]



(* -------------------------------------------------------- *)
(* Handler for the "tsession_data_example_close" service:    *)

let tsession_data_example_close_handler sp () () =
  let sessdat = Eliom_sessions.get_volatile_session_data
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~table:my_table ~sp () in
  Eliom_sessions.close_session
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~sp () >>= fun () ->
  return
    [
      (match sessdat with
        | Eliom_sessions.Data_session_expired -> p [pcdata "Your session has expired."]
        | Eliom_sessions.No_data -> p [pcdata "You were not connected."]
        | Eliom_sessions.Data _ -> p [pcdata "You have been disconnected."]);
      p [Eliom_predefmod.Xhtml.a tsession_data_example sp [pcdata "Retry"] () ]]


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_appl.register
    tsession_data_example_close tsession_data_example_close_handler;
  Eliom_appl.register
    tsession_data_example tsession_data_example_handler;
  Eliom_appl.register
    tsession_data_example_with_post_params
    tsession_data_example_with_post_params_handler


(************************************************************)
(************ Connection of users, version 2 ****************)
(************************************************************)

(*zap* *)
let session_name = "tsession_services"
(* *zap*)
(* -------------------------------------------------------- *)
(* Create services, but do not register them yet:           *)

let tsession_services_example =
  Eliom_services.new_service
    ~path:["tsessionservices"]
    ~get_params:Eliom_parameters.unit
    ()

let tsession_services_example_with_post_params =
  Eliom_services.new_post_service
    ~fallback:tsession_services_example
    ~post_params:(Eliom_parameters.string "login")
    ()

let tsession_services_example_close =
  Eliom_services.new_service
    ~path:["tclose2"]
    ~get_params:Eliom_parameters.unit
    ()


(* ------------------------------------------------------------- *)
(* Handler for the "tsession_services_example" service:           *)
(* It displays the main page of our site, with a login form.     *)

let tsession_services_example_handler sp () () =
  let f =
    Eliom_appl.post_form
      tsession_services_example_with_post_params
      sp
      (fun login ->
        [p [pcdata "login: ";
            string_input ~input_type:`Text ~name:login ()]]) ()
  in
  return [f]


(* ------------------------------------------------------------- *)
(* Handler for the "tsession_services_example_close" service:     *)

let tsession_services_example_close_handler sp () () =
  Eliom_sessions.close_session
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~sp () >>= fun () ->
  Lwt.return [p [pcdata "You have been disconnected. ";
                 a tsession_services_example
                   sp [pcdata "Retry"] ()
                ]]

(* ------------------------------------------------------------- *)
(* Handler for the "session_services_example_with_post_params"   *)
(* service:                                                      *)

let tlaunch_session sp () login =

  (* New handler for the main page: *)
  let new_main_page sp () () =
    return
      [p [pcdata "Welcome ";
          pcdata login;
          pcdata "!"; br ();
          a eliomclient1 sp [pcdata "coucou"] (); br ();
          a tsession_services_example_close
            sp [pcdata "close session"] ()]]
  in

  (* If a session was opened, we close it first! *)
  Eliom_sessions.close_session
 (*zap* *) ~session_name (* *zap*) ~cookie_type:Eliom_common.CTab ~sp () >>= fun () ->

  (* Now we register new versions of main services in the
     session service table: *)
  Eliom_appl.register_for_session (*zap* *) ~session_name (* *zap*)
    ~cookie_type:Eliom_common.CTab
    ~sp
    ~service:tsession_services_example
    (* service is any public service already registered,
       here the main page of our site *)
    new_main_page;

  Eliom_appl.register_for_session (*zap* *) ~session_name (* *zap*)
    ~cookie_type:Eliom_common.CTab
    ~sp
    ~service:eliomclient1
    (fun _ () () ->
      return
        [p [pcdata "Coucou ";
            pcdata login;
            pcdata "!"]]);

  new_main_page sp () ()

(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_appl.register
    ~service:tsession_services_example
    tsession_services_example_handler;
  Eliom_appl.register
    ~service:tsession_services_example_close
    tsession_services_example_close_handler;
  Eliom_appl.register
    ~service:tsession_services_example_with_post_params
    tlaunch_session



(*$$$$$$$$$$$$$$$$$$$$$$

(************************************************************)
(************** Coservices. Basic examples ******************)
(************************************************************)

(* -------------------------------------------------------- *)
(* We create one main service and two coservices:           *)

let coservices_example =
  Eliom_services.new_service
    ~path:["coserv"]
    ~get_params:Eliom_parameters.unit
    ()

let coservices_example_post =
  Eliom_services.new_post_coservice
    ~fallback:coservices_example
    ~post_params:Eliom_parameters.unit
    ()

let coservices_example_get =
  Eliom_services.new_coservice
    ~fallback:coservices_example
    ~get_params:Eliom_parameters.unit
    ()


(* -------------------------------------------------------- *)
(* The three of them display the same page,                 *)
(* but the coservices change the counter.                   *)

let _ =
  let c = ref 0 in
  let page sp () () =
    let l3 = Eliom_predefmod.Xhtml.post_form coservices_example_post sp
        (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                        ~input_type:`Submit
                        ~value:"incr i (post)" ()]]) ()
    in
    let l4 = Eliom_predefmod.Xhtml.get_form coservices_example_get sp
        (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                        ~input_type:`Submit
                        ~value:"incr i (get)" ()]])
    in
    return
      (html
       (head (title (pcdata "")) [])
       (body [p [pcdata "i is equal to ";
                 pcdata (string_of_int !c); br ();
                 a coservices_example sp [pcdata "reload"] (); br ();
                 a coservices_example_get sp [pcdata "incr i"] ()];
              l3;
              l4]))
  in
  Eliom_predefmod.Xhtml.register coservices_example page;
  let f sp () () = c := !c + 1; page sp () () in
  Eliom_predefmod.Xhtml.register coservices_example_post f;
  Eliom_predefmod.Xhtml.register coservices_example_get f
(************************************************************)
(*************** calc: sum of two integers ******************)
(************************************************************)

(*zap* *)
let session_name = "calc_example"
(* *zap*)
(* -------------------------------------------------------- *)
(* We create two main services on the same URL,             *)
(* one with a GET integer parameter:                        *)

let calc =
  new_service
    ~path:["calc"]
    ~get_params:unit
    ()

let calc_i =
  new_service
    ~path:["calc"]
    ~get_params:(int "i")
    ()


(* -------------------------------------------------------- *)
(* The handler for the service without parameter.           *)
(* It displays a form where you can write an integer value: *)

let calc_handler sp () () =
  let create_form intname =
    [p [pcdata "Write a number: ";
        Eliom_predefmod.Xhtml.int_input ~input_type:`Text ~name:intname ();
        br ();
        Eliom_predefmod.Xhtml.string_input ~input_type:`Submit ~value:"Send" ()]]
  in
  let f = Eliom_predefmod.Xhtml.get_form calc_i sp create_form in
  return
    (html
       (head (title (pcdata "")) [])
       (body [f]))


(* -------------------------------------------------------- *)
(* The handler for the service with parameter.              *)
(* It creates dynamically and registers a new coservice     *)
(* with one GET integer parameter.                          *)
(* This new coservice depends on the first value (i)        *)
(* entered by the user.                                     *)

let calc_i_handler sp i () =
  let create_form is =
    (fun entier ->
       [p [pcdata (is^" + ");
           int_input ~input_type:`Text ~name:entier ();
           br ();
           string_input ~input_type:`Submit ~value:"Sum" ()]])
  in
  let is = string_of_int i in
  let calc_result =
    register_new_coservice_for_session
      ~sp
      ~fallback:calc
      ~get_params:(int "j")
      (fun sp j () ->
        let js = string_of_int j in
        let ijs = string_of_int (i+j) in
        return
          (html
             (head (title (pcdata "")) [])
             (body
                [p [pcdata (is^" + "^js^" = "^ijs)]])))
  in
  let f = get_form calc_result sp (create_form is) in
  return
    (html
       (head (title (pcdata "")) [])
       (body [f]))


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_predefmod.Xhtml.register calc   calc_handler;
  Eliom_predefmod.Xhtml.register calc_i calc_i_handler

(************************************************************)
(************ Connection of users, version 3 ****************)
(************************************************************)

(*zap* *)
let session_name = "connect_example3"
(* *zap*)
(* -------------------------------------------------------- *)
(* We create one main service and two (POST) actions        *)
(* (for connection and disconnection)                       *)

let connect_example3 =
  Eliom_services.new_service
    ~path:["action"]
    ~get_params:Eliom_parameters.unit
    ()

let connect_action =
  Eliom_services.new_post_coservice'
    ~name:"connect3"
    ~post_params:(Eliom_parameters.string "login")
    ()

(* As the handler is very simple, we register it now: *)
let disconnect_action =
  Eliom_predefmod.Action.register_new_post_coservice'
    ~name:"disconnect3"
    ~post_params:Eliom_parameters.unit
    (fun sp () () ->
      Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp ())


(* -------------------------------------------------------- *)
(* login ang logout boxes:                                  *)

let disconnect_box sp s =
  Eliom_predefmod.Xhtml.post_form disconnect_action sp
    (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                    ~input_type:`Submit ~value:s ()]]) ()

let login_box sp =
  Eliom_predefmod.Xhtml.post_form connect_action sp
    (fun loginname ->
      [p
         (let l = [pcdata "login: ";
                   Eliom_predefmod.Xhtml.string_input
                     ~input_type:`Text ~name:loginname ()]
         in l)
     ])
    ()


(* -------------------------------------------------------- *)
(* Handler for the "connect_example3" service (main page):    *)

let connect_example3_handler sp () () =
  let sessdat = Eliom_sessions.get_volatile_session_data (*zap* *) ~session_name (* *zap*) ~table:my_table ~sp () in
  return
    (html
       (head (title (pcdata "")) [])
       (body
          (match sessdat with
          | Eliom_sessions.Data name ->
              [p [pcdata ("Hello "^name); br ()];
              disconnect_box sp "Close session"]
          | Eliom_sessions.Data_session_expired
          | Eliom_sessions.No_data -> [login_box sp]
          )))


(* -------------------------------------------------------- *)
(* Handler for connect_action (user logs in):               *)

let connect_action_handler sp () login =
  Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp () >>= fun () ->
  Eliom_sessions.set_volatile_session_data (*zap* *) ~session_name (* *zap*) ~table:my_table ~sp login;
  return ()


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_predefmod.Xhtml.register ~service:connect_example3 connect_example3_handler;
  Eliom_predefmod.Action.register ~service:connect_action connect_action_handler


(*

let cookiename = "mycookie"

let cookies = new_service ["cookies"] unit ()

let _ = Cookies.register cookies
    (fun sp () () ->
      return
       ((html
         (head (title (pcdata "")) [])
         (body [p [pcdata (try
                             "cookie value: "^
                             (Ocsigen_lib.String_Table.find
                                cookiename (Eliom_sessions.get_cookies sp))
                           with _ -> "<cookie not set>");
                   br ();
                   a cookies sp [pcdata "send other cookie"] ()]])),
        [Eliom_services.Set (Eliom_common.CBrowser,
                             None, None,
                             cookiename,
                             string_of_int (Random.int 100),
                             false)]))
*)



(************************************************************)
(************ Connection of users, version 4 ****************)
(**************** (persistent sessions) *********************)
(************************************************************)

(*zap* *)
let session_name = "persistent_sessions"
(* *zap*)
let my_persistent_table =
  create_persistent_table "eliom_example_table"

(* -------------------------------------------------------- *)
(* We create one main service and two (POST) actions        *)
(* (for connection and disconnection)                       *)

let persist_session_example =
  Eliom_services.new_service
    ~path:["persist"]
    ~get_params:unit
    ()

let persist_session_connect_action =
  Eliom_services.new_post_coservice'
    ~name:"connect4"
    ~post_params:(string "login")
    ()

(* disconnect_action, login_box and disconnect_box have been
   defined in the section about actions *)

(*zap* *)

(* -------------------------------------------------------- *)
(* Actually, no. It's a lie because we don't use the
   same session name :-) *)
(* new disconnect action and box:                           *)

let disconnect_action =
  Eliom_predefmod.Action.register_new_post_coservice'
    ~name:"disconnect4"
    ~post_params:Eliom_parameters.unit
    (fun sp () () ->
      Eliom_sessions.close_session ~session_name ~sp ())

let disconnect_box sp s =
  Eliom_predefmod.Xhtml.post_form disconnect_action sp
    (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                    ~input_type:`Submit ~value:s ()]]) ()

let bad_user_key = Polytables.make_key ()
let get_bad_user table = 
  try Polytables.get ~table ~key:bad_user_key with Not_found -> false

(* -------------------------------------------------------- *)
(* new login box:                                           *)

let login_box sp session_expired action =
  Eliom_predefmod.Xhtml.post_form action sp
    (fun loginname ->
      let l =
        [pcdata "login: ";
         string_input ~input_type:`Text ~name:loginname ()]
      in
      [p (if get_bad_user (Eliom_sessions.get_request_cache sp)
      then (pcdata "Wrong user")::(br ())::l
      else
        if session_expired
        then (pcdata "Session expired")::(br ())::l
        else l)
     ])
    ()

(* *zap*)

(* ----------------------------------------------------------- *)
(* Handler for "persist_session_example" service (main page):  *)

let persist_session_example_handler sp () () =
  Eliom_sessions.get_persistent_session_data (*zap* *) ~session_name (* *zap*)
    ~table:my_persistent_table ~sp () >>= fun sessdat ->
  return
    (html
       (head (title (pcdata "")) [])
       (body
          (match sessdat with
          | Eliom_sessions.Data name ->
              [p [pcdata ("Hello "^name); br ()];
              disconnect_box sp "Close session"]
          | Eliom_sessions.Data_session_expired ->
              [login_box sp true persist_session_connect_action;
               p [em [pcdata "The only user is 'toto'."]]]
          | Eliom_sessions.No_data ->
              [login_box sp false persist_session_connect_action;
               p [em [pcdata "The only user is 'toto'."]]]
          )))


(* ----------------------------------------------------------- *)
(* Handler for persist_session_connect_action (user logs in):  *)

let persist_session_connect_action_handler sp () login =
  Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp () >>= fun () ->
  if login = "toto" (* Check user and password :-) *)
  then
    Eliom_sessions.set_persistent_session_data (*zap* *) ~session_name (* *zap*) ~table:my_persistent_table ~sp login
  else ((*zap* *)Polytables.set (Eliom_sessions.get_request_cache sp) bad_user_key true;(* *zap*)return ())


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_predefmod.Xhtml.register
    ~service:persist_session_example
    persist_session_example_handler;
  Eliom_predefmod.Action.register
    ~service:persist_session_connect_action
    persist_session_connect_action_handler


(************************************************************)
(************ Connection of users, version 6 ****************)
(************************************************************)
(*zap* *)
let session_name = "connect_example6"
(* *zap*)
(* -------------------------------------------------------- *)
(* We create one main service and two (POST) actions        *)
(* (for connection and disconnection)                       *)

let connect_example6 =
  Eliom_services.new_service
    ~path:["action2"]
    ~get_params:unit
    ()

let connect_action =
  Eliom_services.new_post_coservice'
    ~name:"connect6"
    ~post_params:(string "login")
    ()

(* new disconnect action and box:                           *)

let disconnect_action =
  Eliom_predefmod.Action.register_new_post_coservice'
    ~name:"disconnect6"
    ~post_params:Eliom_parameters.unit
    (fun sp () () ->
      Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp ())

let disconnect_box sp s =
  Eliom_predefmod.Xhtml.post_form disconnect_action sp
    (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                    ~input_type:`Submit ~value:s ()]]) ()


let bad_user_key = Polytables.make_key ()
let get_bad_user table = 
  try Polytables.get ~table ~key:bad_user_key with Not_found -> false

(* -------------------------------------------------------- *)
(* new login box:                                           *)

let login_box sp session_expired action =
  Eliom_predefmod.Xhtml.post_form action sp
    (fun loginname ->
      let l =
        [pcdata "login: ";
         string_input ~input_type:`Text ~name:loginname ()]
      in
      [p (if get_bad_user (Eliom_sessions.get_request_cache sp)
      then (pcdata "Wrong user")::(br ())::l
      else
        if session_expired
        then (pcdata "Session expired")::(br ())::l
        else l)
     ])
    ()

(* -------------------------------------------------------- *)
(* Handler for the "connect_example6" service (main page):   *)

let connect_example6_handler sp () () =
  let group =
    Eliom_sessions.get_volatile_data_session_group (*zap* *) ~session_name (* *zap*) ~sp ()
  in
  return
    (html
       (head (title (pcdata "")) [])
       (body
          (match group with
          | Eliom_sessions.Data name ->
              [p [pcdata ("Hello "^name); br ()];
              disconnect_box sp "Close session"]
          | Eliom_sessions.Data_session_expired ->
              [login_box sp true connect_action;
               p [em [pcdata "The only user is 'toto'."]]]
          | Eliom_sessions.No_data ->
              [login_box sp false connect_action;
               p [em [pcdata "The only user is 'toto'."]]]
          )))

(* -------------------------------------------------------- *)
(* New handler for connect_action (user logs in):           *)

let connect_action_handler sp () login =
  Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp () >>= fun () ->
  if login = "toto" (* Check user and password :-) *)
  then begin
    Eliom_sessions.set_volatile_data_session_group ~set_max:4 (*zap* *) ~session_name (* *zap*) ~sp login;
    return ()
  end
  else begin
    Polytables.set (Eliom_sessions.get_request_cache sp) bad_user_key true;
    return ()
  end


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_predefmod.Xhtml.register ~service:connect_example6 connect_example6_handler;
  Eliom_predefmod.Action.register ~service:connect_action connect_action_handler



(************************************************************)
(************ Connection of users, version 5 ****************)
(************************************************************)

(*zap* *)
let session_name = "connect_example5"
(* *zap*)
(* -------------------------------------------------------- *)
(* We create one main service and two (POST) actions        *)
(* (for connection and disconnection)                       *)

let connect_example5 =
  Eliom_services.new_service
    ~path:["groups"]
    ~get_params:Eliom_parameters.unit
    ()

let connect_action =
  Eliom_services.new_post_coservice'
    ~name:"connect5"
    ~post_params:(Eliom_parameters.string "login")
    ()

(* As the handler is very simple, we register it now: *)
let disconnect_action =
  Eliom_predefmod.Action.register_new_post_coservice'
    ~name:"disconnect5"
    ~post_params:Eliom_parameters.unit
    (fun sp () () ->
      Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp ())


(* -------------------------------------------------------- *)
(* login ang logout boxes:                                  *)

let disconnect_box sp s =
  Eliom_predefmod.Xhtml.post_form disconnect_action sp
    (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                    ~input_type:`Submit ~value:s ()]]) ()

let login_box sp =
  Eliom_predefmod.Xhtml.post_form connect_action sp
    (fun loginname ->
      [p
         (let l = [pcdata "login: ";
                   Eliom_predefmod.Xhtml.string_input
                     ~input_type:`Text ~name:loginname ()]
         in l)
     ])
    ()


(* -------------------------------------------------------- *)
(* Handler for the "connect_example5" service (main page):    *)

let connect_example5_handler sp () () =
  let sessdat = Eliom_sessions.get_volatile_data_session_group (*zap* *) ~session_name (* *zap*) ~sp () in
  return
    (html
       (head (title (pcdata "")) [])
       (body
          (match sessdat with
          | Eliom_sessions.Data name ->
              [p [pcdata ("Hello "^name); br ()];
              disconnect_box sp "Close session"]
          | Eliom_sessions.Data_session_expired
          | Eliom_sessions.No_data -> [login_box sp]
          )))


(* -------------------------------------------------------- *)
(* Handler for connect_action (user logs in):               *)

let connect_action_handler sp () login =
  Eliom_sessions.close_session (*zap* *) ~session_name (* *zap*) ~sp () >>= fun () ->
  Eliom_sessions.set_volatile_data_session_group ~set_max:4 (*zap* *) ~session_name (* *zap*) ~sp login;
  return ()


(* -------------------------------------------------------- *)
(* Registration of main services:                           *)

let () =
  Eliom_predefmod.Xhtml.register ~service:connect_example5 connect_example5_handler;
  Eliom_predefmod.Action.register ~service:connect_action connect_action_handler






let csrfsafe_example =
  Eliom_services.new_service
    ~path:["csrf"]
    ~get_params:Eliom_parameters.unit
    ()

let csrfsafe_example_post =
  Eliom_services.new_post_coservice
    ~csrf_safe:true
    ~csrf_session_name:"csrf"
    ~csrf_secure_session:true
    ~timeout:10.
    ~max_use:1
    ~https:true
    ~fallback:csrfsafe_example
    ~post_params:Eliom_parameters.unit
    ()

let _ =
  let page sp () () =
    let l3 = Eliom_predefmod.Xhtml.post_form csrfsafe_example_post sp
        (fun _ -> [p [Eliom_predefmod.Xhtml.string_input
                        ~input_type:`Submit
                        ~value:"Click" ()]]) ()
    in
    return
      (html
       (head (title (pcdata "CSRF safe service example")) [])
       (body [p [pcdata "A new coservice will be created each time this form is displayed"];
              l3]))
  in
  Eliom_predefmod.Xhtml.register csrfsafe_example page;
  Eliom_predefmod.Xhtml.register csrfsafe_example_post
    (fun sp () () ->
       Lwt.return
         (html
            (head (title (pcdata "CSRF safe service")) [])
            (body [p [pcdata "This is a CSRF safe service"]])))



    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$ *)














(*zap* *)
open Tutoeliom

(* Main page for this example *)
let main = new_service [] unit ()

let _ = Eliom_predefmod.Xhtmlcompact.register main
  (fun sp () () ->
    Lwt.return
     (html
       (head
          (title (pcdata "Eliom examples"))
          [css_link (make_uri ~service:(static_dir sp) ~sp ["style.css"]) ()])
       (body
          [
            h1 [img ~alt:"Ocsigen" ~src:(Eliom_predefmod.Xhtml.make_uri ~service:(static_dir sp) ~sp ["ocsigen5.png"]) ()];

            h3 [pcdata "Eliom examples"];
            h4 [pcdata "Simple pages"];
            p [
              pcdata "A simple page: ";
              a coucou sp [code [pcdata "coucou"]] ();
              br ();

              pcdata "A page with a counter: ";
              a count sp [code [pcdata "count"]] ();
              br ();


              pcdata "A page in a directory: ";
              a hello sp [code [pcdata "dir/hello"]] ();
              br ();


              pcdata "Default page of a directory: ";
              a default sp [code [pcdata "rep/"]] ()
            ];

            h4 [pcdata "Parameters"];
            p [
              pcdata "A page with GET parameters: ";
              a coucou_params sp [code [pcdata "coucou"]; pcdata " with params"] (45,(22,"krokodile"));
              pcdata "(what if the first parameter is not an integer?)";
              br ();

              pcdata "A page with \"suffix\" URL that knows the IP and user-agent of the client: ";
              a uasuffix sp [code [pcdata "uasuffix"]] (2007,6);
              br ();


              pcdata "A page with \"suffix\" URL and GET parameters: ";
              a isuffix sp [code [pcdata "isuffix"]] ((111, ["OO";"II";"OO"]), 333);
              br ();

              pcdata "A page with constants in suffix: ";
              a constfix sp [pcdata "Page with constants in suffix"] ("aa", ((), "bb"));
              br ();

              pcdata "Form towards page with suffix: ";
              a suffixform sp [pcdata "formsuffix"] ();
              br ();

              pcdata "A page with a parameter of user-defined type : ";
              a mytype sp [code [pcdata "mytype"]] A;
            ];

            h4 [pcdata "Links and Forms"];
            p [
              pcdata "A page with links: ";
              a links sp [code [pcdata "links"]]  ();
              br ();


              pcdata "A page with a link towards itself: ";
              a linkrec sp [code [pcdata "linkrec"]] ();
              br ();


              pcdata "The ";
              a main sp [pcdata "default page"] ();
              pcdata "of this directory (myself)";
              br ();

              pcdata "A page with a GET form that leads to the \"coucou\" page with parameters: ";
              a form sp [code [pcdata "form"]] ();
              br ();


              pcdata "A POST form towards the \"post\" page: ";
              a form2 sp [code [pcdata "form2"]] ();
              br ();


              pcdata "The \"post\" page, when it does not receive parameters: ";
              a no_post_param_service sp [code [pcdata "post"]; pcdata " without post_params"] ();
              br ();


              pcdata "A POST form towards a service with GET parameters: ";
              a form3 sp [code [pcdata "form3"]] ();
              br ();


              pcdata "A POST form towards an external page: ";
              a form4 sp [code [pcdata "form4"]] ();
            ];

            h4 [pcdata "Sessions"];
            p [
              pcdata "Coservices: ";
              a coservices_example sp [code [pcdata "coservice"]] ();
              br ();


              pcdata "A session based on cookies, implemented with session data: ";
              a session_data_example sp [code [pcdata "sessdata"]] ();
              br ();


              pcdata "A session based on cookies, implemented with actions: ";
              a connect_example3 sp [code [pcdata "actions"]] ();
              br ();


              pcdata "A session based on cookies, with session services: ";
              a session_services_example sp [code [pcdata "sessionservices"]] ();
              br ();

              pcdata "A session based on cookies, implemented with actions, with session groups: ";
              a connect_example5 sp [code [pcdata "groups"]] ();
              br ();


              pcdata "The same with wrong user if not \"toto\": ";
              a connect_example6 sp [code [pcdata "actions2"]] ();
              br ();


              pcdata "Coservices in the session table: ";
              a calc sp [code [pcdata "calc"]] ();
              br ();


              pcdata "Persistent sessions: ";
              a persist_session_example sp [code [pcdata "persist"]] ();
              br ();
            ];

            h4 [pcdata "Other"];
            p [
              pcdata "A page that is very slow, implemented in cooperative way: ";
              a looong sp [code [pcdata "looong"]] ();
              br ();


              pcdata "A page that is very slow, using preemptive threads: ";
              a looong sp [code [pcdata "looong2"]] ();
              br ();


              pcdata "Catching errors: ";
              a catch sp [code [pcdata "catch"]] 22;
              pcdata "(change the value in the URL)";
              br ();

              pcdata "Redirection: ";
              a redir sp [code [pcdata "redir"]] 11;
              br ();

              pcdata "Cookies: ";
              a cookies sp [code [pcdata "cookies"]] ();
              br ();


              pcdata "Disposable coservices: ";
              a disposable sp [code [pcdata "disposable"]] ();
              br ();

              pcdata "Coservice with timeout: ";
              a timeout sp [code [pcdata "timeout"]] ();
              br ();

              pcdata "Public coservice created after initialization (with timeout): ";
              a publiccoduringsess sp [code [pcdata "publiccoduringsess"]] ();
              br ();


              pcdata "The following URL send either a statically checked page, or a text page: ";
              a send_any sp [code [pcdata "send_any"]] "valid";
              br ();


              pcdata "A page with a persistent counter: ";
              a count2 sp [code [pcdata "count2"]] ();
              br ();

              a hier1 sp [pcdata "Hierarchical menu"] ();
              br ();

              a divpage sp [code [pcdata "a link sending a &lt;div&gt; page"]] ();
              br ();

              a tonlparams sp [pcdata "Non localized parameters"] ();
              br ();

              a nlparams sp [pcdata "Non localized parameters (absent)"] 4;
              br ();

              a nlparams_with_nlp sp [pcdata "Non localized parameters (present)"] (22, (11, "aa"));
              br ();

              a csrfsafe_example sp [pcdata "CSRF safe services"] ();
              br ();
            ];

            h4 [pcdata "Advanced forms"];
            p [
              pcdata "A page that parses a parameter using a regular expression: ";
              a regexpserv sp [code [pcdata "regexpserv"]] "[toto]";
              br ();

              pcdata "A form with a checkbox: ";
              a form_bool sp [pcdata "Try it"] ();
              br ();

              pcdata "A page that takes a set of parameters: ";
              a set sp [code [pcdata "set"]] ["Ciao";"bello";"ciao"];
              br ();

              pcdata "A form to the previous one: ";
              a setform sp [code [pcdata "setform"]] ();
              br ();

              pcdata "A page that takes any parameter: ";
              a raw_serv sp [code [pcdata "raw_serv"]] [("a","hello"); ("b","ciao")];
              br ();

              pcdata "A form to the previous one: ";
              a raw_form sp [code [pcdata "raw_form"]] ();
              br ();

              pcdata "A form for a list of parameters: ";
              a listform sp [pcdata "Try it"] ();
              br ();
            ];

            h3 [pcdata "Eliom Client"];
            p [
              a eliomclient1 sp [pcdata "Simple example of client side code"] ();
              br ();

              a eliomclient2 sp [pcdata "Using Eliom services in client side code"] ();
            br ();
              a eliomclient3 sp [pcdata "Caml values in service parameters"] ();
            br ();
              a eliomclient4 sp [pcdata "A service sending a Caml value"] ();
            br ();
              a gotowithoutclient sp [pcdata "A page that links to a service that belongs to the application but do not launch the application if it is already launched"] ();
            br ();
              a comet1 sp [pcdata "A really simple comet example"] ();
            br ();
              a comet2 sp [pcdata "A comet example with server to client and client to server asynchronous events"] ();
            br ();
              a comet3 sp [pcdata "Server simultaneous events, transmitted together"] ();
            br ();
              a comet_message_board sp [pcdata "Minimalistic message board"] ();
            br ();
          ];

            h4 [pcdata "Tab sessions"];
            p [
(*              pcdata "Coservices: ";
              a coservices_example sp [code [pcdata "coservice"]] ();
              br ();
*)

              pcdata "A session based on cookies, implemented with session data: ";
              a tsession_data_example sp [code [pcdata "tsessdata"]] ();
              br ();
(*

              pcdata "A session based on cookies, implemented with actions: ";
              a connect_example3 sp [code [pcdata "actions"]] ();
              br ();
*)

              pcdata "A session based on cookies, with session services: ";
              a tsession_services_example sp [code [pcdata "tsessionservices"]] ();
              br ();
(*
              pcdata "A session based on cookies, implemented with actions, with session groups: ";
              a connect_example5 sp [code [pcdata "groups"]] ();
              br ();


              pcdata "The same with wrong user if not \"toto\": ";
              a connect_example6 sp [code [pcdata "actions2"]] ();
              br ();


              pcdata "Coservices in the session table: ";
              a calc sp [code [pcdata "calc"]] ();
              br ();


              pcdata "Persistent sessions: ";
              a persist_session_example sp [code [pcdata "persist"]] ();
              br ();
*)
            ];

          ]
       )))
;;

(* *zap*)
