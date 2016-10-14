CLASS zcl_summer DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    TYPES:
      tt_class_list TYPE STANDARD TABLE OF tadir-obj_name WITH KEY table_line .

    CLASS-METHODS class_constructor .
    METHODS get_bean
      IMPORTING
        !iv_bean_name  TYPE tadir-obj_name
      RETURNING
        VALUE(ro_host) TYPE REF TO object .
    CLASS-METHODS get_instance
      RETURNING
        VALUE(ro_instance) TYPE REF TO zcl_summer .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_registered_bean,
        host_name     TYPE tadir-obj_name,
        host_ref      TYPE REF TO object,
        dependent_ref TYPE REF TO object,
      END OF ty_registered_bean .
    TYPES:
      tt_registered_bean TYPE STANDARD TABLE OF ty_registered_bean WITH KEY host_name .

    CONSTANTS cv_inject TYPE string VALUE '@Inject' ##NO_TEXT.
    DATA mt_registered_bean TYPE tt_registered_bean .
    CLASS-DATA so_instance TYPE REF TO zcl_summer .

    METHODS get_implementation_cls_name
      IMPORTING
        !iv_type           TYPE rs38l_typ
      RETURNING
        VALUE(rv_cls_name) TYPE tadir-obj_name .
    METHODS get_class_list
      IMPORTING
        !iv_package          TYPE devclass
      RETURNING
        VALUE(rt_class_list) TYPE tt_class_list .
    METHODS get_running_package
      RETURNING
        VALUE(rv_package) TYPE devclass .
    METHODS scan_cls_with_inject
      IMPORTING
        !iv_cls             TYPE tadir-obj_name
      RETURNING
        VALUE(rs_injection) TYPE vseoattrib .
    METHODS get_inited_instance
      IMPORTING
        !iv_cls          TYPE seoclsname
      RETURNING
        VALUE(ro_result) TYPE REF TO object .
    METHODS get_setter_method_name
      IMPORTING
        !iv_attr_name    TYPE seocmpname
      RETURNING
        VALUE(rv_setter) TYPE seocmpname .
    METHODS register_bean
      IMPORTING
        !iv_bean_name TYPE tadir-obj_name
        !io_host      TYPE REF TO object
        !io_dep       TYPE REF TO object .
ENDCLASS.



CLASS ZCL_SUMMER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SUMMER=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD class_constructor.
    so_instance = NEW zcl_summer( ).
    DATA(lv_package) = so_instance->get_running_package( ).
    DATA(lt_cls) = so_instance->get_class_list( lv_package ).

    LOOP AT lt_cls ASSIGNING FIELD-SYMBOL(<cls>).
      DATA(ls_injection) = so_instance->scan_cls_with_inject( <cls> ).
      CHECK ls_injection IS NOT INITIAL.
      DATA(lv_cls) = so_instance->get_implementation_cls_name( ls_injection-type ).
      DATA(lo_lamp) = so_instance->get_inited_instance( CONV #( lv_cls ) ).
      DATA(lo_switch) = so_instance->get_inited_instance( ls_injection-clsname ).
      DATA(lv_setter) = so_instance->get_setter_method_name( ls_injection-cmpname ).
      so_instance->register_bean( iv_bean_name = CONV #( ls_injection-clsname ) io_host = lo_switch io_dep = lo_lamp ).

      CALL METHOD lo_switch->(lv_setter)
        EXPORTING
          io_switchable = lo_lamp.
    ENDLOOP.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_BEAN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_BEAN_NAME                   TYPE        TADIR-OBJ_NAME
* | [<-()] RO_HOST                        TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_bean.
    READ TABLE mt_registered_bean ASSIGNING FIELD-SYMBOL(<bean>) WITH KEY
         host_name = iv_bean_name.
    CHECK sy-subrc = 0.

    ro_host = <bean>-host_ref.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->GET_CLASS_LIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PACKAGE                     TYPE        DEVCLASS
* | [<-()] RT_CLASS_LIST                  TYPE        TT_CLASS_LIST
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_class_list.
    SELECT obj_name INTO TABLE rt_class_list FROM tadir WHERE pgmid = 'R3TR' AND object
       = 'CLAS' AND devclass = iv_package.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->GET_IMPLEMENTATION_CLS_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TYPE                        TYPE        RS38L_TYP
* | [<-()] RV_CLS_NAME                    TYPE        TADIR-OBJ_NAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_implementation_cls_name.
* There must be multiple class implementing the given interface specified by iv_type
* for demo purpose I only use the first hit
    SELECT SINGLE clsname INTO rv_cls_name FROM vseoimplem WHERE refclsname = iv_type.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->GET_INITED_INSTANCE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLS                         TYPE        SEOCLSNAME
* | [<-()] RO_RESULT                      TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_inited_instance.

    CREATE OBJECT ro_result TYPE (iv_cls).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SUMMER=>GET_INSTANCE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_INSTANCE                    TYPE REF TO ZCL_SUMMER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_instance.
    ro_instance = so_instance.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->GET_RUNNING_PACKAGE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_PACKAGE                     TYPE        DEVCLASS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_running_package.
    SELECT SINGLE devclass FROM tadir INTO rv_package WHERE pgmid = 'R3TR' AND object = 'PROG'
      AND obj_name = sy-cprog.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->GET_SETTER_METHOD_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ATTR_NAME                   TYPE        SEOCMPNAME
* | [<-()] RV_SETTER                      TYPE        SEOCMPNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_setter_method_name.
    SPLIT iv_attr_name AT '_' INTO TABLE DATA(lt_match).
    READ TABLE lt_match ASSIGNING FIELD-SYMBOL(<match>) INDEX 2.
    ASSERT sy-subrc = 0.
    rv_setter = 'SET_' && <match>.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->REGISTER_BEAN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_BEAN_NAME                   TYPE        TADIR-OBJ_NAME
* | [--->] IO_HOST                        TYPE REF TO OBJECT
* | [--->] IO_DEP                         TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD register_bean.
    DATA(entry) = VALUE ty_registered_bean( host_name = iv_bean_name
               host_ref = io_host dependent_ref = io_dep ).
    APPEND entry TO mt_registered_bean.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_SUMMER->SCAN_CLS_WITH_INJECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLS                         TYPE        TADIR-OBJ_NAME
* | [<-()] RS_INJECTION                   TYPE        VSEOATTRIB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD scan_cls_with_inject.
    DATA: lt_vseoattrib TYPE STANDARD TABLE OF vseoattrib.

    SELECT * INTO TABLE lt_vseoattrib FROM vseoattrib WHERE clsname = iv_cls AND descript
       = cv_inject.
* For demo purpose only handle with first attribute which is annotated with @Inject
    READ TABLE lt_vseoattrib INTO rs_injection INDEX 1.

  ENDMETHOD.
ENDCLASS.