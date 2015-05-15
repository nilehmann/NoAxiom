DECLARE PLUGIN "no_axiom_plugin"
let contrib_name = "no_axiom_plugin"

let path = ["NoAxiom";"NoAxiom"] 

open Assumptions
open Pp
open Names
open Printer

open Tacexpr

let dup f s1 s2 =
  fun g ->
    f s1 
      (fun a ->
        f s2
         (fun b ->
            g a b))

let has_axiom env sigma ax constr = 
  let st = Conv_oracle.get_transp_state (Environ.oracle (Global.env())) in
  let assums = Assumptions.assumptions st constr in
  let fold assum typ accu =
    match assum with
    | Axiom kn -> 
       let (_, is_same) = Reductionops.infer_conv env sigma typ ax in
       accu || is_same
    | _ -> accu || false
  in
  ContextObjectMap.fold fold assums false

let tac () = 
  let noAxiom = Coqlib.find_reference contrib_name path "NoAxiom" in
  let mkNoAxiom = Coqlib.find_reference contrib_name path "mkNoAxiom" in
  dup Tacticals.New.pf_constr_of_global noAxiom mkNoAxiom
  (fun noAxiom mkNoAxiom -> 
    Proofview.Goal.nf_enter
    (fun goal ->
      let concl = Proofview.Goal.concl goal in
      let env = Proofview.Goal.env goal in
      let sigma = Proofview.Goal.sigma goal in
      match Term.kind_of_term concl with
      | Term.App(head, args) 
      when Term.eq_constr head noAxiom && Array.length args = 4 ->
        let typ = Tacmach.New.pf_type_of goal args.(1) in
        if has_axiom env sigma typ args.(3) then
          Tacticals.New.tclZEROMSG (
            Pp.str "The term \"" ++ Printer.pr_constr args.(3) ++ 
            Pp.str "\" use \"" ++ Printer.pr_constr args.(1) ++ 
            Pp.str "\" as an assumption.")
        else
          Tactics.exact_check
          (Term.mkApp (mkNoAxiom, [|args.(0);args.(1);args.(2);args.(3)|]))
      | _ -> 
      Tacticals.New.tclFAIL 1 (Pp.str "Cannot unify with NoAxiom"))) ;; 

TACTIC EXTEND my_fisrt_tac
| ["check_no_axiom"] -> [tac () ]
END
