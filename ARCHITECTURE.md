# cubical-hermitian 架構與依賴治理

[中文規格](SPEC.md) · [English specification](SPEC.en.md) · [中文指南](GUIDE.md) ·
[English guide](GUIDE.en.md) · [中文符號附錄](SPEC-APPENDIX.md) ·
[English appendix](SPEC-APPENDIX.en.md)

> English summary: MoonBit compiles each package as one mutually
> recursive unit, so files inside a package have no compilation
> order.  This project nevertheless fixes a logical dependency DAG.
> Physically it has three packages, `cmd/main → root → algebra`;
> inside them, `architecture.json` assigns every `.mbt` file to one
> of 13 components in layers 0–9, and `tools/arch_check.py` rejects
> unassigned files, duplicate ownership, upward component edges and
> package imports that violate the manifest.  Counts are produced by
> the checker and by `tools/audit_spec.py`; they are not maintained
> by hand in this document.

## 1. 先回答：「60+ 個檔案之間有沒有先後依賴？」

有**邏輯依賴**，但同一 MoonBit package 內沒有**檔案編譯先後**。
MoonBit 以 package 為編譯單位：同一目錄的 `.mbt` 宣告共同求解，
函數與型別可以互相遞迴，所以把 `a.mbt` 改名、與 `b.mbt` 交換
目錄次序，都不會改變語義。不過若完全不管依賴方向，核心、模型、
前端與登記表會彼此糾纏，日後任何盤點都要重新通讀六十多個檔案。

因此架構分成兩級：

1. **實體 package 圖（編譯器強制）**

   ```text
   username/cubical-hermitian/cmd/main
                    │ imports
                    ▼
   username/cubical-hermitian            （root package）
                    │ imports @algebra
                    ▼
   username/cubical-hermitian/algebra
   ```

2. **邏輯 component DAG（`tools/arch_check.py` 守門）**：root 內部
   仍是一個 package，但每個檔案被指派到恰好一個 component。
   高層可依賴同層互遞迴群與低層；低層不得引用高層。登記表與
   laws/tests 是刻意置於頂層的「可看全局」層。

`architecture.json` 是唯一清單來源；本文件只解釋規則，不複製
每次都會變的總行數。

## 2. Component 層級

| 層 | Component | 實體套件 | 職責 | 可依賴 |
|---:|---|---|---|---|
| 0 | `foundation` | root | De Morgan 維度、面公式、ROBDD、DAG BDD、sifting 與 Tseitin／watched-literal DPLL | — |
| 1 | `numeric-hermitian` | root | 浮點複線性代數、投影、向量系統、仿射立方體 | foundation |
| 1 | `exact-algebra` | **algebra** | BigInt 精確多項式、完整因式分解、根隔離、分裂域、去巢、Q 線性代數、代數數、Jordan、譜恆等式、任意精度 Jacobi | —（Moon core 以外） |
| 2 | `finite-cubical` | root | 簡單型別 NbE/HOAS、有限宇宙、wiring、PathP、Glue、J | foundation |
| 3 | `dependent-kernel` | root | 一個刻意保留的 SCC：依賴 NbE、AST Kan、Equiv/Glue、checked lines、DTerm transforms、schema 生成、一等層級與同時宣告 | foundation、finite-cubical |
| 4 | `dependent-kan-lines` | root | 宿主層 `DLine`、維度代換與簡單／有限型別嵌入 | foundation、dependent-kernel、finite-cubical |
| 4 | `models` | root | 範疇模型、有限／子空間 Glue comp、認證數值影子與一般代數認證 | foundation、numeric、finite、exact-algebra |
| 5 | `frontend` | root | pattern／有界 Huet HOU elaborator、參數化模組、已編譯介面、增量快取與穩定 byte codec | dependent-kernel、foundation（模組 codec 內的 `Dim`／`Face`） |
| 5 | `cubical` | root | S³／同倫代表元、IntegerS／π 商呈現、命題截斷、adjoint 與一般纖維、立方體演算法、計算性單值性 | foundation、finite、dependent-kernel |
| 6 | `laws` | mixed | `*_laws.mbt` 行為律見證 | 同套件內較低層 |
| 7 | `registry` | root | theorem/spec 登記表與 root→algebra 的集中匯入邊界 | 全部較低層 |
| 8 | `tests` | mixed | `*_wbtest.mbt` / `*_test.mbt` | 被測套件 |
| 9 | `app` | cmd-main | `moon run cmd/main` 執行入口 | registry 的公開介面 |

檔案明細不在此重複維護；執行：

```bash
python3 tools/arch_check.py
python3 tools/arch_check.py --list-edges
python3 tools/arch_check.py --json
```

第一條會輸出當下每個 package/component 的檔案與行數。

## 3. 為何只物理拆出 `algebra/`？

第八期的原則是 **hybrid**：先拆真正低耦合、可由編譯器守住邊界
的領域，不把互相遞迴核心硬切成多個 package。

