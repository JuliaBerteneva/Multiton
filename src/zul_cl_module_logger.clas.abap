CLASS zul_cl_module_logger DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_log_line,
             ts      TYPE timestampl,
             module  TYPE string,
             level   TYPE c LENGTH 1,  "I/W/E
             message TYPE string,
           END OF ty_log_line.
    TYPES tt_log TYPE STANDARD TABLE OF ty_log_line WITH EMPTY KEY.

    "Multiton access (one instance per module key)
    CLASS-METHODS get_instance
      IMPORTING
        iv_module        TYPE string
      RETURNING
        VALUE(ro_logger) TYPE REF TO zul_cl_module_logger.

    METHODS info  IMPORTING iv_message TYPE string.
    METHODS warn  IMPORTING iv_message TYPE string.
    METHODS error IMPORTING iv_message TYPE string.

    "Access buffered log lines
    METHODS get_buffer
      RETURNING VALUE(rt_log) TYPE tt_log.

    "Example "flush" (replace with BAL / SLG1 if you want)
    METHODS flush_to_list.

    "Optional: reset one module logger buffer
    METHODS clear_buffer.

  PRIVATE SECTION.
    "Registry (Multiton): module -> instance
    TYPES: BEGIN OF ty_registry_line,
             module TYPE string,
             ref    TYPE REF TO zul_cl_module_logger,
           END OF ty_registry_line.
    CLASS-DATA gt_registry TYPE HASHED TABLE OF ty_registry_line
      WITH UNIQUE KEY module.

    DATA mv_module TYPE string.
    DATA mt_log    TYPE tt_log.

    METHODS constructor IMPORTING iv_module TYPE string.
    METHODS add_line IMPORTING iv_level   TYPE char1
                               iv_message TYPE string.
ENDCLASS.

CLASS zul_cl_module_logger IMPLEMENTATION.

  METHOD constructor.
    mv_module = to_upper( iv_module ).
  ENDMETHOD.

  METHOD get_instance.
    DATA(lv_module) = to_upper( iv_module ).

    READ TABLE gt_registry WITH TABLE KEY module = lv_module INTO DATA(ls_reg).
    IF sy-subrc = 0.
      ro_logger = ls_reg-ref.
      RETURN.
    ENDIF.

    ro_logger = NEW zul_cl_module_logger( lv_module ).
    INSERT VALUE #( module = lv_module ref = ro_logger ) INTO TABLE gt_registry.
  ENDMETHOD.

  METHOD add_line.
    GET TIME STAMP FIELD DATA(lv_ts).
    APPEND VALUE ty_log_line(
      ts      = lv_ts
      module  = mv_module
      level   = iv_level
      message = iv_message
    ) TO mt_log.
  ENDMETHOD.

  METHOD info.
    add_line( iv_level = 'I' iv_message = iv_message ).
  ENDMETHOD.

  METHOD warn.
    add_line( iv_level = 'W' iv_message = iv_message ).
  ENDMETHOD.

  METHOD error.
    add_line( iv_level = 'E' iv_message = iv_message ).
  ENDMETHOD.

  METHOD get_buffer.
    rt_log = mt_log.
  ENDMETHOD.

  METHOD clear_buffer.
    CLEAR mt_log.
  ENDMETHOD.

  METHOD flush_to_list.
    "Demo output — replace with application log (BAL) in real systems
    LOOP AT mt_log INTO DATA(ls_line).
      WRITE: / ls_line-module, ls_line-level, ls_line-ts, ls_line-message.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
