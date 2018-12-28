TYPE-POOL yevt.

DEFINE yevt_propagate.

  DATA lo_class_desc              TYPE REF TO cl_abap_objectdescr.
  DATA lv_current_classname       TYPE string.
  DATA lv_current_methodname      TYPE string.
  DATA lo_caller                  TYPE REF TO object.

  DATA lt_callstack               TYPE sys_callst.
  DATA ls_callstack               TYPE LINE OF sys_callst.

  DATA ls_param                   TYPE abap_parmbind.
  DATA lt_params                  TYPE abap_parmbind_tab.

  DATA lt_methods                 TYPE abap_methdescr_tab.
  DATA lt_attr                    TYPE abap_attrdescr_tab.

  FIELD-SYMBOLS: <param_table_ref>    TYPE STANDARD TABLE.
  FIELD-SYMBOLS: <param_ref>          TYPE any.

  DATA exref                      TYPE REF TO cx_root.

  "--> first of all: this code is pretty-printed by engine of abap code formatting. Don't blame on me.

  TRY.
    "--> describe current YEvent Family instance
    lo_class_desc ?= cl_abap_objectdescr=>describe_by_object_ref( me ).
    lv_current_classname = lo_class_desc->get_relative_name( ).

    "--> get relative interface
    SELECT SINGLE refclsname FROM vseoifimpl INTO @DATA(lv_itfname) WHERE clsname = @lv_current_classname.
    "--> retrieve all implemented class, or all YEvent Implementation classes
    SELECT * FROM vseoifimpl INTO TABLE @DATA(lt_callset) WHERE refclsname = @lv_itfname.
    "--> remove this class from list (must not recall myself or an evil portal will open)
    DELETE lt_callset WHERE clsname = lv_current_classname.

    "--> inspect current call stack
    CALL FUNCTION 'SYSTEM_CALLSTACK' IMPORTING et_callstack = lt_callstack.

    "--> extract YEvent family class method
    READ TABLE lt_callstack INTO ls_callstack INDEX 1.
    "--> current method name
    lv_current_methodname = ls_callstack-eventname.

    "--> retrieving method parameters
    lt_methods = lo_class_desc->methods.
    lt_attr = lo_class_desc->attributes.
    READ TABLE lt_methods INTO DATA(wa_methods) WITH KEY name = lv_current_methodname.

    "--> build parameter table
    LOOP AT wa_methods-parameters INTO DATA(ls_parameter).
      UNASSIGN <param_table_ref>.
      UNASSIGN <param_ref>.
      CLEAR ls_param.

      CASE ls_parameter-type_kind.
        WHEN cl_abap_objectdescr=>typekind_table.
          ASSIGN (ls_parameter-name) TO <param_table_ref>.
          GET REFERENCE OF <param_table_ref> INTO ls_param-value.
        WHEN OTHERS.
          ASSIGN (ls_parameter-name) TO <param_ref>.
          GET REFERENCE OF <param_ref> INTO ls_param-value.
      ENDCASE.

      ls_param-name = ls_parameter-name.
      ls_param-kind = cl_abap_objectdescr=>exporting.
      INSERT ls_param INTO TABLE lt_params.
    ENDLOOP.

  CATCH cx_root INTO exref.
    ycl_log=>log( level = ycl_log=>error world = 'YLOG' tag = 'YEVT' method = 'yevt_propagate' msg = 'Error during YEvent propagation process, exception msg: ' && exref->get_text( ) ).
  ENDTRY.

  "--> call current event method in every YEvent Implementation
  LOOP AT lt_callset INTO DATA(ls_callset).
    TRY.
      ycl_log=>log( level = ycl_log=>info world = 'YLOG' tag = 'YEVT' method = 'yevt_propagate' msg = 'Preparing YEvent implementation call ' && ls_callset-clsname && '...' ).
      "--> create YEvent Implementation instance
      CREATE OBJECT lo_caller TYPE (ls_callset-clsname).
      lo_class_desc ?= cl_abap_objectdescr=>describe_by_object_ref( lo_caller ).

      CALL METHOD lo_caller->(lv_current_methodname) PARAMETER-TABLE lt_params.

    CATCH cx_root INTO exref.
        ycl_log=>log( level = ycl_log=>error world = 'YLOG' tag = 'YEVT' method = 'yevt_propagate' msg = 'Error during YEvent implementation call, exception msg: ' && exref->get_text( ) ).
    ENDTRY.

    ycl_log=>log( level = ycl_log=>info world = 'YLOG' tag = 'YEVT' method = 'yevt_propagate' msg = 'YEvent implementation call ' && ls_callset-clsname && ' completed.' ).
  ENDLOOP.

END-OF-DEFINITION.