`algebra/`（`symalg`、`qpoly`、`qmat`、`algnum`、`Jordan`、
`spectral_symbolic`、`Jacobi_interval`、`qpoly_factor`、`root_isolation`、
`splitting_field`、`radical_denest` 與其 laws/tests）原本就沒有
引用立方體核心，root 只是使用它，屬於教科書式單向依賴，所以
成為真正的 MoonBit 子套件。它只使用 MoonBit core 套件（debug/math 與 prelude BigInt）；
root 在 `moon.pkg` import 它為 `@algebra`，公開符號集中由
`algebra_imports.mbt` 以非公開 `using @algebra { ... }` 導入 root
真正需要的名稱。這不把 algebra 符號冒充 root 自身 API 重出口；
符號附錄會把套件欄標成 `algebra`。

`foundation` 暫不實體拆出，原因是 MoonBit 的可見性語義：
`using` 只導入型別、trait 與函數，不導入 enum 構造子；
一般 `pub` 型別在其他 package 是 readonly，要讓別的 package
構造需升成 `pub(all)`。`Dim`、`Face`、`Bdd` 的構造子在 root
有數百處直接使用，搬遷會變成大規模
`Dim::DZero` 式改寫，且等於把內部表示永久公開。收益
低於擾動，故 foundation 現為同 package 的邏輯 L0，由
arch check 禁止它向上引用；核心 `dependent-kernel` 亦同理
保留為一個 SCC。

## 4. 計數不再靠人工通讀

| 問題 | 權威來源 | 命令 |
|---|---|---|
| 有哪些 package、檔案屬哪一層？ | `architecture.json` | `python3 tools/arch_check.py --json` |
| 是否出現反向／跨層非法邊？ | checker 的 package 圖與 component 邊 | `python3 tools/arch_check.py` |
| 公開 API 有幾個符號、屬哪個套件？ | 各套件 `pkg.generated.mbti` | `moon info && python3 tools/audit_spec.py --check` |
| SPEC 逐符號附錄 | 由 mbti 生成的雙語附錄 | `tools/audit_spec.py --write` |
| 定理幾條、測試幾個？ | 登記表與測試執行器 | `moon run cmd/main`、`moon test` |

文件中的整數字面量（測試數、定理數、符號數）每次發版以工具
輸出回填；若文件與工具不一致，以工具與 `moon test` 為準。

## 5. Checker 保證甚麼、不保證甚麼

`tools/arch_check.py` 會：

- 從 manifest 展開每個 `.mbt`，要求每個檔案恰被登記一次；
  新增檔案若未歸位，立即失敗；
- 比對各 `moon.pkg` 的 package import 與 manifest 層級；
- 由原始碼近似抽取「型別／大寫識別字」全域引用與「小寫函數」
  直接呼叫，建立 component 邊，拒絕未核准的上行邊；
- 統計 package/component 的檔案數與行數。

它不是 MoonBit 類型檢查器：同名局部綁定、欄位名與模式變量
仍可能讓近似邊有誤判風險。checker 因此只採用較保守的呼叫
證據，並忽略點號後欄位；真正硬邊界仍是 package 圖與
`moon check --deny-warn`。若出現看似合法的新邊，處理順序是：

1. 若低層真的需要該概念，把小型通用 helper 下移到正確層；
2. 若是登記表才需要的全局檢查，把檢查移到 `verify.mbt`；
3. 只有經人工確認的特殊情況才可考慮在 manifest 加例外，
   且必須在同一變更中說明理由。現時 `exceptions` 為空。

## 6. 新增檔案的歸位流程

1. 先判斷職責層，再寫程式：基礎謂詞不能偷偷呼叫前端。
2. 把檔案加入 `architecture.json` 恰一個 component；若沒有
   合適 component，先討論新增 component 及其層級。
3. 新公開符號執行 `moon info`，再為其在
   `tools/audit_spec.py` 分類並重新生成雙語附錄。
4. 新數學檢查接入 `verify.mbt` 與 `spec.mbt`，不得只存在於
   未登記的測試檔。
5. 提交前最小門檻：

   ```bash
   moon fmt
   moon check --deny-warn
   moon test
   moon run cmd/main
   python3 tools/arch_check.py
   python3 tools/audit_spec.py --check
   ```

## 7. 第八期依賴整理實際做了甚麼

- 抽出實體 `algebra/` package，並建立 root 集中匯入邊界。
- 把原本位於 Kan 核心的全局 `check_kan_all_types` 移到
  registry 層 `verify.mbt`，消除 kernel→models 的上行引用。
- 把 `eps` 下移至 foundation 的 `interval.mbt`；把
  Nat/Bool 值 helper 移至 kernel 的 `dterm_transform.mbt`；
  把範例投影量下移至 `projector.mbt`，使 numeric 層不依賴模型層。
