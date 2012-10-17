
open Eliom_pervasives_base

(** This module is automatically open by {v eliomc v} and {v js_of_eliom v}. *)

(** {2 Client values}

    See the {% <<a_manual chapter="eliom-language"|manual>> %}. *)

(** An ['a] client value on the client is just an ['a].
    See also {% <<a_api subproject="server" text="the abstract representation on the server" |
    type Eliom_pervasives.client_value >> %}. *)
type 'a client_value = 'a Eliom_lib.client_value

(* Re-export Eliom_lib.False here, when
   cf. http://caml.inria.fr/mantis/view.php?id=5778 is fixed *)
(* exception False *)

(** {2 RPC / Server functions}

    See the {% <<a_manual chapter="client-communication" fragment="rpc"|manual>> %}.*)

(** A [('a, 'b) server_function] provides transparently access to a
    server side function which has been created by {% <<a_api
    subproject="server"|Eliom_pervasives.server_function>> %}.

    If the function on the server raises an exception in Lwt, the call
    to the [server_function] raises an exception {% <<a_api|exception
    Exception_on_server>> %}.

    See also {% <<a_api subproject="server" text="the opaque server
    side representation"| type Eliom_pervasives.server_function>> %}.
*)
type ('a, 'b) server_function = 'a -> 'b Lwt.t

(**/**)

val _force_link : unit
