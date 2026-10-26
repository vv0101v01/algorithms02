# cubical-hermitian 規格附錄（逐符號登記）

[English appendix](SPEC-APPENDIX.en.md) · [中文規格正本](SPEC.md) · [English specification](SPEC.en.md)

> 本檔案由 `tools/audit_spec.py --write` 自各套件的 `pkg.generated.mbti`
> （`moon info`）生成，**勿手改**附錄標記之間的內容。套件欄是
> `architecture.json` 登記的 MoonBit 套件（`root` / `algebra` / `cmd-main`）。

<!-- APPENDIX:BEGIN -->
共 **3118** 個公共符號（宣告＋構造子＋欄位），分屬 61 個規格族；按套件：`algebra` 746、`root` 2372。

### 複數標量

- 規範形式：(re, im) 有序對
- 範疇化：交換環 C；共軛為對合
- 判定：eps 分量比較

| 符號 | 套件 | 類別 |
|---|---|---|
| `Complex` | root | 結構 |
| `Complex.im` | root | 欄位 |
| `Complex.re` | root | 欄位 |
| `Complex::equal` | root | 函數 |
| `Complex::not_equal` | root | 函數 |
| `Complex::to_repr` | root | 函數 |
| `cx` | root | 函數 |
| `cx_add` | root | 函數 |
| `cx_approx_eq` | root | 函數 |
| `cx_conj` | root | 函數 |
| `cx_mul` | root | 函數 |
| `cx_real` | root | 函數 |
| `cx_scale` | root | 函數 |
| `cx_sub` | root | 函數 |
| `cx_zero` | root | 函數 |
| `eps` | root | 常量 |

### 複向量與內積

- 規範形式：分量列
- 範疇化：Hilbert 空間 Hilb 的物件；內積誘導對偶
- 判定：分量運算

| 符號 | 套件 | 類別 |
|---|---|---|
| `CVec` | root | 型別別名 |
| `inner` | root | 函數 |
| `vec_add` | root | 函數 |
| `vec_approx_eq` | root | 函數 |
| `vec_norm2` | root | 函數 |
| `vec_orthogonal` | root | 函數 |
| `vec_scale` | root | 函數 |
| `vec_scale_c` | root | 函數 |
| `vec_sub` | root | 函數 |
| `vec_zero` | root | 函數 |

### 矩陣與伴隨

- 規範形式：列之列
- 範疇化：Hilb 態射；† 為 dagger 函子
- 判定：矩陣運算

| 符號 | 套件 | 類別 |
|---|---|---|
| `CMat` | root | 結構 |
| `CMat.n` | root | 欄位 |
| `CMat.rows` | root | 欄位 |
| `mat_add` | root | 函數 |
| `mat_adjoint` | root | 函數 |
| `mat_approx_eq` | root | 函數 |
| `mat_commutes` | root | 函數 |
| `mat_from_rows` | root | 函數 |
| `mat_get` | root | 函數 |
| `mat_identity` | root | 函數 |
| `mat_mul` | root | 函數 |
| `mat_sub` | root | 函數 |
| `mat_trace_re` | root | 函數 |
| `mat_vec` | root | 函數 |
| `mat_zero` | root | 函數 |

### 投影與特徵空間

- 規範形式：Σ vₖvₖ†；分解為正交對 (Pv,(I−P)v)
- 範疇化：自伴冪等態射及其在 Hilb 中的分裂（雙積）
- 判定：特徵值方程／正交性／跡整數性

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_commuting` | root | 函數 |
| `check_eigenspace` | root | 函數 |
| `check_orthogonal_roundtrip` | root | 函數 |
| `check_projector` | root | 函數 |
| `commuting_product` | root | 函數 |
| `commuting_projectors_compatible` | root | 函數 |
| `complement` | root | 函數 |
| `decompose` | root | 函數 |
| `eigen_equations_hold` | root | 函數 |
| `eigenspace_kan_sound` | root | 函數 |
| `eigenspace_well_formed` | root | 函數 |
| `in_image` | root | 函數 |
| `in_kernel` | root | 函數 |
| `is_hermitian` | root | 函數 |
| `is_idempotent` | root | 函數 |
| `is_projector` | root | 函數 |
| `outer` | root | 函數 |
| `projector_certificate_ok` | root | 函數 |
| `projector_from_orthonormal` | root | 函數 |
| `prune_to_eigenspace` | root | 函數 |
| `pruning_is_retraction` | root | 函數 |

### Karoubi 包絡

- 規範形式：物件 P；態射被夾緊矩陣 QAP=A
- 範疇化：冪完備化；恒等是 P 本身；dagger
- 判定：QAP=A 與合成律

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_karoubi_category` | root | 函數 |
| `karoubi_comp` | root | 函數 |
| `karoubi_id` | root | 函數 |
| `karoubi_morphism` | root | 函數 |
| `karoubi_wrap` | root | 函數 |

### 區間

- 規範形式：De Morgan 表達式；端點布林化
- 範疇化：De Morgan 代數（區間物件）
- 判定：求值與重寫簡化

| 符號 | 套件 | 類別 |
|---|---|---|
| `Dim` | root | 列舉 |
| `Dim::DAnd` | root | 構造子 |
| `Dim::DNeg` | root | 構造子 |
| `Dim::DOne` | root | 構造子 |
| `Dim::DOr` | root | 構造子 |
| `Dim::DVar` | root | 構造子 |
| `Dim::DZero` | root | 構造子 |
| `Dim::equal` | root | 函數 |
| `Dim::not_equal` | root | 函數 |
| `Dim::to_repr` | root | 函數 |
| `dmax` | root | 函數 |
| `dmin` | root | 函數 |
| `eval_dim` | root | 函數 |
| `eval_dim_bool` | root | 函數 |
| `interval_laws_hold` | root | 函數 |

### 面公式與 BDD

- 規範形式：由 interned DAG 展開的 ROBDD 樹（相容表示）；主判定在同一 manager 以 root 代表
- 範疇化：面格（自由有界分配格的商）的規範代表
- 判定：DAG apply/root 相等判定；樹形 API 為逐公式展開

| 符號 | 套件 | 類別 |
|---|---|---|
| `Bdd` | root | 列舉 |
| `Bdd::BddNode` | root | 構造子 |
| `Bdd::BddOne` | root | 構造子 |
| `Bdd::BddZero` | root | 構造子 |
| `Bdd::equal` | root | 函數 |
| `Bdd::not_equal` | root | 函數 |
| `Bdd::to_repr` | root | 函數 |
| `Face` | root | 列舉 |
| `Face::FAnd` | root | 構造子 |
| `Face::FBot` | root | 構造子 |
| `Face::FEq0` | root | 構造子 |
| `Face::FEq1` | root | 構造子 |
| `Face::FOr` | root | 構造子 |
| `Face::FTop` | root | 構造子 |
| `Face::equal` | root | 函數 |
| `Face::not_equal` | root | 函數 |
| `Face::to_repr` | root | 函數 |
| `assignment_of_mask` | root | 函數 |
| `bdd_and` | root | 函數 |
| `bdd_face_eq` | root | 函數 |
| `bdd_face_le` | root | 函數 |
| `bdd_not` | root | 函數 |
| `bdd_of_face` | root | 函數 |
| `bdd_or` | root | 函數 |
| `bdd_sat_face` | root | 函數 |
| `bdd_satisfying_cubes` | root | 函數 |
| `check_bdd_canonical` | root | 函數 |
| `check_interval_faces` | root | 函數 |
| `contains_int` | root | 函數 |
| `dim_of_face` | root | 函數 |
| `dim_simplify` | root | 函數 |
| `dim_subst` | root | 函數 |
| `face_bound` | root | 函數 |
| `face_eq_decide` | root | 函數 |
| `face_eq_mod` | root | 函數 |
| `face_holds` | root | 函數 |
| `face_join_universal` | root | 函數 |
| `face_le` | root | 函數 |
| `face_maps_commute` | root | 函數 |
| `face_meet_universal` | root | 函數 |
| `face_not` | root | 函數 |
| `face_of_bdd` | root | 函數 |
| `face_sat` | root | 函數 |
| `face_sat_decide` | root | 函數 |
| `face_simplify` | root | 函數 |
| `face_subst` | root | 函數 |
| `face_unsat` | root | 函數 |
| `face_var0` | root | 函數 |
| `face_var1` | root | 函數 |
| `face_vars` | root | 函數 |
| `face_witness` | root | 函數 |
| `pow2` | root | 函數 |
| `sort_ints` | root | 函數 |

### 面偏序範疇

- 規範形式：BDD 等價類
- 範疇化：偏序範疇：∧積、∨餘積、⊤/⊥ 終始
- 判定：bdd_face_le 與萬有性等式

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_face_poset_category` | root | 函數 |

### 系統與剪枝

- 規範形式：分支列；語義範形見系統符號範形
- 範疇化：面上 presheaf 的偏元素；聯集拼接
- 判定：重疊面的 BDD 可滿足性

| 符號 | 套件 | 類別 |
|---|---|---|
| `VecBranch` | root | 結構 |
| `VecBranch.face` | root | 欄位 |
| `VecBranch.value` | root | 欄位 |
| `VecSystem` | root | 結構 |
| `VecSystem.branches` | root | 欄位 |
| `branch` | root | 函數 |
| `check_systems` | root | 函數 |
| `compatibility_respects_quotient` | root | 函數 |
| `prune_system` | root | 函數 |
| `pruning_respects_quotient` | root | 函數 |
| `system_compatible` | root | 函數 |
| `system_domain_bdd` | root | 函數 |
| `system_eq_mod` | root | 函數 |
| `system_eq_mod_sym` | root | 函數 |
| `system_extend_top` | root | 函數 |
| `system_lookup` | root | 函數 |
| `system_normal_form` | root | 函數 |
| `system_of` | root | 函數 |
| `system_union` | root | 函數 |
| `union_commutes_mod` | root | 函數 |

### 系統符號範形

- 規範形式：值標記不交 BDD 分割＋未定義區域
- 範疇化：偏元素在面格切片中的像分解
- 判定：BDD 區域運算

| 符號 | 套件 | 類別 |
|---|---|---|
| `SymRegion` | root | 結構 |
| `SymRegion.region` | root | 欄位 |
| `SymRegion.value` | root | 欄位 |
| `SystemNF` | root | 結構 |
| `SystemNF.classes` | root | 欄位 |
| `SystemNF.undefined` | root | 欄位 |
| `vec_lex_lt` | root | 函數 |

### 立方體與 Kan 填充

- 規範形式：函數 Iⁿ→Cᵐ；填充用仿射公式；帽子為 comp 結果
- 範疇化：□ 上 cubical set 的實現；retract 的 Kan 結構
- 判定：邊界方程（網格）

| 符號 | 套件 | 類別 |
|---|---|---|
| `Cube` | root | 結構 |
| `Cube.cell` | root | 欄位 |
| `Cube.dim` | root | 欄位 |
| `bumped_filler` | root | 函數 |
| `check_cube3_and_moving_hit_comp` | root | 函數 |
| `check_cube_comp` | root | 函數 |
| `check_cubical_identities` | root | 函數 |
| `check_kan_pruning` | root | 函數 |
| `cube_const` | root | 函數 |
| `cube_eval` | root | 函數 |
| `cube_ext_eq` | root | 函數 |
| `cube_in_eigenspace` | root | 函數 |
| `degenerate_cube` | root | 函數 |
| `filler_respects_box` | root | 函數 |
| `kan_comp_eigenspace` | root | 函數 |
| `kan_comp_path` | root | 函數 |
| `kan_fill_eigenspace` | root | 函數 |
| `open_box_wf` | root | 函數 |
| `path_end` | root | 函數 |
| `path_eval` | root | 函數 |
| `path_line` | root | 函數 |
| `path_refl` | root | 函數 |
| `path_start` | root | 函數 |
| `path_sym` | root | 函數 |
| `path_trans` | root | 函數 |
| `path_trans_endpoints` | root | 函數 |
| `prune_cube` | root | 函數 |
| `pruning_repairs_filler` | root | 函數 |
| `restrict_face` | root | 函數 |
| `square_fill` | root | 函數 |

### 未型別 NbE

- 規範形式：βπ 正規形 nf
- 範疇化：句法範疇在 βπ 商下的態射代表
- 判定：eval/quote 後結構比較

| 符號 | 套件 | 類別 |
|---|---|---|
| `Neutral` | root | 列舉 |
| `Neutral::NeApp` | root | 構造子 |
| `Neutral::NeFst` | root | 構造子 |
| `Neutral::NeSnd` | root | 構造子 |
| `Neutral::NeVar` | root | 構造子 |
| `Term` | root | 列舉 |
| `Term::TmAnn` | root | 構造子 |
| `Term::TmApp` | root | 構造子 |
| `Term::TmBool` | root | 構造子 |
| `Term::TmCoeRefl` | root | 構造子 |
| `Term::TmCoeUaSwap` | root | 構造子 |
| `Term::TmFst` | root | 構造子 |
| `Term::TmLam` | root | 構造子 |
| `Term::TmPair` | root | 構造子 |
| `Term::TmSnd` | root | 構造子 |
| `Term::TmUnit` | root | 構造子 |
| `Term::TmVar` | root | 構造子 |
| `Term::equal` | root | 函數 |
| `Term::not_equal` | root | 函數 |
| `Term::to_repr` | root | 函數 |
| `Value` | root | 列舉 |
| `Value::VBool` | root | 構造子 |
| `Value::VClosure` | root | 構造子 |
| `Value::VNeutral` | root | 構造子 |
| `Value::VPair` | root | 構造子 |
| `Value::VUnit` | root | 構造子 |
| `check_nbe` | root | 函數 |
| `coe_rules_definitional` | root | 函數 |
| `def_eq` | root | 函數 |
| `eval` | root | 函數 |
| `eval_check_t` | root | 函數 |
| `eval_decode_term` | root | 函數 |
| `eval_glue_equiv_term` | root | 函數 |
| `eval_inductive_decode` | root | 函數 |
| `eval_infer_t` | root | 函數 |
| `eval_mk_equiv_term` | root | 函數 |
| `eval_mutual_elim` | root | 函數 |
| `eval_ua_term` | root | 函數 |
| `nbe_single_valued` | root | 函數 |
| `nf` | root | 函數 |
| `quote` | root | 函數 |
| `quote_decode_neutral` | root | 函數 |
| `quote_glue_equiv_type` | root | 函數 |
| `quote_neutral` | root | 函數 |
| `quote_schema_args_full` | root | 函數 |
| `swap_involutive_on_element` | root | 函數 |
| `tm_const` | root | 函數 |
| `tm_id` | root | 函數 |
| `tm_swap` | root | 函數 |
| `vapp` | root | 函數 |
| `vfst` | root | 函數 |
| `vsnd` | root | 函數 |

### HOAS

- 規範形式：經 reify 的 de Bruijn 範形
- 範疇化：函子範疇式綁定；與一階語法範疇等價（模定義相等）
- 判定：reflect/reify 往返

| 符號 | 套件 | 類別 |
|---|---|---|
| `HTm` | root | 列舉 |
| `HTm::HApp` | root | 構造子 |
| `HTm::HBool` | root | 構造子 |
| `HTm::HFst` | root | 構造子 |
| `HTm::HLam` | root | 構造子 |
| `HTm::HPair` | root | 構造子 |
| `HTm::HSnd` | root | 構造子 |
| `HTm::HUnit` | root | 構造子 |
| `HTm::HVar` | root | 構造子 |
| `check_hoas` | root | 函數 |
| `happ` | root | 函數 |
| `hfst` | root | 函數 |
| `hoas_const_example` | root | 函數 |
| `hoas_roundtrip_hoas` | root | 函數 |
| `hoas_roundtrip_term` | root | 函數 |
| `hoas_swap_example` | root | 函數 |
| `hoas_to_term` | root | 函數 |
| `hsnd` | root | 函數 |
| `term_to_hoas` | root | 函數 |

### 型別化 NbE 與 η

- 規範形式：η 長 βπ 範形 nf_eta
- 範疇化：自由笛卡兒閉範疇的態射代表
- 判定：雙向檢查＋按型別 quote

| 符號 | 套件 | 類別 |
|---|---|---|
| `LTy` | root | 列舉 |
| `LTy::LBool` | root | 構造子 |
| `LTy::LFun` | root | 構造子 |
| `LTy::LProd` | root | 構造子 |
| `LTy::LUnit` | root | 構造子 |
| `LTy::equal` | root | 函數 |
| `LTy::not_equal` | root | 函數 |
| `LTy::to_repr` | root | 函數 |
| `TNeutral` | root | 列舉 |
| `TNeutral::TNeApp` | root | 構造子 |
| `TNeutral::TNeFst` | root | 構造子 |
| `TNeutral::TNeSnd` | root | 構造子 |
| `TNeutral::TNeVar` | root | 構造子 |
| `TValue` | root | 列舉 |
| `TValue::TVBool` | root | 構造子 |
| `TValue::TVClosure` | root | 構造子 |
| `TValue::TVNeutral` | root | 構造子 |
| `TValue::TVPair` | root | 構造子 |
| `TValue::TVUnit` | root | 構造子 |
| `TypedValue` | root | 結構 |
| `TypedValue.ty` | root | 欄位 |
| `TypedValue.value` | root | 欄位 |
| `check_eta_all` | root | 函數 |
| `check_eta_function` | root | 函數 |
| `check_eta_product` | root | 函數 |
| `check_eta_spine` | root | 函數 |
| `check_eta_swap_involution` | root | 函數 |
| `check_eta_unit` | root | 函數 |
| `def_eq_eta` | root | 函數 |
| `eta_single_valued_on` | root | 函數 |
| `nf_eta` | root | 函數 |
| `quote_eta` | root | 函數 |
| `quote_tneutral` | root | 函數 |
| `tapp` | root | 函數 |
| `tfst` | root | 函數 |
| `tm_coe_swap_at` | root | 函數 |
| `tm_swap_at` | root | 函數 |
| `tsnd` | root | 函數 |
| `ty_check` | root | 函數 |
| `ty_infer` | root | 函數 |

### 依賴型別 NbE（Π/Σ/宇宙）

- 規範形式：按型別 quote 的 η 長依賴正規形；Π/Σ 第二分量為語義閉包族；累積 Typeᵢ 層級
- 範疇化：帶族範疇 (CwF) 模型：脈絡延伸與依賴代入是閉包施用
- 判定：雙向 elaboration＋型別導向轉換；相等=範形相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `DFamilyParts` | root | 結構 |
| `DFamilyParts.dom` | root | 欄位 |
| `DFamilyParts.fam` | root | 欄位 |
| `DInfer` | root | 結構 |
| `DInfer.ty` | root | 欄位 |
| `DInfer.value` | root | 欄位 |
| `DNeutral` | root | 列舉 |
| `DNeutral::DNApp` | root | 構造子 |
| `DNeutral::DNAppDim` | root | 構造子 |
| `DNeutral::DNBoolElim` | root | 構造子 |
| `DNeutral::DNCircleElim` | root | 構造子 |
| `DNeutral::DNComp` | root | 構造子 |
| `DNeutral::DNDecode` | root | 構造子 |
| `DNeutral::DNEquivBwd` | root | 構造子 |
| `DNeutral::DNEquivFwd` | root | 構造子 |
| `DNeutral::DNEquivRetr` | root | 構造子 |
| `DNeutral::DNEquivSect` | root | 構造子 |
| `DNeutral::DNFst` | root | 構造子 |
| `DNeutral::DNHComp` | root | 構造子 |
| `DNeutral::DNHitElim` | root | 構造子 |
| `DNeutral::DNInductiveElim` | root | 構造子 |
| `DNeutral::DNListElim` | root | 構造子 |
| `DNeutral::DNNatElim` | root | 構造子 |
| `DNeutral::DNSnd` | root | 構造子 |
| `DNeutral::DNTorusElim` | root | 構造子 |
| `DNeutral::DNVar` | root | 構造子 |
| `DTerm` | root | 列舉 |
| `DTerm::DAnn` | root | 構造子 |
| `DTerm::DApp` | root | 構造子 |
| `DTerm::DAppDim` | root | 構造子 |
| `DTerm::DBoolElim` | root | 構造子 |
| `DTerm::DBoolLit` | root | 構造子 |
| `DTerm::DBoolTy` | root | 構造子 |
| `DTerm::DCircleBase` | root | 構造子 |
| `DTerm::DCircleElim` | root | 構造子 |
| `DTerm::DCircleLoop` | root | 構造子 |
| `DTerm::DCircleTy` | root | 構造子 |
| `DTerm::DCoe` | root | 構造子 |
| `DTerm::DComp` | root | 構造子 |
| `DTerm::DCons` | root | 構造子 |
| `DTerm::DDecode` | root | 構造子 |
| `DTerm::DEquivBwd` | root | 構造子 |
| `DTerm::DEquivFwd` | root | 構造子 |
| `DTerm::DEquivRetr` | root | 構造子 |
| `DTerm::DEquivSect` | root | 構造子 |
| `DTerm::DEquivTy` | root | 構造子 |
| `DTerm::DFst` | root | 構造子 |
| `DTerm::DGlueEquiv` | root | 構造子 |
| `DTerm::DHComp` | root | 構造子 |
| `DTerm::DHFill` | root | 構造子 |
| `DTerm::DHitElim` | root | 構造子 |
| `DTerm::DHitIntro` | root | 構造子 |
| `DTerm::DHitType` | root | 構造子 |
| `DTerm::DInductive` | root | 構造子 |
| `DTerm::DInductiveElim` | root | 構造子 |
| `DTerm::DIntro` | root | 構造子 |
| `DTerm::DLam` | root | 構造子 |
| `DTerm::DLamDim` | root | 構造子 |
| `DTerm::DListElim` | root | 構造子 |
| `DTerm::DListTy` | root | 構造子 |
| `DTerm::DMkEquiv` | root | 構造子 |
| `DTerm::DNatElim` | root | 構造子 |
| `DTerm::DNatTy` | root | 構造子 |
| `DTerm::DNatZero` | root | 構造子 |
| `DTerm::DNil` | root | 構造子 |
| `DTerm::DPair` | root | 構造子 |
| `DTerm::DPartial` | root | 構造子 |
| `DTerm::DPath` | root | 構造子 |
| `DTerm::DPathP` | root | 構造子 |
| `DTerm::DPi` | root | 構造子 |
| `DTerm::DSigma` | root | 構造子 |
| `DTerm::DSnd` | root | 構造子 |
| `DTerm::DSucc` | root | 構造子 |
| `DTerm::DTVar` | root | 構造子 |
| `DTerm::DTorusBase` | root | 構造子 |
| `DTerm::DTorusElim` | root | 構造子 |
| `DTerm::DTorusLoopA` | root | 構造子 |
| `DTerm::DTorusLoopB` | root | 構造子 |
| `DTerm::DTorusSquare` | root | 構造子 |
| `DTerm::DTorusTy` | root | 構造子 |
| `DTerm::DUa` | root | 構造子 |
| `DTerm::DUnitLit` | root | 構造子 |
| `DTerm::DUnitTy` | root | 構造子 |
| `DTerm::DUniv` | root | 構造子 |
| `DTerm::DUnivLevel` | root | 構造子 |
| `DTerm::equal` | root | 函數 |
| `DTerm::not_equal` | root | 函數 |
| `DTerm::to_repr` | root | 函數 |
| `DTypeVal` | root | 結構 |
| `DTypeVal.level` | root | 欄位 |
| `DTypeVal.value` | root | 欄位 |
| `DValue` | root | 列舉 |
| `DValue::DVBool` | root | 構造子 |
| `DValue::DVBoolTy` | root | 構造子 |
| `DValue::DVCirclePoint` | root | 構造子 |
| `DValue::DVCircleTy` | root | 構造子 |
| `DValue::DVCons` | root | 構造子 |
| `DValue::DVEquiv` | root | 構造子 |
| `DValue::DVEquivTy` | root | 構造子 |
| `DValue::DVGlue` | root | 構造子 |
| `DValue::DVGlueEquiv` | root | 構造子 |
| `DValue::DVHitCell` | root | 構造子 |
| `DValue::DVHitType` | root | 構造子 |
| `DValue::DVInductive` | root | 構造子 |
| `DValue::DVIntro` | root | 構造子 |
| `DValue::DVLam` | root | 構造子 |
| `DValue::DVListTy` | root | 構造子 |
| `DValue::DVNatTy` | root | 構造子 |
| `DValue::DVNeutral` | root | 構造子 |
| `DValue::DVNil` | root | 構造子 |
| `DValue::DVPair` | root | 構造子 |
| `DValue::DVPartial` | root | 構造子 |
| `DValue::DVPathLam` | root | 構造子 |
| `DValue::DVPathTy` | root | 構造子 |
| `DValue::DVPi` | root | 構造子 |
| `DValue::DVSigma` | root | 構造子 |
| `DValue::DVSucc` | root | 構造子 |
| `DValue::DVThunk` | root | 構造子 |
| `DValue::DVTorusPoint` | root | 構造子 |
| `DValue::DVTorusTy` | root | 構造子 |
| `DValue::DVUnit` | root | 構造子 |
| `DValue::DVUnitTy` | root | 構造子 |
| `DValue::DVUniv` | root | 構造子 |
| `DValue::DVZeroNat` | root | 構造子 |
| `as_pi` | root | 函數 |
| `as_sigma` | root | 函數 |
| `as_univ_level` | root | 函數 |
| `check_dep_all` | root | 函數 |
| `check_dep_pi` | root | 函數 |
| `check_dep_sigma` | root | 函數 |
| `check_dep_universe` | root | 函數 |
| `conv_at` | root | 函數 |
| `conv_neutral` | root | 函數 |
| `conv_ty` | root | 函數 |
| `d_as_type` | root | 函數 |
| `d_check` | root | 函數 |
| `d_infer` | root | 函數 |
| `dapp_typed` | root | 函數 |
| `dep_check_closed` | root | 函數 |
| `dep_id_term` | root | 函數 |
| `dep_id_type` | root | 函數 |
| `dep_nf_closed` | root | 函數 |
| `dep_type_of_closed` | root | 函數 |
| `dep_type_val_of` | root | 函數 |
| `deval` | root | 函數 |
| `dfst_typed` | root | 函數 |
| `dsnd_typed` | root | 函數 |
| `lty_to_dterm` | root | 函數 |
| `quote_at` | root | 函數 |
| `quote_dneutral` | root | 函數 |
| `quote_ty` | root | 函數 |

### 立方 AST 與維度 NbE

- 規範形式：DTerm 的項/維度雙 de Bruijn 索引；線與 tube body；帶 dlevel 的 quote
- 範疇化：帶區間脈絡的 cubical CwF；PathP 為依賴路徑物件，Glue 值為 (raw/DPartial partial,base) 對
- 判定：雙向檢查＋Dim/Face 簡化及 ROBDD 語義謂詞

| 符號 | 套件 | 類別 |
|---|---|---|
| `DGlueParts` | root | 結構 |
| `DGlueParts.base` | root | 欄位 |
| `DGlueParts.face` | root | 欄位 |
| `DGlueParts.level` | root | 欄位 |
| `DGlueParts.line` | root | 欄位 |
| `DGlueParts.system` | root | 欄位 |
| `DPathParts` | root | 結構 |
| `DPathParts.left` | root | 欄位 |
| `DPathParts.line` | root | 欄位 |
| `DPathParts.right` | root | 欄位 |
| `DTubeTerm` | root | 結構 |
| `DTubeTerm.body` | root | 欄位 |
| `DTubeTerm.face` | root | 欄位 |
| `DTubeTerm::equal` | root | 函數 |
| `DTubeTerm::not_equal` | root | 函數 |
| `DTubeTerm::to_repr` | root | 函數 |
| `as_glue` | root | 函數 |
| `as_list_elem` | root | 函數 |
| `as_path` | root | 函數 |
| `check_ast_paths` | root | 函數 |
| `d_tube` | root | 函數 |
| `dapp_dim` | root | 函數 |
| `dep_def_eq_closed` | root | 函數 |
| `deval_dim` | root | 函數 |
| `dim_quote` | root | 函數 |
| `eval_dim_expr` | root | 函數 |
| `eval_tube_terms` | root | 函數 |
| `face_eval_env` | root | 函數 |
| `face_quote` | root | 函數 |
| `fresh_dim` | root | 函數 |
| `quote_tube_branches` | root | 函數 |

### AST Kan comp/hcomp

- 規範形式：分支一律攜帶為 DSystem；在一般維度按型別頭派遣；頂分支取帽、形式合成為 DNComp/DNHComp
- 範疇化：各型別構造子保存 Kan 纖維化結構；hcompU 是 Glue 黏合
- 判定：系統 base/重疊相容＋型別遞迴；coe/fill 為 comp 線段限制

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_ast_coe_terms` | root | 函數 |
| `check_ast_hcomp_data_terms` | root | 函數 |
| `check_ast_hcomp_hit_terms` | root | 函數 |
| `check_ast_hcomp_sigma_path_terms` | root | 函數 |
| `check_ast_hcomp_univ_term` | root | 函數 |
| `check_ast_kan_all` | root | 函數 |
| `check_ast_kan_terms` | root | 函數 |
| `check_ast_kan_types` | root | 函數 |
| `check_circle_torus_point_comp` | root | 函數 |
| `coe_value` | root | 函數 |
| `comp_glue_value` | root | 函數 |
| `comp_path_value` | root | 函數 |
| `comp_pi_value` | root | 函數 |
| `comp_sigma_value` | root | 函數 |
| `comp_univ_value` | root | 函數 |
| `comp_value` | root | 函數 |
| `dim_eq_sem` | root | 函數 |
| `dim_nvars_sem` | root | 函數 |
| `dim_vars_of` | root | 函數 |
| `face_is_bot_sem` | root | 函數 |
| `face_is_sat_sem` | root | 函數 |
| `face_is_top_sem` | root | 函數 |
| `face_nvars_sem` | root | 函數 |
| `fill_value` | root | 函數 |
| `hcomp_univ_value` | root | 函數 |
| `hcomp_value` | root | 函數 |
| `hfill_value` | root | 函數 |

