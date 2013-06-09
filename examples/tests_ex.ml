open Printf
open Pareto

open Common

let t_test_one_sample () =
  let open Distributions.Normal in
  let v = sample ~size:10 standard in
  let (t, pvalue) =
    Tests.T.one_sample v ~mean:0. ~alternative:Tests.TwoSided ()
  in begin
    printf "One-sample T-test for true mean = 0.0\n";
    print_float_array v;
    printf "t = %f, P-value: %f\n" t pvalue;
    print_newline ()
  end

let t_test_two_sample_independent () =
  let open Distributions.Normal in
  let v1 = sample ~size:10 standard in
  let v2 = sample ~size:10 standard in
  let (t, pvalue) = Tests.T.two_sample_independent v1 v2
      ~mean:0.1 ~equal_variance:false ~alternative:Tests.TwoSided ()
  in begin
    printf "Two-sample T-test for mean difference not equal to 0.1\n";
    print_float_array v1;
    print_float_array v2;
    printf "t = %f, P-value: %f\n" t pvalue;
    print_newline ()
  end

let t_test_two_sample_paired () =
  let open Distributions.Normal in
  let v1 = sample ~size:10 standard in
  let v2 = Array.map (fun x -> x +. generate standard) v1 in
  let (t, pvalue) = Tests.T.two_sample_paired v1 v2
      ~mean:0.1 ~alternative:Tests.TwoSided ()
  in begin
    printf "Paired two-sample T-test for mean difference not equal to 0.1\n";
    print_float_array v1;
    print_float_array v2;
    printf "t = %f, P-value: %f\n" t pvalue;
    print_newline ()
  end

let chisq_test_gof () =
  let open Distributions.Uniform in
  let v = sample ~size:10 (create ~lower:0. ~upper:1.) in
  let (chisq, pvalue) = Tests.ChiSquared.goodness_of_fit v () in
  begin
    print_endline "X^2 test for goodness of fit";
    print_float_array v;
    printf "X^2 = %f, P-value: %f\n" chisq pvalue;
    print_newline ()
  end

let chisq_test_independence () =
  let open Distributions.Uniform in
  let d  = create ~lower:0. ~upper:1. in
  let v1 = sample ~size:10 d in
  let v2 = sample ~size:10 d in
  let (chisq, pvalue) =
    Tests.ChiSquared.independence [|v1; v2|] ~correction:true ()
  in begin
    print_endline "X^2 test for independence with Yates' continuity correction\n";
    print_float_array v1;
    print_float_array v2;
    printf "X^2 = %f, P-value: %f\n" chisq pvalue;
    print_newline ()
  end

let mann_whitney_wilcoxon () =
  let v1 = [|11; 1; -1; 2; 0|] in
  let v2 = [|-5; 9; 5; 8; 4|] in
  let (u, pvalue) = Tests.MannWhitneyU.two_sample_independent v1 v2
      ~correction:true ~alternative:Tests.TwoSided ()
  in begin
    printf "Two-sample Mann-Whitney U test\n";
    print_int_array v1;
    print_int_array v2;
    printf "U = %f, P-value: %f\n" u pvalue;
    print_newline ()
  end

let wilcoxon_signed_rank_one_sample () =
  let vs = [|11.; 1.; -1.; 2.; 0.|] in
  let (w, pvalue) = Tests.WilcoxonT.one_sample vs
      ~shift:1. ~correction:true ~alternative:Tests.Greater ()
  in begin
    printf "Wilcoxon signed rank test with continuity correction\n";
    print_float_array vs;
    printf "W = %f, P-value: %f\n" w pvalue;
    print_newline ()
  end

let wilcoxon_signed_rank_paired () =
  let v1 = [|11.; 1.; -1.; 2.; 0.|] in
  let v2 = [|-5.; 9.; 5.; 8.; 4.|] in
  let (w, pvalue) = Tests.WilcoxonT.two_sample_paired v1 v2
      ~correction:true ~alternative:Tests.Less ()
  in begin
    print_endline ("Two-sample paired Wilcoxon signed rank test with " ^
                     "continuity correction");
    print_float_array v1;
    print_float_array v2;
    printf "W = %f, P-value: %f\n" w pvalue;
    print_newline ()
  end

let sign_one_sample () =
  let vs = [|11.; 1.; -1.; 2.; 0.|] in
  let (pi_plus, pvalue) = Tests.Sign.one_sample vs
      ~shift:1. ~alternative:Tests.TwoSided ()
  in begin
    printf "One-sample Sign test\n";
    print_float_array vs;
    printf "π+ = %f, P-value: %f\n" pi_plus pvalue;
    print_newline ()
  end

let sign_paired () =
  let v1 = [|11.; 1.; -1.; 2.; 0.|] in
  let v2 = [|-5.; 9.; 5.; 8.; 4.|] in
  let (pi_plus, pvalue) = Tests.Sign.two_sample_paired v1 v2
      ~alternative:Tests.TwoSided ()
  in begin
    printf "Two-sample Sign test\n";
    print_float_array v1;
    print_float_array v2;
    printf "π+ = %f, P-value: %f\n" pi_plus pvalue;
    print_newline ()
  end


let adjust_bh () =
  let open Distributions.Beta in
  let pvalues = sample ~size:10 (create ~alpha:0.5 ~beta:0.5) in
  let adjusted_pvalues =
    Tests.Multiple.(adjust pvalues BenjaminiHochberg)
  in begin
    printf "Benjamini-Hochberg P-value adjustment\n";
    print_float_array pvalues;
    print_float_array adjusted_pvalues;
    print_newline ()
  end

let adjust_hb () =
  let open Distributions.Beta in
  let pvalues = sample ~size:10 (create ~alpha:0.5 ~beta:0.5) in
  let adjusted_pvalues =
    Tests.Multiple.(adjust pvalues HolmBonferroni)
  in begin
    printf "Holm-Bonferroni P-value adjustment\n";
    print_float_array pvalues;
    print_float_array adjusted_pvalues;
    print_newline ()
  end


let () = begin
  t_test_one_sample ();
  t_test_two_sample_independent ();
  t_test_two_sample_paired ();
  chisq_test_gof ();
  chisq_test_independence ();
  mann_whitney_wilcoxon ();
  wilcoxon_signed_rank_one_sample ();
  wilcoxon_signed_rank_paired ();
  sign_one_sample ();
  sign_paired ();

  adjust_bh ();
  adjust_hb ();
end
