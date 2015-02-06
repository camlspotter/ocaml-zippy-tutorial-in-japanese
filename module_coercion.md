Module coercion �ˤĤ���
=============================

Module coercion �Ȥ����ΤϽ��Ƹ���Ȳ��Τ��Ȥ����狼��ʤ����路�⤽�����ä��Τǡ��狼�롣
�ʤΤǴ�ñ�˥����ǥ������������Ƥ�����

OCaml �Ǥ� module �Υ���ѥ���
==============================

OCaml �Ǥ� module �� tuple ��Ʊ���֥�å���¤���Ѵ�����:


    $ ocaml -dlambda
	...
	# module M = struct let x = 42 let y = "hello" end;;
    (apply (field 1 (global Toploop!)) "M/1023"
      (let (x/1021 42 y/1022 "hello") (makeblock 0 x/1021 y/1022)))
    module M : sig val x : int val y : string end


`(makeblock 0 x/1021 y/1022)` �Ȥ����Τ�������ʬ�� Tuple �Ǥ�Ʊ��:


    # (fun x y -> (x,y)) (42, "hello");;
    (after //toplevel//(1):0-32
      (apply
        (function x/1021 y/1022
          (funct-body //toplevel//(1):0-18
            (before //toplevel//(1):12-17 (makeblock 0 x/1021 y/1022))))
        [0: 42 "hello"]))
    - : '_a -> (int * string) * '_a = <fun>


`(x,y)` ����ʬ�� `(makeblock 0 x/1021 y/1022)` �ˤʤäƤ��롣

�ʤΤ� `sig val x : int val y : string end` �Υ⥸�塼��� `int * string` ��
Ʊ���֥�å���¤�򤷤Ƥ��롣

�ޤ�������ס�

ML �Υ⥸�塼��η��դ��� tuple �������
======================================

`(int * string)` �Ȥ������� tuple �����ä��Ȥ��ơ������ `(string * int)` �Ȥ���
���˻Ȥ��뤫�Ȥ����Ȥ����󤽤�ʤ��ȤϤǤ��ʤ���


    # (Obj.magic (42, "hello") : (string * int));;
    Segmentation fault (core dumped)


����ML �Υ⥸�塼��ϡ� `sig val x : int val y : string end` �Ȥ����������
�⥸�塼��� `sig val y : string val x : int end` �Ȥ������ˤ��Ƥ��ɤ���


    # module M = struct let x = 42 let y = "hello" end;;
    module M : sig val x : int val y : string end
    # module N = (M : sig val y : string val x : int end);;
    module N : sig val y : string val x : int end


���졩 Tuple �Ǥϥ���å��夹��Τˤʤ� module �Ǥϥ���å��夷�ʤ���
`sig val x : int val y : string end` �η�����ĥ⥸�塼��� `(int * string)` 
��Ʊ����¤�򤷤Ƥ���Ϥ��� `sig val y : string val x : int end` �η��ˤ����
`(string * int)` ��Ʊ���Ϥ����ɤ����ƾ�꤯�Ԥ���

Module coercion
======================================

�⤷����ѥ��餬�����äˤ��Ƥ��ʤ��ä��Ȥ���С� tuple �����Ʊ���ǥ���å��夹��Ϥ�����
����å��夷�ʤ��Ȥ������Ȥϲ������̤ʤ��Ȥ򤷤Ƥ��뤫�顣


    $ ocaml -dlambda
	...
    # module M = struct let x = 42 let y = "hello" end;;
    (apply (field 1 (global Toploop!)) "M/1020"
      (let (x/1018 42 y/1019 "hello") (makeblock 0 x/1018 y/1019)))
    module M : sig val x : int val y : string end
	
    # module N = (M : sig val y : string val x : int end);;
    (let (M/1020 (apply (field 0 (global Toploop!)) "M/1020"))
      (apply (field 1 (global Toploop!)) "N/1023"
        (makeblock 0 (field 1 M/1020) (field 0 M/1020))))
    module N : sig val y : string val x : int end


ñ�� `N` �� `M` ��Ʊ���ͤǤϤʤ��Ѵ������äƤ��롣
`(makeblock 0 (field 1 M/1020) (field 0 M/1020))` ����ʬ��
`M` �� 1���ܤ� 0���ܤˡ�0���ܤ� 1���ܤ��֤����֥�å����äƤ��롣

���줬 OCaml �� Typedtree �˽ФƤ��� module_coercion������ sig ����ĥ⥸�塼����ͤ�
����˸ߴ����Τ��뤫��������Ū�� sig �ؤȷ����Ѥ�����ˡ���Ԥ� sig �Υ쥤�����Ȥؤ�
�⥸�塼��֥�å������Ǥ�����֤����뤿��ξ���Ǥ���

����Ū�� module coercion �Ͽ� sig ����˵� sig ���ǤΤɤΰ��֤Υ�Τ���˽ФƤ��뤫
�ʤΤ� int list �ι�¤�ˤʤ뤬���ФƤ����оݤ� module ���ä���硢���� module ���Ф���
module coercion ��ɬ�פˤʤ롣�ޤ� primitive ���Ф��Ƥϡ�˺�줿���������ɤ�䡣