### 資料型別與 HIT 消去

- 規範形式：Nat/List 構造子遞迴；Circle loop@r；Torus square@(i,j) 模對邊等同
- 範疇化：初始代數與 HIT 的依賴消去是 motive 截面，並與形式 composition 交換
- 判定：構造子模式遞迴、Dim 語義相等、motive 中的 comp

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_ast_bool_elim` | root | 函數 |
| `check_ast_data` | root | 函數 |
| `check_ast_hits` | root | 函數 |
| `check_ast_list_len` | root | 函數 |
| `check_ast_nat_dep` | root | 函數 |
| `check_ast_nat_pred` | root | 函數 |
| `circle_dim_of` | root | 函數 |
| `circle_point` | root | 函數 |
| `comp_bool_value` | root | 函數 |
| `comp_circle_value` | root | 函數 |
| `comp_list_value` | root | 函數 |
| `comp_nat_value` | root | 函數 |
| `comp_torus_value` | root | 函數 |
| `d_nat_lit` | root | 函數 |
| `dv_nat_lit` | root | 函數 |
| `eval_bool_elim` | root | 函數 |
| `eval_circle_elim` | root | 函數 |
| `eval_list_elim` | root | 函數 |
| `eval_nat_elim` | root | 函數 |
| `eval_torus_elim` | root | 函數 |
| `torus_dims_of` | root | 函數 |
| `torus_point` | root | 函數 |

### 持久環境、惰性與語義快取

- 規範形式：帶長度持久連結串列 DEnv/DDimEnv（de Bruijn 頭在最內）；DVThunk 最多強制一次；快取鍵為簡化維度/引文項 Debug 鍵；DTerm 全域 hash-consing 以子項 stamp 自底向上建立 intern 表，結構相等子項共享同一 intern id 而重建後項結構相等
- 範疇化：CwF 脈絡延伸是共享尾部的 cons；惰性值是 call-by-need 語義值，memoized 族/維度線是外延函數的有限圖延伸
- 判定：環境索引、force_count 與快取鍵相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `DDimEnv` | root | 列舉 |
| `DDimEnv::DDimEnvCons` | root | 構造子 |
| `DDimEnv::DDimEnvNil` | root | 構造子 |
| `DEnv` | root | 列舉 |
| `DEnv::DEnvCons` | root | 構造子 |
| `DEnv::DEnvNil` | root | 構造子 |
| `DTermInternTable` | root | 結構 |
| `DTermInternTable.ids` | root | 欄位 |
| `DTermInternTable.terms` | root | 欄位 |
| `DThunk` | root | 結構 |
| `DThunk.compute` | root | 欄位 |
| `DThunk.force_count` | root | 欄位 |
| `DThunk.forced` | root | 欄位 |
| `check_dterm_hash_consing` | root | 函數 |
| `check_persistent_env_lazy_cache` | root | 函數 |
| `ddim_at` | root | 函數 |
| `ddim_cons` | root | 函數 |
| `ddim_empty` | root | 函數 |
| `ddim_extend` | root | 函數 |
| `ddim_from_array` | root | 函數 |
| `ddim_len` | root | 函數 |
| `ddim_to_array` | root | 函數 |
| `denv_at` | root | 函數 |
| `denv_cons` | root | 函數 |
| `denv_empty` | root | 函數 |
| `denv_extend` | root | 函數 |
| `denv_from_array` | root | 函數 |
| `denv_len` | root | 函數 |
| `denv_tail` | root | 函數 |
| `denv_to_array` | root | 函數 |
| `dim_cache_key` | root | 函數 |
| `dterm_cache_key` | root | 函數 |
| `dterm_distinct_subterm_count` | root | 函數 |
| `dterm_intern` | root | 函數 |
| `dterm_intern_all` | root | 函數 |
| `dterm_intern_id` | root | 函數 |
| `dterm_intern_table_new` | root | 函數 |
| `dterm_intern_table_size` | root | 函數 |
| `dterm_local_stamp` | root | 函數 |
| `dterm_rebuild` | root | 函數 |
| `dterm_sharing_ratio` | root | 函數 |
| `dterm_tree_node_count` | root | 函數 |
| `force_value` | root | 函數 |
| `lazy_deval` | root | 函數 |
| `lazy_force_count` | root | 函數 |
| `lazy_is_forced` | root | 函數 |
| `lazy_value` | root | 函數 |
| `memo_dim_line` | root | 函數 |
| `memo_family` | root | 函數 |

### 依賴語義系統與 partial 值

- 規範形式：DSystem 分支去 ⊥、按值合併同 body 並以引文排序；DPartialValue 的 BDD 有效區域分割 DSystemNF
- 範疇化：面格切片中的偏元素；多分支 Glue 為 partial type 系統與 base 的極限式配對
- 判定：BDD 區域運算＋分支 body 的型別導向轉換/引文鍵

| 符號 | 套件 | 類別 |
|---|---|---|
| `DFaceTerm` | root | 結構 |
| `DFaceTerm.body` | root | 欄位 |
| `DFaceTerm.face` | root | 欄位 |
| `DFaceTerm::equal` | root | 函數 |
| `DFaceTerm::not_equal` | root | 函數 |
| `DFaceTerm::to_repr` | root | 函數 |
| `DFaceValue` | root | 結構 |
| `DFaceValue.face` | root | 欄位 |
| `DFaceValue.value` | root | 欄位 |
| `DPartialValue` | root | 結構 |
| `DPartialValue.branches` | root | 欄位 |
| `DSystem` | root | 結構 |
| `DSystem.branches` | root | 欄位 |
| `DSystemClass` | root | 結構 |
| `DSystemClass.region` | root | 欄位 |
| `DSystemClass.value` | root | 欄位 |
| `DSystemNF` | root | 結構 |
| `DSystemNF.classes` | root | 欄位 |
| `DSystemNF.undefined` | root | 欄位 |
| `DTubeBranch` | root | 結構 |
| `DTubeBranch.face` | root | 欄位 |
| `DTubeBranch.path` | root | 欄位 |
| `check_dsystem_canonical_partial_nf` | root | 函數 |
| `check_multibranch_glue_partial` | root | 函數 |
| `check_phase5_semantic_systems` | root | 函數 |
| `d_face_term` | root | 函數 |
| `dface_value` | root | 函數 |
| `dsystem_canonical` | root | 函數 |
| `dsystem_checked` | root | 函數 |
| `dsystem_checked_of` | root | 函數 |
| `dsystem_compatibility` | root | 函數 |
| `dsystem_compatibility_report` | root | 函數 |
| `dsystem_compatible_with_base` | root | 函數 |
| `dsystem_domain_face` | root | 函數 |
| `dsystem_empty` | root | 函數 |
| `dsystem_first_match_checked` | root | 函數 |
| `dsystem_first_match_eq` | root | 函數 |
| `dsystem_first_match_normal_form` | root | 函數 |
| `dsystem_first_match_system` | root | 函數 |
| `dsystem_first_path` | root | 函數 |
| `dsystem_map` | root | 函數 |
| `dsystem_of` | root | 函數 |
| `dsystem_of_first_match_nf` | root | 函數 |
| `dsystem_pairwise_compatible` | root | 函數 |
| `dsystem_repair_to_base` | root | 函數 |
| `dsystem_repair_to_base_exact` | root | 函數 |
| `dsystem_singleton` | root | 函數 |
| `glue_partial_values` | root | 函數 |
| `glue_store_partial` | root | 函數 |
| `map_branches` | root | 函數 |
| `partial_domain_bdd` | root | 函數 |
| `partial_empty` | root | 函數 |
| `partial_eq_at` | root | 函數 |
| `partial_normal_form` | root | 函數 |
| `partial_of` | root | 函數 |
| `partial_singleton` | root | 函數 |
| `tube_branch` | root | 函數 |
| `tube_system_nf_at` | root | 函數 |

### 通用歸納族 schema

- 規範形式：telescope＋完整 DTerm 引數型別（外部、直接/巢狀/函數遞迴與約束）；值為 DVIntro，中性消去按生成 case 型別引文
- 範疇化：結構化嚴格正性函子的依賴初始代數；消去子是 motive 截面，comp 沿先前引數 filler 遞迴
- 判定：schema 結構相等、telescope elaboration、極性正性判定與生成檢查

| 符號 | 套件 | 類別 |
|---|---|---|
| `DArgKind` | root | 列舉 |
| `DArgKind::DArgDecoded` | root | 構造子 |
| `DArgKind::DArgDecodedFunction` | root | 構造子 |
| `DArgKind::DArgExternal` | root | 構造子 |
| `DArgKind::DArgFunction` | root | 構造子 |
| `DArgKind::DArgNested` | root | 構造子 |
| `DArgKind::DArgRecursive` | root | 構造子 |
| `DArgKind::equal` | root | 函數 |
| `DArgKind::not_equal` | root | 函數 |
| `DArgKind::to_repr` | root | 函數 |
| `DConstructorArg` | root | 結構 |
| `DConstructorArg.index` | root | 欄位 |
| `DConstructorArg.kind` | root | 欄位 |
| `DConstructorArg.name` | root | 欄位 |
| `DConstructorArg.nested` | root | 欄位 |
| `DConstructorArg.target` | root | 欄位 |
| `DConstructorArg.ty` | root | 欄位 |
| `DConstructorArg::equal` | root | 函數 |
| `DConstructorArg::not_equal` | root | 函數 |
| `DConstructorArg::to_repr` | root | 函數 |
| `DConstructorSpec` | root | 結構 |
| `DConstructorSpec.args` | root | 欄位 |
| `DConstructorSpec.constraints` | root | 欄位 |
| `DConstructorSpec.name` | root | 欄位 |
| `DConstructorSpec.result_index` | root | 欄位 |
| `DConstructorSpec::equal` | root | 函數 |
| `DConstructorSpec::not_equal` | root | 函數 |
| `DConstructorSpec::to_repr` | root | 函數 |
| `DInductiveSpec` | root | 結構 |
| `DInductiveSpec.constructors` | root | 欄位 |
| `DInductiveSpec.decode_cases` | root | 欄位 |
| `DInductiveSpec.decode_level` | root | 欄位 |
| `DInductiveSpec.indices` | root | 欄位 |
| `DInductiveSpec.level` | root | 欄位 |
| `DInductiveSpec.name` | root | 欄位 |
| `DInductiveSpec.params` | root | 欄位 |
| `DInductiveSpec::equal` | root | 函數 |
| `DInductiveSpec::not_equal` | root | 函數 |
| `DInductiveSpec::to_repr` | root | 函數 |
| `DTelescopeEntry` | root | 結構 |
| `DTelescopeEntry.name` | root | 欄位 |
| `DTelescopeEntry.ty` | root | 欄位 |
| `DTelescopeEntry::equal` | root | 函數 |
| `DTelescopeEntry::not_equal` | root | 函數 |
| `DTelescopeEntry::to_repr` | root | 函數 |
| `bool_schema` | root | 函數 |
| `check_generated_inductive_schemas` | root | 函數 |
| `check_schema_indexed` | root | 函數 |
| `check_schema_inductive_comp` | root | 函數 |
| `check_schema_list` | root | 函數 |
| `check_schema_nat_add` | root | 函數 |
| `check_schema_nat_neutral_quote` | root | 函數 |
| `check_schema_tree` | root | 函數 |
| `check_schema_validation` | root | 函數 |
| `check_schema_vec_comp` | root | 函數 |
| `check_schema_w` | root | 函數 |
| `check_telescope_terms` | root | 函數 |
| `comp_inductive_value` | root | 函數 |
| `comp_schema_args` | root | 函數 |
| `conv_inductive_elim_neutral` | root | 函數 |
| `conv_inductive_type` | root | 函數 |
| `conv_intro_at` | root | 函數 |
| `conv_schema_args` | root | 函數 |
| `conv_telescope_values` | root | 函數 |
| `darg_decoded` | root | 函數 |
| `darg_decoded_function` | root | 函數 |
| `darg_external` | root | 函數 |
| `darg_function` | root | 函數 |
| `darg_mutual` | root | 函數 |
| `darg_mutual_function` | root | 函數 |
| `darg_nested` | root | 函數 |
| `darg_recursive` | root | 函數 |
| `dconstructor_constraint` | root | 函數 |
| `dconstructor_spec` | root | 函數 |
| `dconstructor_spec_constrained` | root | 函數 |
| `dinductive_level_scheme` | root | 函數 |
| `dinductive_recursive_spec` | root | 函數 |
| `dinductive_spec` | root | 函數 |
| `dtelescope_entry` | root | 函數 |
| `eval_inductive_elim` | root | 函數 |
| `eval_inductive_elim_term` | root | 函數 |
| `eval_inductive_type_term` | root | 函數 |
| `eval_intro_term` | root | 函數 |
| `fin_schema` | root | 函數 |
| `inductive_arg_type` | root | 函數 |
| `inductive_arg_type_full` | root | 函數 |
| `inductive_case_type` | root | 函數 |
| `inductive_decode_cases_validate` | root | 函數 |
| `inductive_index_types` | root | 函數 |
| `inductive_index_types_cached` | root | 函數 |
| `inductive_motive_type` | root | 函數 |
| `inductive_param_types` | root | 函數 |
| `inductive_param_types_cached` | root | 函數 |
| `inductive_parameter_positivity` | root | 函數 |
| `inductive_plan_type_term` | root | 函數 |
| `inductive_result_indices` | root | 函數 |
| `inductive_schema_key` | root | 函數 |
| `inductive_schema_validate` | root | 函數 |
| `infer_inductive_elim` | root | 函數 |
| `infer_inductive_type` | root | 函數 |
| `infer_intro` | root | 函數 |
| `list_schema` | root | 函數 |
| `nat_schema` | root | 函數 |
| `nat_schema_lit` | root | 函數 |
| `quote_inductive_elim_neutral` | root | 函數 |
| `quote_inductive_type` | root | 函數 |
| `quote_intro_at` | root | 函數 |
| `quote_schema_args` | root | 函數 |
| `quote_schema_motive` | root | 函數 |
| `quote_telescope_values` | root | 函數 |
| `schema_apply_constraint_proofs` | root | 函數 |
| `schema_arg_spec_prefix` | root | 函數 |
| `schema_arg_type` | root | 函數 |
| `schema_arg_type_full` | root | 函數 |
| `schema_concat_values` | root | 函數 |
| `schema_constraint_parts` | root | 函數 |
| `schema_constraints_hold` | root | 函數 |
| `schema_constraints_pi` | root | 函數 |
| `schema_elim_term` | root | 函數 |
| `schema_examples` | root | 函數 |
| `schema_expected_param_terms` | root | 函數 |
| `schema_intro_term` | root | 函數 |
| `schema_motives_conv` | root | 函數 |
| `schema_registry_binary_format_version` | root | 函數 |
| `schema_registry_binary_from_hex` | root | 函數 |
| `schema_registry_binary_roundtrip_ok` | root | 函數 |
| `schema_registry_binary_to_hex` | root | 函數 |
| `schema_registry_from_binary` | root | 函數 |
| `schema_registry_hit_by_id` | root | 函數 |
| `schema_registry_hit_by_name` | root | 函數 |
| `schema_registry_hit_plan` | root | 函數 |
| `schema_registry_inductive_by_id` | root | 函數 |
| `schema_registry_inductive_by_name` | root | 函數 |
| `schema_registry_inductive_plan` | root | 函數 |
| `schema_registry_manifest` | root | 函數 |
| `schema_registry_merge_into` | root | 函數 |
| `schema_registry_new` | root | 函數 |
| `schema_registry_register_hit` | root | 函數 |
| `schema_registry_register_inductive` | root | 函數 |
| `schema_registry_register_inductives` | root | 函數 |
| `schema_registry_restore` | root | 函數 |
| `schema_registry_snapshot` | root | 函數 |
| `schema_registry_snapshot_from_binary` | root | 函數 |
| `schema_registry_snapshot_load_binary_report` | root | 函數 |
| `schema_registry_snapshot_to_binary` | root | 函數 |
| `schema_registry_stats` | root | 函數 |
| `schema_registry_to_binary` | root | 函數 |
| `schema_registry_validate_hit` | root | 函數 |
| `schema_registry_validate_inductive` | root | 函數 |
| `schema_telescope_family_occurs` | root | 函數 |
| `schema_type_term` | root | 函數 |
| `schema_value_prefix` | root | 函數 |
| `telescope_next_type` | root | 函數 |
| `telescope_type_values` | root | 函數 |
| `telescope_type_values_cached` | root | 函數 |
| `tree_schema` | root | 函數 |
| `vec_schema` | root | 函數 |
| `w_schema` | root | 函數 |

### 通用 HIT schema

- 規範形式：任意有限維 cell；任一端點按 face expression 逐維化簡；case 為逐維巢狀 PathP
- 範疇化：帶 face 映射的胞腔型高階初始代數；消去子保存各維 cells
- 判定：face 引數/索引檢查、多維角落雙路化簡轉換與維度語義相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `DHitCellSpec` | root | 結構 |
| `DHitCellSpec.args` | root | 欄位 |
| `DHitCellSpec.constraints` | root | 欄位 |
| `DHitCellSpec.dim_count` | root | 欄位 |
| `DHitCellSpec.faces` | root | 欄位 |
| `DHitCellSpec.name` | root | 欄位 |
| `DHitCellSpec.result_index` | root | 欄位 |
| `DHitCellSpec::equal` | root | 函數 |
| `DHitCellSpec::not_equal` | root | 函數 |
| `DHitCellSpec::to_repr` | root | 函數 |
| `DHitFaceExpr` | root | 結構 |
| `DHitFaceExpr.args` | root | 欄位 |
| `DHitFaceExpr.cell` | root | 欄位 |
| `DHitFaceExpr.dims` | root | 欄位 |
| `DHitFaceExpr::equal` | root | 函數 |
| `DHitFaceExpr::not_equal` | root | 函數 |
| `DHitFaceExpr::to_repr` | root | 函數 |
| `DHitSpec` | root | 結構 |
| `DHitSpec.cells` | root | 欄位 |
| `DHitSpec.indices` | root | 欄位 |
| `DHitSpec.level` | root | 欄位 |
| `DHitSpec.name` | root | 欄位 |
| `DHitSpec.params` | root | 欄位 |
| `DHitSpec::equal` | root | 函數 |
| `DHitSpec::not_equal` | root | 函數 |
| `DHitSpec::to_repr` | root | 函數 |
| `check_generated_hit_schemas` | root | 函數 |
| `check_hit_endpoint_conversion` | root | 函數 |
| `check_hit_schema_arguments` | root | 函數 |
| `check_hit_schema_circle_segment` | root | 函數 |
| `check_hit_schema_torus_comp` | root | 函數 |
| `check_hit_schema_validation` | root | 函數 |
| `circle_schema` | root | 函數 |
| `comp_hit_value` | root | 函數 |
| `conv_hit_cell_at` | root | 函數 |
| `conv_hit_elim_neutral` | root | 函數 |
| `conv_hit_type` | root | 函數 |
| `dhit_arg_face` | root | 函數 |
| `dhit_cell_spec` | root | 函數 |
| `dhit_face` | root | 函數 |
| `dhit_level_scheme` | root | 函數 |
| `dhit_spec` | root | 函數 |
| `eval_hit_elim` | root | 函數 |
| `eval_hit_elim_term` | root | 函數 |
| `eval_hit_intro_term` | root | 函數 |
| `eval_hit_type_term` | root | 函數 |
| `hit_arg_type` | root | 函數 |
| `hit_case_type` | root | 函數 |
| `hit_cell_result_indices` | root | 函數 |
| `hit_cell_value` | root | 函數 |
| `hit_elim_term` | root | 函數 |
| `hit_index_types` | root | 函數 |
| `hit_index_types_cached` | root | 函數 |
| `hit_intro_term` | root | 函數 |
| `hit_motive_type` | root | 函數 |
| `hit_param_types` | root | 函數 |
| `hit_param_types_cached` | root | 函數 |
| `hit_parameter_positivity` | root | 函數 |
| `hit_plan_type_term` | root | 函數 |
| `hit_result_indices` | root | 函數 |
| `hit_schema_examples` | root | 函數 |
| `hit_schema_key` | root | 函數 |
| `hit_schema_validate` | root | 函數 |
| `hit_type_term` | root | 函數 |
| `infer_hit_elim` | root | 函數 |
| `infer_hit_intro` | root | 函數 |
| `infer_hit_type` | root | 函數 |
| `quote_hit_cell_at` | root | 函數 |
| `quote_hit_elim_neutral` | root | 函數 |
| `quote_hit_type` | root | 函數 |
| `segment_schema` | root | 函數 |
| `torus_schema` | root | 函數 |

### 依賴 Kan 線（coe/comp）

- 規範形式：DLine{at, coe, fill}，comp=fill(1)；coe 在 Π 定義域反向、在 Σ 沿第一分量路徑
- 範疇化：型別即 Kan 纖維化結構；依賴族為 (路徑)→DLine；與子空間/Glue 線共同覆蓋全型別族
- 判定：按型別構造子遞迴；coe(r,r) 定義恆等

| 符號 | 套件 | 類別 |
|---|---|---|
| `DLine` | root | 結構 |
| `DLine.at` | root | 欄位 |
| `DLine.coe_fn` | root | 欄位 |
| `DLine.fill_fn` | root | 欄位 |
| `check_dline_dimension_substitution` | root | 函數 |
| `check_kan_all_types` | root | 函數 |
| `check_kan_coe_dependent` | root | 函數 |
| `check_kan_coe_pi_sigma` | root | 函數 |
| `check_kan_comp_tube` | root | 函數 |
| `check_kan_dep_all` | root | 函數 |
| `check_kan_embeddings` | root | 函數 |
| `dbool_not` | root | 函數 |
| `dcoe` | root | 函數 |
| `dcomp` | root | 函數 |
| `dfill` | root | 函數 |
| `dline_at` | root | 函數 |
| `dline_bool` | root | 函數 |
| `dline_bool_not_ua` | root | 函數 |
| `dline_const` | root | 函數 |
| `dline_from_maps` | root | 函數 |
| `dline_of_lty` | root | 函數 |
| `dline_of_ty` | root | 函數 |
| `dline_of_upath` | root | 函數 |
| `dline_pi` | root | 函數 |
| `dline_pi_constfam` | root | 函數 |
| `dline_rev` | root | 函數 |
| `dline_sigma` | root | 函數 |
| `dline_sigma_constfam` | root | 函數 |
| `dline_subst` | root | 函數 |
| `dline_unit` | root | 函數 |
| `dline_univ` | root | 函數 |
| `dvalue_of_ty` | root | 函數 |
| `dvalue_subst_dims` | root | 函數 |
| `dvalue_to_pval` | root | 函數 |
| `path_from` | root | 函數 |

### 精確符號代數

- 規範形式：Q 上多變量多項式規範形（合併去零排序）；分式；複符號量 (re,im)
- 範疇化：多項式戒與分式體承載矩陣代數；共軛為對合
- 判定：多項式恆等／分式交叉相乘（精確）

| 符號 | 套件 | 類別 |
|---|---|---|
| `Poly` | algebra | 結構 |
| `Poly.terms` | algebra | 欄位 |
| `PolyTerm` | algebra | 結構 |
| `PolyTerm.coeff` | algebra | 欄位 |
| `PolyTerm.exps` | algebra | 欄位 |
| `Rat` | algebra | 結構 |
| `Rat.den` | algebra | 欄位 |
| `Rat.num` | algebra | 欄位 |
| `Rat::equal` | algebra | 函數 |
| `Rat::not_equal` | algebra | 函數 |
| `Rat::to_repr` | algebra | 函數 |
| `SymC` | algebra | 結構 |
| `SymC.im` | algebra | 欄位 |
| `SymC.re` | algebra | 欄位 |
| `SymFrac` | algebra | 結構 |
| `SymFrac.den` | algebra | 欄位 |
| `SymFrac.num` | algebra | 欄位 |
| `SymMat` | algebra | 結構 |
| `SymMat.n` | algebra | 欄位 |
| `SymMat.rows` | algebra | 欄位 |
| `SymVec` | algebra | 型別別名 |
| `UPoly` | algebra | 結構 |
| `UPoly.coeffs` | algebra | 欄位 |
| `charpoly_sym` | algebra | 函數 |
| `frac_add` | algebra | 函數 |
| `frac_div` | algebra | 函數 |
| `frac_eq` | algebra | 函數 |
| `frac_int` | algebra | 函數 |
| `frac_is_zero` | algebra | 函數 |
| `frac_make` | algebra | 函數 |
| `frac_mul` | algebra | 函數 |
| `frac_neg` | algebra | 函數 |
| `frac_one` | algebra | 函數 |
| `frac_poly` | algebra | 函數 |
| `frac_rat` | algebra | 函數 |
| `frac_sub` | algebra | 函數 |
| `frac_var` | algebra | 函數 |
| `frac_zero` | algebra | 函數 |
| `int_abs` | algebra | 函數 |
| `int_gcd` | algebra | 函數 |
| `poly_add` | algebra | 函數 |
| `poly_const` | algebra | 函數 |
| `poly_drop_atom` | algebra | 函數 |
| `poly_eq` | algebra | 函數 |
| `poly_eval_point` | algebra | 函數 |
| `poly_eval_var` | algebra | 函數 |
| `poly_insert_atom` | algebra | 函數 |
| `poly_int` | algebra | 函數 |
| `poly_is_zero` | algebra | 函數 |
| `poly_mul` | algebra | 函數 |
| `poly_neg` | algebra | 函數 |
| `poly_normalize` | algebra | 函數 |
| `poly_one` | algebra | 函數 |
| `poly_open_box` | algebra | 函數 |
| `poly_scale` | algebra | 函數 |
| `poly_sub` | algebra | 函數 |
| `poly_subst_all` | algebra | 函數 |
| `poly_var` | algebra | 函數 |
| `poly_zero` | algebra | 函數 |
| `rat_add` | algebra | 函數 |
| `rat_big_int` | algebra | 函數 |
| `rat_div` | algebra | 函數 |
| `rat_eq` | algebra | 函數 |
| `rat_fits_int32` | algebra | 函數 |
| `rat_int` | algebra | 函數 |
| `rat_inv` | algebra | 函數 |
| `rat_is_one` | algebra | 函數 |
| `rat_is_square` | algebra | 函數 |
| `rat_is_zero` | algebra | 函數 |
| `rat_make` | algebra | 函數 |
| `rat_make_big` | algebra | 函數 |
| `rat_make_decimal_strings` | algebra | 函數 |
| `rat_mul` | algebra | 函數 |
| `rat_neg` | algebra | 函數 |
| `rat_nth_root_exact` | algebra | 函數 |
| `rat_one` | algebra | 函數 |
| `rat_sign` | algebra | 函數 |
| `rat_sqrt_if_square` | algebra | 函數 |
| `rat_sub` | algebra | 函數 |
| `rat_to_double` | algebra | 函數 |
| `rat_to_string` | algebra | 函數 |
| `rat_zero` | algebra | 函數 |
| `sc_add` | algebra | 函數 |
| `sc_conj` | algebra | 函數 |
| `sc_eq` | algebra | 函數 |
| `sc_i` | algebra | 函數 |
| `sc_int` | algebra | 函數 |
| `sc_is_zero` | algebra | 函數 |
| `sc_make` | algebra | 函數 |
| `sc_mul` | algebra | 函數 |
| `sc_neg` | algebra | 函數 |
| `sc_one` | algebra | 函數 |
| `sc_rat` | algebra | 函數 |
| `sc_real_frac` | algebra | 函數 |
| `sc_scale_frac` | algebra | 函數 |
| `sc_sub` | algebra | 函數 |
| `sc_var` | algebra | 函數 |
| `sc_zero` | algebra | 函數 |
| `sym_det` | algebra | 函數 |
| `sym_inner` | algebra | 函數 |
| `sym_is_hermitian` | algebra | 函數 |
| `sym_is_idempotent` | algebra | 函數 |
| `sym_mat_add` | algebra | 函數 |
| `sym_mat_adjoint` | algebra | 函數 |
| `sym_mat_eq` | algebra | 函數 |
| `sym_mat_from_rows` | algebra | 函數 |
| `sym_mat_identity` | algebra | 函數 |
| `sym_mat_mul` | algebra | 函數 |
| `sym_mat_of_qmat` | algebra | 函數 |
| `sym_mat_scale` | algebra | 函數 |
| `sym_mat_sub` | algebra | 函數 |
| `sym_mat_trace` | algebra | 函數 |
| `sym_mat_vec` | algebra | 函數 |
| `sym_mat_zero` | algebra | 函數 |
| `sym_outer` | algebra | 函數 |
| `sym_projector_rank_one` | algebra | 函數 |
| `sym_scalar_matrix` | algebra | 函數 |
| `sym_vec_add` | algebra | 函數 |
| `sym_vec_eq` | algebra | 函數 |
| `sym_vec_scale` | algebra | 函數 |
| `sym_vec_scale_c` | algebra | 函數 |
| `sym_vec_sub` | algebra | 函數 |
| `upoly_add` | algebra | 函數 |
| `upoly_const` | algebra | 函數 |
| `upoly_eq` | algebra | 函數 |
| `upoly_mul` | algebra | 函數 |
| `upoly_neg` | algebra | 函數 |
| `upoly_normalize` | algebra | 函數 |
| `upoly_of_rpoly` | algebra | 函數 |
| `upoly_sub` | algebra | 函數 |
| `upoly_x` | algebra | 函數 |
| `upoly_zero` | algebra | 函數 |

### 譜投影與仿射唯一填充

- 規範形式：Pₖ=qₖ(A)/qₖ(λₖ)；雙線性角插值 k00+i k10+j k01+ij k11
- 範疇化：單位分解與譜分解；雙線性是兩仿射方向的張量黏合
- 判定：首一整除（模最小多項式）與在原子 i,j 的恆等

| 符號 | 套件 | 類別 |
|---|---|---|
| `RPoly` | algebra | 結構 |
| `RPoly.coeffs` | algebra | 欄位 |
| `RPolyDiv` | algebra | 結構 |
| `RPolyDiv.quotient` | algebra | 欄位 |
| `RPolyDiv.remainder` | algebra | 欄位 |
| `SymPath` | algebra | 型別別名 |
| `SymSquare` | algebra | 型別別名 |
| `check_spectral_identities` | algebra | 函數 |
| `check_spectral_matrices` | algebra | 函數 |
| `check_symbolic_affine_filler` | algebra | 函數 |
| `check_symbolic_algebra_all` | algebra | 函數 |
| `check_symbolic_nonlinear_boundary` | algebra | 函數 |
| `check_symbolic_pruning` | algebra | 函數 |
| `rpoly_add` | algebra | 函數 |
| `rpoly_const` | algebra | 函數 |
| `rpoly_degree` | algebra | 函數 |
| `rpoly_divisible_by` | algebra | 函數 |
| `rpoly_divmod_monic` | algebra | 函數 |
| `rpoly_eq` | algebra | 函數 |
| `rpoly_eval` | algebra | 函數 |
| `rpoly_eval_mat` | algebra | 函數 |
| `rpoly_factor` | algebra | 函數 |
| `rpoly_is_zero` | algebra | 函數 |
| `rpoly_mul` | algebra | 函數 |
| `rpoly_neg` | algebra | 函數 |
| `rpoly_normalize` | algebra | 函數 |
| `rpoly_one` | algebra | 函數 |
| `rpoly_scale` | algebra | 函數 |
| `rpoly_sub` | algebra | 函數 |
| `rpoly_x` | algebra | 函數 |
| `rpoly_zero` | algebra | 函數 |
| `spectral_denominator` | algebra | 函數 |
| `spectral_minpoly` | algebra | 函數 |
| `spectral_projector_sym` | algebra | 函數 |
| `spectral_q` | algebra | 函數 |
| `sym_affine_path` | algebra | 函數 |
| `sym_bilinear_ansatz` | algebra | 函數 |
| `sym_bilinear_from_corners` | algebra | 函數 |
| `sym_frac_one_minus` | algebra | 函數 |
| `sym_hermitian2` | algebra | 函數 |
| `sym_square_fill` | algebra | 函數 |

### 句法笛卡兒閉範疇

- 規範形式：帶註記閉箭頭，其 nf_eta
- 範疇化：自由 CCC：積與指數的萬有性
- 判定：def_eq_eta 驗證範疇律

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_syntactic_category` | root | 函數 |
| `tm_comp_at` | root | 函數 |
| `tm_comp_closed` | root | 函數 |
| `tm_id_at` | root | 函數 |
| `tm_shift` | root | 函數 |

