///|
// The specification registry (規範形式與範疇化登記).
//
// Every type, operator, structure and specification in this project is
// registered here with three pieces of data:
//   canonical   — its normal / canonical form (規範形式): the chosen
//                 representative by which equality is decided;
//   categorical — its categorification (範疇化): the categorical structure
//                 it is an object / morphism / functor / law of;
//   decision    — how its governing equalities & predicates are decided.
// SPEC.md contains the same registry in document form, with an appendix
// listing every public symbol in the generated interface, grouped under
// these entries; tools/audit_spec.py checks the appendix is exhaustive.

///|
pub enum SpecKind {
  SpecType
  SpecOperator
  SpecStructure
  SpecTheorem
} derive(Debug, Eq)

///|
pub extend SpecKind with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SpecKind with Eq::{not_equal, equal}

///|
pub struct SpecEntry {
  name : String
  kind : SpecKind
  symbols : Array[String]
  canonical : String
  categorical : String
  decision : String
}

///|
fn entry(
  name : String,
  kind : SpecKind,
  symbols : Array[String],
  canonical : String,
  categorical : String,
  decision : String,
) -> SpecEntry {
  SpecEntry::{ name, kind, symbols, canonical, categorical, decision, }
}

///|
pub fn spec_registry() -> Array[SpecEntry] {
  [
    entry(
      "複數標量",
      SpecType,
      ["Complex", "cx", "cx_add", "cx_mul", "cx_conj", "cx_approx_eq"],
      "(re, im) 有序對；相等以 eps 容差判定",
      "交換環 C 的元素；共軛是對合 (involution)",
      "分量比較",
    ),
    entry(
      "複向量與內積",
      SpecStructure,
      ["CVec", "vec_add", "vec_scale", "inner", "vec_orthogonal"],
      "分量表列；相等以 eps 逐分量判定",
      "有限維 Hilbert 空間 Hilb 的物件；內積給出對偶 v ↦ ⟨v, −⟩",
      "分量計算",
    ),
    entry(
      "複方陣與伴隨",
      SpecStructure,
      ["CMat", "mat_mul", "mat_adjoint", "mat_identity", "mat_vec", "outer2"],
      "列 (rows) 的表列",
      "Hilb 中的態射；伴隨 † 是 dagger 函子（反變、對合）",
      "矩陣運算",
    ),
    entry(
      "Hermitian／冪等／投影謂詞",
      SpecOperator,
      ["is_hermitian", "is_idempotent", "is_projector", "mat_commutes"],
      "P†=P 與 P²=P 兩方程的合取；規範形為 Σ vₖvₖ† (ONB 外積和)",
      "dagger 範疇中自伴冪等態射；其分裂即 Karoubi 包絡的物件",
      "eps 容差下矩陣方程",
    ),
    entry(
      "特徵空間分解",
      SpecTheorem,
      [
        "outer", "projector_from_orthonormal", "complement", "decompose", "in_image",
        "in_kernel", "eigenspace_well_formed", "prune_to_eigenspace", "pruning_is_retraction",
      ],
      "v 分解為 (Pv, (I−P)v) 的有序正交對",
      "冪等態射在 Hilb 中分裂：im(P) 是 retract，Cⁿ ≅ im(P) ⊕ ker(P) 是雙積 (biproduct)",
      "特徵值方程＋正交性＋tr(P) 整數性",
    ),
    entry(
      "可交換投影格",
      SpecTheorem,
      ["commuting_product", "commuting_projectors_compatible"],
      "交換族的乘積 PQ（交特徵空間的投影）",
      "投影偏序集 (P ≤ Q ⇔ QP=P) 中交換者的下確界 (meet)",
      "PQ=QP 方程",
    ),
    entry(
      "Karoubi 包絡",
      SpecStructure,
      ["karoubi_morphism", "karoubi_wrap", "karoubi_id", "karoubi_comp"],
      "物件：Hermitian 冪等 P；態射：被 (Q,P) 夾緊的矩陣 QAP=A",
      "冪等分裂完備化；恒等態射是 P 本身；† 給出 dagger 結構",
      "QAP=A 方程＋合成律抽樣驗證",
    ),
    entry(
      "Cubical 區間",
      SpecType,
      ["Dim", "eval_dim", "eval_dim_bool", "interval_laws_hold"],
      "De Morgan 代數表達式；端點語義化為布林公式",
      "區間物件 I 是 De Morgan 代數（有界分配格＋對合 ¬）",
      "端點求值＋dim_simplify 重寫",
    ),
    entry(
      "面公式（餘纖維）",
      SpecType,
      [
        "Face", "face_holds", "face_var0", "face_var1", "face_sat", "face_le", "face_eq_mod",
      ],
      "ROBDD（見下）",
      "餘纖維在面格中：子物件分類子的 cofibration 部分",
      "BDD 符號判定",
    ),
    entry(
      "面公式的 ROBDD 規範形式",
      SpecStructure,
      [
        "Bdd", "bdd_of_face", "bdd_not", "bdd_and", "bdd_or", "bdd_sat_face", "bdd_face_le",
        "bdd_face_eq", "face_witness", "dim_simplify", "face_simplify", "face_vars",
      ],
      "變量遞增序、等子節點消去的約化有序 BDD；結構相等即商相等",
      "自由有界分配格在生成元 Dim 變量上的規範代表；∧/∨ 即 BDD apply",
      "Shannon 展開＋常數簡化剪枝",
    ),
    entry(
      "面偏序範疇",
      SpecStructure,
      [
        "face_meet_universal", "face_join_universal", "check_face_poset_category",
      ],
      "物件為 BDD 等價類",
      "偏序範疇：∧=積，∨=餘積，⊤ 終物件，⊥ 始物件；態射存在性即 ≤",
      "bdd_face_le",
    ),
    entry(
      "系統（偏元素）與剪枝",
      SpecStructure,
      [
        "VecBranch", "VecSystem", "system_lookup", "system_compatible", "prune_system",
        "system_union", "union_commutes_mod", "system_extend_top",
      ],
      "符號規範形：以有效區域 BDD 分割端點立方體的值類別（system_normal_form）",
      "面上 presheaf 的偏元素；聯集是餘積式拼接，商由區域分割給出",
      "BDD 區域代數",
    ),
    entry(
      "系統符號規範形",
      SpecOperator,
      [
        "SymRegion", "SystemNF", "system_normal_form", "system_eq_mod_sym", "system_domain_bdd",
      ],
      "不交 BDD 區域＋值標籤，按值字典序排列，另加未定義區域",
      "偏元素到面格切片範疇中的像分解 (image factorisation)",
      "有效區域 φᵢ ∧ ¬(前覆蓋) 以 bdd_and/bdd_not/bdd_or 計算",
    ),
    entry(
      "立方體與路徑",
      SpecType,
      [
        "Cube", "cube_const", "path_line", "path_refl", "path_sym", "restrict_face",
        "degenerate_cube", "cube_ext_eq", "face_maps_commute",
      ],
      "函數 Iⁿ→Cᵐ 本身（語義立方體）；路徑範形為直線 path_line",
      "立方體範疇 □ 上的 cubical set 在 Cᵐ 中的實現；面/退化生成 □ 的態射",
      "樣本網格外延相等",
    ),
    entry(
      "Kan 填充與 comp（向量／特徵空間）",
      SpecOperator,
      [
        "open_box_wf", "square_fill", "kan_comp_path", "path_trans", "prune_cube",
        "kan_fill_eigenspace", "kan_comp_eigenspace", "eigenspace_kan_sound", "pruning_repairs_filler",
      ],
      "F(i,j)=b(i)+(1−i)(l(j)−b(0))+i(r(j)−b(1))，特徵空間版繼以 P 剪枝",
      "retract 的 Kan 纖維化結構：填充提升性質在 retraction 下封閉；comp 是帽子面",
      "邊界方程於樣本網格驗證",
    ),
    entry(
      "項語法與未型別 NbE",
      SpecStructure,
      [
        "Term", "Neutral", "Value", "eval", "quote", "nf", "def_eq", "nbe_single_valued",
        "coe_rules_definitional",
      ],
      "βπ-正規形（quote∘eval）",
      "λ× 句法範疇到指稱語義函子的單位/餘單位式分解；正規形是商的代表",
      "正規形結構相等",
    ),
    entry(
      "HOAS語法",
      SpecType,
      ["HTm", "happ", "term_to_hoas", "hoas_to_term", "hoas_roundtrip_term"],
      "reify 到 de Bruijn 正規形",
      "高階抽象語法作為函子範疇中的綁定；與一階語法互逆（模定義相等）即範疇等價",
      "reify/reflect 往返與 nf 比較",
    ),
    entry(
      "型別導向 NbE 與 η",
      SpecStructure,
      [
        "LTy", "TValue", "TNeutral", "ty_check", "ty_infer", "eval_check_t", "eval_infer_t",
        "quote_eta", "nf_eta", "def_eq_eta", "eta_single_valued_on",
      ],
      "η-長 βπ-正規形：函數 η 展開 λx.f x，積 η 展開 (fst p,snd p)，單位塌陷 ()",
      "自由笛卡兒閉範疇 (自由 CCC) 中態射的規範代表；quote 是按型別的反思 (reflection)",
      "雙向型別檢查＋按型別 quote＋結構比較",
    ),
    entry(
      "句法笛卡兒閉範疇",
      SpecStructure,
      [
        "tm_shift", "tm_comp_closed", "tm_comp_at", "tm_id_at", "check_syntactic_category",
      ],
      "箭頭：帶註記閉項，範形為其 nf_eta",
      "物件 LTy，態射為項模 βπη；積與指數由 λ/配對給出萬有性",
      "def_eq_eta 判定結合律／恒等律／逆律",
    ),
    entry(
      "Finite universe 型別與值",
      SpecType,
      ["Ty", "PVal", "elems_of", "in_ty", "leaves_of_ty", "flatten_pval"],
      "型別樹的葉序 (leaf sequence)；值樹展平為葉值列",
      "有限集合範疇中的物件，由 Bool/Unit 以積生成",
      "樹遞迴",
    ),
    entry(
      "Wiring 符號等價",
      SpecStructure,
      [
        "LeafKind", "LeafMap", "Wiring", "wiring_id", "wiring_not", "wiring_swap",
        "wiring_prod", "wiring_comp", "wiring_inv", "wiring_assoc", "wiring_left_unitor",
        "wiring_right_unitor", "wiring_wf", "wiring_eq", "wiring_apply",
      ],
      "帶號置換：每輸出葉的 (源索引, 否定旗)；Unit 輸出規範為 (−1,false)",
      "自由對稱冪冪範疇在 Bool(帶對合)/Unit 生成元上的態射；⊗ 與換位子 (braiding)",
      "置換性判定 O(#葉)；合成＝替換＋XOR；相等＝結構相等",
    ),
    entry(
      "同構／等價／ua／coe",
      SpecStructure,
      [
        "Iso", "Equiv", "UPath", "iso_of_wiring", "equiv_of_wiring", "iso_to_equiv",
        "equiv_prod", "equiv_comp", "equiv_inv", "equiv_wf", "equiv_ext_eq", "ua",
        "iso_to_path", "coe_upath", "coe_computes", "upath_eq", "swap_naturality",
      ],
      "wiring 規範形；coe 按端點分情況計算為 equivFun/equivInv/id",
      "ua 是 (A≃B)≃(A=B) 在此有限宇宙的迭代；swap 自然性方塊是交換圖",
      "wiring_eq 與 w;w⁻¹=id 的 wiring 等式",
    ),
    entry(
      "PathP 與離散路徑、J",
      SpecStructure,
      [
        "PathPVal", "pathp_canonical", "pathp_wf", "pathp_prod", "pathp_fst", "pathp_snd",
        "pathp_prod_exchange_roundtrip", "DiscPath", "refl_path", "disc_path_sym",
        "Family", "j_elim_disc", "j_roundtrip",
      ],
      "PathP 規範元：遠端 = coe 之像；離散路徑規範形為常值",
      "路徑物件與依賴路徑 (PathP)；J 是常值線上 coe 的恒等性陳述",
      "端點型別＋點值檢驗",
    ),
    entry(
      "有限 Glue（形成／可靠）",
      SpecStructure,
      [
        "GlueData", "GlueElem", "glue_wf", "make_glue", "unglue", "glue_restrict",
        "glue_from_base", "glue_sound",
      ],
      "(partial, base) 對；由 base 造的規範元 glue_from_base",
      "Glue 是沿等價把偏型別 T 黏到 A 的 (餘)極限式構造；unglue 是投影到 A 的纖維化",
      "φ 的 BDD 可滿足性＋相容方程",
    ),
    entry(
      "一般 Glue comp（有限線）",
      SpecOperator,
      [
        "GlueLineFinite", "glue_data_at0", "glue_data_at1", "glue_line_coherent",
        "glue_comp_finite", "glue_comp_finite_correct",
      ],
      "輸出 base 是校正後的 e₁(t₁)（當 φ₁ 成立）",
      "等價線 = 箭頭範疇 (arrow category) 中的態射；comp 是箭頭範疇中沿線的合成",
      "自然性方塊以 wiring_eq 判定；拒絕不相干線數據",
    ),
    entry(
      "特徵子空間線上的 Glue comp",
      SpecOperator,
      [
        "SubLine", "LinEquivLine", "GlueLineVec", "VecBox", "GlueCompVecResult",
        "prune_cube_subline", "fill_subline", "glue_box_compatible", "glue_comp_vec",
        "glue_comp_vec_sound",
      ],
      "校正方塊 (i,k)↦(1−k)·a_cap(i)+k·U(1)(t_cap(i)) 的 k=1 邊",
      "retract 線族上的 Kan 填充；校正即 A(1) 中的 hcomp 提升",
      "邊界/帽子/落點方程於網格驗證",
    ),
    entry(
      "依賴型別 NbE（Π/Σ/宇宙）",
      SpecStructure,
      [
        "DTerm", "DValue", "DNeutral", "DInfer", "d_infer", "d_check", "d_as_type",
        "conv_at", "conv_ty", "quote_at", "quote_ty", "dep_check_closed", "dep_nf_closed",
        "dep_type_of_closed", "lty_to_dterm", "check_dep_all",
      ],
      "按型別 quote 的 η 長依賴正規形；Π/Σ 的第二分量是語義閉包族，宇宙為累積層級 Typeᵢ:Typeᵢ₊₁",
      "帶族範疇 (categories with families) 的句法模型：脈絡延伸、依賴代入是閉包施用；單純片斷嵌入為非依賴 Π/Σ",
      "雙向 elaboration ＋ 型別導向 conversion；相等為範形結構相等",
    ),
    entry(
      "依賴 Kan 線 coe/comp",
      SpecStructure,
      [
        "DLine", "dline_at", "dcoe", "dfill", "dcomp", "dline_const", "dline_pi",
        "dline_sigma", "dline_univ", "dline_of_lty", "dline_of_ty", "dline_of_upath",
        "check_kan_all_types",
      ],
      "DLine{at, coe_fn, fill_fn}；Π 的 coe 在定義域反向、Σ 的第二分量沿第一分量路徑傳輸；comp=fill(1)",
      "型別即 Kan 纖維化結構；依賴族呈現為 (A 中的路徑)→DLine；連同特徵子空間與 Glue 覆蓋全專案型別族",
      "對型別構造子遞迴求值；coe(r,r) 由 wrapper 定義地恆等",
    ),
    entry(
      "精確符號代數",
      SpecStructure,
      [
        "Rat", "Poly", "PolyTerm", "SymFrac", "SymC", "SymMat", "UPoly", "poly_add",
        "poly_mul", "frac_eq", "sym_det", "charpoly_sym", "sym_projector_rank_one",
      ],
      "Q 上多變量多項式規範形（合併、去零、字典序）；分式以交叉相乘判定相等；複量為實符號有序對",
      "多項式戒與其分式體提供矩陣的代數語義；特徵多項式是 det(XI−A) 的精確展開",
      "多項式恆等（無 eps、無抽樣）",
    ),
    entry(
      "譜投影與仿射唯一填充的符號恆等",
      SpecTheorem,
      [
        "RPoly", "RPolyDiv", "spectral_q", "spectral_minpoly", "spectral_denominator",
        "spectral_projector_sym", "rpoly_divisible_by", "sym_square_fill", "sym_bilinear_from_corners",
        "sym_bilinear_ansatz", "check_symbolic_algebra_all",
      ],
      "譜投影 Pₖ=qₖ(A)/qₖ(λₖ)；仿射填充是四角的雙線性插值，繫數由角值唯一解出",
      "譜分解給出單位分解 ΣPₖ=I 與 ΣλₖPₖ=A；雙線性插值是張量積意義下兩個仿射方向的唯一黏合",
      "首一多項式整除（模最小多項式）及在座標原子 i,j 上的多項式恆等",
    ),
    entry(
      "立方 AST、PathP 與維度 NbE",
      SpecStructure,
      [
        "DTubeTerm", "d_tube", "DPathParts", "DGlueParts", "deval_dim", "eval_dim_expr",
        "dim_quote", "face_eval_env", "face_quote", "dapp_dim", "eval_tube_terms",
        "quote_tube_branches", "dep_def_eq_closed", "check_ast_paths",
      ],
      "同一 DTerm 以分離的項/維度 de Bruijn 索引表示型別線、tube 系統與路徑；範形由帶維度層級的 quote 給出，HIT 點在端點正規化",
      "帶區間脈絡的 cubical CwF 句法模型：PathP 是沿 I 的依賴路徑物件，維度代換即 denv 求值；Glue 值以 (單分支 raw 或多分支 DVPartial partial, base) 對表示",
      "雙向 elaboration；Dim/Face 以 dim_simplify、face_simplify 與 ROBDD 語義謂詞判定",
    ),
    entry(
      "AST Kan 運算 comp/hcomp/hfill/coe",
      SpecOperator,
      [
        "comp_value", "hcomp_value", "fill_value", "hfill_value", "coe_value", "comp_pi_value",
        "comp_sigma_value", "comp_path_value", "comp_glue_value", "comp_univ_value",
        "hcomp_univ_value", "check_ast_kan_terms", "check_ast_kan_types", "check_ast_kan_all",
      ],
      "在一般維度取樣型別線後按頭構造子派遣：Π 沿反向定義域填充、Σ 沿第一分量填充、PathP 加端點分支、Universe 產生保留完整 DSystem 的 Glue；coe/fill 由 comp 的線段限制得到",
      "每個型別構造子保存 Kan 纖維化結構；系統分支是餘纖維上的偏路徑，形式 DNComp/DNHComp 是未化簡合成的中性見證",
      "系統以 base 相容與分支重疊相容檢查；頂面分支取帽、底面分支消去；其餘由型別遞迴或形式中性項判定",
    ),
    entry(
      "資料型別與高階歸納型別消去",
      SpecStructure,
      [
        "d_nat_lit", "dv_nat_lit", "eval_bool_elim", "eval_nat_elim", "eval_list_elim",
        "circle_point", "torus_point", "eval_circle_elim", "eval_torus_elim", "comp_bool_value",
        "comp_nat_value", "comp_list_value", "comp_circle_value", "comp_torus_value",
        "check_ast_data", "check_ast_hits",
      ],
      "Nat/List 以建構子遞迴；Circle 點為 loop@r（端點為 base），Torus 點為 square@(i,j) 且對邊等同；非平凡 HIT 系統保留形式 hcomp 點",
      "Nat/List 是依賴消去的初始代數；Circle/Torus 是帶路徑/方塊生成元的 HIT，消去子是 motive 的截面並與形式 composition 交換",
      "構造子模式遞迴、HIT 點座標的 Dim 語義相等，以及在 motive 中 composition 的消去交換律",
    ),
    entry(
      "持久環境、惰性與語義快取",
      SpecStructure,
      [
        "DEnv", "DDimEnv", "DThunk", "denv_cons", "ddim_cons", "denv_extend", "lazy_value",
        "force_value", "lazy_deval", "memo_dim_line", "memo_family", "check_persistent_env_lazy_cache",
      ],
      "帶長度的持久連結串列：cons 以 O(1) 共享尾部，陣列版環境只在公開邊界轉換一次；DVThunk 強制後保存值且最多計算一次；維度線以簡化 Dim 鍵、型別族以引文項鍵 memoize",
      "CwF 的脈絡延伸與弱化由共享環境尾部實現；惰性語義值是 call-by-need 值，快取是外延函數圖的有限延伸而不改變其指稱",
      "de Bruijn 索引查找、force_count 觀察與穩定 Debug 快取鍵相等",
    ),
    entry(
      "依賴語義系統與 partial 值",
      SpecStructure,
      [
        "DTubeBranch", "tube_branch", "DSystem", "dsystem_of", "dsystem_canonical",
        "DFaceTerm", "DPartialValue", "partial_normal_form", "DSystemNF", "partial_eq_at",
        "glue_partial_values", "glue_store_partial", "check_phase5_semantic_systems",
      ],
      "DSystem 先去底面並簡化面；沿型別線的規範形把可轉換 body 以面聯集合併並按引文排序。partial 值的範形是 BDD 有效區域值類別加未定義區域；DVGlue 保存全部 partial type 分支",
      "面格切片中的偏元素：系統是餘纖維上的偏路徑/偏元素，多分支 Glue 是 partial type 系統與 base type 的配對極限表示",
      "有效區域以 BDD and/not/or 計算；分支合併與排序以型別導向轉換及引文鍵判定",
    ),
    entry(
      "通用歸納族 schema",
      SpecStructure,
      [
        "DArgKind", "DTelescopeEntry", "DConstructorArg", "DConstructorSpec", "DInductiveSpec",
        "dinductive_spec", "inductive_schema_validate", "inductive_case_type", "eval_inductive_elim",
        "infer_inductive_elim", "comp_inductive_value", "nat_schema", "vec_schema",
        "w_schema", "check_generated_inductive_schemas",
      ],
      "有限描述子：參數/索引 telescopes、外部/直接遞迴/函數遞迴引數與結果索引；值範形為引文的 DIntro， 中性消去按生成 motive/case 型別引文",
      "嚴格正性依賴多項式函子的初始代數；依賴消去是 motive 的截面，Kan comp 沿先前引數 filler 逐引數遞迴，函數遞迴引數以 Π comp 處理",
      "描述子結構相等；telescope 與引數/索引由雙向檢查驗證；外部型別與函數定義域以同名族掃描拒絕非嚴格正性出現",
    ),
    entry(
      "通用 HIT schema",
      SpecStructure,
      [
        "DHitFaceExpr", "DHitCellSpec", "DHitSpec", "dhit_spec", "hit_schema_validate",
        "hit_cell_value", "hit_case_type", "eval_hit_elim", "infer_hit_elim", "comp_hit_value",
        "circle_schema", "segment_schema", "torus_schema", "check_generated_hit_schemas",
      ],
      "0/1/2 維 cells：DVHitCell 的維度先簡化，任一端點即代入對應 face expression 遞迴化簡；消去 case 型別為逐維巢狀 PathP，端點是較低維 face 的消去值",
      "帶 face 映射的胞腔高階初始代數；依賴消去把 point/path/square cells 送到 motive 的截面與其路徑/方塊，comp 只在同 cell 同維度時逐引數計算，其餘保留形式合成",
      "face 的目標 cell、引數型別與結果索引由檢查器驗證；2-cell 以兩種維度化簡次序在四角轉換相等驗證相容性",
    ),
    entry(
      "Schema 擴展：函子正性、互歸納、商與宇宙多態",
      SpecStructure,
      [
        "DPositiveFunctor", "DConstructorConstraint", "DMutualFamily", "DLevelExpr",
        "dpositivity_report", "positive_functor_map", "compile_mutual_inductive",
        "instantiate_inductive_level_scheme", "quotient_schema", "decode_term", "check_schema_extensions",
      ],
      "遞迴引數以完整型別或 DPositiveFunctor 解碼，IH 依函子結構生成；互歸納編譯為 Sum-indexed 單一 schema；商是帶等式 cell 的 HIT，任意有限維 cells 逐維以 face expression 化簡",
      "正性函子與互歸納族的初始代數、Tarski 解碼的歸納—遞迴對，以及宇宙層級指派下的 schema 族",
      "別名展開後以極性遞迴判定嚴格正性；構造子 Path 約束、層級 scheme 求值與多維 face 相干性均由檢查器驗證",
    ),
    entry(
      "原始 DSystem 相容性與 first-match 範形",
      SpecStructure,
      [
        "DSystemCompatibility", "DTubeNF", "conv_at_under_face", "dsystem_checked",
        "dsystem_compatibility_report", "dsystem_first_match_normal_form", "check_dsystem_compatibility",
        "check_dsystem_first_match_nf",
      ],
      "相容原始系統經 checked 入口化為通常的型別導向 DSystem 範形；任意 first-match 系統化為互不交疊的有效區域與值路徑類別",
      "面切片中的原始偏元素到 composition 偏元素的相容性反射；first-match 是優先序區域分解",
      "將面轉成 BDD cubes 並在局部維度脈絡下逐 cube 轉換比較 base 與兩兩分支，首個衝突精確回報",
    ),
    entry(
      "AST 一等 Equiv、ua 與 GlueEquiv",
      SpecStructure,
      [
        "DEquivParts", "DGlueEquivParts", "as_equiv_type", "mk_equiv_term", "infer_ua",
        "comp_equiv_value", "comp_glue_equiv_value", "check_equiv_ast",
      ],
      "Equiv 值由正向函數、反向函數與 section/retraction Path 證明組成；GlueEquiv 分支保存完整 partial type 與其指向 base 的一等等價",
      "AST 內帶同倫逆的等價範疇；ua 把等價送入宇宙路徑，GlueEquiv 是沿偏等價系統黏合的型別",
      "雙向檢查 Equiv 四分量，conversion/quote 遞迴至各分量；沿 ua 的 coe 直接計算為 fwd 或 bwd",
    ),
    entry(
      "受檢查型別線與 schema 註冊快取",
      SpecStructure,
      [
        "DCheckedTypeLine", "DSchemaRegistry", "DInductivePlan", "checked_type_line",
        "checked_comp_value", "schema_registry_register_inductive", "schema_registry_validate_hit",
        "default_schema_registry", "check_phase6_infrastructure",
      ],
      "受檢查線保存已驗證的開放型別 body 與環境而不保存任意宿主函數；schema 以穩定鍵 intern 為 plan，telescope 保存完整前綴鏈",
      "由句法 body 表示的型別線與維度代換自然交換；註冊表是 schema elaboration 函數的有限共享圖",
      "在新鮮維度下檢查線 body 的宇宙層級；registry 以鍵命中驗證及語義 telescope，計數器使重用可觀察",
    ),
    entry(
      "精確單變量多項式與有理矩陣",
      SpecStructure,
      [
        "QPoly", "QMat", "QRref", "qpoly_normalize", "qpoly_gcd", "qpoly_extgcd",
        "qpoly_factor_rational_roots", "qmat_charpoly", "qmat_minimal_polynomial",
        "qmat_inverse",
      ],
      "QPoly 為去除尾零的升冪有理係數列，QMat 為有理列之列，線性子空間以 RREF 自由變量基底表示",
      "歐氏環 Q[x] 與有限維有理線性範疇；矩陣多項式求值給出 Q[x] 模結構",
      "primitive pseudo-remainder gcd/extgcd、Yun squarefree 分解、有理根枚舉、Faddeev–LeVerrier 與精確 RREF",
    ),
    entry(
      "代數擴張、廣義特徵空間與 Jordan 理論",
      SpecStructure,
      [
        "QuadNum", "AlgNum", "AlgMat", "QGeneralizedEigenspace", "QJordanDecomposition",
        "quad_denested_sqrt", "alg_rebase_to_minimal", "qmat_generalized_projector",
        "qmat_Jordan_decomposition", "algmat_Jordan_decomposition", "check_algebraic_extensions_and_Jordan",
      ],
      "QuadNum 為 a+b√d 的無平方因數範式，AlgNum 為模極小多項式的餘式；Jordan 分解由廣義核鏈的塊大小與鏈基底給出",
      "有限代數擴張體上的線性代數；主分解來自互質多項式因子的單位分解，Jordan 型刻畫分裂時的相似類",
      "以特徵多項式重數、(A−λI) 冪次 nullity 與鏈提升精確計算；Q 上未分裂部分保留殘餘因子並可在 AlgMat 擴張上處理",
    ),
    entry(
      "BDD DAG、預算搜尋與認證數值影子",
      SpecStructure,
      [
        "BddManager", "FaceDecision", "FaceSatDecision", "bdd_dag_of_face_best",
        "face_eq_within_budget", "face_sat_dpll", "QuadC", "CertMat", "CertPath",
        "ProjectorCertificate", "certify_numeric_projector", "check_bdd_and_certified_numeric",
      ],
      "面在 manager 中以 hash-consed root 表示，大小為 reachable DAG 節點；數值矩陣的精確影子由 QuadC 矩陣與多項式係數立方體給出",
      "布林函數的共享 ROBDD 圖與精確複二次矩陣代數；Double 層是影子的近似觀察而非等式來源",
      "同 manager root 相等判定面等式，節點預算或 DPLL 處理不可行建構；投影與填充恆等以精確結構相等驗證，浮點只量偏差與 residual",
    ),
    entry(
      "容器函子巢狀遞迴、互歸納與歸納遞迴宣告面",
      SpecStructure,
      [
        "dfunctor_container", "container_tree_schema", "check_container_functor_tree",
        "check_mutual_inductives", "check_tarski_induction_recursion",
      ],
      "DFunctorContainer(shape, positions, index) 表示 Sigma(s:Shape), Positions(s)->X(index s p)，與既有正性函子、互歸納編譯和 DDecode 共用生成器",
      "任意有限依賴多項式/container 函子的初始代數；互歸納是標籤索引和，歸納—遞迴是碼族與解碼的同時初始結構",
      "形狀與位置型別不得提及本族，遞迴索引在 shape/position 兩綁定子下檢查；IH 是對所有 positions 的 Pi 型",
    ),
    entry(
      "懸掛球面與 S³",
      SpecStructure,
      [
        "suspension_schema", "sphere_schema", "sphere2_schema", "sphere3_schema",
        "sphere3_meridian_term", "sphere3_meridian_value", "check_sphere3",
      ],
      "Susp(X) 由 north、south 與每點一條 meridian 生成；S² 與 S³ 分別是圓的一次與兩次懸掛，端點在 hit_cell_value 中化簡",
      "把 X×I 的上下端各塌縮成一點的 HIT；消去子由南北兩點的值和所有 meridian 上的依賴路徑組成",
      "基底 HIT 須無索引且先驗證；端點、恆等消去與固定 meridian 的 hcomp 以轉換與引文範形判定",
    ),
    entry(
      "Jacobi 酉旋轉的符號區間證書",
      SpecStructure,
      [
        "RatInterval", "CInterval", "QCpxMat", "QCIntervalMat", "JacobiCoefficients",
        "JacobiRotationCertificate", "JacobiCertificate", "jacobi_coefficients",
        "jacobi_unitary_interval", "jacobi_interval_eigen", "jacobi_certificate_sound",
        "check_Jacobi_interval",
      ],
      "精確 Hermitian 點矩陣的複矩形區間包絡；每次旋轉保存 before/after、累積變換與有理 c/s/phase 包絡，矩陣以 dyadic 外向捨入保持有界分母",
      "酉相似變換在區間矩陣格上的包含單調提升；最終 Hermitian 包絡的 Gershgorin 圓盤依重疊分簇並計重數",
      "sqrt 以整數二分和精確平方比較包絡；逐旋轉重算係數包含、J†J-I 含零、after 包 J†AJ 與 transform 包 VJ",
    ),
    entry(
      "Miller pattern 高階合一與雙向 elaborator",
      SpecStructure,
      [
        "UTerm", "Unifier", "STerm", "Elaborator", "ElabResult", "hou_fresh_meta",
        "hou_unify", "hou_semantic_optimize", "elab_infer", "elab_check", "elab_result_to_dterm",
        "check_hou_elaborator",
      ],
      "表面命名項解析為 de Bruijn UTerm；metavariable 以作用域變量的 pattern spine 表示，zonked 核心經 beta/投影/Nat 語義簡化後譯至 DTerm",
      "Miller pattern 是高階合一的可判定片斷；雙向 elaboration 將隱含型別引數與 dependent motive 化為同一類 flex-rigid 問題",
      "WHNF、eta、rigid 分解、不同綁定變量 spine 的抽象、occurs/scope 檢查；未解 metavariable 不得進入 DTerm，結果再由依賴檢查器驗收",
    ),
    entry(
      "參數化模組、import/open 與名字空間",
      SpecStructure,
      [
        "ModuleDef", "ModuleImport", "ModuleDecl", "ModuleEnv", "ModuleSignature",
        "ModuleInstance", "module_signature", "module_validate", "module_resolve",
        "module_ref", "module_instantiate", "module_instance_find", "check_module_system",
      ],
      "模組是參數、imports、本地宣告組成的 telescope；bindings 把限定名、別名與 opened/renamed 名映射到 telescope ordinal，實例是同時代換的閉合宣告列",
      "參數化模組是函子，import 是遞迴函子套用後內聯，open 是名字投影而非複製宣告；opaque export 在邊界後成為中性常數",
      "模組循環與重複路徑拒絕，參數引數與每條映射宣告以 d_check 驗證，only/hiding/rename 的歧義名字拒絕，閉合實例逐條 dep_check",
    ),
    entry(
      "立方體演算法：transport、路徑代數與 Kan box",
      SpecStructure,
      [
        "KanBox", "kan_box", "kan_box_fill", "kan_box_comp", "kan_box_pathp", "transport_value",
        "transport_back_value", "transport_checked_line_value", "transport_filler_value",
        "transport_pathp_value", "dpath_refl_value", "dpath_sym_value", "dpath_segment_value",
        "dpath_prefix_value", "dpath_trans_square_value", "dpath_trans_value", "dpath_cong_value",
        "dpath_funext_value", "subst_value", "subst_pathp_value", "dtransport_term",
        "dpath_trans_term", "dfunext_term", "check_cubical_algorithms",
      ],
      "transport 是沿型別線的 coe，filler 是其 PathP；路徑傳遞是 hcomp 方塊的頂邊，funext 與 subst 分別是逐點路徑與族線 coe，KanBox 把開盒的線、系統與 base 打包",
      "cubical CwF 中由 Kan 纖維化結構生成的路徑物件運算：反演、串接、函子性與依賴代入",
      "全部派遣至核心 coe/comp/fill 並以型別導向轉換驗證端點；閉項 builders 再由 dep_check_closed 驗收",
    ),
    entry(
      "計算性單值性（univalence）",
      SpecStructure,
      [
        "UniversePath", "upath_to_equiv", "upath_refl", "upath_sym", "upath_trans",
        "finite_transport", "transport_roundtrip_path_value", "path_to_equiv_value",
        "equiv_to_universe_path_value", "ua_transport_value", "ua_beta_path_value",
        "ua_beta_back_path_value", "univalence_retr_path_value", "univalence_sect_square_value",
        "univalence_equiv_value", "universe_path_of_checked_line", "universe_path_of_ua_term_closed",
        "universe_path_to_equiv_value", "universe_path_normal_form", "universe_path_transport_conv",
        "path_to_equiv_term", "ua_map_term", "path_to_equiv_map_term", "check_finite_univalence",
        "check_univalence",
      ],
      "有限宇宙的路徑以 wiring 等價為範形；依賴 AST 的宇宙路徑以受檢查型別線表示，pathToEquiv 取其 coe 等價，ua 取 Glue 線，uaβ 由 transport filler unglue 得到，往返分別由 Equiv 中的同倫與二維 Glue 方塊見證",
      "宇宙的路徑範疇與等價範疇之間的等價 (Equiv A B) ≃ Path U A B；Glue 是沿等價的黏合，transport 是其 coe 函子",
      "有限側以 wiring 相等判定；AST 側以 coe/comp 計算、型別導向轉換驗證往返端點與方塊四邊，閉項 pathToEquiv 以 DMkEquiv 的 fill/coe 證明由依賴檢查器驗收",
    ),
    entry(
      "完備精確代數：因式分解、根隔離、分裂域與去巢",
      SpecStructure,
      [
        "QPolyCompleteFactorization", "qpoly_factor_complete", "qpoly_isolate_complex_roots",
        "complex_root_isolations_are_certified", "qpoly_splitting_field", "splitting_field_is_certified",
        "radical_simplify", "check_Jacobi_arbitrary_precision",
      ],
      "Rat 以 BigInt 正規化；Q[x] 化為不可約因式重數列；實根以 Sturm 隔離區間、複根以兩兩不交 Rouché 圓盤表示；分裂域以逐次 AlgNum 塔與全部分解表示；Jacobi 端點為任意精度有理數",
      "Q[x] 的唯一因式分解與代數閉包中的根多重集；分裂域是使多項式在擴張塔上完全分裂的有限擴張，根式去巢是擴張中 nth-root 的見證搜尋",
      "Kronecker 預算語義明示；複根在快路徑不足時以 Cauchy 正方形、Taylor 排除與 Rouché 細分補至次數；所有證書以精確多項式運算重驗",
    ),
    entry(
      "一等宇宙多態與同時宣告 schema",
      SpecStructure,
      [
        "DLevelDecl", "dterm_instantiate_levels", "DTypeOperatorDecl", "extract_positive_functor",
        "DNestedIterDecl", "compile_nested_iter_decl", "DMutualDecl", "mutual_decl_elaborate",
        "DSimultaneousIRSpec", "eval_simultaneous_ir", "check_hit_moving_dimension_lift",
      ],
      "層級宣告以 binders＋實例化層級向量表示；型別算子先展開透明定義再抽取正性函子；Bush 類巢狀型由迭代參數前進編譯；互歸納與同時 IR 以聯合規格及其生成消去／求值表示",
      "宇宙多態是層級指派上的 scheme；非均勻巢狀資料是參數迭代的初始代數族，互歸納是向量函子的聯合初始代數，同時 IR 是碼與同步函數的同時初始結構",
      "未實例化 DUnivLevel 在檢查時拒絕；正性報告記錄算子展開與極性；實例化、生成檢查與移動維度 HIT cell 以依賴轉換驗證",
    ),
    entry(
      "原始 DSystem 的剪枝、合意區域與受限修復",
      SpecOperator,
      [
        "conv_at_under_face_report", "tube_paths_conv_under_face", "face_agreement_region",
        "dsystem_repair_to_base", "check_dsystem_repair_phase9",
      ],
      "面下轉換只保留由 BDD 證明的合意子區域；修復輸出不交化後與 base 在維度端點相合的分支及被移除區域，無法修復者保留衝突報告",
      "partial element 在面格切片中的限制與像分解；agreement region 是兩分支在 cofibration 上的相等化子面",
      "以 BDD 區域剪枝取代立方體枚舉；端點與重疊處用型別導向轉換檢查，修復只刪去可證不相合區域",
    ),
    entry(
      "Adjoint 等價資料、contractible fiber 類型與命題截斷",
      SpecStructure,
      [
        "DAdjointEquivParts", "equiv_triangle_type", "adjoint_equiv_type_term", "equiv_improved_sect_value",
        "equiv_fiber_center_value", "singleton_contraction_value", "prop_trunc_schema",
        "trunc_type_term", "check_propositional_truncation",
      ],
      "adjoint 資料是在 quasi-inverse Equiv 上加三角形 Path(Path) 分量；improved counit 以 ε(fgy)⁻¹∙f(η(gy))∙εy 取代 section；命題截斷以 point 與任意兩點間 squash cell 的 HIT 表示",
      "half-adjoint equivalence 是帶一個三角形相干的等價；contractible fiber 以 Σ center 與全域收縮路徑刻畫；截斷是到命題宇宙的左伴隨式反射 HIT",
      "三角形與 fiber 型別以 AST 檢查；identity/singleton 與 improved section 端點以轉換驗證；一般收縮與 adjointification 由第十期 lemIso 構造另行登記",
    ),
    entry(
      "維度代換閉合與持久 schema 註冊",
      SpecStructure,
      [
        "dline_subst", "dline_rev", "dvalue_subst_dims", "checked_line_reparam_closed",
        "DSchemaRegistrySnapshot", "schema_registry_snapshot", "schema_registry_restore",
        "schema_registry_merge_into", "schema_registry_register_inductives", "schema_registry_manifest",
      ],
      "裸 DLine 與語義封閉值攜帶可重參數化的維度代換；註冊表以 64 個 bucket 的 hash-cons plan、snapshot 與 manifest 指紋為持久範形",
      "立方代換是維度脈絡間的函子作用；registry 是 schema 描述子集合上的 interned 有限圖，snapshot/merge 對 plan 身分函子性地保存",
      "代換後 coe 與反向線以轉換驗證；bucket 只縮小候選集而身分仍以完整鍵判定，restore/merge/batch 後統計與 plan 身分重驗",
    ),
    entry(
      "一般代數認證數值與 DAG 原生 BDD 操作",
      SpecStructure,
      [
        "AlgC", "AlgCertMat", "AlgCertPath", "alg_cert_outer", "alg_cert_is_projector",
        "alg_cert_square_in_image", "bdd_dag_reachable_count", "bdd_dag_eval", "bdd_dag_sat_count",
        "bdd_dag_restrict", "bdd_dag_exists", "bdd_dag_forall", "bdd_dag_dnf_face",
        "face_sat_decide", "face_eq_decide",
      ],
      "AlgC 是同一 AlgNum modulus 上的實虛對；形式路徑／方塊以任意次多項式係數表表示；BDD 以 reachable DAG root 為範形，滿足數是 BigInt",
      "一般有限代數擴張 C=K(i) 上的 Hermitian 線性代數；DAG 是固定變量序布林函數的共享規範圖，exists/forall 是投影量化",
      "投影、像與方塊含入以係數精確相等判定；DAG 操作直接在 interned graph 上 memoized，預算不足時 DNF 回 None 或轉 DPLL 總判定",
    ),
    entry(
      "球面同倫代表元與 Hopf 連結不變量",
      SpecStructure,
      [
        "loop_space_type_term", "based_map_type_term", "circle_degree_value", "sphere_degree_value",
        "suspension_unit_loop_value", "sphere3_swapped_schema", "sphere3_swapped_equiv_value",
        "hopf_map_s3_to_s2", "hopf_linking_number_numeric", "check_sphere_homotopy_representatives",
        "check_hopf_numeric",
      ],
      "Omega^n 以巢狀 Path 與迭代 refl 表示；整數度數映射由 circle loop 冪次逐層懸掛；極交換 S³ 以 south/north 順序互換的 HIT 表示；Hopf 映射採 C² 單位球座標",
      "懸掛是端點塌縮函子，基點映射與 loop space 是 pointed 類型範疇的代表元；Hopf 纖維是 S¹ 主叢纖維，其連結數是 Hopf 不變量",
      "生成 meridian 上以轉換檢查度數與單位環路，交換呈現以依賴消去 sect/retr 路徑檢查；Hopf 像與纖維由代數恆等檢查，連結數以立體投影後 Gauss 積分數值判定絕對值 1",
    ),
    entry(
      "非 Miller pattern 的受限高階合一",
      SpecOperator,
      ["check_hou_phase9_extensions"],
      "重複變量 spine 取首個重複 binder；succ/pair 構造子 spine 以 pred/fst/snd 擷取葉變量；相異 flex-flex 以支援交集上的共同 fresh meta 表示",
      "這些片斷是 pattern unification 在重複代換與可逆構造子模式上的保守擴張；共同 meta 是兩 flexible substitution 支援的交集反射",
      "此確定性層的同頭 flex-flex 只在逐項引數合一後 spine 相同才解；任意 rigid spine 與置換由第十期有界搜尋層處理",
    ),
    entry(
      "模組分離編譯、介面連結與增量快取",
      SpecStructure,
      [
        "CompiledModule", "CompiledModuleEnv", "ModuleCompileCache", "module_decl_abstract",
        "module_compile", "compiled_module_validate", "compiled_module_to_module_def",
        "module_link_instantiate", "module_compile_cached", "compiled_module_specialize_prefix",
        "check_module_compilation",
      ],
      "CompiledModule 保存已檢查的參數 telescope、展平 entries、exports、依賴介面指紋與 public projection 編碼；介面 hash 不含 opaque body，實作 hash 含全部 entries",
      "抽象宣告是 telescope 中的中性介面條目；編譯是模組函子到已檢查物件的映射，連結以 synthetic import-free 定義取代來源，prefix 特化是部分函子套用",
      "抽象模組可簽章但不可實例化；implementation 須介面 hash 相同且補足抽象 exports；cache 以來源與依賴介面指紋判定 hit；磁碟二進位格式由第十期 codec 另行登記",
    ),
    entry(
      "一般可收縮纖維與自動 adjointification",
      SpecStructure,
      [
        "equiv_fiber_type_value", "equiv_fiber_path_value", "equiv_fiber_contraction_value",
        "equiv_contractible_fibers_value", "adjointify_equiv_value", "check_general_adjointification_and_contractible_fibers",
      ],
      "任意纖維元素間的路徑以 lemIso 三層填充方塊表示：兩次 hfill 連接 g∘p 與 retr、再連接兩條填充，來源方塊 hcomp 後由 f 與 section 自然性方塊閉合；adjoint retr 是 f x 纖維中往 (x,refl) 收縮的第一分量，三角形由第二分量方塊轉角 hcomp 抽出",
      "quasi-inverse 的 isEquiv 刻畫是所有 homotopy fibers 可收縮；half-adjoint 三角形是該收縮在對角纖維上的邊界方塊",
      "Bool 非與圓形恆等上以轉換驗證收縮兩端、一般中點的面下邊界、替換 retr 端點與三角形兩端；離散 Bool composition 另以 cap 值展開使巢狀 hcomp 有布林範形",
    ),
    entry(
      "有界 Huet 高階合一搜尋",
      SpecOperator,
      [
        "HouSearchStatus", "HouSearchReport", "hou_search_unify", "hou_search_unify_bool",
        "check_hou_bounded_search",
      ],
      "搜尋狀態是可回復的 Unifier 快照、節點/分支計數與深度；候選範式為確定性片斷解、rigid imitation 模板、formal spine 上的 projection、eta 生成、同頭不變座標剪枝及相異 flex-flex 共同常數",
      "Huet 搜尋在高階代換的分支樹上以 imitation 與 projection 生成候選；回報區分已解、閉 rigid 衝突、深度殘餘與節點預算耗盡",
      "每節點先試確定性 hou_unify，失敗回復快照；任意 rigid spine 由 imitation 分解為 formal 引數上的 fresh 子目標；同頭置換只保留逐項可證不變座標，失敗不污染輸入 unifier；一般 HOU 不可判定故不宣稱完備必停判定",
    ),
    entry(
      "穩定已編譯模組二進位格式",
      SpecStructure,
      [
        "ModuleBinaryStatus", "ModuleBinaryLoad", "compiled_module_binary_format_version",
        "compiled_module_to_binary", "compiled_module_from_binary", "compiled_module_load_binary",
        "compiled_module_load_binary_report", "compiled_module_binary_to_hex", "compiled_module_binary_from_hex",
        "check_module_binary_format",
      ],
      "檔案是 CHMODBIN 魔數、版本/flags、payload 長度與 DJB2-xor checksum 標頭，後接小端固定欄位 payload；字串為 UTF-16LE code-unit 串，DTerm、Dim/Face、層級表達式、正性函子、歸納與 HIT 描述子各用固定標籤遞迴編碼",
      "CompiledModule 的持久範形是其全部已檢查欄位，接口/實作 hash 仍由模組編譯層定義；hex 是二進位位元組的文字檔案表示",
      "解析器驗證位元組範圍、魔數、版本、長度、checksum、計數剩餘量與遞迴深度，並要求 payload 精確耗盡；load 形式再以 compiled_module_validate 驗 hash 與 synthetic 定義重 elaboration，竄改與截斷回精確狀態",
    ),
    entry(
      "極端輸入成本控制：BDD、SAT 與精確多項式",
      SpecOperator,
      [
        "bdd_manager_cache_stats", "BddOptimizedBuild", "bdd_dag_of_face_optimized",
        "FaceCnfStats", "face_cnf_stats", "face_sat_watched_dpll", "face_eq_watched_dpll",
        "check_bdd_cost_optimizations", "check_qpoly_fast_arithmetic",
      ],
      "BDD 成本範形包括 reachable node 數、節點/apply 桶數與快取條數；face 的搜尋範形是 Tseitin CNF 的 variables/auxiliaries/clauses/literals；稠密整數多項式以共同分母縮放後 Karatsuba 分治，稀疏多項式保留跳零卷積",
      "sifting 是變量序上的局部搜尋；watched literals 把單位傳播限制在被賦值文字監視的子句；Karatsuba 以三次子乘法取代四次，這些都降低可處理片斷成本而不改變最壞情況指數下界",
      "BDD 初始候選序後逐變量試全部插入位置並受 rebuild 預算限制；apply cache 隨條數增長重散列；DPLL 以保存相位與衝突活動選變量且見證回驗，預算耗盡回明示狀態；多項式冪改二進位冪",
    ),
    entry(
      "核內整數、π₃ 商呈現與球面環路代表元分類",
      SpecStructure,
      [
        "integer_schema", "integer_type_term", "integer_value", "integer_succ_value",
        "integer_pred_value", "homotopy_group_type_term", "pi3_sphere_type_term",
        "sphere_loop_power_value", "SphereLoopExpr", "sphere_loop_expr_degree", "sphere_loop_expr_value",
        "check_sphere_loop_representatives_internal",
      ],
      "IntegerS 以 zero、posSucc(NatS)、negSucc(NatS) 唯一表示整數；πₙ 以 Ωⁿ 對命題截斷路徑關係的 QuotientS 表示；球面生成環路由 circle loop 經懸掛 unit 逐層提升，並沿 meridian(base) 與其逆的消去方塊 transport 改基；代表元表達式以 generator、逆與合成生成且 degree 為其範形",
      "Ωⁿ 是迭代基點路徑類型，πₙ 是代表元在高一路徑下的商；懸掛 unit 是 pointed suspension/loop 伴隨的單位，代表元微積分是自由生成子上的群字問題範形",
      "IntegerS 與 π₃(S²)/π₃(S³) 型別以依賴檢查驗證，succ/pred 與代表元 degree 往返以轉換/整數相等驗證，S²/S³ 生成環路檢查外層端點；此登記只宣稱代表元分類與 decode，一般合成 encode/decode 分類定理仍保留為邊界",
    ),
    entry(
      "跨家族巢狀函子與同時 IR 編譯（第十一期）",
      SpecStructure,
      [
        "DFunctorParamArg", "dfunctor_family", "dfunctor_param_self", "dfunctor_param_term",
        "simultaneous_ir_compile_decode", "code_interpretation_ir", "check_family_nested_functors",
        "check_simultaneous_ir_compiled_decode",
      ],
      "DFunctorFamily(spec, params, indices) 以值攜帶目標規格；參數槽由 DFunctorParamArg 標明 Term（外部項，經 schema_eval_under 在當前脈絡求值）或 Self（宿主家族於給定索引實例化）；IH bundle 是每構造子引數一槽的巢狀 DVPair…DVUnit；同時 IR 經中性探測宇宙等級與位置映射編譯為改名後的 decode 規格",
      "跨家族巢狀是嚴格正函子的複合（外部初始代數以宿主代數為參數）；gather 把巢狀 IH 束提升為宿主 motive 截面；同時歸納—遞迴在宇宙結果僅依賴單一解碼函數時退化為 Tarski 解碼",
      "validate 拒絕 Decoded* 引數類與參數非葉出現（不可 gather）；編譯拒絕真正互依（他函數 IH 槽被引用）與依賴 code 的宇宙等級；FamRoseTreeS/FamVecTreeS 以束葉計數與 IH 型別轉換驗證，編譯範例於值層與項層與同時形式一致；自引用同規格的 Bush 形巢狀明示不在本期範圍",
    ),
    entry(
      "Face 合意區域、精確修復與不透明立方開盒（第十一期）",
      SpecStructure,
      [
        "face_agreement_face", "face_agreement_face_sound", "DSystemRepairExact",
        "dsystem_repair_to_base_exact", "DCubeFunction", "DCubeOpenBox", "DCubeBoxFace",
        "DCubeBoxReport", "dcube_open_box", "dcube_box_validate", "dcube_box_fill_verified",
        "dcube_box_cap", "PolyCube", "PolyOpenBox", "poly_box_fill_verified", "check_face_agreement_and_exact_repair",
        "check_dcube_open_box_filler", "check_poly_cubes",
      ],
      "兩值的合意區域同給布林 BDD 形與 Face 值形（後者以 FEq0/FEq1 的析取保留 i=0 與 i=1 雙端點，布林化後等於 BddOne）；立方是宿主函數（維度列→語義值／有理多項式座標）；開盒缺一面、帽是填充在缺面的限制",
      "合意面是面格切片中兩偏元素的等化子；checked 修復是進入相容系統子類的反射；外部立方是 □ 上的外部函子資料，其填充是宿主層的 Kan 條件；多項式立方以 F += w·(S − F|face) 迭代修正至邊界恆等",
      "Face 合意以逐頂點轉換求最大面並以 sound 檢查封閉；exact repair 只保留 Face 值合意面內的分支部分（頂點層面不刪）；開盒逐對重疊以轉換／規範多項式相等驗證，不相容與不完整皆拒絕並給失敗計數",
    ),
    entry(
      "lemIso 一般點與 Circle/Torus 點值合成（第十一期）",
      SpecTheorem,
      [
        "check_lemiso_generic_points", "check_circle_torus_point_comp", "dim_of_face",
      ],
      "lemIso 收縮方塊在中性點與中性路徑兩端求值後以端點與邊界方程表示；圓與環面的點值合成範形是座標的 De Morgan 選擇式（dim_of_face 把面公式重讀為維度式）",
      "adjointification 的纖維收縮在一般（非規範）點上成立；原始 Circle/Torus 型別上的 comp 在點值資料下由座標方程閉合，非點值 tube 保留為 DNComp 形式合成",
      "中性點直接轉換判定；中性路徑案例以維度兩端限制檢查（端點不化約的路徑消去中性式需要 conversion 內 case-split，明示不做）；點值 tube 以 pairwise 相容加 fold 選擇計算並以 dim_eq_sem 驗證",
    ),
    entry(
      "註冊位元組持久化與 DTerm 全域 hash-consing（第十一期）",
      SpecStructure,
      [
        "schema_registry_to_binary", "schema_registry_from_binary", "schema_registry_snapshot_from_binary",
        "schema_registry_snapshot_load_binary_report", "DSchemaRegistryBinaryLoad",
        "schema_registry_binary_roundtrip_ok", "DTermInternTable", "dterm_intern",
        "dterm_intern_id", "dterm_rebuild", "check_schema_registry_byte_persistence",
        "check_dterm_hash_consing",
      ],
      "CHREGBIN v1＝magic＋版本 u16＋長度 u32＋校驗 u32＋以模組 codec 編碼的全 DTerm/schema payload（第十二期 v2 改共用 DAG codec、v1 仍可讀，見第十二期儲存庫條目）；hash-cons 範形是自底向上的 intern 表（stamp→id 的有限圖），重建項與原項結構相等",
      "註冊表是可共享 elaboration 計劃的有限圖，其位元組形是穩定外表示；intern 是項語言到其子項共享商的態射，不改變檢查與正規形",
      "位元組載入逐一拒絕 bad magic/版本/截斷/校驗並回報狀態；往返後重驗註冊；intern 以 tree/distinct 子項計數與 dep_check/dep_nf 在 intern 前後一致驗證",
    ),
    entry(
      "自適應因式圖樣剪枝、雙二次去巢與特徵值簇分離（第十一期）",
      SpecOperator,
      [
        "QPolyDegreePattern", "qpoly_mod_degree_patterns", "qpoly_irreducible_by_mod_patterns",
        "check_qpoly_mod_pattern_pruning", "BiquadNum", "biquad_sqrt", "biquad_sign",
        "radical_to_biquad", "radical_equal_exact", "check_biquadratic_denesting",
        "JacobiClusterSeparation", "SeparatedEigenInterval", "jacobi_separate_clusters",
        "jacobi_cluster_separation_certified", "check_jacobi_cluster_separation",
      ],
      "模素數不可約因式次數的升冪列即次數圖樣；雙二次範形為基底 [1,√d₁,√d₂,√(d₁d₂)]（d₁<d₂ 無平方因子、遞增）上的有理係數；分離範形為不交特徵區間連同多重數",
      "圖樣是 Galois 群在根集合置換的循環型；雙二次數是二次子域合成的 Galois 閉包元素，共軛給出範數；平方自由部分的根是互異特徵值集",
      "圖樣先於有理根與 Kronecker 列舉剪枝（素數至 251、圖樣配額 32；x⁴+1 型 V4 情形誠實無法排除二次因式）；雙二次運算在 Q*/Q*² 的公共基底上行、開根以單根槽二次公式與多根槽 AlgNum 橋判定並平方重驗，符號以塔式平方比較判定；簇分離以平方自由部分 Sturm 區間對原多項式計數並以重疊唯一匹配",
    ),
    entry(
      "CDCL 子句學習與 BDD 精確最佳變量序（第十一期）",
      SpecOperator,
      [
        "FaceCdclStats", "FaceCdclResult", "face_sat_cdcl", "face_eq_cdcl", "face_sat_cdcl_report",
        "BddOptimalBuild", "bdd_dag_of_face_optimal", "check_cdcl_clause_learning",
        "check_bdd_optimal_order_exact",
      ],
      "學習子句以 1-UIP 斷言文字領頭；最優序範形為使 reachable node 數在全部排列中最小的排列連同 tried/exact 旗標",
      "CDCL 是蘊含圖上的衝突分析（學習子句是衝突的 resolution 證書）；變量序問題是布林函數共享範形在對稱群作用下的極值化；兩者皆不改變面格語義",
      "watched 傳播、VSIDS 活動、Luby 重啟節奏；與 2ⁿ brute force 和舊 DPLL 差分驗證、鴿洞實例要求 learned>0；最優序 n≤8 全排列可證、超出回報 exact=false 並語義對驗 face_holds；SAT 與 BDD 最壞指數界保留不變",
    ),
    entry(
      "圓的萬有覆疊與 encode/decode（第十一期）",
      SpecStructure,
      [
        "circle_hit_type_value", "circle_loop_space_type_value", "integer_succ_equiv_value",
        "circle_cover_value", "circle_encode_value", "circle_encode_pieces_value",
        "circle_decode_value", "check_circle_encode_decode",
      ],
      "helix 族在 base 的纖維是 IntegerS（zero / posSucc(NatS) / negSucc(NatS)，|n|−1 編碼）、在 loop 點是後繼等價的 ua GlueEquiv 型别；繞數與整數代表皆為規範 DVIntro 值",
      "覆疊族是圓上的纖維化，encode 是 subst 路徑提升的端點，decode 是整數初始代數到環路空間的消去；分類陳述是兩向複合在代表元的範疇等式",
      "base 纖維以宇宙層轉換等於 ℤ、loop 點纖維等於 ua 線；encode 在 refl/生成元/逆元直接計算為 0/1/−1；單次 subst 越過複合環路的 trans 點原經宇宙 comp 的 Glue 型別線不串接後繼等價（第十一期內涵邊界），第十二期起改經端點 Glue 線合成串接，loop²/loop³/loop⁻²/抵消的單次 subst 分別得 2/3/−2/0 並與 transport 函子性細分的計算一致；decode∘encode 在代表元以環路空間轉換判定、encode∘decode 在 0,±1 直接而在 ±2,3 依 decode 分解細分；任意中性環路的完整 π₁(S¹)≃ℤ 等價需商/funext 機械，仍為保留邊界；原始 DVCircleTy 以 dim_eq_sem 作點轉換會把 loop² 折回 loop，不作為分類對象",
    ),
    entry(
      "HOU 深搜尋、模組交錯編排與二進位版本遷移（第十一期）",
      SpecStructure,
      [
        "HouIterativeReport", "hou_search_unify_iterative", "check_hou_search_extensions",
        "ModuleItem", "check_module_interleaved_items", "CompiledModuleStore", "CompiledModuleStoreStats",
        "compiled_module_store_put", "compiled_module_to_binary_v1", "check_module_binary_versions_and_store",
      ],
      "模組定義範形為參數後單一 ModuleItem 列（import 與 decl 交錯），舊 decls 形展開為 imports 前置的等價列；CHMODBIN v2 在 v1 payload 後加 producer 字串；store 範形為 (blobs, hits, misses)",
      "交錯的模組函子 telescope 中 import 與宣告同為可依賴先行條目的延伸；迭代加深是同一帶預算搜尋函子在深度偏序上的最小不動點逼近",
      "HOU 以深 imitation、放寬的 projection 上限與同頭 identification 擴展，HouIterativeReport 記錄求解深度且解僅 specific unifier（非 MGU、一般 HOU 不可判定仍明示）；交錯範例中 legacy 排序必失敗而交錯成功；v1 寫出由 v2 截尾重建、遷移載入逐欄相等，tag 8 的 Family 節點在 v1 寫出時被拒",
    ),
    entry(
      "BDD 子集 DP 最佳序與 CDCL 子句刪除／RUP 證明（第十二期）",
      SpecOperator,
      [
        "bdd_dag_of_face_optimal_dp", "FaceCdclProofResult", "face_sat_cdcl_proof",
        "face_cdcl_proof_check", "check_bdd_optimal_order_dp", "check_cdcl_proof_and_reduction",
      ],
      "子集 DP 範形是對每個前綴子集計算的最小上層節點寬度表與逐步重建的順序；RUP 證明範形是與子句庫分開的學習子句序列，每條皆為在先行子句下以單位傳播蘊含的子句",
      "變量序問題在固定順序向量子集格上是動態規劃的最短路；RUP 是 resolution 的單位傳播片段，子句刪除保持可滿足性不變式而證明日誌不受刪除影響",
      "DP 於 n≤12 給出可證最優序（n=10 時 tried=5120）、n=13 起 exact=false；LBD 刪除只在 decision level 0 執行、reason 子句保留並重建 watches；RUP checker 以單位傳播重播驗證鴿洞反駁，刪除量在實例上可觀察",
    ),
    entry(
      "Schema 同規格非均勻遞迴、Self 參數型別與正性宣告（第十二期）",
      SpecStructure,
      [
        "DFunctorSelfFamily", "check_self_family_and_gather_shapes", "DPositivityDeclaration",
        "dpositivity_declaration", "dpositivity_declaration_from_lambda", "dterm_family_positivity_declared",
        "dterm_family_strictly_positive_declared", "inductive_parameter_positivity_declared",
        "check_positivity_declarations",
      ],
      "DFunctorSelfFamily(pargs, index) 是不攜帶目標規格的同規格自嵌標記（宿主字面值不可自引用其規格）；DPositivityDeclaration 範形為 (head, arity, strict_args, positive_args, scope)",
      "同規格自嵌是參數位上的非均勻初始代數遞迴（Bush：tail 型別為 Bush (Bush Bool)）；正性宣告是把不透明算子視為已知正函子的受信延伸，λ 驗證版是結構分析認可的正函子子類",
      "handler 以已建立的宿主 Self 型別取代 DVUnitTy 使依賴先行 Self 參數的後續參數可通過（List/Sigma 形狀一併 gather）；宣告以 depth-aware walk 於 binder 下移位比對且對參數 probe 代換同型，無宣告時不透明應用正性為 unknown、有宣告可得 strict，domain 位置仍負；SelfFamily 本身的正性只回 unknown；宣告不構成不透明算子正性的證明",
    ),
    entry(
      "同時 IR eliminator 編譯（第十二期）",
      SpecStructure,
      [
        "simultaneous_ir_eliminator_type", "simultaneous_ir_compile_eliminator_block",
        "simultaneous_ir_compile_eliminator", "check_simultaneous_ir_eliminator_compilation",
      ],
      "互賴函數塊逐函數依宣告序編為同一 base 家族 eliminator 的閉項：已編的較早宇宙函數項供外來 IH、函數引數的自身遞迴在 lambda 下套用",
      "在單一初始代數上的同步歸納—遞迴可由其 eliminator 的截面複合表示；motive 餘域為 DVUniv(base.level)，故函數層級須嚴格小於 base 層級（與 decode 路線的片斷互補）",
      "每項經 dep_check_closed 且在外層脈絡以新鮮中性值強制套用 motive 與各 case lambda 逐一檢查本體（d_check 對 lambda 本體惰性，僅閉項檢查不足）；循環互賴、層級不合、前向引用、非宇宙外來函數與巢狀/decoded 引數回 None；互賴 El/El2 的範形與 decode 路線相符",
    ),
    entry(
      "DSystem 結構合意與 repair 補入（第十二期）",
      SpecStructure,
      [
        "bdd_tree_cofactor", "dterm_dim_vars", "DSystemRepairSupplemented", "dsystem_repair_with_candidates",
        "check_dsystem_structural_agreement_and_supplementation",
      ],
      "合意區域的結構範形只保留分支語法上實際出現的維度（其餘變量以 cofactor 相等自 BDD 消失）；補入結果記錄 (system, base_removed_region, repaired_branches, added_branches, rejected_candidates, compatible)",
      "面合意是面格中的等化子，其支撐是兩值維度支撐的聯集；補入是相容子系統格中沿給定順序的貪心延伸",
      "合意檢查把逐頂點轉換探測限制在相關維度（12 維環境中雙端點合意面仍得 root var 0 的緊湊 BDD）；repair 先 exact 截斷再逐一在可驗證相容下補入候選並拒絕其餘，結果是順序相依的極大相容子系統，不宣稱為最大",
    ),
    entry(
      "Bool case-split 轉換與路徑值合成（第十二期）",
      SpecOperator,
      [
        "conv_terms_case_split", "conv_terms_plain", "check_case_split_conversion_and_path_comp",
      ],
      "case-split 轉換以新鮮中性環境求值的普通轉換打頭，失敗時對型別求值為 DVBoolTy 且出現於兩項或型別的脈絡變量遞迴代入 true/false；路徑值合成的範形為 comp_path_value 以端點 tube 遞迴至基底 comp 的 DVPathLam",
      "Bool 是離散立方型別，變量 case-split 對轉換是健全的 η 型加強；Circle/Torus 分支帽座標以一般分支值代入合成方向 1 讀出，是座標多項式在端點的取值而非端點範形",
      "if x then 0 else 0 ≡ 0 切分可判、真正依賴 x 者仍拒絕，雙 Bool 變量與相依型別代入遞迴處理，Nat 變量不切分、未出現不誤判；右端點行經環路的 Path 型別合成算出環路帽（Circle 與 Torus 雙座標），輸入系統不合型別時結果不作保證",
    ),
    entry(
      "Artifact 儲存庫、共享 DAG codec 與版本協商（第十二期）",
      SpecStructure,
      [
        "ArtifactByteStore", "artifact_byte_store_new", "artifact_memory_byte_store_new",
        "ArtifactRecord", "ArtifactRepository", "artifact_repository_new", "artifact_repository_put",
        "artifact_repository_get", "artifact_repository_list", "artifact_repository_remove",
        "artifact_repository_recover", "artifact_repository_verify_all", "ArtifactRepositoryStats",
        "artifact_repository_put_compiled_module", "artifact_repository_get_registry_snapshot",
        "BinaryVersionPolicy", "binary_negotiate_version", "compiled_module_binary_version_policy",
        "schema_registry_binary_version_policy", "check_artifact_repository_and_dag_codec",
      ],
      "儲存庫範形為抽象鍵→位元組儲存上的 blobs 與 manifests（雙哈希、長度、格式版本）加單一 index 鍵；DAG codec 範形為達節點門檻後以 tag 255 back-reference 序列化的共享項圖，CHMODBIN v3 與 CHREGBIN v2 共用；版本政策範形為 (current, supported, oldest_writable)",
      "儲存庫是命名工件在抽象鍵值儲存上的函子式持久層，提交順序 blobs→manifests→index 給出原子可見性；版本協商是支持集交集在可寫偏序上的最大元",
      "put 後 index 才指向新 manifest，未完成提交不可見；blob 損壞於 get 以哈希拒絕，index 全失由 manifests 掃描復原並計數；DAG 往返逐欄相等且小項不啟用 back-ref；協商在無共同版本時回 None、寫出不低於雙方 oldest_writable；抽象儲存是協議而非 OS 磁碟",
    ),
    entry(
      "不可約證書、三次／三二次塔與簇感知 Jacobi（第十二期）",
      SpecOperator,
      [
        "QPolyIrreducibilityCertificate", "qpoly_irreducibility_certificate", "qpoly_irreducibility_certificate_check",
        "qpoly_irreducible_certified", "check_qpoly_irreducibility_certificates",
        "CubicNum", "cubic_make", "cubic_norm", "cubic_sign", "radical_to_cubic",
        "TriquadNum", "triquad_make", "triquad_sign", "triquad_sqrt_of_biquad", "radical_to_triquad",
        "check_tower_fields", "JacobiClusterAwareReport", "jacobi_interval_eigen_cluster_aware",
        "check_jacobi_cluster_aware_iteration",
      ],
      "不可約證書範形為 CertLinear/CertLowDegreeNoRationalRoot/CertModPrime/CertEisenstein 可重驗標記連同見證；CubicNum 為 cubefree m 上的 a+b∛m+c∛m²、TriquadNum 為三個平方類獨立生成元的 8 維係數；簇感知報告攜帶證書、精度、重啟次數與分離狀態",
      "證書是不可約性在證書範疇中的態射（檢查比重算因式分解便宜）；根式判等的塔是有限 Galois 塔的子格；簇感知迭代把譜簇資訊回饋進相似變換的 pivot 選擇",
      "x⁴+1 以零 Kronecker 預算經 Eisenstein 平移證書判定，證書檢查全拒變造；四層 radical_equal_exact 逐層嘗試單二次/雙二次/純三次/三二次且開方以平方重驗，生成元逐一以平方類獨立化簡；簇感知迭代在迭代內分離 count-2 簇且證書可由 jacobi_certificate_sound 核驗（與事後 Sturm 簇分離分開記錄）",
    ),
    entry(
      "HOU 主合一子與殘留約束語意（第十二期）",
      SpecOperator,
      [
        "HouMguStatus", "HouConstraint", "HouMguReport", "hou_unify_mgu", "check_hou_pattern_mgu_and_residuals",
      ],
      "報告範形為 (status, substitution, residual)：Principal 時 substitution 是字彙序規範化的主替代、Residual 時為部分替代連同 HouConstraint 列 (lhs, rhs, depth)",
      "Miller pattern 片斷中合一子範疇有初始物件（MGU 模改名唯一）；殘留約束是該範疇邊界上的未解相等問題，續解是替代在約束上的作用",
      "flex-flex 交集、pruning 與 pattern 抽象產主合一子並以具體其他合一子的可分解性抽查；occurs/頭衝突給 no-unifier 且失敗還原先行狀態；重複變量與 constructor-spine 形回 Residual 並可由後續替代續解，一般 HOU 不可判定性與非 pattern 形的不完整性明示",
    ),
    entry(
      "宿主立方分層外延檢查（第十二期）",
      SpecOperator,
      [
        "DCubeStratifiedReport", "dcube_cubes_conv_stratified_report", "dcube_cubes_conv_stratified",
        "dcube_box_validate_stratified", "dcube_filler_faces_ok_stratified", "dcube_box_fill_verified_stratified",
        "check_dcube_stratified_extensionality",
      ],
      "分層探針範形為三個乘積池的維度賦值枚舉：逐軸 {0,1,新鮮變量}、逐軸 {0,1,共享 s,共享 t} 與逐軸 {s,¬s,s∧t,s∨t}；報告為 (equal, probes, failed, complete)",
      "探針層對應立方體面格的層（strata）與連接退化：宿主函數在面、對角與連接子立方上的限制決定其在這些商上的外延行為",
      "逐探針以 conv_at 比較、首個失敗即停；只在端點/對角/連接層與常數立方相異的宿主函數被分層檢查拒絕而一般點檢查放行； arity 2 的相等對共行 41 探針；盒驗證與填充改走分層邊轉換；探針數逾 4096 的層跳過並回 complete=false，有限探針不構成全外延證明",
    ),
    entry(
      "環路單位律 3-胞與精確有理 Hopf（第十二期）",
      SpecTheorem,
      [
        "dpath_left_unit3_value", "dpath_right_unit3_value", "hopf_map_rat", "hopf_rotate_rat",
        "check_hopf_exact_rational", "check_loop_unit_3cells_and_hopf_exact",
      ],
      "單位 3-胞範形為巢狀 DVPathLam：左單位是 transitivity 方塊上保持端點的兩階段連接旋轉之複合、右單位是垂直滑行；Hopf 範形為 ℚ⁴→ℚ³ 的二次多項式映射與 ℚ 上的相位旋轉",
      "單位 3-胞是迭代環路空間 ∞-群胚中單位律的見證態射（代表元層）；有理 Hopf 恆等式是多項式恆等在稠密有理子集上的精確實現",
      "3-胞在 S²/S³ 冪代表元上以一般參數檢查兩面與中間端點轉換；有理檢查逐點精確驗證落於 S²、沿有理旋轉像不變、極點纖維與兩纖維抽樣不交；結合律/交換律 3-胞、內部 Hopf 映射與 π₃ 分類不宣稱",
    ),
    entry(
      "定理登記表與範例",
      SpecTheorem,
      [
        "CheckResult", "run_all_checks", "all_checks_pass", "print_report", "example_projector",
        "sample_terms", "check_projector", "check_eigenspace", "check_cube_comp",
        "check_nbe", "check_eta_all", "check_bdd_canonical", "check_glue_comp_all",
        "check_categories_all",
      ],
      "條目 (名稱, Bool)；全表 PASS 為總驗收範式",
      "每一條目是一條可判定命題在具體見證上的實現",
      "moon test 與 moon run cmd/main",
    ),
    entry(
      "規格登記自身",
      SpecStructure,
      [
        "SpecKind", "SpecEntry", "spec_registry", "spec_registry_sound", "spec_covers",
        "spec_count",
      ],
      "條目本身即 (名稱, 類別, 符號, 範形, 範疇, 判定) 六元組",
      "登記是「規格的規格」；完備性由 SPEC-APPENDIX 雙語附錄以多套件產生介面核對",
      "tools/audit_spec.py 逐符號審計",
    ),
  ]
}

///|
fn spec_symbol_count(reg : Array[SpecEntry], sym : String) -> Int32 {
  let mut count = 0
  for i in 0..<reg.length() {
    for k in 0..<reg[i].symbols.length() {
      if reg[i].symbols[k] == sym {
        count = count + 1
      }
    }
  }
  count
}

///|
/// The registry is sound: every entry fully specified, names unique, and
/// no symbol claimed by two entries.
pub fn spec_registry_sound() -> Bool {
  let reg = spec_registry()
  for i in 0..<reg.length() {
    let e = reg[i]
    if e.name == "" ||
      e.canonical == "" ||
      e.categorical == "" ||
      e.decision == "" ||
      e.symbols.length() == 0 {
      return false
    }
    for j in 0..<reg.length() {
      if i != j && reg[j].name == e.name {
        return false
      }
    }
    for k in 0..<e.symbols.length() {
      if spec_symbol_count(reg, e.symbols[k]) != 1 {
        return false
      }
    }
  }
  true
}

///|
pub fn spec_covers(sym : String) -> Bool {
  spec_symbol_count(spec_registry(), sym) >= 1
}

///|
pub fn spec_count() -> Int32 {
  spec_registry().length()
}
