report  zbcalv_tree_01.
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
* Purpose:
* ~~~~~~~~
* This report shows the essential steps to build up a hierarchy
* using an ALV Tree Control (class CL_GUI_ALV_TREE).
* Note that it is _not_ possible to build up this hierarchy
* using a simple ALV Tree Control (class CL_GUI_ALV_TREE_SIMPLE).
*-----------------------------------------------------------------
* To check program behavior
* ~~~~~~~~~~~~~~~~~~~~~~~~~
* Start this report. The hierarchy tree consists of nodes for each
* month on top level (this level can not be build by a simple ALV Tree
* because there is no field for months in our output table SFLIGHT.
* Thus, you can not define this hierarchy by sorting).
* Nor initial calculations neither a special layout has been applied
* (the lines on the right do not show anything).
* Note also that this example does not build up and change the
* fieldcatalog of the output table. For this reason, _all_ fields
* of the output table are shown in the columns although the fields
* CARRID and FLDATE are already placed in the tree on the left.
* (Of course, this is not a good style. See BCALV_TREE_02 on how to
* hide columns).
*-------------------------------------------------------------------
* Essential steps (Search for '§')
* ~~~~~~~~~~~~~~~
* 1.Usual steps when using control technology.
*    1a. Define reference variables.
*    1b. Create ALV Tree Control and corresponding container.
*
* 2.Create Hierarchy-header
* 3.Create empty Tree Control
* 4.Create hierarchy (nodes and leaves)
*    4a. Select data
*    4b. Sort output table according to your conceived hierarchy
*    4c. Add data to tree
*
* 5.Send data to frontend.
* 6.Call dispatch to process toolbar functions
*
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

* §1a. Define reference variables
data: g_alv_tree         type ref to cl_gui_alv_tree,
      g_custom_container type ref to cl_gui_custom_container.

data: gt_sflight      type sflight occurs 0,      "Output-Table
      ok_code like sy-ucomm,
      save_ok like sy-ucomm,           "OK-Code
      g_max type i value 255.

end-of-selection.

  call screen 100.

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
*       process before output
*----------------------------------------------------------------------*
module pbo output.

  set pf-status 'MAIN100'.
  set titlebar 'MAINTITLE'.

  if g_alv_tree is initial.
    perform init_tree.

    call method cl_gui_cfw=>flush
      exceptions
        cntl_system_error = 1
        cntl_error        = 2.
    if sy-subrc ne 0.
      call function 'POPUP_TO_INFORM'
        exporting
          titel = 'Automation Queue failure'(801)
          txt1  = 'Internal error:'(802)
          txt2  = 'A method in the automation queue'(803)
          txt3  = 'caused a failure.'(804).
    endif.
  endif.

endmodule.                             " PBO  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
*       process after input
*----------------------------------------------------------------------*
module pai input.
  save_ok = ok_code.
  clear ok_code.

  case save_ok.
    when 'EXIT' or 'BACK' or 'CANC'.
      perform exit_program.

    when others.
* §6. Call dispatch to process toolbar functions
      call method cl_gui_cfw=>dispatch.

  endcase.

  call method cl_gui_cfw=>flush.
endmodule.                             " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  init_tree
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form init_tree.
* §1b. Create ALV Tree Control and corresponding Container.

* create container for alv-tree
  data: l_tree_container_name(30) type c.

  l_tree_container_name = 'CCONTAINER1'.

     create object g_custom_container
        exporting
              container_name = l_tree_container_name
        exceptions
              cntl_error                  = 1
              cntl_system_error           = 2
              create_error                = 3
              lifetime_error              = 4
              lifetime_dynpro_dynpro_link = 5.
    if sy-subrc <> 0.
      message x208(00) with 'ERROR'(100).
    endif.

* create tree control
  create object g_alv_tree
    exporting
        parent              = g_custom_container
        node_selection_mode = cl_gui_column_tree=>node_sel_mode_single
        item_selection      = 'X'
        no_html_header      = 'X'
        no_toolbar          = ''
    exceptions
        cntl_error                   = 1
        cntl_system_error            = 2
        create_error                 = 3
        lifetime_error               = 4
        illegal_node_selection_mode  = 5
        failed                       = 6
        illegal_column_name          = 7.
  if sy-subrc <> 0.
    message x208(00) with 'ERROR'.                          "#EC NOTEXT
  endif.

