class ZCL_ORDER_TOOL definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
protected section.
private section.

  class-data SO_CORE type ref to CL_CRM_BOL_CORE .
ENDCLASS.



CLASS ZCL_ORDER_TOOL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ORDER_TOOL=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CLASS_CONSTRUCTOR.
    DATA: lo_core            TYPE REF TO cl_crm_bol_core,
          lo_collection      TYPE REF TO if_bol_entity_col,
          lv_view_name       TYPE crmt_view_name,
          lv_query_name      TYPE crmt_ext_obj_name,
          ls_parameter TYPE GENILT_QUERY_PARAMETERS,
          lt_query_parameter TYPE GENILT_SELECTION_PARAMETER_TAB,
          ls_query_parameter LIKE LINE OF lt_query_parameter,
          lv_size            TYPE i.

    ls_query_parameter-attr_name = 'OBJECT_ID'.
    ls_query_parameter-low = '2036'.
    ls_query_parameter-option = 'EQ'.
    ls_query_parameter-sign = 'I'.
    APPEND ls_query_parameter TO lt_query_parameter.

    ls_query_parameter-attr_name = 'PROCESS_TYPE'.
    ls_query_parameter-low = 'OPPT'.
    ls_query_parameter-option = 'EQ'.
    ls_query_parameter-sign = 'I'.
    APPEND ls_query_parameter TO lt_query_parameter.

    lo_core = cl_crm_bol_core=>get_instance( ).
    lo_core->load_component_set( 'BT' ).
    lv_query_name = 'BTQ1Order'.

    data(lo_result) = lo_core->dquery(
        iv_query_name               = lv_query_name
        is_query_parameters         = ls_parameter
        IT_SELECTION_PARAMETERS             = lt_query_parameter
        iv_view_name                = lv_view_name ).

    check LO_RESULT->size( ) = 1.
    data(lo_order_result) = lo_result->get_first( ).

    data(lo_bt_order) = lo_order_result->get_related_entity( 'BTADVS1Ord' ).
    CHECK lo_bt_order IS NOT INITIAL.

    data(lo_header) = lo_bt_order->get_related_entity( 'BTOrderHeader' ).

    check lo_header IS NOT INITIAL.

    data(lo_items) = lo_header->get_related_entities( IV_RELATION_NAME = 'BTHeaderItemsExt' ).
    CHECK lo_items->size( ) = 1.

    data(lo_item) = lo_items->get_first( ).

    data(lo_admini) = lo_item->get_related_entity( 'BTItemsFirstLevel' ).
    check lo_admini IS NOT INITIAL.

    data(lo_product) = lo_admini->get_related_entity( 'BTItemProductExt' ).

  endmethod.
ENDCLASS.