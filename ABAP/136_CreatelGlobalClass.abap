*&---------------------------------------------------------------------*
*& Report ZDYANMIC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDYANMIC.
 DATA ls_vseoclass      TYPE vseoclass.
  DATA ls_imp_if         TYPE seor_implementing_r.
  DATA lt_imp_if         TYPE seor_implementings_r.
  DATA ls_imp_det        TYPE seoredef.
  DATA lt_methods_source TYPE seo_method_source_table.
  DATA ls_method_source  TYPE seo_method_source.
  DATA lv_method         type LINE OF SEOO_METHODS_R.

  data: lv_classname LIKE ls_vseoclass-clsname value 'ZCLJERRY8'.

  ls_vseoclass-clsname   = lv_classname.
  ls_vseoclass-state     = seoc_state_implemented.
  ls_vseoclass-exposure  = seoc_exposure_public.
  ls_vseoclass-descript  = 'Application Exit Stub Class for Solution:'.
  ls_vseoclass-langu     = sy-langu.
  ls_vseoclass-clsccincl = abap_true.
  ls_vseoclass-unicode   = abap_true.
  ls_vseoclass-fixpt     = abap_true.
  ls_vseoclass-clsfinal  = abap_true.

  ls_imp_det = ls_imp_if-clsname       = lv_classname.
  ls_imp_det = ls_imp_if-refclsname    = 'IF_HELLOWORLD'.
  ls_imp_if-state      = seoc_state_implemented.
  APPEND ls_imp_if TO lt_imp_if.

"  LOOP AT mt_method_tab INTO lv_method.
     CLEAR: ls_method_source.
     datA: lv_name type string.
     ls_method_source-cpdname = 'IF_HELLOWORLD~PRINT'.
     "LS_METHOD_SOURCE-cpdname = 'HELLO'.                                  "#EC NOTEXT
     "APPEND '" Namespace:' && mv_namespace                                           TO ls_method_source-source.         "#EC NOTEXT
     APPEND '  DATA  lo_as_badi_extension TYPE STRING.'       TO ls_method_source-source.         "#EC NOTEXT

     APPEND ls_method_source TO lt_methods_source.
  "ot_source_code = lt_methods_source.
  "ov_class = ls_vseoclass.
  "ov_implementations = lt_imp_if.


  DATA: lv_class           TYPE vseoclass,
        lt_implementation  TYPE seop_source_string,
        ls_mtdkey          TYPE seocpdkey,
        CV_IMPLEMENTATION TYPE SEOR_IMPLEMENTINGS_R,
        ls_source_code     TYPE seo_method_source.

  lv_class = lv_classname.

  CALL FUNCTION 'SEO_CLASS_CREATE_COMPLETE'
    EXPORTING
      "corrnr                     = mv_tr
      devclass                   = '$TMP'
      version                    = seoc_version_active
      authority_check            = abap_true
      overwrite                  = abap_true
      suppress_method_generation = abap_false
      genflag                    = abap_false
      method_sources             = lt_methods_source
      suppress_dialog            = abap_true
    CHANGING
      class                      = lv_class
      implementings              = lt_imp_if
    EXCEPTIONS
      existing                   = 1
      is_interface               = 2
      db_error                   = 3
      component_error            = 4
      no_access                  = 5
      other                      = 6
      OTHERS                     = 7.

WRITE: / sy-subrc.