* §2. Create Hierarchy-header
* The simple ALV Tree uses the text of the fields which were used
* for sorting to define this header. When you use
* the 'normal' ALV Tree the hierarchy is build up freely
* by the programmer this is not possible, so he has to define it
* himself.
  data l_hierarchy_header type treev_hhdr.
  perform build_hierarchy_header changing l_hierarchy_header.

* §3. Create empty Tree Control
* IMPORTANT: Table 'gt_sflight' must be empty. Do not change this table
* (even after this method call). You can change data of your table
* by calling methods of CL_GUI_ALV_TREE.
* Furthermore, the output table 'gt_outtab' must be global and can
* only be used for one ALV Tree Control.
  call method g_alv_tree->set_table_for_first_display
    exporting
      i_structure_name    = 'SFLIGHT'
      is_hierarchy_header = l_hierarchy_header
    changing
      it_outtab           = gt_sflight. "table must be empty !

* §4. Create hierarchy (nodes and leaves)
  perform jerry_create_tree.

* §5. Send data to frontend.
  call method g_alv_tree->frontend_update.

* wait for automatic flush at end of pbo
endform.

form jerry_create_tree.
   DATA: p_relat_key type lvc_nkey,
         p_node_key type lvc_nkey,
         ls_sflight LIKE LINE OF gt_sflight.

   call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = 'Jerry'
      is_outtab_line   = ls_sflight
    importing
      e_new_node_key   = p_node_key.

   call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_node_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = 'Scala'
      is_outtab_line   = ls_sflight
    importing
      e_new_node_key   = p_node_key.


   call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_node_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = 'i042416'
      is_outtab_line   = ls_sflight
    importing
      e_new_node_key   = p_node_key.
endform.                             " init_tree
*&---------------------------------------------------------------------*
*&      Form  build_hierarchy_header
*&---------------------------------------------------------------------*
*       build hierarchy-header-information
*----------------------------------------------------------------------*
*      -->P_L_HIERARCHY_HEADER  strucxture for hierarchy-header
*----------------------------------------------------------------------*
form build_hierarchy_header changing
                               p_hierarchy_header type treev_hhdr.

  p_hierarchy_header-heading = 'Month/Carrier/Date'(300).
  p_hierarchy_header-tooltip = 'Flights in a month'(400).
  p_hierarchy_header-width = 30.
  p_hierarchy_header-width_pix = ' '.

endform.                               " build_hierarchy_header
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       free object and leave program
*----------------------------------------------------------------------*
form exit_program.

  call method g_custom_container->free.
  leave program.

endform.                               " exit_program
*&---------------------------------------------------------------------*
*&      Form  create_hierarchy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form create_hierarchy.

  data: ls_sflight type sflight,
        lt_sflight type sflight occurs 0,
        l_yyyymm(6) type c,            "year and month of sflight-fldate
        l_yyyymm_last(6) type c,
        l_carrid like sflight-carrid,
        l_carrid_last like sflight-carrid.

  data: l_month_key type lvc_nkey,
        l_carrid_key type lvc_nkey,
        l_last_key type lvc_nkey.

* §4a. Select data
  select * from sflight into table lt_sflight up to g_max rows.

* §4b. Sort output table according to your conceived hierarchy
* We sort in this order:
*    year and month (top level nodes, yyyymm of DATS)
*      carrier id (next level)
*         day of month (leaves, dd of DATS)
  sort lt_sflight by fldate+0(6) carrid fldate+6(2).
* Note: The top level nodes do not correspond to a field of the
* output table. Instead we use data of the table to invent another
* hierarchy level above the levels that can be build by sorting.

* §4c. Add data to tree

  loop at lt_sflight into ls_sflight.
* Prerequesite: The table is sorted.
* You add a node everytime the values of a sorted field changes.
* Finally, the complete line is added as a leaf below the last
* node.
    l_yyyymm = ls_sflight-fldate+0(6).
    l_carrid = ls_sflight-carrid.

* Top level nodes:
    if l_yyyymm <> l_yyyymm_last.      "on change of l_yyyymm
      l_yyyymm_last = l_yyyymm.

