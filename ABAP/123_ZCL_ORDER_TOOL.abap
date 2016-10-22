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
    DATA: ls_query_para TYPE GENILT_QUERY_PARAMETERS,
          lt_sel_para TYPE GENILT_SELECTION_PARAMETER_TAB,
          ls_sel_para LIKE LINE OF lt_sel_para.

    so_core = CL_CRM_BOL_CORE=>get_instance( ).

    so_core->load_component_set( 'BT' ).

    ls_sel_para = value #( attr_name = 'OBJECT_ID' option = 'EQ' sign = 'I' low = '423' ).
    APPEND ls_sel_para TO lt_sel_para.

    ls_sel_para-attr_name = 'PROCESS_TYPE'.
    ls_sel_para-low = 'OPPT'.
    APPEND ls_sel_para TO lt_sel_para.
    data(lo_orders) = so_core->dquery(
       IV_QUERY_NAME = 'BTQ1Order'
       IS_QUERY_PARAMETERS = ls_query_para
       IT_SELECTION_PARAMETERS = lt_sel_para
    ).

    CHECK lo_orders->size( ) = 1.


  endmethod.
ENDCLASS.