include "eliom_forms.mli"
  subst type uri := XML.uri
    and type pcdata_elt := HTML5_types.pcdata Eliom_content_core.HTML5.elt

    and type form_elt := [> HTML5_types.form ] Eliom_content_core.HTML5.elt
    and type form_content_elt := HTML5_types.form_content Eliom_content_core.HTML5.elt
    and type form_content_elt_list := HTML5_types.form_content Eliom_content_core.HTML5.elt list
    and type form_attrib_t := HTML5_types.form_attrib Eliom_content_core.HTML5.attrib list

    and type 'a a_elt := [> 'a HTML5_types.a ] Eliom_content_core.HTML5.elt
    and type 'a a_content_elt := 'a Eliom_content_core.HTML5.elt
    and type 'a a_content_elt_list := 'a Eliom_content_core.HTML5.elt list
    and type a_attrib_t := HTML5_types.a_attrib Eliom_content_core.HTML5.attrib list

    and type link_elt := [> HTML5_types.link ] Eliom_content_core.HTML5.elt
    and type link_attrib_t := HTML5_types.link_attrib Eliom_content_core.HTML5.attrib list

    and type script_elt := [> HTML5_types.script ] Eliom_content_core.HTML5.elt
    and type script_attrib_t := HTML5_types.script_attrib Eliom_content_core.HTML5.attrib list

    and type textarea_elt := [> HTML5_types.textarea ] Eliom_content_core.HTML5.elt
    and type textarea_attrib_t := HTML5_types.textarea_attrib Eliom_content_core.HTML5.attrib list

    and type input_elt := [> HTML5_types.input ] Eliom_content_core.HTML5.elt
    and type input_attrib_t := HTML5_types.input_attrib Eliom_content_core.HTML5.attrib list

    and type select_elt := [> HTML5_types.select ] Eliom_content_core.HTML5.elt
    and type select_attrib_t := HTML5_types.select_attrib Eliom_content_core.HTML5.attrib list

    and type button_elt := [> HTML5_types.button ] Eliom_content_core.HTML5.elt
    and type button_content_elt := HTML5_types.button_content Eliom_content_core.HTML5.elt
    and type button_content_elt_list := HTML5_types.button_content Eliom_content_core.HTML5.elt list
    and type button_attrib_t := HTML5_types.button_attrib Eliom_content_core.HTML5.attrib list

    and type optgroup_attrib_t := [ HTML5_types.common | `Disabled ] Eliom_content_core.HTML5.attrib list
    and type option_attrib_t := HTML5_types.option_attrib Eliom_content_core.HTML5.attrib list

    and type input_type_t :=
      [< `Hidden
      | `Password
      | `Submit
      | `Text ]

    and type raw_input_type_t :=
      [< `Button
      | `Hidden
      | `Password
      | `Reset
      | `Submit
      | `Text ]

    and type button_type_t :=
      [< `Button
      | `Reset
      | `Submit
      ]

    and type for_attrib := [> `For ] Eliom_content_core.HTML5.attrib