*Providing no key means that the node is added on top level:
      perform add_month using    l_yyyymm
                                      ''
                             changing l_month_key.
* The month changed, thus, there is no predecessor carrier
      clear l_carrid_last.
    endif.

* Carrier nodes:
* (always inserted as child of the last month
*  which is identified by 'l_month_key')
    if l_carrid <> l_carrid_last.      "on change of l_carrid
      l_carrid_last = l_carrid.
      perform add_carrid_line using    ls_sflight
                                       l_month_key
                              changing l_carrid_key.
    endif.

* Leaf:
* (always inserted as child of the last carrier
*  which is identified by 'l_carrid_key')
    perform add_complete_line using  ls_sflight
                                     l_carrid_key
                            changing l_last_key.
  endloop.

endform.                               " create_hierarchy

*&---------------------------------------------------------------------*
*&      Form  add_month
*&---------------------------------------------------------------------*
form add_month  using     p_yyyymm type c
                          p_relat_key type lvc_nkey
                changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_sflight type sflight,
        l_month(15) type c.            "output string for month

* get month name for node text
  perform get_month using p_yyyymm
                    changing l_month.
  l_node_text = l_month.

* add node:
* ALV Tree firstly inserts this node as a leaf if you do not provide
* IS_NODE_LAYOUT with field ISFOLDER set. In form 'add_carrid_line'
* the leaf gets a child and thus ALV converts it to a folder
* automatically.
*
  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_sflight
    importing
      e_new_node_key   = p_node_key.

endform.                               " add_month
*--------------------------------------------------------------------
form add_carrid_line using     ps_sflight type sflight
                               p_relat_key type lvc_nkey
                     changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value,
        ls_sflight type sflight.

* add node
* ALV Tree firstly inserts this node as a leaf if you do not provide
* IS_NODE_LAYOUT with field ISFOLDER set. In form 'add_carrid_line'
* the leaf gets a child and thus ALV converts it to a folder
* automatically.
*
  l_node_text =  ps_sflight-carrid.
  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = l_node_text
      is_outtab_line   = ls_sflight
    importing
      e_new_node_key   = p_node_key.

endform.                               " add_carrid_line
*&---------------------------------------------------------------------*
*&      Form  add_complete_line
*&---------------------------------------------------------------------*
form add_complete_line using   ps_sflight type sflight
                               p_relat_key type lvc_nkey
                     changing  p_node_key type lvc_nkey.

  data: l_node_text type lvc_value.

  write ps_sflight-fldate to l_node_text mm/dd/yyyy.

* add leaf:
* ALV Tree firstly inserts this node as a leaf if you do not provide
* IS_NODE_LAYOUT with field ISFOLDER set.
* Since these nodes will never get children they stay leaves
* (as intended).
*
  call method g_alv_tree->add_node
    exporting
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      is_outtab_line   = ps_sflight
      i_node_text      = l_node_text
    importing
      e_new_node_key   = p_node_key.

endform.                               " add_complete_line
*&---------------------------------------------------------------------*
*&      Form  GET_MONTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_YYYYMM  text
*      <--P_L_MONTH  text
*----------------------------------------------------------------------*
form get_month using    p_yyyymm
               changing p_month.
* Returns the name of month according to the digits in p_yyyymm

  data: l_monthdigits(2) type c.

  l_monthdigits = p_yyyymm+4(2).
  case l_monthdigits.
    when '01'.
      p_month = 'January'(701).
    when '02'.
      p_month = 'February'(702).
    when '03'.
      p_month = 'March'(703).
    when '04'.
      p_month = 'April'(704).
    when '05'.
      p_month = 'May'(705).
    when '06'.
      p_month = 'June'(706).
    when '07'.
      p_month = 'July'(707).
    when '08'.
      p_month = 'August'(708).
    when '09'.
      p_month = 'September'(709).
    when '10'.
      p_month = 'October'(710).
    when '11'.
      p_month = 'November'(711).
    when '12'.
      p_month = 'December'(712).
  endcase.
  concatenate p_yyyymm+0(4) '->' p_month into p_month.

endform.                               " GET_MONTH
*-----------------------------------------------------------------------