### 有限宇宙型別與值

- 規範形式：葉序／葉值列
- 範疇化：有限集合範疇中由 Bool/Unit 以積生成
- 判定：樹遞迴

| 符號 | 套件 | 類別 |
|---|---|---|
| `PVal` | root | 列舉 |
| `PVal::PVBool` | root | 構造子 |
| `PVal::PVPair` | root | 構造子 |
| `PVal::PVUnit` | root | 構造子 |
| `PVal::equal` | root | 函數 |
| `PVal::not_equal` | root | 函數 |
| `PVal::to_repr` | root | 函數 |
| `Ty` | root | 列舉 |
| `Ty::TyBool` | root | 構造子 |
| `Ty::TyProd` | root | 構造子 |
| `Ty::TyUnit` | root | 構造子 |
| `Ty::equal` | root | 函數 |
| `Ty::not_equal` | root | 函數 |
| `Ty::to_repr` | root | 函數 |
| `elems_of` | root | 函數 |
| `in_ty` | root | 函數 |
| `pval_fst` | root | 函數 |
| `pval_not` | root | 函數 |
| `pval_snd` | root | 函數 |
| `pval_swap` | root | 函數 |
| `pval_to_dvalue` | root | 函數 |

### Wiring 符號等價

- 規範形式：帶號置換（Unit 輸出 /(−1,false)）
- 範疇化：自由對稱冪冪範疇態射；⊗／換位／結合子／單位子
- 判定：置換性 O(#葉)；相等=結構相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `LeafKind` | root | 列舉 |
| `LeafKind::LKBool` | root | 構造子 |
| `LeafKind::LKUnit` | root | 構造子 |
| `LeafKind::equal` | root | 函數 |
| `LeafKind::not_equal` | root | 函數 |
| `LeafKind::to_repr` | root | 函數 |
| `LeafMap` | root | 結構 |
| `LeafMap.neg` | root | 欄位 |
| `LeafMap.src_index` | root | 欄位 |
| `LeafMap::equal` | root | 函數 |
| `LeafMap::not_equal` | root | 函數 |
| `LeafMap::to_repr` | root | 函數 |
| `Wiring` | root | 結構 |
| `Wiring.dst` | root | 欄位 |
| `Wiring.mapping` | root | 欄位 |
| `Wiring.src` | root | 欄位 |
| `check_wiring_category` | root | 函數 |
| `check_wiring_coherence` | root | 函數 |
| `flatten_pval` | root | 函數 |
| `leaf_count` | root | 函數 |
| `leaves_of_ty` | root | 函數 |
| `wiring_apply` | root | 函數 |
| `wiring_assoc` | root | 函數 |
| `wiring_comp` | root | 函數 |
| `wiring_eq` | root | 函數 |
| `wiring_id` | root | 函數 |
| `wiring_inv` | root | 函數 |
| `wiring_left_unitor` | root | 函數 |
| `wiring_not` | root | 函數 |
| `wiring_prod` | root | 函數 |
| `wiring_right_unitor` | root | 函數 |
| `wiring_swap` | root | 函數 |
| `wiring_wf` | root | 函數 |

### 同構、等價、ua、coe

- 規範形式：wiring；coe 按端點計算
- 範疇化：ua 在有限宇宙；積交換為自然性方塊
- 判定：wiring_eq 與 w;w⁻¹=id

| 符號 | 套件 | 類別 |
|---|---|---|
| `Equiv` | root | 結構 |
| `Equiv.bwd` | root | 欄位 |
| `Equiv.dst` | root | 欄位 |
| `Equiv.fwd` | root | 欄位 |
| `Equiv.src` | root | 欄位 |
| `Equiv.wiring` | root | 欄位 |
| `Iso` | root | 結構 |
| `Iso.dst` | root | 欄位 |
| `Iso.from_fn` | root | 欄位 |
| `Iso.src` | root | 欄位 |
| `Iso.to_fn` | root | 欄位 |
| `Iso.wiring` | root | 欄位 |
| `UPath` | root | 結構 |
| `UPath.equiv` | root | 欄位 |
| `check_coe_definitional` | root | 函數 |
| `check_ua_coe` | root | 函數 |
| `coe_computes` | root | 函數 |
| `coe_upath` | root | 函數 |
| `equiv_bool_not` | root | 函數 |
| `equiv_bwd_value` | root | 函數 |
| `equiv_comp` | root | 函數 |
| `equiv_ext_eq` | root | 函數 |
| `equiv_ext_eq_oracle` | root | 函數（差分測試 oracle，非判定路徑） |
| `equiv_fun_value` | root | 函數 |
| `equiv_fwd_value` | root | 函數 |
| `equiv_id` | root | 函數 |
| `equiv_id_value` | root | 函數 |
| `equiv_inv` | root | 函數 |
| `equiv_inv_fun_value` | root | 函數 |
| `equiv_inv_value` | root | 函數 |
| `equiv_make_value` | root | 函數 |
| `equiv_of_wiring` | root | 函數 |
| `equiv_parts` | root | 函數 |
| `equiv_prod` | root | 函數 |
| `equiv_retr_type` | root | 函數 |
| `equiv_retr_value` | root | 函數 |
| `equiv_sect_type` | root | 函數 |
| `equiv_sect_value` | root | 函數 |
| `equiv_swap` | root | 函數 |
| `equiv_type_term` | root | 函數 |
| `equiv_wf` | root | 函數 |
| `equiv_wf_extensional` | root | 函數（差分測試 oracle，非判定路徑） |
| `iso_bool_not` | root | 函數 |
| `iso_of_wiring` | root | 函數 |
| `iso_swap` | root | 函數 |
| `iso_to_equiv` | root | 函數 |
| `iso_to_path` | root | 函數 |
| `iso_wf` | root | 函數 |
| `iso_wf_extensional` | root | 函數（差分測試 oracle，非判定路徑） |
| `swap_naturality` | root | 函數 |
| `ua` | root | 函數 |
| `ua_line_value` | root | 函數 |
| `ua_term` | root | 函數 |
| `ua_type_at` | root | 函數 |
| `ua_value` | root | 函數 |
| `upath_eq` | root | 函數 |
| `upath_left` | root | 函數 |
| `upath_right` | root | 函數 |

### PathP、離散路徑與 J

- 規範形式：規範 PathP 元（遠端為 coe 像）；離散路徑常值
- 範疇化：依賴路徑物件；J 來自常值線 coe 的恆等性
- 判定：端點與點值檢驗

| 符號 | 套件 | 類別 |
|---|---|---|
| `DiscPath` | root | 結構 |
| `DiscPath.hi` | root | 欄位 |
| `DiscPath.lo` | root | 欄位 |
| `DiscPath.point` | root | 欄位 |
| `DiscPath.ty` | root | 欄位 |
| `Family` | root | 結構 |
| `Family.fiber` | root | 欄位 |
| `PathPVal` | root | 結構 |
| `PathPVal.at0` | root | 欄位 |
| `PathPVal.at1` | root | 欄位 |
| `PathPVal.line` | root | 欄位 |
| `PathPVal.point` | root | 欄位 |
| `check_j` | root | 函數 |
| `check_pathp_exchange` | root | 函數 |
| `disc_path_sym` | root | 函數 |
| `disc_path_wf` | root | 函數 |
| `disc_samples` | root | 函數 |
| `j_elim_disc` | root | 函數 |
| `j_roundtrip` | root | 函數 |
| `pathp_canonical` | root | 函數 |
| `pathp_fst` | root | 函數 |
| `pathp_prod` | root | 函數 |
| `pathp_prod_exchange_roundtrip` | root | 函數 |
| `pathp_snd` | root | 函數 |
| `pathp_wf` | root | 函數 |
| `refl_path` | root | 函數 |

### 有限 Glue

- 規範形式：(partial, base) 對；glue_from_base 由 base 範形
- 範疇化：沿等價黏合的極限式構造；unglue 為纖維化投影
- 判定：face_sat＋相容方程

| 符號 | 套件 | 類別 |
|---|---|---|
| `GlueData` | root | 結構 |
| `GlueData.base_ty` | root | 欄位 |
| `GlueData.equiv` | root | 欄位 |
| `GlueData.face` | root | 欄位 |
| `GlueData.partial_ty` | root | 欄位 |
| `GlueElem` | root | 結構 |
| `GlueElem.base` | root | 欄位 |
| `GlueElem.partial` | root | 欄位 |
| `check_glue` | root | 函數 |
| `check_glue_equiv_quote_preserves_syntax` | root | 函數 |
| `glue_equiv_base_of` | root | 函數 |
| `glue_equiv_collapse` | root | 函數 |
| `glue_equiv_domain_face` | root | 函數 |
| `glue_equiv_partial_values` | root | 函數 |
| `glue_equiv_store_partial` | root | 函數 |
| `glue_equiv_systems_conv` | root | 函數 |
| `glue_equiv_term` | root | 函數 |
| `glue_equiv_top_index` | root | 函數 |
| `glue_from_base` | root | 函數 |
| `glue_restrict` | root | 函數 |
| `glue_sound` | root | 函數 |
| `glue_wf` | root | 函數 |
| `make_glue` | root | 函數 |
| `unglue` | root | 函數 |

### Glue comp（有限線）

- 規範形式：輸出 (t₁, e₁(t₁))
- 範疇化：箭頭範疇 Ty²：等價線是其態射，comp 是沿線合成
- 判定：自然性方塊 wiring_eq；不相干則拒絕

| 符號 | 套件 | 類別 |
|---|---|---|
| `GlueLineFinite` | root | 結構 |
| `GlueLineFinite.a_line` | root | 欄位 |
| `GlueLineFinite.e0` | root | 欄位 |
| `GlueLineFinite.e1` | root | 欄位 |
| `GlueLineFinite.face0` | root | 欄位 |
| `GlueLineFinite.face1` | root | 欄位 |
| `GlueLineFinite.t_line` | root | 欄位 |
| `check_glue_comp_all` | root | 函數 |
| `check_glue_comp_finite` | root | 函數 |
| `check_glue_comp_vec` | root | 函數 |
| `glue_comp_finite` | root | 函數 |
| `glue_comp_finite_correct` | root | 函數 |
| `glue_data_at0` | root | 函數 |
| `glue_data_at1` | root | 函數 |
| `glue_line_coherent` | root | 函數 |

### Glue comp（子空間線）

- 規範形式：校正方塊 k=1 邊
- 範疇化：變動 retract 線上的 Kan 提升；校正為 hcomp
- 判定：邊界／帽子／落點方程（網格）

| 符號 | 套件 | 類別 |
|---|---|---|
| `GlueCompVecResult` | root | 結構 |
| `GlueCompVecResult.a_cap` | root | 欄位 |
| `GlueCompVecResult.a_cap_raw` | root | 欄位 |
| `GlueCompVecResult.a_fill_raw` | root | 欄位 |
| `GlueCompVecResult.correction` | root | 欄位 |
| `GlueCompVecResult.t_cap` | root | 欄位 |
| `GlueCompVecResult.t_fill` | root | 欄位 |
| `GlueLineVec` | root | 結構 |
| `GlueLineVec.base_line` | root | 欄位 |
| `GlueLineVec.equiv` | root | 欄位 |
| `GlueLineVec.face_active` | root | 欄位 |
| `GlueLineVec.part_line` | root | 欄位 |
| `LinEquivLine` | root | 結構 |
| `LinEquivLine.bwd` | root | 欄位 |
| `LinEquivLine.fwd` | root | 欄位 |
| `SubLine` | root | 結構 |
| `SubLine.proj` | root | 欄位 |
| `VecBox` | root | 結構 |
| `VecBox.bottom` | root | 欄位 |
| `VecBox.left` | root | 欄位 |
| `VecBox.right` | root | 欄位 |
| `cube_in_subline` | root | 函數 |
| `fill_subline` | root | 函數 |
| `glue_box_compatible` | root | 函數 |
| `glue_comp_vec` | root | 函數 |
| `glue_comp_vec_sound` | root | 函數 |
| `lin_equiv_from_unit_paths` | root | 函數 |
| `map_cube_equiv_line` | root | 函數 |
| `map_cube_matrix` | root | 函數 |
| `outer2` | root | 函數 |
| `prune_cube_subline` | root | 函數 |
| `subline_const` | root | 函數 |
| `subline_from_unit_path` | root | 函數 |
| `vec_box` | root | 函數 |
| `vec_normalize` | root | 函數 |

### BDD DAG、預算與 DPLL

- 規範形式：hash-consed DAG 節點 ID；root 的 reachable node count 為 ROBDD 大小；apply cache 於 apply_misses 超過桶數四倍時 doubling rehash；sifting 逐變量試全部插入位置並以 reachable size 衡量 並回報 initial/final/attempts/improved；CNF 以 Tseitin 門變量線性編碼
- 範疇化：布林函數在固定變量次序下的共享規範圖；apply 是格運算的 memoized 實現；watched-literal DPLL 是面格可滿足性的搜尋判定
- 判定：同 manager root-id 相等、root≠0 的 sat、節點預算 FaceDecision、或有步數預算的 DPLL（舊掃描式與 watched-literal）；另有候選變量次序最小化與 3ⁿ 最壞節點界；watched/list DPLL 以 2^n brute force 差分驗證，sifting 以恆等哨兵避免大小同分時誤稱改善；CDCL 在 watched 傳播上加 1-UIP 子句學習、VSIDS 與 Luby 重啟，於生成面與鴿洞實例對驗；n≤8 時全排列枚舉給出可證最優變量序，超出上限明示非精確

| 符號 | 套件 | 類別 |
|---|---|---|
| `BddApplyEntry` | root | 結構 |
| `BddApplyEntry.a` | root | 欄位 |
| `BddApplyEntry.b` | root | 欄位 |
| `BddApplyEntry.op` | root | 欄位 |
| `BddApplyEntry.result` | root | 欄位 |
| `BddBestBuild` | root | 結構 |
| `BddBestBuild.built` | root | 欄位 |
| `BddBestBuild.order` | root | 欄位 |
| `BddDagFace` | root | 結構 |
| `BddDagFace.manager` | root | 欄位 |
| `BddDagFace.ok` | root | 欄位 |
| `BddDagFace.root` | root | 欄位 |
| `BddDagNode` | root | 結構 |
| `BddDagNode.hi` | root | 欄位 |
| `BddDagNode.lo` | root | 欄位 |
| `BddDagNode.rank` | root | 欄位 |
| `BddManager` | root | 結構 |
| `BddManager.apply_buckets` | root | 欄位 |
| `BddManager.apply_hits` | root | 欄位 |
| `BddManager.apply_misses` | root | 欄位 |
| `BddManager.buckets` | root | 欄位 |
| `BddManager.exceeded` | root | 欄位 |
| `BddManager.max_nodes` | root | 欄位 |
| `BddManager.mk_calls` | root | 欄位 |
| `BddManager.n` | root | 欄位 |
| `BddManager.nodes` | root | 欄位 |
| `BddManager.order` | root | 欄位 |
| `BddManager.position` | root | 欄位 |
| `BddOptimalBuild` | root | 結構 |
| `BddOptimalBuild.built` | root | 欄位 |
| `BddOptimalBuild.exact` | root | 欄位 |
| `BddOptimalBuild.order` | root | 欄位 |
| `BddOptimalBuild.size` | root | 欄位 |
| `BddOptimalBuild.tried` | root | 欄位 |
| `BddOptimizedBuild` | root | 結構 |
| `BddOptimizedBuild.attempts` | root | 欄位 |
| `BddOptimizedBuild.built` | root | 欄位 |
| `BddOptimizedBuild.improved` | root | 欄位 |
| `BddOptimizedBuild.initial_reachable` | root | 欄位 |
| `BddOptimizedBuild.order` | root | 欄位 |
| `BddOptimizedBuild.reachable` | root | 欄位 |
| `FaceBoolExpr::equal` | root | 函數 |
| `FaceBoolExpr::not_equal` | root | 函數 |
| `FaceBoolExpr::to_repr` | root | 函數 |
| `FaceCdclResult` | root | 結構 |
| `FaceCdclResult.decision` | root | 欄位 |
| `FaceCdclResult.stats` | root | 欄位 |
| `FaceCdclStats` | root | 結構 |
| `FaceCdclStats.conflicts` | root | 欄位 |
| `FaceCdclStats.decisions` | root | 欄位 |
| `FaceCdclStats.learned` | root | 欄位 |
| `FaceCdclStats.propagations` | root | 欄位 |
| `FaceCdclStats.restarts` | root | 欄位 |
| `FaceCdclStats::equal` | root | 函數 |
| `FaceCdclStats::not_equal` | root | 函數 |
| `FaceCdclStats::to_repr` | root | 函數 |
| `FaceCnfStats` | root | 結構 |
| `FaceCnfStats.auxiliary_variables` | root | 欄位 |
| `FaceCnfStats.clauses` | root | 欄位 |
| `FaceCnfStats.literals` | root | 欄位 |
| `FaceCnfStats.variables` | root | 欄位 |
| `FaceCnfStats::equal` | root | 函數 |
| `FaceCnfStats::not_equal` | root | 函數 |
| `FaceCnfStats::to_repr` | root | 函數 |
| `FaceDecision` | root | 列舉 |
| `FaceDecision::FaceBudgetExceeded` | root | 構造子 |
| `FaceDecision::FaceDecided` | root | 構造子 |
| `FaceDecision::equal` | root | 函數 |
| `FaceDecision::not_equal` | root | 函數 |
| `FaceDecision::to_repr` | root | 函數 |
| `FaceSatDecision` | root | 列舉 |
| `FaceSatDecision::FaceSat` | root | 構造子 |
| `FaceSatDecision::FaceSearchBudgetExceeded` | root | 構造子 |
| `FaceSatDecision::FaceUnsat` | root | 構造子 |
| `FaceSatDecision::equal` | root | 函數 |
| `FaceSatDecision::not_equal` | root | 函數 |
| `FaceSatDecision::to_repr` | root | 函數 |
| `bdd_dag_and` | root | 函數 |
| `bdd_dag_build_face` | root | 函數 |
| `bdd_dag_dnf_face` | root | 函數 |
| `bdd_dag_eval` | root | 函數 |
| `bdd_dag_exists` | root | 函數 |
| `bdd_dag_face_eq` | root | 函數 |
| `bdd_dag_face_le` | root | 函數 |
| `bdd_dag_false` | root | 函數 |
| `bdd_dag_forall` | root | 函數 |
| `bdd_dag_not` | root | 函數 |
| `bdd_dag_of_face` | root | 函數 |
| `bdd_dag_of_face_best` | root | 函數 |
| `bdd_dag_of_face_optimal` | root | 函數 |
| `bdd_dag_of_face_optimized` | root | 函數 |
| `bdd_dag_or` | root | 函數 |
| `bdd_dag_reachable_count` | root | 函數 |
| `bdd_dag_restrict` | root | 函數 |
| `bdd_dag_sat_count` | root | 函數 |
| `bdd_dag_sat_face` | root | 函數 |
| `bdd_dag_true` | root | 函數 |
| `bdd_dag_var` | root | 函數 |
| `bdd_dag_witness` | root | 函數 |
| `bdd_dag_xor` | root | 函數 |
| `bdd_manager_cache_stats` | root | 函數 |
| `bdd_manager_new` | root | 函數 |
| `bdd_manager_node_count` | root | 函數 |
| `bdd_manager_stats` | root | 函數 |
| `bdd_manager_with_order` | root | 函數 |
| `bdd_tree_of_dag` | root | 函數 |
| `bdd_var_order_candidates` | root | 函數 |
| `bdd_worst_case_nodes` | root | 函數 |
| `check_bdd_cost_optimizations` | root | 函數 |
| `check_bdd_dag_native_operations` | root | 函數 |
| `check_bdd_optimal_order_exact` | root | 函數 |
| `check_cdcl_clause_learning` | root | 函數 |
| `face_cnf_stats` | root | 函數 |
| `face_eq_cdcl` | root | 函數 |
| `face_eq_dpll` | root | 函數 |
| `face_eq_watched_dpll` | root | 函數 |
| `face_eq_within_budget` | root | 函數 |
| `face_sat_cdcl` | root | 函數 |
| `face_sat_cdcl_report` | root | 函數 |
| `face_sat_dpll` | root | 函數 |
| `face_sat_watched_dpll` | root | 函數 |
| `face_sat_within_budget` | root | 函數 |

### 原始 DSystem 相容性與 first-match 範形

- 規範形式：相容系統沿用 DSystem 型別導向範形；任意 first-match 系統化為不交有效區域 DTubeNF；兩值的合意區域同時給出布林 BDD 形與保留雙端點的 Face 值形，exact repair 以 Face 值合意面截斷分支而不動端點
- 範疇化：面相對切片中的偏元素；checked 構造是進入 composition 系統子類的反射
- 判定：BDD cube 枚舉上的局部脈絡轉換，檢查 base 與兩兩重疊；不相容回報首個衝突

| 符號 | 套件 | 類別 |
|---|---|---|
| `DFaceConvReport` | root | 結構 |
| `DFaceConvReport.holds` | root | 欄位 |
| `DFaceConvReport.leaf_checks` | root | 欄位 |
| `DFaceConvReport.nodes_visited` | root | 欄位 |
| `DFaceConvReport.pruned_nodes` | root | 欄位 |
| `DSystemCompatibility` | root | 結構 |
| `DSystemCompatibility.branch` | root | 欄位 |
| `DSystemCompatibility.compatible` | root | 欄位 |
| `DSystemCompatibility.other_branch` | root | 欄位 |
| `DSystemCompatibility.reason` | root | 欄位 |
| `DSystemCompatibility::equal` | root | 函數 |
| `DSystemCompatibility::not_equal` | root | 函數 |
| `DSystemCompatibility::to_repr` | root | 函數 |
| `DSystemIncompatibility` | root | 列舉 |
| `DSystemIncompatibility::DSystemBaseIncompatible` | root | 構造子 |
| `DSystemIncompatibility::DSystemBranchesIncompatible` | root | 構造子 |
| `DSystemIncompatibility::DSystemOk` | root | 構造子 |
| `DSystemIncompatibility::equal` | root | 函數 |
| `DSystemIncompatibility::not_equal` | root | 函數 |
| `DSystemIncompatibility::to_repr` | root | 函數 |
| `DSystemRepair` | root | 結構 |
| `DSystemRepair.base_removed_region` | root | 欄位 |
| `DSystemRepair.compatible` | root | 欄位 |
| `DSystemRepair.repaired_branches` | root | 欄位 |
| `DSystemRepair.system` | root | 欄位 |
| `DSystemRepairExact` | root | 結構 |
| `DSystemRepairExact.base_removed_region` | root | 欄位 |
| `DSystemRepairExact.compatible` | root | 欄位 |
| `DSystemRepairExact.repaired_branches` | root | 欄位 |
| `DSystemRepairExact.system` | root | 欄位 |
| `DTubeNF` | root | 結構 |
| `DTubeNF.classes` | root | 欄位 |
| `DTubeNF.undefined` | root | 欄位 |
| `DTubeNFClass` | root | 結構 |
| `DTubeNFClass.path` | root | 欄位 |
| `DTubeNFClass.region` | root | 欄位 |
| `check_dsystem_compatibility` | root | 函數 |
| `check_dsystem_first_match_nf` | root | 函數 |
| `check_dsystem_repair_phase9` | root | 函數 |
| `check_face_agreement_and_exact_repair` | root | 函數 |
| `conv_at_under_face` | root | 函數 |
| `conv_at_under_face_report` | root | 函數 |
| `dtube_nf_class` | root | 函數 |
| `face_agreement_face` | root | 函數 |
| `face_agreement_face_sound` | root | 函數 |
| `face_agreement_region` | root | 函數 |
| `tube_paths_conv_under_face` | root | 函數 |

### AST 一等 Equiv 與 GlueEquiv

- 規範形式：DEquiv 攜帶 fwd/bwd/sect/retr 四項；DVGlueEquiv 攜帶完整 Equiv 分支與 base/partial 對
- 範疇化：AST 內的等價是帶同倫逆證明的同構；ua 是通往宇宙路徑的函子，GlueEquiv 是沿 partial 等價系統的黏合
- 判定：雙向檢查四個分量與兩條 PathP 證明；conversion/quote 按 Equiv 分量與分支面遞迴；沿 ua 的 coe 定義地為 fwd/bwd

| 符號 | 套件 | 類別 |
|---|---|---|
| `DEquivBranch` | root | 結構 |
| `DEquivBranch.equiv` | root | 欄位 |
| `DEquivBranch.face` | root | 欄位 |
| `DEquivBranch.ty` | root | 欄位 |
| `DEquivBranch::equal` | root | 函數 |
| `DEquivBranch::not_equal` | root | 函數 |
| `DEquivBranch::to_repr` | root | 函數 |
| `DEquivBranchValue` | root | 結構 |
| `DEquivBranchValue.equiv` | root | 欄位 |
| `DEquivBranchValue.face` | root | 欄位 |
| `DEquivBranchValue.ty` | root | 欄位 |
| `DEquivParts` | root | 結構 |
| `DEquivParts.bwd` | root | 欄位 |
| `DEquivParts.dst` | root | 欄位 |
| `DEquivParts.fwd` | root | 欄位 |
| `DEquivParts.retr` | root | 欄位 |
| `DEquivParts.sect` | root | 欄位 |
| `DEquivParts.src` | root | 欄位 |
| `DEquivTypeParts` | root | 結構 |
| `DEquivTypeParts.dst` | root | 欄位 |
| `DEquivTypeParts.level` | root | 欄位 |
| `DEquivTypeParts.src` | root | 欄位 |
| `DGlueEquivParts` | root | 結構 |
| `DGlueEquivParts.base` | root | 欄位 |
| `DGlueEquivParts.branches` | root | 欄位 |
| `DGlueEquivParts.face` | root | 欄位 |
| `DGlueEquivParts.level` | root | 欄位 |
| `as_equiv_type` | root | 函數 |
| `as_glue_equiv` | root | 函數 |
| `bool_not_equiv_term` | root | 函數 |
| `bool_not_term` | root | 函數 |
| `check_equiv_ast` | root | 函數 |
| `comp_equiv_value` | root | 函數 |
| `comp_glue_equiv_value` | root | 函數 |
| `d_check_glue_equiv_partial` | root | 函數 |
| `d_equiv_branch` | root | 函數 |
| `dequiv_branch_value` | root | 函數 |
| `infer_equiv_projection` | root | 函數 |
| `infer_equiv_ty` | root | 函數 |
| `infer_glue_equiv` | root | 函數 |
| `infer_mk_equiv` | root | 函數 |
| `infer_ua` | root | 函數 |
| `mk_equiv_term` | root | 函數 |

### 受檢查語義型別線

- 規範形式：DCheckedTypeLine 保存已檢查的開放型別 body、脈絡、環境與宇宙層級，不保存裸宿主函數
- 範疇化：可代換的立方型別線由句法 body 在維度環境下求值，天然與維度代換交換
- 判定：構造時以新鮮維度檢查 body : Typeᵢ；at 以維度求值，coe/comp 直接派遣 AST Kan

| 符號 | 套件 | 類別 |
|---|---|---|
| `DCheckedTypeLine` | root | 結構 |
| `DCheckedTypeLine.body` | root | 欄位 |
| `DCheckedTypeLine.constant` | root | 欄位 |
| `DCheckedTypeLine.ctx` | root | 欄位 |
| `DCheckedTypeLine.denv` | root | 欄位 |
| `DCheckedTypeLine.env` | root | 欄位 |
| `DCheckedTypeLine.level` | root | 欄位 |
| `DCheckedTypeLine.line` | root | 欄位 |
| `check_phase6_infrastructure` | root | 函數 |
| `check_semantic_dimension_substitution` | root | 函數 |
| `checked_coe_value` | root | 函數 |
| `checked_comp_value` | root | 函數 |
| `checked_constant_type_line` | root | 函數 |
| `checked_constant_type_line_closed` | root | 函數 |
| `checked_fill_value` | root | 函數 |
| `checked_line_at` | root | 函數 |
| `checked_line_body` | root | 函數 |
| `checked_line_conv` | root | 函數 |
| `checked_line_endpoints` | root | 函數 |
| `checked_line_fn` | root | 函數 |
| `checked_line_is_constant` | root | 函數 |
| `checked_line_level` | root | 函數 |
| `checked_line_of_pathp_term` | root | 函數 |
| `checked_line_quote_body` | root | 函數 |
| `checked_line_reify_closed` | root | 函數 |
| `checked_line_reparam_closed` | root | 函數 |
| `checked_pathp_type` | root | 函數 |
| `checked_type_line` | root | 函數 |
| `checked_type_line_closed` | root | 函數 |
| `checked_ua_line` | root | 函數 |

### Schema 註冊與 elaboration 快取

- 規範形式：DSchemaRegistry 中以穩定 Debug 鍵 intern 的 DInductivePlan/DHitPlan 與 telescope 前綴鏈；位元組形 CHREGBIN v1＝magic＋版本＋長度＋校驗＋全 DTerm/schema codec 的 payload
- 範疇化：schema 描述子是可共享計劃；快取只保存同一 elaboration 函數的有限圖，不改變指稱
- 判定：驗證布爾值與語義 telescope 前綴按 (term,args,args) 鍵查表；hit/miss 計數可觀察

| 符號 | 套件 | 類別 |
|---|---|---|
| `DHitPlan` | root | 結構 |
| `DHitPlan.generic_index_types` | root | 欄位 |
| `DHitPlan.generic_param_types` | root | 欄位 |
| `DHitPlan.id` | root | 欄位 |
| `DHitPlan.key` | root | 欄位 |
| `DHitPlan.spec` | root | 欄位 |
| `DHitPlan.valid` | root | 欄位 |
| `DInductivePlan` | root | 結構 |
| `DInductivePlan.generic_index_types` | root | 欄位 |
| `DInductivePlan.generic_param_types` | root | 欄位 |
| `DInductivePlan.id` | root | 欄位 |
| `DInductivePlan.key` | root | 欄位 |
| `DInductivePlan.spec` | root | 欄位 |
| `DInductivePlan.valid` | root | 欄位 |
| `DSchemaRegistry` | root | 結構 |
| `DSchemaRegistry.hit_buckets` | root | 欄位 |
| `DSchemaRegistry.hits` | root | 欄位 |
| `DSchemaRegistry.inductive_buckets` | root | 欄位 |
| `DSchemaRegistry.inductives` | root | 欄位 |
| `DSchemaRegistry.telescope_hits` | root | 欄位 |
| `DSchemaRegistry.telescope_misses` | root | 欄位 |
| `DSchemaRegistry.telescopes` | root | 欄位 |
| `DSchemaRegistry.validation_hits` | root | 欄位 |
| `DSchemaRegistry.validation_misses` | root | 欄位 |
| `DSchemaRegistryBinaryLoad` | root | 結構 |
| `DSchemaRegistryBinaryLoad.snapshot` | root | 欄位 |
| `DSchemaRegistryBinaryLoad.status` | root | 欄位 |
| `DSchemaRegistrySnapshot` | root | 結構 |
| `DSchemaRegistrySnapshot.hit_specs` | root | 欄位 |
| `DSchemaRegistrySnapshot.hit_valid` | root | 欄位 |
| `DSchemaRegistrySnapshot.inductive_specs` | root | 欄位 |
| `DSchemaRegistrySnapshot.inductive_valid` | root | 欄位 |
| `DTelescopeCacheEntry` | root | 結構 |
| `DTelescopeCacheEntry.entries` | root | 欄位 |
| `DTelescopeCacheEntry.prefix_types` | root | 欄位 |
| `DTelescopeCacheEntry.prefix_values` | root | 欄位 |
| `DTelescopeCacheEntry.types` | root | 欄位 |
| `DTelescopeCacheEntry.values` | root | 欄位 |
| `check_family_functor_persistence` | root | 函數 |
| `check_schema_registry_byte_persistence` | root | 函數 |
| `check_schema_registry_persistence` | root | 函數 |
| `default_schema_registry` | root | 常量 |

### Schema 函子、正性與歸納遞迴

- 規範形式：DPositiveFunctor 的 Id/Const/Product/Sum/List/Pi/Container/DecodedFunction/Family 語法及其解碼型別（Family 以 DFunctorParamArg 區分宿主 Self 代入與外部參數項，僅跨家族、參數須葉出現且 IH 可 gather）；DPositivityReport 記錄出現與極性
- 範疇化：正性型別函子的初始代數與 decoded induction hypothesis；DDecode 是 Tarski 宇宙的歸納—遞迴解碼函數
- 判定：在別名展開後的 DTerm 上做極性遞迴：巢狀函子與正位置接受、負位置/未知中性族應用拒絕；IH 由函子遞迴生成

| 符號 | 套件 | 類別 |
|---|---|---|
| `DFunctorParamArg` | root | 列舉 |
| `DFunctorParamArg::DFunctorParamSelf` | root | 構造子 |
| `DFunctorParamArg::DFunctorParamTerm` | root | 構造子 |
| `DFunctorParamArg::equal` | root | 函數 |
| `DFunctorParamArg::not_equal` | root | 函數 |
| `DFunctorParamArg::to_repr` | root | 函數 |
| `DPositiveFunctor` | root | 列舉 |
| `DPositiveFunctor::DFunctorConst` | root | 構造子 |
| `DPositiveFunctor::DFunctorContainer` | root | 構造子 |
| `DPositiveFunctor::DFunctorFamily` | root | 構造子 |
| `DPositiveFunctor::DFunctorIdentity` | root | 構造子 |
| `DPositiveFunctor::DFunctorList` | root | 構造子 |
| `DPositiveFunctor::DFunctorPi` | root | 構造子 |
| `DPositiveFunctor::DFunctorProduct` | root | 構造子 |
| `DPositiveFunctor::DFunctorSigma` | root | 構造子 |
| `DPositiveFunctor::DFunctorSum` | root | 構造子 |
| `DPositiveFunctor::equal` | root | 函數 |
| `DPositiveFunctor::not_equal` | root | 函數 |
| `DPositiveFunctor::to_repr` | root | 函數 |
| `DPositivityReport` | root | 結構 |
| `DPositivityReport.negative_polarity` | root | 欄位 |
| `DPositivityReport.occurs` | root | 欄位 |
| `DPositivityReport.positive_polarity` | root | 欄位 |
| `DPositivityReport.strictly_positive` | root | 欄位 |
| `DPositivityReport.unknown` | root | 欄位 |
| `DPositivityReport::equal` | root | 函數 |
| `DPositivityReport::not_equal` | root | 函數 |
| `DPositivityReport::to_repr` | root | 函數 |
| `check_container_functor_tree` | root | 函數 |
| `check_family_nested_functors` | root | 函數 |
| `check_nested_rose_tree` | root | 函數 |
| `check_structural_positivity` | root | 函數 |
| `check_tarski_induction_recursion` | root | 函數 |
| `comp_schema_args_decoded` | root | 函數 |
| `container_tree_schema` | root | 函數 |
| `conv_decode_neutral` | root | 函數 |
| `conv_schema_args_full` | root | 函數 |
| `decode_term` | root | 函數 |
| `dfunctor_const` | root | 函數 |
| `dfunctor_container` | root | 函數 |
| `dfunctor_family` | root | 函數 |
| `dfunctor_identity` | root | 函數 |
| `dfunctor_list` | root | 函數 |
| `dfunctor_param_self` | root | 函數 |
| `dfunctor_param_term` | root | 函數 |
| `dfunctor_pi` | root | 函數 |
| `dfunctor_product` | root | 函數 |
| `dfunctor_sigma` | root | 函數 |
| `dfunctor_sum` | root | 函數 |
| `dpositivity_report` | root | 函數 |
| `dterm_children` | root | 函數 |
| `dterm_family_occurs` | root | 函數 |
| `dterm_family_positivity` | root | 函數 |
| `dterm_family_strictly_positive` | root | 函數 |
| `dterm_shift` | root | 函數 |
| `dterm_substitute` | root | 函數 |
| `infer_decode` | root | 函數 |
| `positive_functor_ih_type` | root | 函數 |
| `positive_functor_map` | root | 函數 |
| `positive_functor_type` | root | 函數 |

### Schema 擴展：互歸納、商與宇宙多態

- 規範形式：DMutualFamily 的 Sum-indexed 合併 schema；DLevelExpr 的層級 scheme；商即帶等式 1-cell 的 HIT
- 範疇化：互相歸納族是索引和上的單一初始代數；宇宙 scheme 是層級指派的函數；商構造為高階胞腔黏合
- 判定：互構子以分量索引約束編譯並以 Σ motive 消去；scheme 依層級向量求值並可再驗證；構造子等式以 Path 約束檢查

| 符號 | 套件 | 類別 |
|---|---|---|
| `DConstructorConstraint` | root | 結構 |
| `DConstructorConstraint.lhs` | root | 欄位 |
| `DConstructorConstraint.rhs` | root | 欄位 |
| `DConstructorConstraint.ty` | root | 欄位 |
| `DConstructorConstraint::equal` | root | 函數 |
| `DConstructorConstraint::not_equal` | root | 函數 |
| `DConstructorConstraint::to_repr` | root | 函數 |
| `DHitLevelScheme` | root | 結構 |
| `DHitLevelScheme.build` | root | 欄位 |
| `DHitLevelScheme.level_arity` | root | 欄位 |
| `DHitLevelScheme.name` | root | 欄位 |
| `DHitLevelScheme.result_level` | root | 欄位 |
| `DInductiveLevelScheme` | root | 結構 |
| `DInductiveLevelScheme.build` | root | 欄位 |
| `DInductiveLevelScheme.level_arity` | root | 欄位 |
| `DInductiveLevelScheme.name` | root | 欄位 |
| `DInductiveLevelScheme.result_level` | root | 欄位 |
| `DLevelExpr` | root | 列舉 |
| `DLevelExpr::DLevelConst` | root | 構造子 |
| `DLevelExpr::DLevelMax` | root | 構造子 |
| `DLevelExpr::DLevelSucc` | root | 構造子 |
| `DLevelExpr::DLevelVar` | root | 構造子 |
| `DLevelExpr::equal` | root | 函數 |
| `DLevelExpr::not_equal` | root | 函數 |
| `DLevelExpr::to_repr` | root | 函數 |
| `DMutualFamily` | root | 結構 |
| `DMutualFamily.combined` | root | 欄位 |
| `DMutualFamily.components` | root | 欄位 |
| `DMutualFamily.ctor_offsets` | root | 欄位 |
| `DMutualFamily.name` | root | 欄位 |
| `check_schema_extensions` | root | 函數 |
| `circle_level_scheme` | root | 函數 |
| `compile_mutual_inductive` | root | 函數 |
| `cube3_schema` | root | 函數 |
| `dlevel_const` | root | 函數 |
| `dlevel_eval` | root | 函數 |
| `dlevel_hit_decl` | root | 函數 |
| `dlevel_inductive_decl` | root | 函數 |
| `dlevel_max` | root | 函數 |
| `dlevel_succ` | root | 函數 |
| `dlevel_term_decl` | root | 函數 |
| `dlevel_var` | root | 函數 |
| `equal_nat_pair_schema` | root | 函數 |
| `even_odd_components` | root | 函數 |
| `even_odd_family` | root | 函數 |
| `instantiate_hit_level_scheme` | root | 函數 |
| `instantiate_inductive_level_scheme` | root | 函數 |
| `instantiate_level_hit_decl` | root | 函數 |
| `instantiate_level_inductive_decl` | root | 函數 |
| `instantiate_level_term_decl` | root | 函數 |
| `list_level_scheme` | root | 函數 |
| `mutual_ctor_index` | root | 函數 |
| `mutual_decl_elaborate` | root | 函數 |
| `mutual_decl_positivity` | root | 函數 |
| `mutual_elim_term` | root | 函數 |
| `mutual_intro_term` | root | 函數 |
| `mutual_intro_value` | root | 函數 |
| `mutual_motive_function` | root | 函數 |
| `mutual_nat_term` | root | 函數 |
| `mutual_nat_value` | root | 函數 |
| `mutual_type_term` | root | 函數 |
| `mutual_type_value` | root | 函數 |
| `quotient_eq_term` | root | 函數 |
| `quotient_point_term` | root | 函數 |
| `quotient_schema` | root | 函數 |
| `rose_tree_schema` | root | 函數 |
| `tarski_universe_schema` | root | 函數 |
| `tree_forest_components` | root | 函數 |
| `tree_forest_family` | root | 函數 |

### 精確單變量多項式與有理矩陣

- 規範形式：QPoly 的升冪稠密係數（尾零去除）；QMat 的有理列之列；RREF 與 pivot 列
- 範疇化：Q[x] 歐氏環與 Qⁿ 線性範疇；特徵/最小多項式是矩陣代數的表示不變量
- 判定：乘法在稀疏輸入走非零卷積、稠密輸入走公分母 BigInt 整係數縮放（schoolbook/Karatsuba 視項數而定）再除回，冪次走平方乘法；primitive pseudo-remainder gcd、Yun 重因數分解、有理根定理、Faddeev–LeVerrier、RREF；相等全為有理結構相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `QMat` | algebra | 結構 |
| `QMat.n` | algebra | 欄位 |
| `QMat.rows` | algebra | 欄位 |
| `QMat::equal` | algebra | 函數 |
| `QMat::not_equal` | algebra | 函數 |
| `QMat::to_repr` | algebra | 函數 |
| `QPoly` | algebra | 結構 |
| `QPoly.coeffs` | algebra | 欄位 |
| `QPoly::equal` | algebra | 函數 |
| `QPoly::not_equal` | algebra | 函數 |
| `QPoly::to_repr` | algebra | 函數 |
| `QPolyDiv` | algebra | 結構 |
| `QPolyDiv.quotient` | algebra | 欄位 |
| `QPolyDiv.remainder` | algebra | 欄位 |
| `QPolyExtGcd` | algebra | 結構 |
| `QPolyExtGcd.g` | algebra | 欄位 |
| `QPolyExtGcd.s` | algebra | 欄位 |
| `QPolyExtGcd.t` | algebra | 欄位 |
| `QPolyFactor` | algebra | 結構 |
| `QPolyFactor.factor` | algebra | 欄位 |
| `QPolyFactor.multiplicity` | algebra | 欄位 |
| `QPolyRationalFactorization` | algebra | 結構 |
| `QPolyRationalFactorization.multiplicities` | algebra | 欄位 |
| `QPolyRationalFactorization.residual` | algebra | 欄位 |
| `QPolyRationalFactorization.roots` | algebra | 欄位 |
| `QRref` | algebra | 結構 |
| `QRref.pivots` | algebra | 欄位 |
| `QRref.rank` | algebra | 欄位 |
| `QRref.rows` | algebra | 欄位 |
| `QVec` | algebra | 型別別名 |
| `check_qpoly_fast_arithmetic` | algebra | 函數 |
| `qmat_add` | algebra | 函數 |
| `qmat_charpoly` | algebra | 函數 |
| `qmat_column_basis` | algebra | 函數 |
| `qmat_det` | algebra | 函數 |
| `qmat_eq` | algebra | 函數 |
| `qmat_from_columns` | algebra | 函數 |
| `qmat_from_int_rows` | algebra | 函數 |
| `qmat_from_rows` | algebra | 函數 |
| `qmat_identity` | algebra | 函數 |
| `qmat_inverse` | algebra | 函數 |
| `qmat_is_zero` | algebra | 函數 |
| `qmat_minimal_polynomial` | algebra | 函數 |
| `qmat_mul` | algebra | 函數 |
| `qmat_nullity` | algebra | 函數 |
| `qmat_nullspace` | algebra | 函數 |
| `qmat_poly_eval` | algebra | 函數 |
| `qmat_pow` | algebra | 函數 |
| `qmat_rank` | algebra | 函數 |
| `qmat_scalar` | algebra | 函數 |
| `qmat_scale` | algebra | 函數 |
| `qmat_sub` | algebra | 函數 |
| `qmat_trace` | algebra | 函數 |
| `qmat_transpose` | algebra | 函數 |
| `qmat_vec` | algebra | 函數 |
| `qmat_zero` | algebra | 函數 |
| `qpoly_add` | algebra | 函數 |
| `qpoly_coeff` | algebra | 函數 |
| `qpoly_const` | algebra | 函數 |
| `qpoly_degree` | algebra | 函數 |
| `qpoly_derivative` | algebra | 函數 |
| `qpoly_div_exact` | algebra | 函數 |
| `qpoly_divmod` | algebra | 函數 |
| `qpoly_eq` | algebra | 函數 |
| `qpoly_eval` | algebra | 函數 |
| `qpoly_extgcd` | algebra | 函數 |
| `qpoly_factor` | algebra | 函數 |
| `qpoly_factor_degree_candidates` | algebra | 函數 |
| `qpoly_factor_rational_roots` | algebra | 函數 |
| `qpoly_gcd` | algebra | 函數 |
| `qpoly_int` | algebra | 函數 |
| `qpoly_integer_coeffs` | algebra | 函數 |
| `qpoly_integer_coeffs_big` | algebra | 函數 |
| `qpoly_irreducible_by_mod_patterns` | algebra | 函數 |
| `qpoly_irreducible_upto3` | algebra | 函數 |
| `qpoly_is_one` | algebra | 函數 |
| `qpoly_is_squarefree` | algebra | 函數 |
| `qpoly_is_zero` | algebra | 函數 |
| `qpoly_leading` | algebra | 函數 |
| `qpoly_mod` | algebra | 函數 |
| `qpoly_mod_degree_patterns` | algebra | 函數 |
| `qpoly_monic` | algebra | 函數 |
| `qpoly_mul` | algebra | 函數 |
| `qpoly_neg` | algebra | 函數 |
| `qpoly_normalize` | algebra | 函數 |
| `qpoly_one` | algebra | 函數 |
| `qpoly_pow` | algebra | 函數 |
| `qpoly_primitive_part` | algebra | 函數 |
| `qpoly_pseudo_remainder` | algebra | 函數 |
| `qpoly_rational_roots` | algebra | 函數 |
| `qpoly_root_factor` | algebra | 函數 |
| `qpoly_root_multiplicity` | algebra | 函數 |
| `qpoly_scale` | algebra | 函數 |
| `qpoly_squarefree_factorization` | algebra | 函數 |
| `qpoly_squarefree_part` | algebra | 函數 |
| `qpoly_sub` | algebra | 函數 |
| `qpoly_x` | algebra | 函數 |
| `qpoly_zero` | algebra | 函數 |
| `qrows_nullspace` | algebra | 函數 |
| `qrows_rank` | algebra | 函數 |
| `qrows_rref` | algebra | 函數 |
| `qvec_add` | algebra | 函數 |
| `qvec_eq` | algebra | 函數 |
| `qvec_in_span` | algebra | 函數 |
| `qvec_independent_subset` | algebra | 函數 |
| `qvec_is_zero` | algebra | 函數 |
| `qvec_rank` | algebra | 函數 |
| `qvec_scale` | algebra | 函數 |
| `qvec_sub` | algebra | 函數 |
| `qvec_zero` | algebra | 函數 |

### 代數擴張與根式範形

- 規範形式：QuadNum 的 a+b√d（d 無平方因數）；AlgNum 的 Q[x]/(m) 餘式多項式
- 範疇化：二次擴張與一般有限代數擴張體；範數/跡由乘法矩陣行列式/跡給出
- 判定：模極小多項式的剩餘算術與擴張歐氏求逆；根式去巢以平方判別；相等為係數相等

| 符號 | 套件 | 類別 |
|---|---|---|
| `AlgNum` | algebra | 結構 |
| `AlgNum.modulus` | algebra | 欄位 |
| `AlgNum.poly` | algebra | 欄位 |
| `AlgNum::equal` | algebra | 函數 |
| `AlgNum::not_equal` | algebra | 函數 |
| `AlgNum::to_repr` | algebra | 函數 |
| `QuadNum` | algebra | 結構 |
| `QuadNum.a` | algebra | 欄位 |
| `QuadNum.b` | algebra | 欄位 |
| `QuadNum.d` | algebra | 欄位 |
| `QuadNum::equal` | algebra | 函數 |
| `QuadNum::not_equal` | algebra | 函數 |
| `QuadNum::to_repr` | algebra | 函數 |
| `alg_add` | algebra | 函數 |
| `alg_coeffs` | algebra | 函數 |
| `alg_compatible` | algebra | 函數 |
| `alg_div` | algebra | 函數 |
| `alg_eq` | algebra | 函數 |
| `alg_eval_qpoly` | algebra | 函數 |
| `alg_ext_degree` | algebra | 函數 |
| `alg_generator` | algebra | 函數 |
| `alg_int` | algebra | 函數 |
| `alg_inv` | algebra | 函數 |
| `alg_is_zero` | algebra | 函數 |
| `alg_make` | algebra | 函數 |
| `alg_minimal_polynomial` | algebra | 函數 |
| `alg_modulus_irreducible_small` | algebra | 函數 |
| `alg_mul` | algebra | 函數 |
| `alg_multiplication_matrix` | algebra | 函數 |
| `alg_neg` | algebra | 函數 |
| `alg_norm` | algebra | 函數 |
| `alg_nth_root_in_field` | algebra | 函數 |
| `alg_of_quad` | algebra | 函數 |
| `alg_one` | algebra | 函數 |
| `alg_pow` | algebra | 函數 |
| `alg_rat` | algebra | 函數 |
| `alg_rebase_to_minimal` | algebra | 函數 |
| `alg_scale_rat` | algebra | 函數 |
| `alg_sqrt_in_field` | algebra | 函數 |
| `alg_sqrt_rat` | algebra | 函數 |
| `alg_sub` | algebra | 函數 |
| `alg_to_quad` | algebra | 函數 |
| `alg_to_rat` | algebra | 函數 |
| `alg_trace` | algebra | 函數 |
| `alg_zero` | algebra | 函數 |
| `int_sqrt_exact` | algebra | 函數 |
| `int_squarefree_decomp` | algebra | 函數 |
| `quad_add` | algebra | 函數 |
| `quad_compatible` | algebra | 函數 |
| `quad_conj` | algebra | 函數 |
| `quad_denested_cuberoot` | algebra | 函數 |
| `quad_denested_sqrt` | algebra | 函數 |
| `quad_div` | algebra | 函數 |
| `quad_eq` | algebra | 函數 |
| `quad_int` | algebra | 函數 |
| `quad_inv` | algebra | 函數 |
| `quad_is_rat` | algebra | 函數 |
| `quad_is_zero` | algebra | 函數 |
| `quad_make` | algebra | 函數 |
| `quad_make_big` | algebra | 函數 |
| `quad_mul` | algebra | 函數 |
| `quad_neg` | algebra | 函數 |
| `quad_norm` | algebra | 函數 |
| `quad_nth_root_in_field` | algebra | 函數 |
| `quad_one` | algebra | 函數 |
| `quad_pow` | algebra | 函數 |
| `quad_rat` | algebra | 函數 |
| `quad_sqrt_int` | algebra | 函數 |
| `quad_sqrt_rat` | algebra | 函數 |
| `quad_sub` | algebra | 函數 |
| `quad_to_double` | root | 函數 |
| `quad_to_rat` | algebra | 函數 |
| `quad_trace` | algebra | 函數 |
| `quad_zero` | algebra | 函數 |

### 廣義特徵空間與 Jordan 理論

- 規範形式：(A−λI) 冪次零化列、遞增 nullity、Jordan 塊大小與鏈底基；PJP⁻¹=A
- 範疇化：主分解是互質多項式因子的單位分解；Jordan 型是相似等價的完全不變量片斷
- 判定：以特徵多項式重數、冪次核維度與鏈提升精確判定；不可在 Q 完全分裂者回報殘餘因子，AlgMat 在擴張上續行

| 符號 | 套件 | 類別 |
|---|---|---|
| `AlgGeneralizedEigenspace` | algebra | 結構 |
| `AlgGeneralizedEigenspace.algebraic_multiplicity` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.basis` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.block_sizes` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.eigenvalue` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.geometric_multiplicity` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.index` | algebra | 欄位 |
| `AlgGeneralizedEigenspace.nullities` | algebra | 欄位 |
| `AlgJordanDecomposition` | algebra | 結構 |
| `AlgJordanDecomposition.block_sizes` | algebra | 欄位 |
| `AlgJordanDecomposition.eigenvalues` | algebra | 欄位 |
| `AlgJordanDecomposition.j` | algebra | 欄位 |
| `AlgJordanDecomposition.p` | algebra | 欄位 |
| `AlgMat` | algebra | 結構 |
| `AlgMat.modulus` | algebra | 欄位 |
| `AlgMat.n` | algebra | 欄位 |
| `AlgMat.rows` | algebra | 欄位 |
| `AlgRref` | algebra | 結構 |
| `AlgRref.pivots` | algebra | 欄位 |
| `AlgRref.rank` | algebra | 欄位 |
| `AlgRref.rows` | algebra | 欄位 |
| `AlgVec` | algebra | 型別別名 |
| `QGeneralizedEigenspace` | algebra | 結構 |
| `QGeneralizedEigenspace.algebraic_multiplicity` | algebra | 欄位 |
| `QGeneralizedEigenspace.basis` | algebra | 欄位 |
| `QGeneralizedEigenspace.block_sizes` | algebra | 欄位 |
| `QGeneralizedEigenspace.eigenvalue` | algebra | 欄位 |
| `QGeneralizedEigenspace.geometric_multiplicity` | algebra | 欄位 |
| `QGeneralizedEigenspace.index` | algebra | 欄位 |
| `QGeneralizedEigenspace.nullities` | algebra | 欄位 |
| `QJordanDecomposition` | algebra | 結構 |
| `QJordanDecomposition.block_sizes` | algebra | 欄位 |
| `QJordanDecomposition.eigenvalues` | algebra | 欄位 |
| `QJordanDecomposition.j` | algebra | 欄位 |
| `QJordanDecomposition.p` | algebra | 欄位 |
| `QPrimaryProjector` | algebra | 結構 |
| `QPrimaryProjector.cofactor` | algebra | 欄位 |
| `QPrimaryProjector.complement` | algebra | 欄位 |
| `QPrimaryProjector.factor` | algebra | 欄位 |
| `QPrimaryProjector.polynomial` | algebra | 欄位 |
| `QPrimaryProjector.projector` | algebra | 欄位 |
| `QRationalSpectrum` | algebra | 結構 |
| `QRationalSpectrum.eigenvalues` | algebra | 欄位 |
| `QRationalSpectrum.multiplicities` | algebra | 欄位 |
| `QRationalSpectrum.residual` | algebra | 欄位 |
| `algmat_Jordan_chains` | algebra | 函數 |
| `algmat_Jordan_decomposition` | algebra | 函數 |
| `algmat_add` | algebra | 函數 |
| `algmat_charpoly` | algebra | 函數 |
| `algmat_eigenvalue_multiplicity` | algebra | 函數 |
| `algmat_eq` | algebra | 函數 |
| `algmat_from_columns` | algebra | 函數 |
| `algmat_from_qmat` | algebra | 函數 |
| `algmat_generalized_eigenspace` | algebra | 函數 |
| `algmat_identity` | algebra | 函數 |
| `algmat_mul` | algebra | 函數 |
| `algmat_nullity` | algebra | 函數 |
| `algmat_nullspace` | algebra | 函數 |
| `algmat_pow` | algebra | 函數 |
| `algmat_rank` | algebra | 函數 |
| `algmat_scalar` | algebra | 函數 |
| `algmat_sub` | algebra | 函數 |
| `algmat_trace` | algebra | 函數 |
| `algmat_vec` | algebra | 函數 |
| `algmat_zero` | algebra | 函數 |
| `algrows_nullspace` | algebra | 函數 |
| `algrows_rref` | algebra | 函數 |
| `algvec_in_span` | algebra | 函數 |
| `algvec_is_zero` | algebra | 函數 |
| `algvec_rank` | algebra | 函數 |
| `algvec_zero` | algebra | 函數 |
| `check_algebraic_extensions_and_Jordan` | algebra | 函數 |
| `qmat_Jordan_block_sizes` | algebra | 函數 |
| `qmat_Jordan_chains` | algebra | 函數 |
| `qmat_Jordan_decomposition` | algebra | 函數 |
| `qmat_Jordan_decomposition_auto` | algebra | 函數 |
| `qmat_diagonalizable_at` | algebra | 函數 |
| `qmat_eigen_nullities` | algebra | 函數 |
| `qmat_eigenvalue_multiplicity` | algebra | 函數 |
| `qmat_generalized_eigenspace` | algebra | 函數 |
| `qmat_generalized_projector` | algebra | 函數 |
| `qmat_is_diagonalizable_rational` | algebra | 函數 |
| `qmat_primary_projector` | algebra | 函數 |
| `qmat_primary_subspace_basis` | algebra | 函數 |
| `qmat_rational_spectrum` | algebra | 函數 |
| `qmat_vector_annihilator` | algebra | 函數 |

### 認證數值影子與精確立方體

- 規範形式：QuadC=QuadNum+i·QuadNum；CertMat 與次數≤2 的 CertPath/CertSquare 係數
- 範疇化：精確複二次矩陣代數與多項式立方體；Double 矩陣只是精確影子的近似表示
- 判定：P²=P、P†=P、正交分解與盒邊界以精確結構相等驗證；數值一致性只量測對影子的偏差與浮點 residual

| 符號 | 套件 | 類別 |
|---|---|---|
| `AlgC` | root | 結構 |
| `AlgC.im` | root | 欄位 |
| `AlgC.re` | root | 欄位 |
| `AlgCertMat` | root | 結構 |
| `AlgCertMat.n` | root | 欄位 |
| `AlgCertMat.rows` | root | 欄位 |
| `AlgCertPath` | root | 結構 |
| `AlgCertPath.coeffs` | root | 欄位 |
| `AlgCertSquare` | root | 結構 |
| `AlgCertSquare.coeffs` | root | 欄位 |
| `AlgCertVec` | root | 型別別名 |
| `CertMat` | root | 結構 |
| `CertMat.n` | root | 欄位 |
| `CertMat.rows` | root | 欄位 |
| `CertPath` | root | 結構 |
| `CertPath.coeffs` | root | 欄位 |
| `CertSquare` | root | 結構 |
| `CertSquare.coeffs` | root | 欄位 |
| `CertVec` | root | 型別別名 |
| `NumericProjectorCertificate` | root | 結構 |
| `NumericProjectorCertificate.exact` | root | 欄位 |
| `NumericProjectorCertificate.max_deviation` | root | 欄位 |
| `NumericProjectorCertificate.numeric_residual` | root | 欄位 |
| `NumericProjectorCertificate.ok` | root | 欄位 |
| `NumericProjectorCertificate.tolerance` | root | 欄位 |
| `ProjectorCertificate` | root | 結構 |
| `ProjectorCertificate.complement_projector` | root | 欄位 |
| `ProjectorCertificate.hermitian` | root | 欄位 |
| `ProjectorCertificate.idempotent` | root | 欄位 |
| `ProjectorCertificate.matrix` | root | 欄位 |
| `ProjectorCertificate.orthogonal_split` | root | 欄位 |
| `ProjectorCertificate.trace` | root | 欄位 |
| `QuadC` | root | 結構 |
| `QuadC.im` | root | 欄位 |
| `QuadC.re` | root | 欄位 |
| `QuadC::equal` | root | 函數 |
| `QuadC::not_equal` | root | 函數 |
| `QuadC::to_repr` | root | 函數 |
| `alg_cert_in_image` | root | 函數 |
| `alg_cert_inner` | root | 函數 |
| `alg_cert_is_projector` | root | 函數 |
| `alg_cert_mat_adjoint` | root | 函數 |
| `alg_cert_mat_eq` | root | 函數 |
| `alg_cert_mat_from_rows` | root | 函數 |
| `alg_cert_mat_mul` | root | 函數 |
| `alg_cert_mat_vec` | root | 函數 |
| `alg_cert_outer` | root | 函數 |
| `alg_cert_path_eval` | root | 函數 |
| `alg_cert_path_in_image` | root | 函數 |
| `alg_cert_square_eval` | root | 函數 |
| `alg_cert_square_in_image` | root | 函數 |
| `alg_cert_vec_add` | root | 函數 |
| `alg_cert_vec_eq` | root | 函數 |
| `alg_cert_vec_scale` | root | 函數 |
| `algc_add` | root | 函數 |
| `algc_conj` | root | 函數 |
| `algc_eq` | root | 函數 |
| `algc_i` | root | 函數 |
| `algc_is_zero` | root | 函數 |
| `algc_make` | root | 函數 |
| `algc_mul` | root | 函數 |
| `algc_neg` | root | 函數 |
| `algc_one` | root | 函數 |
| `algc_real` | root | 函數 |
| `algc_scale_alg` | root | 函數 |
| `algc_sub` | root | 函數 |
| `algc_zero` | root | 函數 |
| `cert_complement` | root | 函數 |
| `cert_eigenspace_kan_sound` | root | 函數 |
| `cert_example_projector` | root | 函數 |
| `cert_example_unit` | root | 函數 |
| `cert_filler_respects_box` | root | 函數 |
| `cert_in_image` | root | 函數 |
| `cert_in_kernel` | root | 函數 |
| `cert_inner` | root | 函數 |
| `cert_is_hermitian` | root | 函數 |
| `cert_is_idempotent` | root | 函數 |
| `cert_is_projector` | root | 函數 |
| `cert_mat_add` | root | 函數 |
| `cert_mat_adjoint` | root | 函數 |
| `cert_mat_eq` | root | 函數 |
| `cert_mat_from_rows` | root | 函數 |
| `cert_mat_identity` | root | 函數 |
| `cert_mat_mul` | root | 函數 |
| `cert_mat_scale_quad` | root | 函數 |
| `cert_mat_sub` | root | 函數 |
| `cert_mat_to_numeric` | root | 函數 |
| `cert_mat_trace` | root | 函數 |
| `cert_mat_vec` | root | 函數 |
| `cert_mat_zero` | root | 函數 |
| `cert_open_box_wf` | root | 函數 |
| `cert_outer` | root | 函數 |
| `cert_path_const` | root | 函數 |
| `cert_path_end` | root | 函數 |
| `cert_path_eq` | root | 函數 |
| `cert_path_in_image` | root | 函數 |
| `cert_path_is_affine` | root | 函數 |
| `cert_path_line` | root | 函數 |
| `cert_path_start` | root | 函數 |
| `cert_path_sym` | root | 函數 |
| `cert_projector_of_vector` | root | 函數 |
| `cert_pruning_repairs_filler` | root | 函數 |
| `cert_square_add` | root | 函數 |
| `cert_square_apply` | root | 函數 |
| `cert_square_bilinear` | root | 函數 |
| `cert_square_bump` | root | 函數 |
| `cert_square_eq` | root | 函數 |
| `cert_square_face` | root | 函數 |
| `cert_square_fill` | root | 函數 |
| `cert_square_in_image` | root | 函數 |
| `cert_vec_add` | root | 函數 |
| `cert_vec_eq` | root | 函數 |
| `cert_vec_scale` | root | 函數 |
| `cert_vec_scale_quad` | root | 函數 |
| `cert_vec_sub` | root | 函數 |
| `cert_vec_to_numeric` | root | 函數 |
| `cert_vec_zero` | root | 函數 |
| `certify_numeric_projector` | root | 函數 |
| `certify_projector` | root | 函數 |
| `check_bdd_and_certified_numeric` | root | 函數 |
| `check_certified_algebraic_numeric` | root | 函數 |
| `cube_root_two_modulus` | root | 函數 |
| `cube_root_unit_vector` | root | 函數 |
| `double_dyadic_interval` | root | 函數 |
| `numeric_mat_max_deviation` | root | 函數 |
| `numeric_projector_residual` | root | 函數 |
| `qcc_add` | root | 函數 |
| `qcc_conj` | root | 函數 |
| `qcc_eq` | root | 函數 |
| `qcc_i` | root | 函數 |
| `qcc_is_zero` | root | 函數 |
| `qcc_make` | root | 函數 |
| `qcc_mul` | root | 函數 |
| `qcc_neg` | root | 函數 |
| `qcc_one` | root | 函數 |
| `qcc_rat` | root | 函數 |
| `qcc_real` | root | 函數 |
| `qcc_scale_quad` | root | 函數 |
| `qcc_sub` | root | 函數 |
| `qcc_to_complex` | root | 函數 |
| `qcc_zero` | root | 函數 |

### 球面與懸掛 HIT

- 規範形式：Susp(X) 的 north/south 兩點與每點一條 meridian；S²=Susp(S¹)、S³=Susp(S²)
- 範疇化：懸掛是把 X×I 兩端各塌縮為一點的 HIT 商；迭代懸掛給出球面族
- 判定：generic HIT schema 驗證、meridian 端點 face 化簡、依賴消去與 hcomp

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_sphere3` | root | 函數 |
| `sphere2_north_term` | root | 函數 |
| `sphere2_north_value` | root | 函數 |
| `sphere2_schema` | root | 函數 |
| `sphere3_meridian_term` | root | 函數 |
| `sphere3_meridian_value` | root | 函數 |
| `sphere3_north_term` | root | 函數 |
| `sphere3_north_value` | root | 函數 |
| `sphere3_schema` | root | 函數 |
| `sphere3_south_term` | root | 函數 |
| `sphere3_south_value` | root | 函數 |
| `sphere3_type_term` | root | 函數 |
| `sphere3_type_value` | root | 函數 |
| `sphere_schema` | root | 函數 |
| `suspension_schema` | root | 函數 |

### Jacobi 區間譜迭代

- 規範形式：RatInterval/CInterval 矩形包絡與 dyadic 外向捨入後的 Hermitian 區間矩陣；每次旋轉保存 before/after 與累積酉變換
- 範疇化：Hermitian 相似變換在區間矩陣包絡上的單調提升；Gershgorin 圓盤給出譜的像分解與重數簇
- 判定：精確有理平方比較證明 sqrt/相位/c/s 包絡包含真值；逐旋轉重算 J†J−I∋0 與 J†AJ⊆after，最終圓盤分簇計數；特徵值簇分離以平方自由部分（Sturm 鏈＋與導數 gcd）的 Sturm 區間對原多項式計數回多重數，區間重疊唯一匹配

| 符號 | 套件 | 類別 |
|---|---|---|
| `CInterval` | algebra | 結構 |
| `CInterval.im` | algebra | 欄位 |
| `CInterval.re` | algebra | 欄位 |
| `CInterval::equal` | algebra | 函數 |
| `CInterval::not_equal` | algebra | 函數 |
| `CInterval::to_repr` | algebra | 函數 |
| `EigenInterval` | algebra | 結構 |
| `EigenInterval.count` | algebra | 欄位 |
| `EigenInterval.hi` | algebra | 欄位 |
| `EigenInterval.lo` | algebra | 欄位 |
| `EigenInterval::equal` | algebra | 函數 |
| `EigenInterval::not_equal` | algebra | 函數 |
| `EigenInterval::to_repr` | algebra | 函數 |
| `JacobiCertificate` | algebra | 結構 |
| `JacobiCertificate.eigenvalues` | algebra | 欄位 |
| `JacobiCertificate.final_matrix` | algebra | 欄位 |
| `JacobiCertificate.initial` | algebra | 欄位 |
| `JacobiCertificate.precision_bits` | algebra | 欄位 |
| `JacobiCertificate.rotations` | algebra | 欄位 |
| `JacobiCertificate.transform` | algebra | 欄位 |
| `JacobiCertificate::equal` | algebra | 函數 |
| `JacobiCertificate::not_equal` | algebra | 函數 |
| `JacobiCertificate::to_repr` | algebra | 函數 |
| `JacobiClusterSeparation` | algebra | 結構 |
| `JacobiClusterSeparation.complete` | algebra | 欄位 |
| `JacobiClusterSeparation.intervals` | algebra | 欄位 |
| `JacobiClusterSeparation::equal` | algebra | 函數 |
| `JacobiClusterSeparation::not_equal` | algebra | 函數 |
| `JacobiClusterSeparation::to_repr` | algebra | 函數 |
| `JacobiCoefficients` | algebra | 結構 |
| `JacobiCoefficients.cosine` | algebra | 欄位 |
| `JacobiCoefficients.modulus` | algebra | 欄位 |
| `JacobiCoefficients.p` | algebra | 欄位 |
| `JacobiCoefficients.phase` | algebra | 欄位 |
| `JacobiCoefficients.q` | algebra | 欄位 |
| `JacobiCoefficients.sine` | algebra | 欄位 |
| `JacobiCoefficients::equal` | algebra | 函數 |
| `JacobiCoefficients::not_equal` | algebra | 函數 |
| `JacobiCoefficients::to_repr` | algebra | 函數 |
| `JacobiRotationCertificate` | algebra | 結構 |
| `JacobiRotationCertificate.after` | algebra | 欄位 |
| `JacobiRotationCertificate.after_off_sq_upper` | algebra | 欄位 |
| `JacobiRotationCertificate.before` | algebra | 欄位 |
| `JacobiRotationCertificate.before_off_sq_upper` | algebra | 欄位 |
| `JacobiRotationCertificate.coeffs` | algebra | 欄位 |
| `JacobiRotationCertificate.transform_after` | algebra | 欄位 |
| `JacobiRotationCertificate.transform_before` | algebra | 欄位 |
| `JacobiRotationCertificate.unitary_residual_contains_zero` | algebra | 欄位 |
| `JacobiRotationCertificate::equal` | algebra | 函數 |
| `JacobiRotationCertificate::not_equal` | algebra | 函數 |
| `JacobiRotationCertificate::to_repr` | algebra | 函數 |
| `QCIntervalMat` | algebra | 結構 |
| `QCIntervalMat.n` | algebra | 欄位 |
| `QCIntervalMat.rows` | algebra | 欄位 |
| `QCIntervalMat::equal` | algebra | 函數 |
| `QCIntervalMat::not_equal` | algebra | 函數 |
| `QCIntervalMat::to_repr` | algebra | 函數 |
| `QCpx` | algebra | 結構 |
| `QCpx.im` | algebra | 欄位 |
| `QCpx.re` | algebra | 欄位 |
| `QCpx::equal` | algebra | 函數 |
| `QCpx::not_equal` | algebra | 函數 |
| `QCpx::to_repr` | algebra | 函數 |
| `QCpxMat` | algebra | 結構 |
| `QCpxMat.n` | algebra | 欄位 |
| `QCpxMat.rows` | algebra | 欄位 |
| `QCpxMat::equal` | algebra | 函數 |
| `QCpxMat::not_equal` | algebra | 函數 |
| `QCpxMat::to_repr` | algebra | 函數 |
| `RatInterval` | algebra | 結構 |
| `RatInterval.hi` | algebra | 欄位 |
| `RatInterval.lo` | algebra | 欄位 |
| `RatInterval::equal` | algebra | 函數 |
| `RatInterval::not_equal` | algebra | 函數 |
| `RatInterval::to_repr` | algebra | 函數 |
| `SeparatedEigenInterval` | algebra | 結構 |
| `SeparatedEigenInterval.cluster` | algebra | 欄位 |
| `SeparatedEigenInterval.hi` | algebra | 欄位 |
| `SeparatedEigenInterval.lo` | algebra | 欄位 |
| `SeparatedEigenInterval.multiplicity` | algebra | 欄位 |
| `SeparatedEigenInterval::equal` | algebra | 函數 |
| `SeparatedEigenInterval::not_equal` | algebra | 函數 |
| `SeparatedEigenInterval::to_repr` | algebra | 函數 |
| `check_jacobi_cluster_separation` | algebra | 函數 |
| `cinterval` | algebra | 函數 |
| `cinterval_add` | algebra | 函數 |
| `cinterval_conj` | algebra | 函數 |
| `cinterval_contains` | algebra | 函數 |
| `cinterval_hull` | algebra | 函數 |
| `cinterval_midpoint` | algebra | 函數 |
| `cinterval_mul` | algebra | 函數 |
| `cinterval_neg` | algebra | 函數 |
| `cinterval_normalize` | algebra | 函數 |
| `cinterval_one` | algebra | 函數 |
| `cinterval_point` | algebra | 函數 |
| `cinterval_sub` | algebra | 函數 |
| `cinterval_subset` | algebra | 函數 |
| `cinterval_zero` | algebra | 函數 |
| `eigen_interval_contains` | algebra | 函數 |
| `jacobi_certificate_sound` | algebra | 函數 |
| `jacobi_cluster_separation_certified` | algebra | 函數 |
| `jacobi_coefficients` | algebra | 函數 |
| `jacobi_interval_eigen` | algebra | 函數 |
| `jacobi_separate_clusters` | algebra | 函數 |
| `jacobi_similarity_interval` | algebra | 函數 |
| `jacobi_unitary_interval` | algebra | 函數 |
| `jacobi_unitary_residual_contains_zero` | algebra | 函數 |
| `qci_mat_add` | algebra | 函數 |
| `qci_mat_adjoint` | algebra | 函數 |
| `qci_mat_contains` | algebra | 函數 |
| `qci_mat_contains_point` | algebra | 函數 |
| `qci_mat_from_point` | algebra | 函數 |
| `qci_mat_from_rows` | algebra | 函數 |
| `qci_mat_hermitian_hull` | algebra | 函數 |
| `qci_mat_identity` | algebra | 函數 |
| `qci_mat_is_hermitian` | algebra | 函數 |
| `qci_mat_midpoint` | algebra | 函數 |
| `qci_mat_mul` | algebra | 函數 |
| `qci_mat_normalize` | algebra | 函數 |
| `qci_mat_sub` | algebra | 函數 |
| `qci_mat_zero` | algebra | 函數 |
| `qci_off_frobenius_sq_upper` | algebra | 函數 |
| `qcpx` | algebra | 函數 |
| `qcpx_is_zero` | algebra | 函數 |
| `qcpx_mat_from_qmat` | algebra | 函數 |
| `qcpx_mat_from_rows` | algebra | 函數 |
| `qcpx_mat_is_hermitian` | algebra | 函數 |
| `qcpx_real` | algebra | 函數 |
| `rat_abs_exact` | algebra | 函數 |
| `rat_cmp_exact` | algebra | 函數 |
| `rat_interval` | algebra | 函數 |
| `rat_interval_abs` | algebra | 函數 |
| `rat_interval_add` | algebra | 函數 |
| `rat_interval_contains` | algebra | 函數 |
| `rat_interval_div` | algebra | 函數 |
| `rat_interval_hull` | algebra | 函數 |
| `rat_interval_midpoint` | algebra | 函數 |
| `rat_interval_mul` | algebra | 函數 |
| `rat_interval_neg` | algebra | 函數 |
| `rat_interval_normalize` | algebra | 函數 |
| `rat_interval_point` | algebra | 函數 |
| `rat_interval_recip` | algebra | 函數 |
| `rat_interval_sqrt` | algebra | 函數 |
| `rat_interval_sub` | algebra | 函數 |
| `rat_interval_subset` | algebra | 函數 |
| `rat_interval_width` | algebra | 函數 |
| `rat_le_exact` | algebra | 函數 |
| `rat_round_down_pow2` | algebra | 函數 |
| `rat_round_up_pow2` | algebra | 函數 |
| `rat_sqrt_interval` | algebra | 函數 |

### 高階合一與雙向 elaborator

- 規範形式：UTerm 的 Miller pattern spine `?F x₁…xₙ` 與 zonk 後 beta/投影簡化核心；表面 STerm 按名解析為 de Bruijn UTerm；HouSearchReport 記錄 status/nodes/branches/depth
- 範疇化：pattern HOU 是高階合一的可判定片斷；有界 Huet 搜尋在此之上以 transactional state 試 rigid/spine 分解、同頭不變座標、distinct flex-flex、imitation 與 projection；雙向 elaboration 把隱含引數與 dependent motive 問題送入同一合一器再編譯至依賴覈心
- 判定：確定性層以 WHNF 後 rigid 分解、pattern 抽象、occurs/scope 檢查與閉項 fallback 判定；搜尋層在節點與證明項深度預算內求 solved/no-unifier，否則以 residual 或 budget-exceeded 明示未定（一般 HOU 不可判定，不作完備宣稱）；check/infer 插入隱含 metavariables，未解者拒絕轉 DTerm；第十一期增加深層 imitation、projection 候選上限與同頭 identification，迭代加深以 HouIterativeReport 記錄輪次與求解深度

| 符號 | 套件 | 類別 |
|---|---|---|
| `ElabResult` | root | 結構 |
| `ElabResult.term` | root | 欄位 |
| `ElabResult.ty` | root | 欄位 |
| `ElabResult::equal` | root | 函數 |
| `ElabResult::not_equal` | root | 函數 |
| `ElabResult::to_repr` | root | 函數 |
| `ElabVar` | root | 結構 |
| `ElabVar.name` | root | 欄位 |
| `ElabVar.ty` | root | 欄位 |
| `ElabVar::equal` | root | 函數 |
| `ElabVar::not_equal` | root | 函數 |
| `ElabVar::to_repr` | root | 函數 |
| `Elaborator` | root | 結構 |
| `Elaborator.unifier` | root | 欄位 |
| `Elaborator.vars` | root | 欄位 |
| `Elaborator::equal` | root | 函數 |
| `Elaborator::not_equal` | root | 函數 |
| `Elaborator::to_repr` | root | 函數 |
| `HouIterativeReport` | root | 結構 |
| `HouIterativeReport.report` | root | 欄位 |
| `HouIterativeReport.rounds` | root | 欄位 |
| `HouIterativeReport.solved_at_depth` | root | 欄位 |
| `HouIterativeReport::equal` | root | 函數 |
| `HouIterativeReport::not_equal` | root | 函數 |
| `HouIterativeReport::to_repr` | root | 函數 |
| `HouSearchReport` | root | 結構 |
| `HouSearchReport.branches_tried` | root | 欄位 |
| `HouSearchReport.max_depth_reached` | root | 欄位 |
| `HouSearchReport.nodes` | root | 欄位 |
| `HouSearchReport.solved_metas` | root | 欄位 |
| `HouSearchReport.status` | root | 欄位 |
| `HouSearchReport::equal` | root | 函數 |
| `HouSearchReport::not_equal` | root | 函數 |
| `HouSearchReport::to_repr` | root | 函數 |
| `HouSearchStatus` | root | 列舉 |
| `HouSearchStatus::HouBudgetExceeded` | root | 構造子 |
| `HouSearchStatus::HouNoUnifier` | root | 構造子 |
| `HouSearchStatus::HouResidual` | root | 構造子 |
| `HouSearchStatus::HouSolved` | root | 構造子 |
| `HouSearchStatus::equal` | root | 函數 |
| `HouSearchStatus::not_equal` | root | 函數 |
| `HouSearchStatus::to_repr` | root | 函數 |
| `STerm` | root | 列舉 |
| `STerm::SAnn` | root | 構造子 |
| `STerm::SApp` | root | 構造子 |
| `STerm::SBoolLit` | root | 構造子 |
| `STerm::SFst` | root | 構造子 |
| `STerm::SHole` | root | 構造子 |
| `STerm::SLam` | root | 構造子 |
| `STerm::SNatElim` | root | 構造子 |
| `STerm::SNatZero` | root | 構造子 |
| `STerm::SPair` | root | 構造子 |
| `STerm::SSnd` | root | 構造子 |
| `STerm::SSucc` | root | 構造子 |
| `STerm::SUnitLit` | root | 構造子 |
| `STerm::SVar` | root | 構造子 |
| `STerm::equal` | root | 函數 |
| `STerm::not_equal` | root | 函數 |
| `STerm::to_repr` | root | 函數 |
| `UMetaInfo` | root | 結構 |
| `UMetaInfo.context_depth` | root | 欄位 |
| `UMetaInfo.solution` | root | 欄位 |
| `UMetaInfo::equal` | root | 函數 |
| `UMetaInfo::not_equal` | root | 函數 |
| `UMetaInfo::to_repr` | root | 函數 |
| `UTerm` | root | 列舉 |
| `UTerm::UApp` | root | 構造子 |
| `UTerm::UBoolLit` | root | 構造子 |
| `UTerm::UConst` | root | 構造子 |
| `UTerm::UFst` | root | 構造子 |
| `UTerm::UImplicitPi` | root | 構造子 |
| `UTerm::ULam` | root | 構造子 |
| `UTerm::UMeta` | root | 構造子 |
| `UTerm::UNatElim` | root | 構造子 |
| `UTerm::UNatZero` | root | 構造子 |
| `UTerm::UPair` | root | 構造子 |
| `UTerm::UPi` | root | 構造子 |
| `UTerm::USigma` | root | 構造子 |
| `UTerm::USnd` | root | 構造子 |
| `UTerm::USucc` | root | 構造子 |
| `UTerm::UType` | root | 構造子 |
| `UTerm::UVar` | root | 構造子 |
| `UTerm::equal` | root | 函數 |
| `UTerm::not_equal` | root | 函數 |
| `UTerm::to_repr` | root | 函數 |
| `Unifier` | root | 結構 |
| `Unifier.metas` | root | 欄位 |
| `Unifier.solved_count` | root | 欄位 |
| `Unifier::equal` | root | 函數 |
| `Unifier::not_equal` | root | 函數 |
| `Unifier::to_repr` | root | 函數 |
| `check_hou_bounded_search` | root | 函數 |
| `check_hou_elaborator` | root | 函數 |
| `check_hou_phase9_extensions` | root | 函數 |
| `check_hou_search_extensions` | root | 函數 |
| `elab_check` | root | 函數 |
| `elab_infer` | root | 函數 |
| `elab_result_to_dterm` | root | 函數 |
| `elab_type_to_dterm` | root | 函數 |
| `elaborator_new` | root | 函數 |
| `hou_fresh_meta` | root | 函數 |
| `hou_search_unify` | root | 函數 |
| `hou_search_unify_bool` | root | 函數 |
| `hou_search_unify_iterative` | root | 函數 |
| `hou_search_unify_iterative_bool` | root | 函數 |
| `hou_semantic_optimize` | root | 函數 |
| `hou_unify` | root | 函數 |
| `unifier_new` | root | 函數 |
| `uterm_contains_unsolved_meta` | root | 函數 |
| `uterm_whnf` | root | 函數 |
| `uty_arrow` | root | 函數 |
| `uty_bool` | root | 函數 |
| `uty_implicit_arrow` | root | 函數 |
| `uty_nat` | root | 函數 |
| `uty_unit` | root | 函數 |

### 參數化模組與名字空間

- 規範形式：模組 telescope（參數→以 ModuleItem 交錯的 imports 與本地宣告；舊 decls-only 建構仍可讀，語義為全部 imports 前置）與分離的 name→ordinal bindings；實例是同時代換後的閉合宣告
- 範疇化：參數化模組是模組函子，import 是函子套用的內聯，open/alias/rename 是同一 telescope entry 的不同名字投影
- 判定：循環檢測、參數引數依賴檢查、import 選擇/隱藏/改名的歧義拒絕、opaque export 中性化，以及實例閉合後逐宣告 dep_check

| 符號 | 套件 | 類別 |
|---|---|---|
| `ModuleBinding` | root | 結構 |
| `ModuleBinding.name` | root | 欄位 |
| `ModuleBinding.ordinal` | root | 欄位 |
| `ModuleBinding::equal` | root | 函數 |
| `ModuleBinding::not_equal` | root | 函數 |
| `ModuleBinding::to_repr` | root | 函數 |
| `ModuleDecl` | root | 結構 |
| `ModuleDecl.body` | root | 欄位 |
| `ModuleDecl.exported` | root | 欄位 |
| `ModuleDecl.name` | root | 欄位 |
| `ModuleDecl.transparent` | root | 欄位 |
| `ModuleDecl.ty` | root | 欄位 |
| `ModuleDecl::equal` | root | 函數 |
| `ModuleDecl::not_equal` | root | 函數 |
| `ModuleDecl::to_repr` | root | 函數 |
| `ModuleDef` | root | 結構 |
| `ModuleDef.decls` | root | 欄位 |
| `ModuleDef.imports` | root | 欄位 |
| `ModuleDef.items` | root | 欄位 |
| `ModuleDef.opens` | root | 欄位 |
| `ModuleDef.params` | root | 欄位 |
| `ModuleDef.path` | root | 欄位 |
| `ModuleDef::equal` | root | 函數 |
| `ModuleDef::not_equal` | root | 函數 |
| `ModuleDef::to_repr` | root | 函數 |
| `ModuleEntry` | root | 結構 |
| `ModuleEntry.body` | root | 欄位 |
| `ModuleEntry.canonical_name` | root | 欄位 |
| `ModuleEntry.exported` | root | 欄位 |
| `ModuleEntry.local_name` | root | 欄位 |
| `ModuleEntry.source_module` | root | 欄位 |
| `ModuleEntry.transparent` | root | 欄位 |
| `ModuleEntry.ty` | root | 欄位 |
| `ModuleEntry::equal` | root | 函數 |
| `ModuleEntry::not_equal` | root | 函數 |
| `ModuleEntry::to_repr` | root | 函數 |
| `ModuleEnv` | root | 結構 |
| `ModuleEnv.modules` | root | 欄位 |
| `ModuleEnv::equal` | root | 函數 |
| `ModuleEnv::not_equal` | root | 函數 |
| `ModuleEnv::to_repr` | root | 函數 |
| `ModuleExport` | root | 結構 |
| `ModuleExport.name` | root | 欄位 |
| `ModuleExport.ordinal` | root | 欄位 |
| `ModuleExport.transparent` | root | 欄位 |
| `ModuleExport::equal` | root | 函數 |
| `ModuleExport::not_equal` | root | 函數 |
| `ModuleExport::to_repr` | root | 函數 |
| `ModuleImport` | root | 結構 |
| `ModuleImport.alias_name` | root | 欄位 |
| `ModuleImport.args` | root | 欄位 |
| `ModuleImport.hiding` | root | 欄位 |
| `ModuleImport.module_path` | root | 欄位 |
| `ModuleImport.only` | root | 欄位 |
| `ModuleImport.opened` | root | 欄位 |
| `ModuleImport.renames` | root | 欄位 |
| `ModuleImport::equal` | root | 函數 |
| `ModuleImport::not_equal` | root | 函數 |
| `ModuleImport::to_repr` | root | 函數 |
| `ModuleInstance` | root | 結構 |
| `ModuleInstance.bindings` | root | 欄位 |
| `ModuleInstance.decls` | root | 欄位 |
| `ModuleInstance.module_path` | root | 欄位 |
| `ModuleInstance::equal` | root | 函數 |
| `ModuleInstance::not_equal` | root | 函數 |
| `ModuleInstance::to_repr` | root | 函數 |
| `ModuleInstanceDecl` | root | 結構 |
| `ModuleInstanceDecl.body` | root | 欄位 |
| `ModuleInstanceDecl.canonical_name` | root | 欄位 |
| `ModuleInstanceDecl.exported` | root | 欄位 |
| `ModuleInstanceDecl.name` | root | 欄位 |
| `ModuleInstanceDecl.transparent` | root | 欄位 |
| `ModuleInstanceDecl.ty` | root | 欄位 |
| `ModuleInstanceDecl::equal` | root | 函數 |
| `ModuleInstanceDecl::not_equal` | root | 函數 |
| `ModuleInstanceDecl::to_repr` | root | 函數 |
| `ModuleItem` | root | 列舉 |
| `ModuleItem::ModuleItemDecl` | root | 構造子 |
| `ModuleItem::ModuleItemImport` | root | 構造子 |
| `ModuleItem::equal` | root | 函數 |
| `ModuleItem::not_equal` | root | 函數 |
| `ModuleItem::to_repr` | root | 函數 |
| `ModuleRename` | root | 結構 |
| `ModuleRename.from_name` | root | 欄位 |
| `ModuleRename.to_name` | root | 欄位 |
| `ModuleRename::equal` | root | 函數 |
| `ModuleRename::not_equal` | root | 函數 |
| `ModuleRename::to_repr` | root | 函數 |
| `ModuleSignature` | root | 結構 |
| `ModuleSignature.bindings` | root | 欄位 |
| `ModuleSignature.entries` | root | 欄位 |
| `ModuleSignature.exports` | root | 欄位 |
| `ModuleSignature.module_path` | root | 欄位 |
| `ModuleSignature::equal` | root | 函數 |
| `ModuleSignature::not_equal` | root | 函數 |
| `ModuleSignature::to_repr` | root | 函數 |
| `bool_ops_module` | root | 函數 |
| `check_module_interleaved_items` | root | 函數 |
| `check_module_system` | root | 函數 |
| `generic_iterate_module` | root | 函數 |
| `module_decl` | root | 函數 |
| `module_def` | root | 函數 |
| `module_env_add` | root | 函數 |
| `module_env_find` | root | 函數 |
| `module_env_new` | root | 函數 |
| `module_example_env` | root | 函數 |
| `module_import` | root | 函數 |
| `module_instance_find` | root | 函數 |
| `module_instantiate` | root | 函數 |
| `module_ref` | root | 函數 |
| `module_rename` | root | 函數 |
| `module_resolve` | root | 函數 |
| `module_signature` | root | 函數 |
| `module_validate` | root | 函數 |

### 立方體演算法

- 規範形式：KanBox 打包型別線、系統與 base；transport filler 是 PathP；路徑傳遞是 hcomp 方塊的頂邊
- 範疇化：cubical CwF 中由 Kan 纖維化結構生成的路徑物件運算：反演、串接、函子性與依賴代入
- 判定：派遣至覈心 coe/comp/fill 並以轉換驗證端點；閉項 builders 再由 dep_check_closed 驗收

| 符號 | 套件 | 類別 |
|---|---|---|
| `KanBox` | root | 結構 |
| `KanBox.base` | root | 欄位 |
| `KanBox.dlevel` | root | 欄位 |
| `KanBox.line` | root | 欄位 |
| `KanBox.system` | root | 欄位 |
| `check_cubical_algorithms` | root | 函數 |
| `dfunext_term` | root | 函數 |
| `dpath_at_value` | root | 函數 |
| `dpath_cong_term` | root | 函數 |
| `dpath_cong_value` | root | 函數 |
| `dpath_funext_value` | root | 函數 |
| `dpath_prefix_value` | root | 函數 |
| `dpath_refl_term` | root | 函數 |
| `dpath_refl_value` | root | 函數 |
| `dpath_segment_value` | root | 函數 |
| `dpath_sym_term` | root | 函數 |
| `dpath_sym_value` | root | 函數 |
| `dpath_trans_square_value` | root | 函數 |
| `dpath_trans_term` | root | 函數 |
| `dpath_trans_value` | root | 函數 |
| `dtransport_back_term` | root | 函數 |
| `dtransport_term` | root | 函數 |
| `kan_box` | root | 函數 |
| `kan_box_comp` | root | 函數 |
| `kan_box_fill` | root | 函數 |
| `kan_box_pathp` | root | 函數 |
| `subst_pathp_value` | root | 函數 |
| `subst_value` | root | 函數 |
| `transport_back_value` | root | 函數 |
| `transport_checked_line_value` | root | 函數 |
| `transport_filler_value` | root | 函數 |
| `transport_pathp_value` | root | 函數 |
| `transport_value` | root | 函數 |

### 計算性單值性（univalence）

- 規範形式：有限宇宙路徑以 wiring 等價為範形；依賴宇宙路徑是受檢查型別線，pathToEquiv 取其 coe 等價，ua 取 Glue 線，uaβ 是 transport filler 的 unglue，往返由 Equiv 同倫與二維 Glue 方塊見證
- 範疇化：宇宙路徑範疇與等價之間的等價 (Equiv A B) ≃ Path U A B；Glue 沿等價黏合，transport 是其 coe 函子
- 判定：有限側以 wiring 相等；AST 側以 coe/comp 計算並以型別導向轉換驗證往返端點與方塊四邊；閉項 pathToEquiv 的 fill/coe 證明由依賴檢查器驗收

| 符號 | 套件 | 類別 |
|---|---|---|
| `UniversePath` | root | 結構 |
| `UniversePath.dst` | root | 欄位 |
| `UniversePath.level` | root | 欄位 |
| `UniversePath.line` | root | 欄位 |
| `UniversePath.src` | root | 欄位 |
| `check_finite_univalence` | root | 函數 |
| `check_univalence` | root | 函數 |
| `equiv_to_universe_path_value` | root | 函數 |
| `finite_transport` | root | 函數 |
| `path_to_equiv_map_term` | root | 函數 |
| `path_to_equiv_term` | root | 函數 |
| `path_to_equiv_value` | root | 函數 |
| `transport_roundtrip_path_value` | root | 函數 |
| `ua_beta_back_path_value` | root | 函數 |
| `ua_beta_path_value` | root | 函數 |
| `ua_map_term` | root | 函數 |
| `ua_transport_value` | root | 函數 |
| `univalence_equiv_value` | root | 函數 |
| `univalence_retr_path_value` | root | 函數 |
| `univalence_sect_square_value` | root | 函數 |
| `universe_path_normal_form` | root | 函數 |
| `universe_path_of_checked_line` | root | 函數 |
| `universe_path_of_ua_term_closed` | root | 函數 |
| `universe_path_path_value` | root | 函數 |
| `universe_path_to_equiv_value` | root | 函數 |
| `universe_path_transport_conv` | root | 函數 |
| `upath_refl` | root | 函數 |
| `upath_sym` | root | 函數 |
| `upath_to_equiv` | root | 函數 |
| `upath_trans` | root | 函數 |

### 完備精確代數與根隔離

- 規範形式：BigInt 有理數；Q[x] 不可約因式與重數；Sturm 實根區間與不交 Rouché 複圓盤；逐次代數塔中的分裂根；去巢根式表達式；雙二次數以至多兩個無平方因子基底 d₁,d₂ 及基底 [1,√d₁,√d₂,√(d₁d₂)] 上的有理係數表示
- 範疇化：Q[x] 唯一因式分解、代數閉包中的根多重集與有限分裂擴張；AlgPoly 是擴張係數多項式
- 判定：因式分解先行自適應 mod-p 次數圖樣與有理根剪枝再行 Kronecker 列舉；Sturm 計數、Cauchy 正方形 Taylor 排除與 Rouché 細分；根式去巢在雙二次域內以共軛範數與代數數平方根判定（真正雙二次被開方數需另一雙二次或更高 multicubic 根者為明示界限）；證書皆以精確多項式重算

| 符號 | 套件 | 類別 |
|---|---|---|
| `AlgPoly` | algebra | 結構 |
| `AlgPoly.coeffs` | algebra | 欄位 |
| `AlgPoly.modulus` | algebra | 欄位 |
| `AlgPolyDiv` | algebra | 結構 |
| `AlgPolyDiv.quotient` | algebra | 欄位 |
| `AlgPolyDiv.remainder` | algebra | 欄位 |
| `AlgPolyFactor` | algebra | 結構 |
| `AlgPolyFactor.factor` | algebra | 欄位 |
| `AlgPolyFactor.multiplicity` | algebra | 欄位 |
| `BiquadNum` | algebra | 結構 |
| `BiquadNum.basis` | algebra | 欄位 |
| `BiquadNum.coeffs` | algebra | 欄位 |
| `BiquadNum::equal` | algebra | 函數 |
| `BiquadNum::not_equal` | algebra | 函數 |
| `BiquadNum::to_repr` | algebra | 函數 |
| `ComplexDisk` | algebra | 結構 |
| `ComplexDisk.im` | algebra | 欄位 |
| `ComplexDisk.radius` | algebra | 欄位 |
| `ComplexDisk.re` | algebra | 欄位 |
| `ComplexRootIsolation` | algebra | 結構 |
| `ComplexRootIsolation.disk` | algebra | 欄位 |
| `ComplexRootIsolation.multiplicity` | algebra | 欄位 |
| `ComplexRootIsolation.polynomial` | algebra | 欄位 |
| `QPolyCompleteFactorization` | algebra | 結構 |
| `QPolyCompleteFactorization.factors` | algebra | 欄位 |
| `QPolyCompleteFactorization.leading` | algebra | 欄位 |
| `QPolyDegreePattern` | algebra | 結構 |
| `QPolyDegreePattern.degrees` | algebra | 欄位 |
| `QPolyDegreePattern.prime` | algebra | 欄位 |
| `RadicalExpr` | algebra | 列舉 |
| `RadicalExpr::RAdd` | algebra | 構造子 |
| `RadicalExpr::RDiv` | algebra | 構造子 |
| `RadicalExpr::RMul` | algebra | 構造子 |
| `RadicalExpr::RNeg` | algebra | 構造子 |
| `RadicalExpr::RRat` | algebra | 構造子 |
| `RadicalExpr::RRoot` | algebra | 構造子 |
| `RadicalExpr::RSub` | algebra | 構造子 |
| `RealRootIsolation` | algebra | 結構 |
| `RealRootIsolation.lower` | algebra | 欄位 |
| `RealRootIsolation.multiplicity` | algebra | 欄位 |
| `RealRootIsolation.polynomial` | algebra | 欄位 |
| `RealRootIsolation.upper` | algebra | 欄位 |
| `SplittingField` | algebra | 結構 |
| `SplittingField.modulus` | algebra | 欄位 |
| `SplittingField.roots` | algebra | 欄位 |
| `SplittingRoot` | algebra | 結構 |
| `SplittingRoot.multiplicity` | algebra | 欄位 |
| `SplittingRoot.value` | algebra | 欄位 |
| `algpoly_add` | algebra | 函數 |
| `algpoly_degree` | algebra | 函數 |
| `algpoly_derivative` | algebra | 函數 |
| `algpoly_div_exact` | algebra | 函數 |
| `algpoly_divmod` | algebra | 函數 |
| `algpoly_eq` | algebra | 函數 |
| `algpoly_eval` | algebra | 函數 |
| `algpoly_factor_complete` | algebra | 函數 |
| `algpoly_from_qpoly` | algebra | 函數 |
| `algpoly_gcd` | algebra | 函數 |
| `algpoly_is_zero` | algebra | 函數 |
| `algpoly_mod` | algebra | 函數 |
| `algpoly_monic` | algebra | 函數 |
| `algpoly_mul` | algebra | 函數 |
| `algpoly_norm_shifted` | algebra | 函數 |
| `algpoly_one` | algebra | 函數 |
| `algpoly_pow` | algebra | 函數 |
| `algpoly_scale` | algebra | 函數 |
| `algpoly_squarefree_factorization` | algebra | 函數 |
| `algpoly_sub` | algebra | 函數 |
| `algpoly_zero` | algebra | 函數 |
| `bigint_abs` | algebra | 函數 |
| `bigint_divisors` | algebra | 函數 |
| `bigint_gcd` | algebra | 函數 |
| `bigint_lcm` | algebra | 函數 |
| `bigint_nth_root_exact` | algebra | 函數 |
| `bigint_nth_root_floor` | algebra | 函數 |
| `bigint_prime_factorization` | algebra | 函數 |
| `bigint_sqrt_exact` | algebra | 函數 |
| `bigint_sqrt_floor` | algebra | 函數 |
| `bigint_squarefree_decomp` | algebra | 函數 |
| `bigint_to_double` | algebra | 函數 |
| `biquad_add` | algebra | 函數 |
| `biquad_div` | algebra | 函數 |
| `biquad_eq` | algebra | 函數 |
| `biquad_inv` | algebra | 函數 |
| `biquad_mul` | algebra | 函數 |
| `biquad_neg` | algebra | 函數 |
| `biquad_of_quad` | algebra | 函數 |
| `biquad_rat` | algebra | 函數 |
| `biquad_sign` | algebra | 函數 |
| `biquad_sqrt` | algebra | 函數 |
| `biquad_sqrt_rat` | algebra | 函數 |
| `biquad_sub` | algebra | 函數 |
| `biquad_to_radical` | algebra | 函數 |
| `biquad_zero` | algebra | 函數 |
| `check_biquadratic_denesting` | algebra | 函數 |
| `check_qpoly_factor_complete` | algebra | 函數 |
| `check_qpoly_mod_pattern_pruning` | algebra | 函數 |
| `check_radical_denesting` | algebra | 函數 |
| `check_root_isolation` | algebra | 函數 |
| `check_splitting_field` | algebra | 函數 |
| `complex_root_isolations_are_certified` | algebra | 函數 |
| `qcpx_hermitian_charpoly` | algebra | 函數 |
| `qcpx_hermitian_eigenvalue_isolations` | algebra | 函數 |
| `qmat_symmetric_eigenvalue_isolations` | algebra | 函數 |
| `qpoly_complete_factorization_expand` | algebra | 函數 |
| `qpoly_factor_complete` | algebra | 函數 |
| `qpoly_factor_complete_with_budget` | algebra | 函數 |
| `qpoly_is_irreducible` | algebra | 函數 |
| `qpoly_isolate_complex_roots` | algebra | 函數 |
| `qpoly_isolate_real_roots` | algebra | 函數 |
| `qpoly_real_root_count` | algebra | 函數 |
| `qpoly_splitting_field` | algebra | 函數 |
| `qpoly_sturm_sequence` | algebra | 函數 |
| `qpoly_sturm_variations` | algebra | 函數 |
| `radical_equal_exact` | algebra | 函數 |
| `radical_int` | algebra | 函數 |
| `radical_rat` | algebra | 函數 |
| `radical_simplify` | algebra | 函數 |
| `radical_sqrt` | algebra | 函數 |
| `radical_to_biquad` | algebra | 函數 |
| `real_root_isolation_refine` | algebra | 函數 |
| `real_root_isolations_are_certified` | algebra | 函數 |
| `splitting_field_is_certified` | algebra | 函數 |

### 一等宇宙多態與同時宣告 schema

- 規範形式：DLevelDecl 的層級 binders 與實例化；透明算子展開後的正性函子；迭代編譯的非均勻巢狀族；聯合互歸納與同時 IR 規格
- 範疇化：宇宙 scheme、參數迭代初始代數、向量函子聯合初始代數與同步歸納—遞迴結構
- 判定：層級作用域、正性報告、生成 telescope 與依賴轉換；未實例化層級在覈心檢查拒絕

| 符號 | 套件 | 類別 |
|---|---|---|
| `DLevelDecl` | root | 列舉 |
| `DLevelDecl::DLevelHit` | root | 構造子 |
| `DLevelDecl::DLevelInductive` | root | 構造子 |
| `DLevelDecl::DLevelTerm` | root | 構造子 |
| `DLevelHitDecl` | root | 結構 |
| `DLevelHitDecl.binders` | root | 欄位 |
| `DLevelHitDecl.result_level` | root | 欄位 |
| `DLevelHitDecl.template` | root | 欄位 |
| `DLevelInductiveDecl` | root | 結構 |
| `DLevelInductiveDecl.binders` | root | 欄位 |
| `DLevelInductiveDecl.decode_level` | root | 欄位 |
| `DLevelInductiveDecl.result_level` | root | 欄位 |
| `DLevelInductiveDecl.template` | root | 欄位 |
| `DLevelTermDecl` | root | 結構 |
| `DLevelTermDecl.binders` | root | 欄位 |
| `DLevelTermDecl.body` | root | 欄位 |
| `DLevelTermDecl.name` | root | 欄位 |
| `DLevelTermDecl.ty` | root | 欄位 |
| `DLevelTermInstance` | root | 結構 |
| `DLevelTermInstance.body` | root | 欄位 |
| `DLevelTermInstance.ty` | root | 欄位 |
| `DMutualDecl` | root | 結構 |
| `DMutualDecl.components` | root | 欄位 |
| `DMutualDecl.name` | root | 欄位 |
| `DMutualPositivityReport` | root | 結構 |
| `DMutualPositivityReport.cross_edges` | root | 欄位 |
| `DMutualPositivityReport.offending_component` | root | 欄位 |
| `DMutualPositivityReport.strictly_positive` | root | 欄位 |
| `DNestedArg` | root | 列舉 |
| `DNestedArg::DNestedExternal` | root | 構造子 |
| `DNestedArg::DNestedRecursive` | root | 構造子 |
| `DNestedConstructor` | root | 結構 |
| `DNestedConstructor.args` | root | 欄位 |
| `DNestedConstructor.constraints` | root | 欄位 |
| `DNestedConstructor.name` | root | 欄位 |
| `DNestedIterDecl` | root | 結構 |
| `DNestedIterDecl.constructors` | root | 欄位 |
| `DNestedIterDecl.level` | root | 欄位 |
| `DNestedIterDecl.name` | root | 欄位 |
| `DNestedIterDecl.param_level` | root | 欄位 |
| `DNestedIterDecl.param_name` | root | 欄位 |
| `DNestedIterDecl.transform` | root | 欄位 |
| `DNestedIterFamily` | root | 結構 |
| `DNestedIterFamily.auxiliary` | root | 欄位 |
| `DNestedIterFamily.decl` | root | 欄位 |
| `DSimultaneousFunction` | root | 結構 |
| `DSimultaneousFunction.cases` | root | 欄位 |
| `DSimultaneousFunction.name` | root | 欄位 |
| `DSimultaneousFunction.result_type` | root | 欄位 |
| `DSimultaneousIRSpec` | root | 結構 |
| `DSimultaneousIRSpec.base` | root | 欄位 |
| `DSimultaneousIRSpec.functions` | root | 欄位 |
| `DTypeOperatorDecl` | root | 結構 |
| `DTypeOperatorDecl.body` | root | 欄位 |
| `DTypeOperatorDecl.head` | root | 欄位 |
| `DTypeOperatorDecl.name` | root | 欄位 |
| `bush_decl` | root | 函數 |
| `bush_family` | root | 函數 |
| `check_hit_moving_dimension_lift` | root | 函數 |
| `check_level_polymorphic_declarations` | root | 函數 |
| `check_mutual_declaration_positivity` | root | 函數 |
| `check_nested_iter_datatype` | root | 函數 |
| `check_simultaneous_induction_recursion` | root | 函數 |
| `check_simultaneous_ir_compiled_decode` | root | 函數 |
| `check_type_operator_positivity_extraction` | root | 函數 |
| `circle_level_decl` | root | 函數 |
| `code_interpretation_ir` | root | 函數 |
| `compile_nested_iter_decl` | root | 函數 |
| `darg_nested_from_type` | root | 函數 |
| `dlevel_expr_in_scope` | root | 函數 |
| `dmutual_decl` | root | 函數 |
| `dnested_constructor` | root | 函數 |
| `dnested_external` | root | 函數 |
| `dnested_iter_decl` | root | 函數 |
| `dnested_recursive` | root | 函數 |
| `dsimultaneous_function` | root | 函數 |
| `dsimultaneous_ir_spec` | root | 函數 |
| `dterm_instantiate_levels` | root | 函數 |
| `dterm_levels_in_scope` | root | 函數 |
| `dtype_operator_decl` | root | 函數 |
| `eval_simultaneous_ir` | root | 函數 |
| `extract_positive_functor` | root | 函數 |
| `level_decl_hit` | root | 函數 |
| `level_decl_inductive` | root | 函數 |
| `level_decl_term` | root | 函數 |
| `level_decl_validate` | root | 函數 |
| `level_hit_decl_validate` | root | 函數 |
| `level_identity_decl` | root | 函數 |
| `level_inductive_decl_validate` | root | 函數 |
| `level_term_decl_validate` | root | 函數 |
| `list_level_decl` | root | 函數 |
| `nat_parity_double_ir` | root | 函數 |
| `nested_iter_intro_term_at` | root | 函數 |
| `nested_iter_type_term` | root | 函數 |
| `simultaneous_ir_compile_decode` | root | 函數 |
| `simultaneous_ir_function_universe_level` | root | 函數 |
| `simultaneous_ir_uses_other_hypotheses` | root | 函數 |
| `simultaneous_ir_validate` | root | 函數 |
| `type_operator_is_strictly_positive` | root | 函數 |
| `type_operator_positivity` | root | 函數 |

### Adjoint 等價、纖維與命題截斷

- 規範形式：quasi-inverse 上加三角形 Path(Path)；improved counit；一般 fiber 的 Σ 點、lemIso 路徑與中心的收縮 (center, contraction)；PropTrunc 的 point/squash HIT
- 範疇化：half-adjoint equivalence、contractible fiber 的等價刻畫與到命題的截斷反射
- 判定：adjointify_equiv_value 與 equiv_contractible_fibers_value 由 hfill/hcomp/dpath 構造，端點與 Path(Path) 三角形以依賴檢查／轉換驗證（circle-中點等深層調整點按面-restriction 檢查）

| 符號 | 套件 | 類別 |
|---|---|---|
| `DAdjointEquivParts` | root | 結構 |
| `DAdjointEquivParts.equiv` | root | 欄位 |
| `DAdjointEquivParts.triangle` | root | 欄位 |
| `adjoint_equiv_make` | root | 函數 |
| `adjoint_equiv_to_equiv` | root | 函數 |
| `adjoint_equiv_type_term` | root | 函數 |
| `adjoint_id_value` | root | 函數 |
| `adjointify_equiv_value` | root | 函數 |
| `check_adjoint_equivalence_and_fibers` | root | 函數 |
| `check_general_adjointification_and_contractible_fibers` | root | 函數 |
| `check_lemiso_generic_points` | root | 函數 |
| `check_propositional_truncation` | root | 函數 |
| `contractible_fibers_type_term` | root | 函數 |
| `equiv_contractible_fibers_value` | root | 函數 |
| `equiv_fiber_center_value` | root | 函數 |
| `equiv_fiber_contraction_value` | root | 函數 |
| `equiv_fiber_path_value` | root | 函數 |
| `equiv_fiber_type_value` | root | 函數 |
| `equiv_improved_sect_value` | root | 函數 |
| `equiv_triangle_type` | root | 函數 |
| `equiv_with_improved_sect` | root | 函數 |
| `fiber_type_term` | root | 函數 |
| `identity_fibers_contractible_value` | root | 函數 |
| `is_contr_type_term` | root | 函數 |
| `prop_trunc_schema` | root | 函數 |
| `prop_trunc_schema_at` | root | 函數 |
| `singleton_contraction_value` | root | 函數 |
| `trunc_point_term` | root | 函數 |
| `trunc_rec_unit_term` | root | 函數 |
| `trunc_squash_path_term` | root | 函數 |
| `trunc_squash_term` | root | 函數 |
| `trunc_type_term` | root | 函數 |

### 球面同倫代表元與 Hopf 不變量

- 規範形式：Ωⁿ 的巢狀 Path；懸掛迭代的整數度數映射；極交換 S³ 的 HIT；C² 單位球上的 Hopf 映射與相位纖維；IntegerS 的 zero/posSucc/negSucc 唯一構造子範形與語義 succ/pred；π₃ 以 Ω³(Sphereₙ) 模命題截斷 Path 關係的 QuotientS 商呈現；SphereLoopExpr 的 generator 冪
- 範疇化：懸掛函子、基點映射與 loop space 的代表元；Hopf S¹-纖維化及其連結數；π₃ 商型是 loop space 模存在路徑關係的商呈現
- 判定：生成 meridian 轉換；三重迭代 suspension_unit 沿 transitivity-square cancellation 以 subst rebase 為懸掛的 loop；代表元運算的整數冪次以 end-to-end 檢查求值；Hopf 像/纖維代數檢查與立體投影後 Gauss 連結積分 |lk|=1。此層是代表元與典範冪，不宣稱一般合成 encode/decode 證明 π₃(S³)≅ℤ 或以 Hopf 不變量證明 π₃(S²)≅ℤ

| 符號 | 套件 | 類別 |
|---|---|---|
| `SphereLoopExpr` | root | 列舉 |
| `SphereLoopExpr::SphereLoopCompose` | root | 構造子 |
| `SphereLoopExpr::SphereLoopGenerator` | root | 構造子 |
| `SphereLoopExpr::SphereLoopInverse` | root | 構造子 |
| `SphereLoopExpr::SphereLoopRefl` | root | 構造子 |
| `SphereLoopExpr::equal` | root | 函數 |
| `SphereLoopExpr::not_equal` | root | 函數 |
| `SphereLoopExpr::to_repr` | root | 函數 |
| `based_map_type_term` | root | 函數 |
| `check_hopf_numeric` | root | 函數 |
| `check_sphere_homotopy_representatives` | root | 函數 |
| `check_sphere_loop_representatives_internal` | root | 函數 |
| `circle_degree_value` | root | 函數 |
| `circle_hit_base_value` | root | 函數 |
| `circle_hit_loop_path_value` | root | 函數 |
| `circle_hit_loop_power_value` | root | 函數 |
| `dpath_trans_sym_cancel_value` | root | 函數 |
| `homotopy_group_type_term` | root | 函數 |
| `hopf_linking_number_numeric` | root | 函數 |
| `hopf_map_s3_to_s2` | root | 函數 |
| `hopf_north_fiber` | root | 函數 |
| `hopf_phase_rotate` | root | 函數 |
| `hopf_south_fiber` | root | 函數 |
| `integer_pred_value` | root | 函數 |
| `integer_schema` | root | 函數 |
| `integer_succ_value` | root | 函數 |
| `integer_term` | root | 函數 |
| `integer_type_term` | root | 函數 |
| `integer_type_value` | root | 函數 |
| `integer_value` | root | 函數 |
| `iterated_refl_term` | root | 函數 |
| `iterated_refl_value` | root | 函數 |
| `loop_space_type_term` | root | 函數 |
| `loop_space_type_value` | root | 函數 |
| `pi3_sphere_point_term` | root | 函數 |
| `pi3_sphere_type_term` | root | 函數 |
| `sphere3_from_swapped_value` | root | 函數 |
| `sphere3_swapped_equiv_value` | root | 函數 |
| `sphere3_swapped_meridian_value` | root | 函數 |
| `sphere3_swapped_north_value` | root | 函數 |
| `sphere3_swapped_retr_value` | root | 函數 |
| `sphere3_swapped_schema` | root | 函數 |
| `sphere3_swapped_sect_value` | root | 函數 |
| `sphere3_swapped_south_value` | root | 函數 |
| `sphere3_swapped_type_term` | root | 函數 |
| `sphere3_to_swapped_value` | root | 函數 |
| `sphere_degree_function_value` | root | 函數 |
| `sphere_degree_value` | root | 函數 |
| `sphere_loop_compose_value` | root | 函數 |
| `sphere_loop_expr_degree` | root | 函數 |
| `sphere_loop_expr_of_integer` | root | 函數 |
| `sphere_loop_expr_value` | root | 函數 |
| `sphere_loop_power_value` | root | 函數 |
| `sphere_north_term` | root | 函數 |
| `sphere_north_value` | root | 函數 |
| `sphere_type_term` | root | 函數 |
| `sphere_type_value` | root | 函數 |
| `suspend_loop_value` | root | 函數 |
| `suspension_map_value` | root | 函數 |
| `suspension_meridian_path_value` | root | 函數 |
| `suspension_unit_loop_value` | root | 函數 |

### 模組分離編譯與連結

- 規範形式：CompiledModule 的展平已檢查 telescope、exports、依賴指紋與介面公共投影；抽象宣告 body=None；cache 以來源指紋索引；穩定二進位以 magic CHMODBIN＋版本 u16＋長度 u32＋校驗 u32＋payload（標籤位元組、固定寬度小端 i32、UTF-16LE 字串）表達，v2 在 v1 payload 後追加 producer 字串；CompiledModuleStore 保存模組 artifact 位元組並記錄命中/未命中
- 範疇化：模組函子的已編譯物件與 synthetic import-free 連結定義；prefix 特化是部分函子套用；序列化是 compiled module 的穩定外表示
- 判定：介面 hash 忽略 opaque body、實作 hash 覆蓋全部 entries；implementation 補足抽象 exports；cache 依來源與依賴介面指紋失效；解碼逐一拒絕 bad magic／版本／截斷／校驗／格式／尾隨位元組，並重跑 module 驗證與 fingerprint 一致性檢查；載入接受 v1/v2 並把 v1 遷移為缺省 producer，v2-only 節點（如 functor tag 8）於 v1 寫出時以 None 拒絕

| 符號 | 套件 | 類別 |
|---|---|---|
| `CompiledModule` | root | 結構 |
| `CompiledModule.dependencies` | root | 欄位 |
| `CompiledModule.entries` | root | 欄位 |
| `CompiledModule.exports` | root | 欄位 |
| `CompiledModule.format_version` | root | 欄位 |
| `CompiledModule.implementation_hash` | root | 欄位 |
| `CompiledModule.interface_encoding` | root | 欄位 |
| `CompiledModule.interface_hash` | root | 欄位 |
| `CompiledModule.module_path` | root | 欄位 |
| `CompiledModule.params` | root | 欄位 |
| `CompiledModule.producer` | root | 欄位 |
| `CompiledModule::equal` | root | 函數 |
| `CompiledModule::not_equal` | root | 函數 |
| `CompiledModule::to_repr` | root | 函數 |
| `CompiledModuleEnv` | root | 結構 |
| `CompiledModuleEnv.modules` | root | 欄位 |
| `CompiledModuleEnv::equal` | root | 函數 |
| `CompiledModuleEnv::not_equal` | root | 函數 |
| `CompiledModuleEnv::to_repr` | root | 函數 |
| `CompiledModuleStore` | root | 結構 |
| `CompiledModuleStore.blobs` | root | 欄位 |
| `CompiledModuleStore.hits` | root | 欄位 |
| `CompiledModuleStore.misses` | root | 欄位 |
| `CompiledModuleStoreStats` | root | 結構 |
| `CompiledModuleStoreStats.entries` | root | 欄位 |
| `CompiledModuleStoreStats.hits` | root | 欄位 |
| `CompiledModuleStoreStats.misses` | root | 欄位 |
| `CompiledModuleStoreStats.total_bytes` | root | 欄位 |
| `CompiledModuleStoreStats::equal` | root | 函數 |
| `CompiledModuleStoreStats::not_equal` | root | 函數 |
| `CompiledModuleStoreStats::to_repr` | root | 函數 |
| `ModuleBinaryLoad` | root | 結構 |
| `ModuleBinaryLoad.module_` | root | 欄位 |
| `ModuleBinaryLoad.status` | root | 欄位 |
| `ModuleBinaryLoad::equal` | root | 函數 |
| `ModuleBinaryLoad::not_equal` | root | 函數 |
| `ModuleBinaryLoad::to_repr` | root | 函數 |
| `ModuleBinaryStatus` | root | 列舉 |
| `ModuleBinaryStatus::ModuleBinaryBadMagic` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryChecksumMismatch` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryMalformed` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryOk` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryTrailingBytes` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryTruncated` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryUnsupportedVersion` | root | 構造子 |
| `ModuleBinaryStatus::ModuleBinaryValidationFailed` | root | 構造子 |
| `ModuleBinaryStatus::equal` | root | 函數 |
| `ModuleBinaryStatus::not_equal` | root | 函數 |
| `ModuleBinaryStatus::to_repr` | root | 函數 |
| `ModuleCompileCache` | root | 結構 |
| `ModuleCompileCache.entries` | root | 欄位 |
| `ModuleCompileCache::equal` | root | 函數 |
| `ModuleCompileCache::not_equal` | root | 函數 |
| `ModuleCompileCache::to_repr` | root | 函數 |
| `ModuleCompileCacheEntry` | root | 結構 |
| `ModuleCompileCacheEntry.compiled` | root | 欄位 |
| `ModuleCompileCacheEntry.fingerprint` | root | 欄位 |
| `ModuleCompileCacheEntry.module_path` | root | 欄位 |
| `ModuleCompileCacheEntry::equal` | root | 函數 |
| `ModuleCompileCacheEntry::not_equal` | root | 函數 |
| `ModuleCompileCacheEntry::to_repr` | root | 函數 |
| `ModuleDependencyFingerprint` | root | 結構 |
| `ModuleDependencyFingerprint.interface_hash` | root | 欄位 |
| `ModuleDependencyFingerprint.path` | root | 欄位 |
| `ModuleDependencyFingerprint::equal` | root | 函數 |
| `ModuleDependencyFingerprint::not_equal` | root | 函數 |
| `ModuleDependencyFingerprint::to_repr` | root | 函數 |
| `abstract_point_module` | root | 函數 |
| `check_module_binary_format` | root | 函數 |
| `check_module_binary_versions_and_store` | root | 函數 |
| `check_module_compilation` | root | 函數 |
| `compiled_module_binary_format_version` | root | 函數 |
| `compiled_module_binary_from_hex` | root | 函數 |
| `compiled_module_binary_supported_versions` | root | 函數 |
| `compiled_module_binary_to_hex` | root | 函數 |
| `compiled_module_binary_version_of` | root | 函數 |
| `compiled_module_env_add` | root | 函數 |
| `compiled_module_env_find` | root | 函數 |
| `compiled_module_env_new` | root | 函數 |
| `compiled_module_env_to_module_env` | root | 函數 |
| `compiled_module_format_version` | root | 函數 |
| `compiled_module_from_binary` | root | 函數 |
| `compiled_module_instantiate` | root | 函數 |
| `compiled_module_is_implementation` | root | 函數 |
| `compiled_module_load_binary` | root | 函數 |
| `compiled_module_load_binary_report` | root | 函數 |
| `compiled_module_migrate_binary` | root | 函數 |
| `compiled_module_producer_default` | root | 函數 |
| `compiled_module_specialize_prefix` | root | 函數 |
| `compiled_module_store_contains` | root | 函數 |
| `compiled_module_store_get` | root | 函數 |
| `compiled_module_store_new` | root | 函數 |
| `compiled_module_store_put` | root | 函數 |
| `compiled_module_store_stats` | root | 函數 |
| `compiled_module_to_binary` | root | 函數 |
| `compiled_module_to_binary_v1` | root | 函數 |
| `compiled_module_to_module_def` | root | 函數 |
| `compiled_module_validate` | root | 函數 |
| `module_compile` | root | 函數 |
| `module_compile_cache_lookup` | root | 函數 |
| `module_compile_cache_new` | root | 函數 |
| `module_compile_cache_size` | root | 函數 |
| `module_compile_cached` | root | 函數 |
| `module_compile_with_compiled` | root | 函數 |
| `module_decl_abstract` | root | 函數 |
| `module_dependency_fingerprint` | root | 函數 |
| `module_dependency_of_compiled` | root | 函數 |
| `module_link_instantiate` | root | 函數 |
| `module_link_signature` | root | 函數 |
| `module_source_fingerprint` | root | 函數 |
| `point_client_module` | root | 函數 |
| `point_implementation_module` | root | 函數 |

### 範疇化總檢

- 規範形式：範疇律的布爾合取
- 範疇化：彙總各範疇的身分／合成／相干律
- 判定：逐律求值

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_categories_all` | root | 函數 |

### 定理登記與範例

- 規範形式：(名稱, Bool) 登記列；具體見證向量／項
- 範疇化：可判定命題在見證上的實現
- 判定：moon test／登記表

| 符號 | 套件 | 類別 |
|---|---|---|
| `CheckResult` | root | 結構 |
| `CheckResult.name` | root | 欄位 |
| `CheckResult.ok` | root | 欄位 |
| `all_checks_pass` | root | 函數 |
| `check_Jacobi_arbitrary_precision` | algebra | 函數 |
| `check_Jacobi_interval` | algebra | 函數 |
| `check_constructor_constraints` | root | 函數 |
| `check_mutual_inductives` | root | 函數 |
| `check_quotient_schema` | root | 函數 |
| `check_universe_schemes` | root | 函數 |
| `example_projector` | root | 函數 |
| `example_unit` | root | 函數 |
| `grid` | root | 函數 |
| `inv_sqrt2` | root | 函數 |
| `print_report` | root | 函數 |
| `run_all_checks` | root | 函數 |
| `sample_terms` | root | 函數 |
| `sample_vectors` | root | 函數 |
| `vec_e3` | root | 函數 |

### 規格登記

- 規範形式：SpecEntry 六元組
- 範疇化：規格之規格；完備性對產生介面核對
- 判定：spec_registry_sound＋本審計

| 符號 | 套件 | 類別 |
|---|---|---|
| `SpecEntry` | root | 結構 |
| `SpecEntry.canonical` | root | 欄位 |
| `SpecEntry.categorical` | root | 欄位 |
| `SpecEntry.decision` | root | 欄位 |
| `SpecEntry.kind` | root | 欄位 |
| `SpecEntry.name` | root | 欄位 |
| `SpecEntry.symbols` | root | 欄位 |
| `SpecKind` | root | 列舉 |
| `SpecKind::SpecOperator` | root | 構造子 |
| `SpecKind::SpecStructure` | root | 構造子 |
| `SpecKind::SpecTheorem` | root | 構造子 |
| `SpecKind::SpecType` | root | 構造子 |
| `SpecKind::equal` | root | 函數 |
| `SpecKind::not_equal` | root | 函數 |
| `SpecKind::to_repr` | root | 函數 |
| `spec_count` | root | 函數 |
| `spec_covers` | root | 函數 |
| `spec_registry` | root | 函數 |
| `spec_registry_sound` | root | 函數 |

### 圓的萬有覆疊與 encode/decode

- 規範形式：覆疊纖維在 base 是 IntegerS 規範整數、在 loop 點是 ua 線的 GlueEquiv 型別；環路代表元為 schema 圓的 DVHitCell 路徑，繞數為規範整數值
- 範疇化：helix 是圓到宇宙的纖維化族；encode 是沿環路在覆疊中的 subst 提升端點，decode 是整數消去給出的環路冪
- 判定：base 纖維以宇宙層轉換等於 ℤ；生成元/逆/refl 的 subst 直接計算，複合環路以 transport 函子性細分（單次 subst 越過 trans 點時經宇宙 comp 的 Glue 線不串接等價，為已記錄的內涵邊界）；兩向往返在代表元上以轉換檢查

| 符號 | 套件 | 類別 |
|---|---|---|
| `check_circle_encode_decode` | root | 函數 |
| `circle_cover_value` | root | 函數 |
| `circle_decode_value` | root | 函數 |
| `circle_encode_pieces_value` | root | 函數 |
| `circle_encode_value` | root | 函數 |
| `circle_hit_type_value` | root | 函數 |
| `circle_loop_space_type_value` | root | 函數 |
| `integer_succ_equiv_value` | root | 函數 |

### 宿主不透明立方與開盒填充

- 規範形式：立方是宿主函數（維度列→語義值／有理多項式座標）；開盒為缺一面的邊界資料，帽是填充在缺面的限制
- 範疇化：□ 上外部立方資料與 Kan 填充條件的宿主實作；多項式立方是精確有理座標系中的立方映射，迭代開盒填充以 F += w·(S − F|face) 逐面修正
- 判定：邊界完整性與重疊相容以型別轉換／規範多項式相等逐面驗證；不相容或不完整給出失敗計數與拒絕

| 符號 | 套件 | 類別 |
|---|---|---|
| `DCubeBoxFace` | root | 結構 |
| `DCubeBoxFace.axis` | root | 欄位 |
| `DCubeBoxFace.cube` | root | 欄位 |
| `DCubeBoxFace.hi` | root | 欄位 |
| `DCubeBoxReport` | root | 結構 |
| `DCubeBoxReport.complete` | root | 欄位 |
| `DCubeBoxReport.failed_overlaps` | root | 欄位 |
| `DCubeBoxReport.overlaps_ok` | root | 欄位 |
| `DCubeFunction` | root | 結構 |
| `DCubeFunction.arity` | root | 欄位 |
| `DCubeFunction.at` | root | 欄位 |
| `DCubeOpenBox` | root | 結構 |
| `DCubeOpenBox.ambient_dlevel` | root | 欄位 |
| `DCubeOpenBox.arity` | root | 欄位 |
| `DCubeOpenBox.faces` | root | 欄位 |
| `DCubeOpenBox.ty` | root | 欄位 |
| `PolyBoxFace` | algebra | 結構 |
| `PolyBoxFace.axis` | algebra | 欄位 |
| `PolyBoxFace.cube` | algebra | 欄位 |
| `PolyBoxFace.hi` | algebra | 欄位 |
| `PolyCube` | algebra | 結構 |
| `PolyCube.coords` | algebra | 欄位 |
| `PolyCube.dim` | algebra | 欄位 |
| `PolyOpenBox` | algebra | 結構 |
| `PolyOpenBox.dim` | algebra | 欄位 |
| `PolyOpenBox.faces` | algebra | 欄位 |
| `check_dcube_open_box_filler` | root | 函數 |
| `check_poly_cubes` | algebra | 函數 |
| `dcube_at` | root | 函數 |
| `dcube_box_cap` | root | 函數 |
| `dcube_box_complete` | root | 函數 |
| `dcube_box_face` | root | 函數 |
| `dcube_box_face_of` | root | 函數 |
| `dcube_box_fill` | root | 函數 |
| `dcube_box_fill_verified` | root | 函數 |
| `dcube_box_validate` | root | 函數 |
| `dcube_constant` | root | 函數 |
| `dcube_cubes_conv` | root | 函數 |
| `dcube_degenerate` | root | 函數 |
| `dcube_face` | root | 函數 |
| `dcube_filler_faces_ok` | root | 函數 |
| `dcube_function` | root | 函數 |
| `dcube_generic_dims` | root | 函數 |
| `dcube_of_path` | root | 函數 |
| `dcube_of_point` | root | 函數 |
| `dcube_open_box` | root | 函數 |
| `poly_box_cap` | algebra | 函數 |
| `poly_box_face` | algebra | 函數 |
| `poly_box_face_of` | algebra | 函數 |
| `poly_box_fill` | algebra | 函數 |
| `poly_box_fill_verified` | algebra | 函數 |
| `poly_box_filler_faces_ok` | algebra | 函數 |
| `poly_box_validate` | algebra | 函數 |
| `poly_cube` | algebra | 函數 |
| `poly_cube_add` | algebra | 函數 |
| `poly_cube_compose` | algebra | 函數 |
| `poly_cube_const` | algebra | 函數 |
| `poly_cube_degeneracy` | algebra | 函數 |
| `poly_cube_eq` | algebra | 函數 |
| `poly_cube_eval` | algebra | 函數 |
| `poly_cube_face` | algebra | 函數 |
| `poly_cube_identity` | algebra | 函數 |
| `poly_cube_scale` | algebra | 函數 |
| `poly_cube_sub` | algebra | 函數 |

### 輔助工具

- 規範形式：整數／網格等具體值
- 範疇化：基礎集合層工具
- 判定：直接計算

| 符號 | 套件 | 類別 |
|---|---|---|
| `int_pow` | root | 函數 |
<!-- APPENDIX:END -->
