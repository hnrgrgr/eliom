include "eliom_reg.mli"
  subst type page    := HTML5_types.html Eliom_content_core.HTML5.elt
    and type options := unit
    and type return  := http_service
    and type result  := (browser_content, http_service) kind