- `cubical_algorithms.mbt` 與 `univalence.mbt` 登記在
  L5 `cubical`：只往下呼叫核心 `coe/comp/fill`、Equiv/Glue 與
  checked lines，覈心沒有反向呼叫它們。
- SPEC 的逐符號巨表已拆至生成的
  `SPEC-APPENDIX.md` / `SPEC-APPENDIX.en.md`，正文只保留設計
  規格；附錄新增 Package 欄，一個符號屬於 root 還是 algebra
  由產生的 mbti 決定。


## 8. 第九期新增檔案如何歸位

第九期沒有新增實體套件或邏輯層；新檔案按既有責任歸位：
`algebra/qpoly_factor.mbt`、`root_isolation.mbt`、
`splitting_field.mbt`、`radical_denest.mbt` 屬 L1 `exact-algebra`；
`schema_phase9.mbt` 因與 DTerm/schema 核心互呼叫而屬 L3
`dependent-kernel`；`certified_algebraic.mbt` 屬 L4 `models`；
`module_compilation.mbt` 屬 L5 `frontend`；
`sphere_homotopy.mbt`、`equivalence_phase9.mbt`、`truncation.mbt`
屬 L5 `cubical`。`dependent-kan-lines` 因新的 `DLine` 代換直接
使用 L0 的 `Dim` 求值，manifest 明示其對 `foundation` 的邊。
Root 的 `moon.pkg` 另加入 core `math` 供 Hopf 連結積分的三角函數；
它不是專案套件邊，實體圖仍是 `cmd/main → root → algebra`。

## 9. 第十期新增檔案如何歸位

第十期同樣沒有新增實體套件或邏輯元件：

- `face_sat_watched.mbt` 只使用 L0 的 `Dim`、`Face`，以及
  `bdd_dag.mbt` 既有的 face decision 型別，因此屬 L0
  `foundation`；它讓 foundation 自己提供 canonical BDD 之外的
  watched-literal 搜尋，不引入核心反向依賴。
- `equivalence_phase10.mbt` 與 `sphere_classification.mbt` 是建在
  dependent kernel 上的高層 cubical 構造，屬 L5 `cubical`。
  前者放一般 `lemIso`、纖維收縮與 adjointification；後者放
  `IntegerS`、π 商型與典範環路代表元。
- `module_binary.mbt` 屬 L5 `frontend`。其 DTerm codec 無可避免地
  要編碼核心項中的 `Dim` 與 `Face`，所以 manifest 新增了直接的
  `frontend → foundation` 邊；這是下行邊，不改變實體套件圖
  `cmd/main → root → algebra`。
- BDD cost 改動直接落在既有 L0 `bdd_dag.mbt`，QPoly 的
  sparse／Karatsuba 路徑直接落在既有 L1 `algebra/qpoly.mbt`，
  root 也只在既有 `algebra_imports.mbt` 邊界多匯入一支檢查函數。
- 新白箱測試由既有 L8 `tests` wildcard 收納；新增檢查均已接入
  L7 `verify.mbt`、`spec.mbt` 與雙語附錄審計，沒有只在測試檔
  存在的孤兒結果。


## 10. 第十一期新增檔案如何歸位

第十一期同樣沒有新增實體套件或邏輯元件：

- `algebra/biquad_denest.mbt`、`algebra/poly_cube.mbt` 屬 L1
  `exact-algebra`：前者只用同套件的 `QuadNum`/`AlgNum` 機械，
  後者是精確多項式座標的立方與開盒，不引入跨套件邊。
- `dcube_filler.mbt` 與 `dterm_intern.mbt` 屬 L3
  `dependent-kernel`：前者與 `dsystem_compat.mbt`、`kan_ast.mbt`
  互呼叫（開盒的相容檢查與 comp 填充本來就屬核心 SCC），後者是
  `DTerm` 自身的子項遍歷/重建，與 `dterm_transform.mbt` 同層。
- `schema_registry_persist.mbt` 屬 L5 `frontend`：它重用
  `module_binary.mbt` 的 codec 基礎設施（同一元件）編碼 L3 的
  registry；核心不需要知道位元組層。
- `circle_classify.mbt` 屬 L5 `cubical`，與
  `sphere_classification.mbt`、`sphere_homotopy.mbt` 並列：它是
  建在 kernel 之上的覆疊/分類構造。為其所做的
  `comp_glue_equiv_value` 端點合成改動落在既有 L3
  `equiv_ast.mbt`，且只在「端點無分支而一般點有分支」時生效。
- `phase11_laws.mbt` 由 L6 `laws` 的 `*_laws.mbt` wildcard 收納，
  承接原本只在白箱測試的第十一期斷言體，使 L7 registry 能直接
  執行；root 只在既有 `algebra_imports.mbt` 邊界多匯入四支代數
  檢查函數。實體套件圖仍是 `cmd/main → root → algebra`。
