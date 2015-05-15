Add LoadPath "../theories" as My_module.
Add ML Path "../src".
Require Import NoAxiom.

Axiom my_axiom : forall (A : Type) (P : A -> Prop) (a : A), P a.



Theorem my_theorem1 : forall n :nat, n = n. reflexivity. Qed.

Theorem my_theorem2 : forall n, n >= 0.
  apply my_axiom.
Qed.

Theorem my_test1 : NoAxiom my_axiom my_theorem1. check_no_axiom. Qed.


Theorem my_test : NoAxiom my_axiom my_theorem2.
  check_no_axiom.

