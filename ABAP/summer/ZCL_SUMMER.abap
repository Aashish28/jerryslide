class ZCL_SUMMER definition
  public
  final
  create public .

public section.

  types:
    TT_CLASS_LIST type STANDARD TABLE OF tadir-obj_name WITH KEY TABLE_LINE .

  methods GET_BEAN
    importing
      !IV_BEAN_NAME type TADIR-OBJ_NAME
    exporting
      !CO_HOST type ref to OBJECT
      !CO_DEPENDENT type ref to OBJECT .
  methods GET_IMPLEMENTATION_CLS_NAME
    importing
      !IV_TYPE type RS38L_TYP
    returning
      value(RV_CLS_NAME) type TADIR-OBJ_NAME .
  methods GET_CLASS_LIST
    importing
      !IV_PACKAGE type DEVCLASS
    returning
      value(RT_CLASS_LIST) type TT_CLASS_LIST .
  methods GET_RUNNING_PACKAGE
    returning
      value(RV_PACKAGE) type DEVCLASS .
  methods SCAN_CLS_WITH_INJECT
    importing
      !IV_CLS type TADIR-OBJ_NAME
    returning
      value(RS_INJECTION) type VSEOATTRIB .
  methods GET_INITED_INSTANCE
    importing
      !IV_CLS type SEOCLSNAME
    returning
      value(RO_RESULT) type ref to OBJECT .
  methods GET_SETTER_METHOD_NAME
    importing
      !IV_ATTR_NAME type SEOCMPNAME
    returning
      value(RV_SETTER) type SEOCMPNAME .
  methods REGISTER_BEAN
    importing
      !IV_BEAN_NAME type TADIR-OBJ_NAME
      !IO_HOST type ref to OBJECT
      !IO_DEP type ref to OBJECT .
protected section.
private section.

  types:
    BEGIN OF ty_registered_bean,
             host_name TYPE tadir-obj_name,
             host_ref TYPE REF TO object,
             dependent_ref TYPE REF TO object,
          END OF ty_registered_bean .
  types:
    tt_registered_bean TYPE STANDARD TABLE OF ty_registered_bean WITH KEY host_name .

  constants CV_INJECT type STRING value '@Inject' ##NO_TEXT.
  data MT_REGISTERED_BEAN type TT_REGISTERED_BEAN .
ENDCLASS.



CLASS ZCL_SUMMER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_BEAN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_BEAN_NAME                   TYPE        TADIR-OBJ_NAME
* | [<---] CO_HOST                        TYPE REF TO OBJECT
* | [<---] CO_DEPENDENT                   TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_BEAN.
    READ TABLE mt_registered_bean ASSIGNING FIELD-SYMBOL(<bean>) WITH KEY
         host_name = iv_bean_name.
    CHECK sy-subrc = 0.

    co_host = <bean>-host_ref.
    co_dependent = <bean>-dependent_ref.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_CLASS_LIST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PACKAGE                     TYPE        DEVCLASS
* | [<-()] RT_CLASS_LIST                  TYPE        TT_CLASS_LIST
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_CLASS_LIST.
    SELECT obj_name INTO TABLE rt_class_list FROM tadir WHERE pgmid = 'R3TR' AND object
       = 'CLAS' AND devclass = iv_package.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_IMPLEMENTATION_CLS_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_TYPE                        TYPE        RS38L_TYP
* | [<-()] RV_CLS_NAME                    TYPE        TADIR-OBJ_NAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_IMPLEMENTATION_CLS_NAME.
* There must be multiple class implementing the given interface specified by iv_type
* for demo purpose I only use the first hit
  SELECT SINGLE clsname INTO rv_cls_name FROM VSEOIMPLEM WHERE REFCLSNAME = iv_type.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_INITED_INSTANCE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLS                         TYPE        SEOCLSNAME
* | [<-()] RO_RESULT                      TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_INITED_INSTANCE.

    CREATE object ro_result TYPE (iv_Cls).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_RUNNING_PACKAGE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RV_PACKAGE                     TYPE        DEVCLASS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_RUNNING_PACKAGE.
    select single devclass FROM tadir into rv_package WHERE pgmid = 'R3TR' AND object = 'PROG'
      and obj_name = sy-CPROG.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->GET_SETTER_METHOD_NAME
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ATTR_NAME                   TYPE        SEOCMPNAME
* | [<-()] RV_SETTER                      TYPE        SEOCMPNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_SETTER_METHOD_NAME.
    split iv_attr_name AT '_' INTO Table data(lt_match).
    READ TABLE lt_match ASSIGNING FIELD-SYMBOL(<match>) INDEX 2.
    ASSERT sy-subrc = 0.
    rv_setter = 'SET_' && <match>.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->REGISTER_BEAN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_BEAN_NAME                   TYPE        TADIR-OBJ_NAME
* | [--->] IO_HOST                        TYPE REF TO OBJECT
* | [--->] IO_DEP                         TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method REGISTER_BEAN.
    data(entry) = value ty_registered_bean( host_name = iv_bean_name
               host_Ref = io_host dependent_ref = io_dep ).
    APPEND entry TO mt_registered_bean.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_SUMMER->SCAN_CLS_WITH_INJECT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLS                         TYPE        TADIR-OBJ_NAME
* | [<-()] RS_INJECTION                   TYPE        VSEOATTRIB
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SCAN_CLS_WITH_INJECT.
    DATA: lt_VSEOATTRIB TYPE STANDARD TABLE OF VSEOATTRIB.

    SELECT * INTO TABLE lt_VSEOATTRIB FROM VSEOATTRIB WHERE clsname = iv_cls AND descript
       = cv_inject.
* For demo purpose only handle with first attribute which is annotated with @Inject
    READ TABLE lt_VSEOATTRIB INTO rs_injection INDEX 1.

  endmethod.
ENDCLASS.