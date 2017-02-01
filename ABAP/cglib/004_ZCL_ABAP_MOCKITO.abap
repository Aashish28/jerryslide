class ZCL_ABAP_MOCKITO definition
  public
  final
  create private .

public section.

  class-methods CLASS_CONSTRUCTOR .
  methods GET_MOCKED_DATA
    importing
      !IO_CLS type ref to OBJECT
      !IV_METHOD_NAME type STRING
      !IV_ARGUMENT type STRING
    returning
      value(RV_RESULT) type STRING .
  class-methods WHEN
    importing
      !IO_DUMMY type ANY optional
    returning
      value(RO_INSTANCE) type ref to ZCL_ABAP_MOCKITO .
  methods THEN_RETURN
    importing
      !IV_RETURN type STRING .
  class-methods MOCK
    importing
      !IV_CLASS_NAME type STRING
    returning
      value(RO_INSTANCE) type ref to OBJECT .
protected section.
private section.

  types:
    begin of ty_method,
            name type string,
            argument type string,
            result type string,
      end of ty_method .
  types:
    tt_method type STANDARD TABLE OF ty_method with key name argument .
  types:
    BEGIN OF ty_mocked_data,
           cls_instance TYPE REF TO object,
           mock_methods type tt_method,
        end of tY_mocked_data .
  types:
    tt_mocked_data type STANDARD TABLE OF ty_mocked_data with key cls_instance .
  types:
    BEGIN OF ty_to_be_mocked,
     cls_instance TYPE REF TO object,
     method TYPE string,
     argument TYPE string,
     end of ty_to_be_mocked .

  class-data SO_INSTANCE type ref to ZCL_ABAP_MOCKITO .
  data MT_MOCKED_DATA type TT_MOCKED_DATA .
  data MS_METHOD_TO_BE_MOCKED type TY_TO_BE_MOCKED .
  class-data MT_SOURCE type SEOP_SOURCE_STRING .

  methods LOG_STUB
    importing
      !IO_CLS type ref to OBJECT
      !IV_METHOD_NAME type STRING
      !IV_ARGUMENT type STRING .
  class-methods FILL_SOURCE_CODE
    importing
      !IV_CLASS_NAME type STRING .
  class-methods GENERATE_STUB
    importing
      !IV_CLASS_NAME type STRING
    returning
      value(RO_STUB) type ref to OBJECT .
ENDCLASS.



CLASS ZCL_ABAP_MOCKITO IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAP_MOCKITO=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CLASS_CONSTRUCTOR.
    so_instance = new zcl_abap_mockito( ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_ABAP_MOCKITO=>FILL_SOURCE_CODE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLASS_NAME                  TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD fill_source_code.
    DATA:
      lt_public_method TYPE TABLE OF seocmpname.

    APPEND |program.class { iv_class_name }_SUB definition inheriting from { iv_class_name } |
    & | create public. public section.| TO mt_source.

    SELECT cmpname INTO TABLE lt_public_method FROM seocompo WHERE clsname = iv_class_name
     AND cmptype = 1 AND mtdtype = 0.

    LOOP AT lt_public_method ASSIGNING FIELD-SYMBOL(<method>).
      APPEND |methods { <method> } redefinition.| TO mt_source.
    ENDLOOP.

    APPEND |protected section.private section.ENDCLASS.CLASS { iv_class_name }_SUB IMPLEMENTATION.|
     TO mt_source.

    LOOP AT lt_public_method ASSIGNING FIELD-SYMBOL(<method1>).
      APPEND |method { <method1> }.| TO mt_source.

      APPEND 'BREAK-POINT.endmethod.' TO mt_source.
    ENDLOOP.
    APPEND 'ENDCLASS.' TO mt_source.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_ABAP_MOCKITO=>GENERATE_STUB
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLASS_NAME                  TYPE        STRING
* | [<-()] RO_STUB                        TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GENERATE_STUB.
    DATA(lv_new_cls_name) = iv_class_name && '_SUB'.

    TRANSLATE lv_new_cls_name TO UPPER CASE.
    TRY.
        GENERATE SUBROUTINE POOL mt_source NAME DATA(prog).
        DATA(class) = |\\PROGRAM={ prog }\\CLASS={ lv_new_cls_name }|.
        CREATE OBJECT ro_stub TYPE (class).
      CATCH cx_root INTO DATA(cx_root).
        WRITE: / cx_root->get_text( ).
    ENDTRY.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABAP_MOCKITO->GET_MOCKED_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_CLS                         TYPE REF TO OBJECT
* | [--->] IV_METHOD_NAME                 TYPE        STRING
* | [--->] IV_ARGUMENT                    TYPE        STRING
* | [<-()] RV_RESULT                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_MOCKED_DATA.
    READ TABLE MT_MOCKED_DATA ASSIGNING FIELD-SYMBOL(<mocked>) with key cls_instance = io_cls.
    IF sy-subrc = 0.
      READ TABLE <mocked>-mock_methods ASSIGNING FIELD-SYMBOL(<method>) with key name = iv_method_name
        argument = iv_argument.
      IF sy-subrc = 0.
         rv_result = <method>-result.
         RETURN.
      ENDIF.
    ENDIF.

    log_stub( io_cls = io_cls iv_method_name = iv_method_name iv_argument = iv_argument ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ABAP_MOCKITO->LOG_STUB
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_CLS                         TYPE REF TO OBJECT
* | [--->] IV_METHOD_NAME                 TYPE        STRING
* | [--->] IV_ARGUMENT                    TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method LOG_STUB.

    READ TABLE MT_MOCKED_DATA ASSIGNING FIELD-SYMBOL(<mocked>) WITH KEY
     cls_instance = io_cls.
    IF sy-subrc <> 0.
      data(ls_entry) = value ty_method( name = iv_method_name argument = iv_argument ).
      data: lt_method type tt_method.
      APPEND ls_entry to lt_method.

      data(ls_mock) = value ty_mocked_data( cls_instance = io_cls mock_methods = lt_method ).
      APPEND ls_mock to MT_MOCKED_DATA.
    ELSE.
      data(ls_entry2) = value ty_method( name = iv_method_name argument = iv_argument ).
      APPEND ls_entry2 TO <mocked>-mock_methods.
    ENDIF.

    ms_method_to_be_mocked = value #( cls_instance = io_cls method = iv_method_name argument = iv_argument ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAP_MOCKITO=>MOCK
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_CLASS_NAME                  TYPE        STRING
* | [<-()] RO_INSTANCE                    TYPE REF TO OBJECT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method MOCK.
     clear: mt_source.
     FILL_SOURCE_CODE( iv_class_name ).

     ro_instance = GENERATE_stub( iv_class_name ).
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ABAP_MOCKITO->THEN_RETURN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_RETURN                      TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method THEN_RETURN.
    READ TABLE MT_MOCKED_DATA ASSIGNING FIELD-SYMBOL(<class>) WITH KEY cls_instance = MS_METHOD_TO_BE_MOCKED-cls_instance.
    ASSERT sy-subrc = 0.

    READ TABLE <class>-mock_methods ASSIGNING FIELD-SYMBOL(<method>) with key name = MS_METHOD_TO_BE_MOCKED-method
     argument = MS_METHOD_TO_BE_MOCKED-argument.
    ASSERT SY-SUBRC = 0.

    <METHOD>-result = IV_RETURN.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAP_MOCKITO=>WHEN
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_DUMMY                       TYPE        ANY(optional)
* | [<-()] RO_INSTANCE                    TYPE REF TO ZCL_ABAP_MOCKITO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method WHEN.
    ro_instance = so_instance.
  endmethod.
ENDCLASS.