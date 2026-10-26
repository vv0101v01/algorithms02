#!/usr/bin/env python3
"""Generate / audit the per-symbol specification appendices.

Parses pkg.generated.mbti (run `moon info` first) for every public
declaration, enum constructor and struct field, classifies each symbol
into a specification family (canonical form / categorification / decision
procedure), and (re)writes the appendix of SPEC.md between the
APPENDIX markers.  --check verifies the appendix is exactly the set of
interface symbols, each listed once, each classified.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
APPENDIX_ZH = ROOT / "SPEC-APPENDIX.md"
APPENDIX_EN = ROOT / "SPEC-APPENDIX.en.md"

FAMILIES = {
    "複數標量": ("(re, im) 有序對", "交換環 C；共軛為對合", "eps 分量比較"),
    "複向量與內積": ("分量列", "Hilbert 空間 Hilb 的物件；內積誘導對偶", "分量運算"),
    "矩陣與伴隨": ("列之列", "Hilb 態射；† 為 dagger 函子", "矩陣運算"),
    "投影與特徵空間": ("Σ vₖvₖ†；分解為正交對 (Pv,(I−P)v)", "自伴冪等態射及其在 Hilb 中的分裂（雙積）", "特徵值方程／正交性／跡整數性"),
    "Karoubi 包絡": ("物件 P；態射被夾緊矩陣 QAP=A", "冪完備化；恒等是 P 本身；dagger", "QAP=A 與合成律"),
    "區間": ("De Morgan 表達式；端點布林化", "De Morgan 代數（區間物件）", "求值與重寫簡化"),
    "面公式與 BDD": ("由 interned DAG 展開的 ROBDD 樹（相容表示）；主判定在同一 manager 以 root 代表", "面格（自由有界分配格的商）的規範代表", "DAG apply/root 相等判定；樹形 API 為逐公式展開"),
    "面偏序範疇": ("BDD 等價類", "偏序範疇：∧積、∨餘積、⊤/⊥ 終始", "bdd_face_le 與萬有性等式"),
    "系統與剪枝": ("分支列；語義範形見系統符號範形", "面上 presheaf 的偏元素；聯集拼接", "重疊面的 BDD 可滿足性"),
    "系統符號範形": ("值標記不交 BDD 分割＋未定義區域", "偏元素在面格切片中的像分解", "BDD 區域運算"),
    "立方體與 Kan 填充": ("函數 Iⁿ→Cᵐ；填充用仿射公式；帽子為 comp 結果", "□ 上 cubical set 的實現；retract 的 Kan 結構", "邊界方程（網格）"),
    "未型別 NbE": ("βπ 正規形 nf", "句法範疇在 βπ 商下的態射代表", "eval/quote 後結構比較"),
    "HOAS": ("經 reify 的 de Bruijn 範形", "函子範疇式綁定；與一階語法範疇等價（模定義相等）", "reflect/reify 往返"),
    "型別化 NbE 與 η": ("η 長 βπ 範形 nf_eta", "自由笛卡兒閉範疇的態射代表", "雙向檢查＋按型別 quote"),
    "依賴型別 NbE（Π/Σ/宇宙）": ("按型別 quote 的 η 長依賴正規形；Π/Σ 第二分量為語義閉包族；累積 Typeᵢ 層級", "帶族範疇 (CwF) 模型：脈絡延伸與依賴代入是閉包施用", "雙向 elaboration＋型別導向轉換；相等=範形相等"),
    "立方 AST 與維度 NbE": ("DTerm 的項/維度雙 de Bruijn 索引；線與 tube body；帶 dlevel 的 quote", "帶區間脈絡的 cubical CwF；PathP 為依賴路徑物件，Glue 值為 (raw/DPartial partial,base) 對", "雙向檢查＋Dim/Face 簡化及 ROBDD 語義謂詞"),
    "AST Kan comp/hcomp": ("分支一律攜帶為 DSystem；在一般維度按型別頭派遣；頂分支取帽、形式合成為 DNComp/DNHComp", "各型別構造子保存 Kan 纖維化結構；hcompU 是 Glue 黏合", "系統 base/重疊相容＋型別遞迴；coe/fill 為 comp 線段限制"),
    "資料型別與 HIT 消去": ("Nat/List 構造子遞迴；Circle loop@r；Torus square@(i,j) 模對邊等同", "初始代數與 HIT 的依賴消去是 motive 截面，並與形式 composition 交換", "構造子模式遞迴、Dim 語義相等、motive 中的 comp"),
    "持久環境、惰性與語義快取": ("帶長度持久連結串列 DEnv/DDimEnv（de Bruijn 頭在最內）；DVThunk 最多強制一次；快取鍵為簡化維度/引文項 Debug 鍵", "CwF 脈絡延伸是共享尾部的 cons；惰性值是 call-by-need 語義值，memoized 族/維度線是外延函數的有限圖延伸", "環境索引、force_count 與快取鍵相等"),
    "依賴語義系統與 partial 值": ("DSystem 分支去 ⊥、按值合併同 body 並以引文排序；DPartialValue 的 BDD 有效區域分割 DSystemNF", "面格切片中的偏元素；多分支 Glue 為 partial type 系統與 base 的極限式配對", "BDD 區域運算＋分支 body 的型別導向轉換/引文鍵"),
    "通用歸納族 schema": ("telescope＋完整 DTerm 引數型別（外部、直接/巢狀/函數遞迴與約束）；值為 DVIntro，中性消去按生成 case 型別引文", "結構化嚴格正性函子的依賴初始代數；消去子是 motive 截面，comp 沿先前引數 filler 遞迴", "schema 結構相等、telescope elaboration、極性正性判定與生成檢查"),
    "通用 HIT schema": ("任意有限維 cell；任一端點按 face expression 逐維化簡；case 為逐維巢狀 PathP", "帶 face 映射的胞腔型高階初始代數；消去子保存各維 cells", "face 引數/索引檢查、多維角落雙路化簡轉換與維度語義相等"),
    "依賴 Kan 線（coe/comp）": ("DLine{at, coe, fill}，comp=fill(1)；coe 在 Π 定義域反向、在 Σ 沿第一分量路徑", "型別即 Kan 纖維化結構；依賴族為 (路徑)→DLine；與子空間/Glue 線共同覆蓋全型別族", "按型別構造子遞迴；coe(r,r) 定義恆等"),
    "精確符號代數": ("Q 上多變量多項式規範形（合併去零排序）；分式；複符號量 (re,im)", "多項式戒與分式體承載矩陣代數；共軛為對合", "多項式恆等／分式交叉相乘（精確）"),
    "譜投影與仿射唯一填充": ("Pₖ=qₖ(A)/qₖ(λₖ)；雙線性角插值 k00+i k10+j k01+ij k11", "單位分解與譜分解；雙線性是兩仿射方向的張量黏合", "首一整除（模最小多項式）與在原子 i,j 的恆等"),
    "句法笛卡兒閉範疇": ("帶註記閉箭頭，其 nf_eta", "自由 CCC：積與指數的萬有性", "def_eq_eta 驗證範疇律"),
    "有限宇宙型別與值": ("葉序／葉值列", "有限集合範疇中由 Bool/Unit 以積生成", "樹遞迴"),
    "Wiring 符號等價": ("帶號置換（Unit 輸出 /(−1,false)）", "自由對稱冪冪範疇態射；⊗／換位／結合子／單位子", "置換性 O(#葉)；相等=結構相等"),
    "同構、等價、ua、coe": ("wiring；coe 按端點計算", "ua 在有限宇宙；積交換為自然性方塊", "wiring_eq 與 w;w⁻¹=id"),
    "PathP、離散路徑與 J": ("規範 PathP 元（遠端為 coe 像）；離散路徑常值", "依賴路徑物件；J 來自常值線 coe 的恆等性", "端點與點值檢驗"),
    "有限 Glue": ("(partial, base) 對；glue_from_base 由 base 範形", "沿等價黏合的極限式構造；unglue 為纖維化投影", "face_sat＋相容方程"),
    "Glue comp（有限線）": ("輸出 (t₁, e₁(t₁))", "箭頭範疇 Ty²：等價線是其態射，comp 是沿線合成", "自然性方塊 wiring_eq；不相干則拒絕"),
    "Glue comp（子空間線）": ("校正方塊 k=1 邊", "變動 retract 線上的 Kan 提升；校正為 hcomp", "邊界／帽子／落點方程（網格）"),
    "BDD DAG、預算與 DPLL": ("hash-consed DAG 節點 ID；root 的 reachable node count 為 ROBDD 大小；apply cache 於 apply_misses 超過桶數四倍時 doubling rehash；sifting 逐變量試全部插入位置並以 reachable size 衡量 並回報 initial/final/attempts/improved；CNF 以 Tseitin 門變量線性編碼", "布林函數在固定變量次序下的共享規範圖；apply 是格運算的 memoized 實現；watched-literal DPLL 是面格可滿足性的搜尋判定", "同 manager root-id 相等、root≠0 的 sat、節點預算 FaceDecision、或有步數預算的 DPLL（舊掃描式與 watched-literal）；另有候選變量次序最小化與 3ⁿ 最壞節點界；watched/list DPLL 以 2^n brute force 差分驗證，sifting 以恆等哨兵避免大小同分時誤稱改善"),
    "原始 DSystem 相容性與 first-match 範形": ("相容系統沿用 DSystem 型別導向範形；任意 first-match 系統化為不交有效區域 DTubeNF", "面相對切片中的偏元素；checked 構造是進入 composition 系統子類的反射", "BDD cube 枚舉上的局部脈絡轉換，檢查 base 與兩兩重疊；不相容回報首個衝突"),
    "AST 一等 Equiv 與 GlueEquiv": ("DEquiv 攜帶 fwd/bwd/sect/retr 四項；DVGlueEquiv 攜帶完整 Equiv 分支與 base/partial 對", "AST 內的等價是帶同倫逆證明的同構；ua 是通往宇宙路徑的函子，GlueEquiv 是沿 partial 等價系統的黏合", "雙向檢查四個分量與兩條 PathP 證明；conversion/quote 按 Equiv 分量與分支面遞迴；沿 ua 的 coe 定義地為 fwd/bwd"),
    "受檢查語義型別線": ("DCheckedTypeLine 保存已檢查的開放型別 body、脈絡、環境與宇宙層級，不保存裸宿主函數", "可代換的立方型別線由句法 body 在維度環境下求值，天然與維度代換交換", "構造時以新鮮維度檢查 body : Typeᵢ；at 以維度求值，coe/comp 直接派遣 AST Kan"),
    "Schema 註冊與 elaboration 快取": ("DSchemaRegistry 中以穩定 Debug 鍵 intern 的 DInductivePlan/DHitPlan 與 telescope 前綴鏈", "schema 描述子是可共享計劃；快取只保存同一 elaboration 函數的有限圖，不改變指稱", "驗證布爾值與語義 telescope 前綴按 (term,args,args) 鍵查表；hit/miss 計數可觀察"),
    "Schema 函子、正性與歸納遞迴": ("DPositiveFunctor 的 Id/Const/Product/Sum/List/Pi/Container 語法及其解碼型別；DPositivityReport 記錄出現與極性", "正性型別函子的初始代數與 decoded induction hypothesis；DDecode 是 Tarski 宇宙的歸納—遞迴解碼函數", "在別名展開後的 DTerm 上做極性遞迴：巢狀函子與正位置接受、負位置/未知中性族應用拒絕；IH 由函子遞迴生成"),
    "Schema 擴展：互歸納、商與宇宙多態": ("DMutualFamily 的 Sum-indexed 合併 schema；DLevelExpr 的層級 scheme；商即帶等式 1-cell 的 HIT", "互相歸納族是索引和上的單一初始代數；宇宙 scheme 是層級指派的函數；商構造為高階胞腔黏合", "互構子以分量索引約束編譯並以 Σ motive 消去；scheme 依層級向量求值並可再驗證；構造子等式以 Path 約束檢查"),
    "精確單變量多項式與有理矩陣": ("QPoly 的升冪稠密係數（尾零去除）；QMat 的有理列之列；RREF 與 pivot 列", "Q[x] 歐氏環與 Qⁿ 線性範疇；特徵/最小多項式是矩陣代數的表示不變量", "乘法在稀疏輸入走非零卷積、稠密輸入走公分母 BigInt 整係數縮放（schoolbook/Karatsuba 視項數而定）再除回，冪次走平方乘法；primitive pseudo-remainder gcd、Yun 重因數分解、有理根定理、Faddeev–LeVerrier、RREF；相等全為有理結構相等"),
    "代數擴張與根式範形": ("QuadNum 的 a+b√d（d 無平方因數）；AlgNum 的 Q[x]/(m) 餘式多項式", "二次擴張與一般有限代數擴張體；範數/跡由乘法矩陣行列式/跡給出", "模極小多項式的剩餘算術與擴張歐氏求逆；根式去巢以平方判別；相等為係數相等"),
    "廣義特徵空間與 Jordan 理論": ("(A−λI) 冪次零化列、遞增 nullity、Jordan 塊大小與鏈底基；PJP⁻¹=A", "主分解是互質多項式因子的單位分解；Jordan 型是相似等價的完全不變量片斷", "以特徵多項式重數、冪次核維度與鏈提升精確判定；不可在 Q 完全分裂者回報殘餘因子，AlgMat 在擴張上續行"),
    "認證數值影子與精確立方體": ("QuadC=QuadNum+i·QuadNum；CertMat 與次數≤2 的 CertPath/CertSquare 係數", "精確複二次矩陣代數與多項式立方體；Double 矩陣只是精確影子的近似表示", "P²=P、P†=P、正交分解與盒邊界以精確結構相等驗證；數值一致性只量測對影子的偏差與浮點 residual"),
    "球面與懸掛 HIT": ("Susp(X) 的 north/south 兩點與每點一條 meridian；S²=Susp(S¹)、S³=Susp(S²)", "懸掛是把 X×I 兩端各塌縮為一點的 HIT 商；迭代懸掛給出球面族", "generic HIT schema 驗證、meridian 端點 face 化簡、依賴消去與 hcomp"),
    "Jacobi 區間譜迭代": ("RatInterval/CInterval 矩形包絡與 dyadic 外向捨入後的 Hermitian 區間矩陣；每次旋轉保存 before/after 與累積酉變換", "Hermitian 相似變換在區間矩陣包絡上的單調提升；Gershgorin 圓盤給出譜的像分解與重數簇", "精確有理平方比較證明 sqrt/相位/c/s 包絡包含真值；逐旋轉重算 J†J−I∋0 與 J†AJ⊆after，最終圓盤分簇計數"),
    "高階合一與雙向 elaborator": ("UTerm 的 Miller pattern spine `?F x₁…xₙ` 與 zonk 後 beta/投影簡化核心；表面 STerm 按名解析為 de Bruijn UTerm；HouSearchReport 記錄 status/nodes/branches/depth", "pattern HOU 是高階合一的可判定片斷；有界 Huet 搜尋在此之上以 transactional state 試 rigid/spine 分解、同頭不變座標、distinct flex-flex、imitation 與 projection；雙向 elaboration 把隱含引數與 dependent motive 問題送入同一合一器再編譯至依賴覈心", "確定性層以 WHNF 後 rigid 分解、pattern 抽象、occurs/scope 檢查與閉項 fallback 判定；搜尋層在節點與證明項深度預算內求 solved/no-unifier，否則以 residual 或 budget-exceeded 明示未定（一般 HOU 不可判定，不作完備宣稱）；check/infer 插入隱含 metavariables，未解者拒絕轉 DTerm"),
    "參數化模組與名字空間": ("模組 telescope（參數→imports→本地宣告）與分離的 name→ordinal bindings；實例是同時代換後的閉合宣告", "參數化模組是模組函子，import 是函子套用的內聯，open/alias/rename 是同一 telescope entry 的不同名字投影", "循環檢測、參數引數依賴檢查、import 選擇/隱藏/改名的歧義拒絕、opaque export 中性化，以及實例閉合後逐宣告 dep_check"),
    "立方體演算法": (
        "KanBox 打包型別線、系統與 base；transport filler 是 PathP；路徑傳遞是 hcomp 方塊的頂邊",
        "cubical CwF 中由 Kan 纖維化結構生成的路徑物件運算：反演、串接、函子性與依賴代入",
        "派遣至覈心 coe/comp/fill 並以轉換驗證端點；閉項 builders 再由 dep_check_closed 驗收",
    ),
    "計算性單值性（univalence）": (
        "有限宇宙路徑以 wiring 等價為範形；依賴宇宙路徑是受檢查型別線，pathToEquiv 取其 coe 等價，ua 取 Glue 線，uaβ 是 transport filler 的 unglue，往返由 Equiv 同倫與二維 Glue 方塊見證",
        "宇宙路徑範疇與等價之間的等價 (Equiv A B) ≃ Path U A B；Glue 沿等價黏合，transport 是其 coe 函子",
        "有限側以 wiring 相等；AST 側以 coe/comp 計算並以型別導向轉換驗證往返端點與方塊四邊；閉項 pathToEquiv 的 fill/coe 證明由依賴檢查器驗收",
    ),
    "完備精確代數與根隔離": ("BigInt 有理數；Q[x] 不可約因式與重數；Sturm 實根區間與不交 Rouché 複圓盤；逐次代數塔中的分裂根；去巢根式表達式", "Q[x] 唯一因式分解、代數閉包中的根多重集與有限分裂擴張；AlgPoly 是擴張係數多項式", "Kronecker/有限域提升、Sturm 計數、Cauchy 正方形 Taylor 排除與 Rouché 細分；證書皆以精確多項式重算"),
    "一等宇宙多態與同時宣告 schema": ("DLevelDecl 的層級 binders 與實例化；透明算子展開後的正性函子；迭代編譯的非均勻巢狀族；聯合互歸納與同時 IR 規格", "宇宙 scheme、參數迭代初始代數、向量函子聯合初始代數與同步歸納—遞迴結構", "層級作用域、正性報告、生成 telescope 與依賴轉換；未實例化層級在覈心檢查拒絕"),
    "Adjoint 等價、纖維與命題截斷": ("quasi-inverse 上加三角形 Path(Path)；improved counit；一般 fiber 的 Σ 點、lemIso 路徑與中心的收縮 (center, contraction)；PropTrunc 的 point/squash HIT", "half-adjoint equivalence、contractible fiber 的等價刻畫與到命題的截斷反射", "adjointify_equiv_value 與 equiv_contractible_fibers_value 由 hfill/hcomp/dpath 構造，端點與 Path(Path) 三角形以依賴檢查／轉換驗證（circle-中點等深層調整點按面-restriction 檢查）"),
    "球面同倫代表元與 Hopf 不變量": ("Ωⁿ 的巢狀 Path；懸掛迭代的整數度數映射；極交換 S³ 的 HIT；C² 單位球上的 Hopf 映射與相位纖維；IntegerS 的 zero/posSucc/negSucc 唯一構造子範形與語義 succ/pred；π₃ 以 Ω³(Sphereₙ) 模命題截斷 Path 關係的 QuotientS 商呈現；SphereLoopExpr 的 generator 冪", "懸掛函子、基點映射與 loop space 的代表元；Hopf S¹-纖維化及其連結數；π₃ 商型是 loop space 模存在路徑關係的商呈現", "生成 meridian 轉換；三重迭代 suspension_unit 沿 transitivity-square cancellation 以 subst rebase 為懸掛的 loop；代表元運算的整數冪次以 end-to-end 檢查求值；Hopf 像/纖維代數檢查與立體投影後 Gauss 連結積分 |lk|=1。此層是代表元與典範冪，不宣稱一般合成 encode/decode 證明 π₃(S³)≅ℤ 或以 Hopf 不變量證明 π₃(S²)≅ℤ"),
    "模組分離編譯與連結": ("CompiledModule 的展平已檢查 telescope、exports、依賴指紋與介面公共投影；抽象宣告 body=None；cache 以來源指紋索引；穩定二進位以 magic CHMODBIN＋版本 u16＋長度 u32＋校驗 u32＋payload（標籤位元組、固定寬度小端 i32、UTF-16LE 字串）表達", "模組函子的已編譯物件與 synthetic import-free 連結定義；prefix 特化是部分函子套用；序列化是 compiled module 的穩定外表示", "介面 hash 忽略 opaque body、實作 hash 覆蓋全部 entries；implementation 補足抽象 exports；cache 依來源與依賴介面指紋失效；解碼逐一拒絕 bad magic／版本／截斷／校驗／格式／尾隨位元組，並重跑 module 驗證與 fingerprint 一致性檢查"),
    "範疇化總檢": ("範疇律的布爾合取", "彙總各範疇的身分／合成／相干律", "逐律求值"),
    "定理登記與範例": ("(名稱, Bool) 登記列；具體見證向量／項", "可判定命題在見證上的實現", "moon test／登記表"),
    "規格登記": ("SpecEntry 六元組", "規格之規格；完備性對產生介面核對", "spec_registry_sound＋本審計"),
    "輔助工具": ("整數／網格等具體值", "基礎集合層工具", "直接計算"),
}

TYPE_FAMILY = {
    "Complex": "複數標量", "CVec": "複向量與內積", "CMat": "矩陣與伴隨",
    "Dim": "區間", "Face": "面公式與 BDD", "Bdd": "面公式與 BDD",
    "VecBranch": "系統與剪枝", "VecSystem": "系統與剪枝",
    "SymRegion": "系統符號範形", "SystemNF": "系統符號範形",
    "Cube": "立方體與 Kan 填充", "KanBox": "立方體演算法", "UniversePath": "計算性單值性（univalence）",
    "Term": "未型別 NbE", "Neutral": "未型別 NbE", "Value": "未型別 NbE",
    "HTm": "HOAS",
    "LTy": "型別化 NbE 與 η", "TNeutral": "型別化 NbE 與 η",
    "TValue": "型別化 NbE 與 η", "TypedValue": "型別化 NbE 與 η",
    "Ty": "有限宇宙型別與值", "PVal": "有限宇宙型別與值",
    "LeafKind": "Wiring 符號等價", "LeafMap": "Wiring 符號等價", "Wiring": "Wiring 符號等價",
    "Iso": "同構、等價、ua、coe", "Equiv": "同構、等價、ua、coe", "UPath": "同構、等價、ua、coe",
    "PathPVal": "PathP、離散路徑與 J", "DiscPath": "PathP、離散路徑與 J", "Family": "PathP、離散路徑與 J",
    "GlueData": "有限 Glue", "GlueElem": "有限 Glue",
    "GlueLineFinite": "Glue comp（有限線）",
    "SubLine": "Glue comp（子空間線）", "LinEquivLine": "Glue comp（子空間線）",
    "GlueLineVec": "Glue comp（子空間線）", "VecBox": "Glue comp（子空間線）",
    "GlueCompVecResult": "Glue comp（子空間線）",
    "DEnv": "持久環境、惰性與語義快取", "DDimEnv": "持久環境、惰性與語義快取",
    "DThunk": "持久環境、惰性與語義快取",
    "DSystem": "依賴語義系統與 partial 值", "DFaceTerm": "依賴語義系統與 partial 值",
    "DFaceValue": "依賴語義系統與 partial 值", "DPartialValue": "依賴語義系統與 partial 值",
    "DSystemClass": "依賴語義系統與 partial 值", "DSystemNF": "依賴語義系統與 partial 值",
    "DArgKind": "通用歸納族 schema", "DTelescopeEntry": "通用歸納族 schema",
    "DConstructorArg": "通用歸納族 schema", "DConstructorSpec": "通用歸納族 schema",
    "DInductiveSpec": "通用歸納族 schema",
    "DHitFaceExpr": "通用 HIT schema", "DHitCellSpec": "通用 HIT schema", "DHitSpec": "通用 HIT schema",
    "DTerm": "依賴型別 NbE（Π/Σ/宇宙）", "DNeutral": "依賴型別 NbE（Π/Σ/宇宙）",
    "DValue": "依賴型別 NbE（Π/Σ/宇宙）", "DInfer": "依賴型別 NbE（Π/Σ/宇宙）",
    "DTypeVal": "依賴型別 NbE（Π/Σ/宇宙）", "DFamilyParts": "依賴型別 NbE（Π/Σ/宇宙）",
    "DTubeTerm": "立方 AST 與維度 NbE", "DPathParts": "立方 AST 與維度 NbE",
    "DGlueParts": "立方 AST 與維度 NbE", "DTubeBranch": "依賴語義系統與 partial 值",
    "DLine": "依賴 Kan 線（coe/comp）",
    "Rat": "精確符號代數", "PolyTerm": "精確符號代數", "Poly": "精確符號代數",
    "SymFrac": "精確符號代數", "SymC": "精確符號代數", "SymMat": "精確符號代數",
    "UPoly": "精確符號代數", "SymVec": "精確符號代數",
    "RPoly": "譜投影與仿射唯一填充", "RPolyDiv": "譜投影與仿射唯一填充",
    "SymPath": "譜投影與仿射唯一填充", "SymSquare": "譜投影與仿射唯一填充",
    "CheckResult": "定理登記與範例",
    "SpecKind": "規格登記", "SpecEntry": "規格登記",
    "BddApplyEntry": "BDD DAG、預算與 DPLL", "BddBestBuild": "BDD DAG、預算與 DPLL",
    "BddDagFace": "BDD DAG、預算與 DPLL", "BddDagNode": "BDD DAG、預算與 DPLL",
    "BddManager": "BDD DAG、預算與 DPLL", "FaceDecision": "BDD DAG、預算與 DPLL",
    "FaceSatDecision": "BDD DAG、預算與 DPLL",
    "DSystemCompatibility": "原始 DSystem 相容性與 first-match 範形",
    "DSystemIncompatibility": "原始 DSystem 相容性與 first-match 範形",
    "DTubeNF": "原始 DSystem 相容性與 first-match 範形",
    "DTubeNFClass": "原始 DSystem 相容性與 first-match 範形",
    "DEquivBranch": "AST 一等 Equiv 與 GlueEquiv", "DEquivBranchValue": "AST 一等 Equiv 與 GlueEquiv",
    "DEquivParts": "AST 一等 Equiv 與 GlueEquiv", "DEquivTypeParts": "AST 一等 Equiv 與 GlueEquiv",
    "DGlueEquivParts": "AST 一等 Equiv 與 GlueEquiv",
    "DCheckedTypeLine": "受檢查語義型別線",
    "DHitPlan": "Schema 註冊與 elaboration 快取", "DInductivePlan": "Schema 註冊與 elaboration 快取",
    "DSchemaRegistry": "Schema 註冊與 elaboration 快取", "DTelescopeCacheEntry": "Schema 註冊與 elaboration 快取",
    "DPositiveFunctor": "Schema 函子、正性與歸納遞迴", "DPositivityReport": "Schema 函子、正性與歸納遞迴",
    "DConstructorConstraint": "Schema 擴展：互歸納、商與宇宙多態",
    "DHitLevelScheme": "Schema 擴展：互歸納、商與宇宙多態",
    "DInductiveLevelScheme": "Schema 擴展：互歸納、商與宇宙多態",
    "DLevelExpr": "Schema 擴展：互歸納、商與宇宙多態", "DMutualFamily": "Schema 擴展：互歸納、商與宇宙多態",
    "QPoly": "精確單變量多項式與有理矩陣", "QMat": "精確單變量多項式與有理矩陣",
    "QVec": "精確單變量多項式與有理矩陣", "QPolyDiv": "精確單變量多項式與有理矩陣",
    "QPolyExtGcd": "精確單變量多項式與有理矩陣", "QPolyFactor": "精確單變量多項式與有理矩陣",
    "QPolyRationalFactorization": "精確單變量多項式與有理矩陣", "QRref": "精確單變量多項式與有理矩陣",
    "QuadNum": "代數擴張與根式範形", "AlgNum": "代數擴張與根式範形",
    "AlgGeneralizedEigenspace": "廣義特徵空間與 Jordan 理論", "AlgJordanDecomposition": "廣義特徵空間與 Jordan 理論",
    "AlgMat": "廣義特徵空間與 Jordan 理論", "AlgRref": "廣義特徵空間與 Jordan 理論", "AlgVec": "廣義特徵空間與 Jordan 理論",
    "QGeneralizedEigenspace": "廣義特徵空間與 Jordan 理論", "QJordanDecomposition": "廣義特徵空間與 Jordan 理論",
    "QPrimaryProjector": "廣義特徵空間與 Jordan 理論", "QRationalSpectrum": "廣義特徵空間與 Jordan 理論",
    "CertMat": "認證數值影子與精確立方體", "CertVec": "認證數值影子與精確立方體",
    "CertPath": "認證數值影子與精確立方體", "CertSquare": "認證數值影子與精確立方體",
    "QuadC": "認證數值影子與精確立方體", "ProjectorCertificate": "認證數值影子與精確立方體",
    "NumericProjectorCertificate": "認證數值影子與精確立方體",
    "RatInterval": "Jacobi 區間譜迭代", "CInterval": "Jacobi 區間譜迭代",
    "QCpx": "Jacobi 區間譜迭代", "QCpxMat": "Jacobi 區間譜迭代",
    "QCIntervalMat": "Jacobi 區間譜迭代", "JacobiCoefficients": "Jacobi 區間譜迭代",
    "JacobiRotationCertificate": "Jacobi 區間譜迭代", "JacobiCertificate": "Jacobi 區間譜迭代",
    "EigenInterval": "Jacobi 區間譜迭代",
    "UTerm": "高階合一與雙向 elaborator", "UMetaInfo": "高階合一與雙向 elaborator",
    "Unifier": "高階合一與雙向 elaborator", "STerm": "高階合一與雙向 elaborator",
    "ElabVar": "高階合一與雙向 elaborator", "Elaborator": "高階合一與雙向 elaborator",
    "ElabResult": "高階合一與雙向 elaborator",
    "ModuleRename": "參數化模組與名字空間", "ModuleImport": "參數化模組與名字空間",
    "ModuleDecl": "參數化模組與名字空間", "ModuleDef": "參數化模組與名字空間",
    "ModuleEnv": "參數化模組與名字空間", "ModuleEntry": "參數化模組與名字空間",
    "ModuleBinding": "參數化模組與名字空間", "ModuleExport": "參數化模組與名字空間",
    "ModuleSignature": "參數化模組與名字空間", "ModuleInstanceDecl": "參數化模組與名字空間",
    "ModuleInstance": "參數化模組與名字空間",
}

EXACT = {
    "bool_ops_module": "參數化模組與名字空間", "generic_iterate_module": "參數化模組與名字空間",
    "container_tree_schema": "Schema 函子、正性與歸納遞迴",
    "as_equiv_type": "AST 一等 Equiv 與 GlueEquiv", "as_glue_equiv": "AST 一等 Equiv 與 GlueEquiv",
    "bool_not_equiv_term": "AST 一等 Equiv 與 GlueEquiv", "bool_not_term": "AST 一等 Equiv 與 GlueEquiv",
    "comp_equiv_value": "AST 一等 Equiv 與 GlueEquiv", "comp_glue_equiv_value": "AST 一等 Equiv 與 GlueEquiv",
    "d_check_glue_equiv_partial": "AST 一等 Equiv 與 GlueEquiv", "d_equiv_branch": "AST 一等 Equiv 與 GlueEquiv",
    "dequiv_branch_value": "AST 一等 Equiv 與 GlueEquiv", "mk_equiv_term": "AST 一等 Equiv 與 GlueEquiv",
    "conv_at_under_face": "原始 DSystem 相容性與 first-match 範形",
    "tube_paths_conv_under_face": "原始 DSystem 相容性與 first-match 範形",
    "dtube_nf_class": "原始 DSystem 相容性與 first-match 範形",
    "default_schema_registry": "Schema 註冊與 elaboration 快取",
    "dterm_children": "Schema 函子、正性與歸納遞迴", "dterm_shift": "Schema 函子、正性與歸納遞迴",
    "dterm_substitute": "Schema 函子、正性與歸納遞迴", "conv_schema_args_full": "Schema 函子、正性與歸納遞迴",
    "decode_term": "Schema 函子、正性與歸納遞迴", "infer_decode": "Schema 函子、正性與歸納遞迴",
    "conv_decode_neutral": "Schema 函子、正性與歸納遞迴", "comp_schema_args_decoded": "Schema 函子、正性與歸納遞迴",
    "circle_level_scheme": "Schema 擴展：互歸納、商與宇宙多態", "list_level_scheme": "Schema 擴展：互歸納、商與宇宙多態",
    "cube3_schema": "Schema 擴展：互歸納、商與宇宙多態", "equal_nat_pair_schema": "Schema 擴展：互歸納、商與宇宙多態",
    "even_odd_components": "Schema 擴展：互歸納、商與宇宙多態", "even_odd_family": "Schema 擴展：互歸納、商與宇宙多態",
    "tree_forest_components": "Schema 擴展：互歸納、商與宇宙多態", "tree_forest_family": "Schema 擴展：互歸納、商與宇宙多態",
    "rose_tree_schema": "Schema 擴展：互歸納、商與宇宙多態", "tarski_universe_schema": "Schema 擴展：互歸納、商與宇宙多態",
    "quotient_eq_term": "Schema 擴展：互歸納、商與宇宙多態", "quotient_point_term": "Schema 擴展：互歸納、商與宇宙多態",
    "quotient_schema": "Schema 擴展：互歸納、商與宇宙多態",
    "int_sqrt_exact": "代數擴張與根式範形", "int_squarefree_decomp": "代數擴張與根式範形",
    "double_dyadic_interval": "認證數值影子與精確立方體",
    "eps": "複數標量",
    "outer": "投影與特徵空間", "outer2": "Glue comp（子空間線）",
    "assignment_of_mask": "面公式與 BDD", "pow2": "面公式與 BDD",
    "vec_box": "Glue comp（子空間線）", "vec_lex_lt": "系統符號範形",
    "vec_normalize": "Glue comp（子空間線）",
    "vec_e3": "定理登記與範例", "grid": "定理登記與範例",
    "inv_sqrt2": "定理登記與範例", "example_unit": "定理登記與範例",
    "example_projector": "定理登記與範例", "sample_vectors": "定理登記與範例",
    "sample_terms": "定理登記與範例",
    "disc_samples": "PathP、離散路徑與 J",
    "tm_id": "未型別 NbE", "tm_const": "未型別 NbE", "tm_swap": "未型別 NbE",
    "coe_rules_definitional": "未型別 NbE", "swap_involutive_on_element": "未型別 NbE",
    "cube_in_subline": "Glue comp（子空間線）",
    "prune_cube_subline": "Glue comp（子空間線）",
    "int_pow": "輔助工具", "sort_ints": "面公式與 BDD", "contains_int": "面公式與 BDD",
    "dmin": "區間", "dmax": "區間",
    "check_categories_all": "範疇化總檢",
    "spec_registry_sound": "規格登記",
    "deval": "依賴型別 NbE（Π/Σ/宇宙）", "d_infer": "依賴型別 NbE（Π/Σ/宇宙）",
    "d_check": "依賴型別 NbE（Π/Σ/宇宙）", "d_as_type": "依賴型別 NbE（Π/Σ/宇宙）",
    "dapp_typed": "依賴型別 NbE（Π/Σ/宇宙）", "dfst_typed": "依賴型別 NbE（Π/Σ/宇宙）",
    "dsnd_typed": "依賴型別 NbE（Π/Σ/宇宙）", "as_pi": "依賴型別 NbE（Π/Σ/宇宙）",
    "as_sigma": "依賴型別 NbE（Π/Σ/宇宙）", "as_univ_level": "依賴型別 NbE（Π/Σ/宇宙）",
    "conv_at": "依賴型別 NbE（Π/Σ/宇宙）", "conv_ty": "依賴型別 NbE（Π/Σ/宇宙）",
    "conv_neutral": "依賴型別 NbE（Π/Σ/宇宙）", "quote_at": "依賴型別 NbE（Π/Σ/宇宙）",
    "quote_ty": "依賴型別 NbE（Π/Σ/宇宙）", "quote_dneutral": "依賴型別 NbE（Π/Σ/宇宙）",
    "dep_type_val_of": "依賴型別 NbE（Π/Σ/宇宙）", "lty_to_dterm": "依賴型別 NbE（Π/Σ/宇宙）",
    "as_path": "立方 AST 與維度 NbE", "as_glue": "立方 AST 與維度 NbE",
    "as_list_elem": "立方 AST 與維度 NbE", "d_tube": "立方 AST 與維度 NbE",
    "fresh_dim": "立方 AST 與維度 NbE", "deval_dim": "立方 AST 與維度 NbE",
    "eval_dim_expr": "立方 AST 與維度 NbE", "eval_tube_terms": "立方 AST 與維度 NbE",
    "dim_quote": "立方 AST 與維度 NbE", "face_eval_env": "立方 AST 與維度 NbE",
    "face_quote": "立方 AST 與維度 NbE", "quote_tube_branches": "立方 AST 與維度 NbE",
    "dapp_dim": "立方 AST 與維度 NbE", "dep_def_eq_closed": "立方 AST 與維度 NbE",
    "dim_vars_of": "AST Kan comp/hcomp", "dim_nvars_sem": "AST Kan comp/hcomp",
    "dim_eq_sem": "AST Kan comp/hcomp", "face_nvars_sem": "AST Kan comp/hcomp",
    "face_is_top_sem": "AST Kan comp/hcomp", "face_is_bot_sem": "AST Kan comp/hcomp",
    "face_is_sat_sem": "AST Kan comp/hcomp", "tube_branch": "依賴語義系統與 partial 值",
    "map_branches": "依賴語義系統與 partial 值", "comp_value": "AST Kan comp/hcomp",
    "hcomp_value": "AST Kan comp/hcomp", "fill_value": "AST Kan comp/hcomp",
    "hfill_value": "AST Kan comp/hcomp", "coe_value": "AST Kan comp/hcomp",
    "comp_pi_value": "AST Kan comp/hcomp", "comp_sigma_value": "AST Kan comp/hcomp",
    "comp_path_value": "AST Kan comp/hcomp", "comp_glue_value": "AST Kan comp/hcomp",
    "comp_univ_value": "AST Kan comp/hcomp", "hcomp_univ_value": "AST Kan comp/hcomp",
    "circle_point": "資料型別與 HIT 消去", "torus_point": "資料型別與 HIT 消去",
    "circle_dim_of": "資料型別與 HIT 消去", "torus_dims_of": "資料型別與 HIT 消去",
    "d_nat_lit": "資料型別與 HIT 消去", "dv_nat_lit": "資料型別與 HIT 消去",
    "eval_bool_elim": "資料型別與 HIT 消去", "eval_nat_elim": "資料型別與 HIT 消去", "eval_list_elim": "資料型別與 HIT 消去",
    "eval_circle_elim": "資料型別與 HIT 消去", "eval_torus_elim": "資料型別與 HIT 消去",
    "comp_bool_value": "資料型別與 HIT 消去", "comp_nat_value": "資料型別與 HIT 消去",
    "comp_list_value": "資料型別與 HIT 消去", "comp_circle_value": "資料型別與 HIT 消去",
    "comp_torus_value": "資料型別與 HIT 消去",
    "quote_eta": "型別化 NbE 與 η", "quote_tneutral": "型別化 NbE 與 η",
    "nf_eta": "型別化 NbE 與 η", "def_eq_eta": "型別化 NbE 與 η",
    "sym_affine_path": "譜投影與仿射唯一填充", "sym_square_fill": "譜投影與仿射唯一填充",
    "sym_bilinear_from_corners": "譜投影與仿射唯一填充", "sym_bilinear_ansatz": "譜投影與仿射唯一填充",
    "sym_frac_one_minus": "譜投影與仿射唯一填充", "sym_hermitian2": "譜投影與仿射唯一填充",
    "d_face_term": "依賴語義系統與 partial 值", "dface_value": "依賴語義系統與 partial 值",
    "glue_partial_values": "依賴語義系統與 partial 值", "glue_store_partial": "依賴語義系統與 partial 值",
    "dim_cache_key": "持久環境、惰性與語義快取",
    "check_telescope_terms": "通用歸納族 schema", "telescope_type_values": "通用歸納族 schema",
    "conv_telescope_values": "通用歸納族 schema", "quote_telescope_values": "通用歸納族 schema",
    "conv_schema_args": "通用歸納族 schema", "quote_schema_args": "通用歸納族 schema",
    "schema_motives_conv": "通用歸納族 schema", "quote_schema_motive": "通用歸納族 schema",
    "comp_schema_args": "通用歸納族 schema", "comp_inductive_value": "通用歸納族 schema",
    "eval_inductive_elim": "通用歸納族 schema", "eval_inductive_elim_term": "通用歸納族 schema",
    "eval_inductive_type_term": "通用歸納族 schema", "eval_intro_term": "通用歸納族 schema",
    "infer_inductive_elim": "通用歸納族 schema", "infer_inductive_type": "通用歸納族 schema",
    "infer_intro": "通用歸納族 schema", "conv_inductive_elim_neutral": "通用歸納族 schema",
    "conv_inductive_type": "通用歸納族 schema", "conv_intro_at": "通用歸納族 schema",
    "quote_inductive_elim_neutral": "通用歸納族 schema",
    "quote_inductive_type": "通用歸納族 schema", "quote_intro_at": "通用歸納族 schema",
    "nat_schema": "通用歸納族 schema", "bool_schema": "通用歸納族 schema",
    "list_schema": "通用歸納族 schema", "vec_schema": "通用歸納族 schema",
    "fin_schema": "通用歸納族 schema", "tree_schema": "通用歸納族 schema", "w_schema": "通用歸納族 schema",
    "nat_schema_lit": "通用歸納族 schema",
    "eval_hit_elim": "通用 HIT schema", "eval_hit_elim_term": "通用 HIT schema",
    "eval_hit_intro_term": "通用 HIT schema", "eval_hit_type_term": "通用 HIT schema",
    "infer_hit_elim": "通用 HIT schema", "infer_hit_intro": "通用 HIT schema", "infer_hit_type": "通用 HIT schema",
    "conv_hit_cell_at": "通用 HIT schema", "conv_hit_elim_neutral": "通用 HIT schema",
    "conv_hit_type": "通用 HIT schema", "quote_hit_cell_at": "通用 HIT schema",
    "quote_hit_elim_neutral": "通用 HIT schema", "quote_hit_type": "通用 HIT schema",
    "comp_hit_value": "通用 HIT schema", "circle_schema": "通用 HIT schema",
    "segment_schema": "通用 HIT schema", "torus_schema": "通用 HIT schema",
}


TYPE_FAMILY.update({
    "AlgPoly": "完備精確代數與根隔離", "AlgPolyDiv": "完備精確代數與根隔離",
    "AlgPolyFactor": "完備精確代數與根隔離", "ComplexDisk": "完備精確代數與根隔離",
    "ComplexRootIsolation": "完備精確代數與根隔離",
    "QPolyCompleteFactorization": "完備精確代數與根隔離",
    "RadicalExpr": "完備精確代數與根隔離", "RealRootIsolation": "完備精確代數與根隔離",
    "SplittingField": "完備精確代數與根隔離", "SplittingRoot": "完備精確代數與根隔離",
    "DLevelDecl": "一等宇宙多態與同時宣告 schema",
    "DLevelHitDecl": "一等宇宙多態與同時宣告 schema",
    "DLevelInductiveDecl": "一等宇宙多態與同時宣告 schema",
    "DLevelTermDecl": "一等宇宙多態與同時宣告 schema",
    "DLevelTermInstance": "一等宇宙多態與同時宣告 schema",
    "DMutualDecl": "一等宇宙多態與同時宣告 schema",
    "DMutualPositivityReport": "一等宇宙多態與同時宣告 schema",
    "DNestedArg": "一等宇宙多態與同時宣告 schema",
    "DNestedConstructor": "一等宇宙多態與同時宣告 schema",
    "DNestedIterDecl": "一等宇宙多態與同時宣告 schema",
    "DNestedIterFamily": "一等宇宙多態與同時宣告 schema",
    "DSimultaneousFunction": "一等宇宙多態與同時宣告 schema",
    "DSimultaneousIRSpec": "一等宇宙多態與同時宣告 schema",
    "DTypeOperatorDecl": "一等宇宙多態與同時宣告 schema",
    "DFaceConvReport": "原始 DSystem 相容性與 first-match 範形",
    "DSystemRepair": "原始 DSystem 相容性與 first-match 範形",
    "DSchemaRegistrySnapshot": "Schema 註冊與 elaboration 快取",
    "DAdjointEquivParts": "Adjoint 等價、纖維與命題截斷",
    "AlgC": "認證數值影子與精確立方體",
    "AlgCertMat": "認證數值影子與精確立方體",
    "AlgCertPath": "認證數值影子與精確立方體",
    "AlgCertSquare": "認證數值影子與精確立方體",
    "AlgCertVec": "認證數值影子與精確立方體",
    "CompiledModule": "模組分離編譯與連結",
    "CompiledModuleEnv": "模組分離編譯與連結",
    "ModuleCompileCache": "模組分離編譯與連結",
    "ModuleCompileCacheEntry": "模組分離編譯與連結",
    "ModuleDependencyFingerprint": "模組分離編譯與連結",
    "BddOptimizedBuild": "BDD DAG、預算與 DPLL",
    "FaceBoolExpr": "BDD DAG、預算與 DPLL",
    "FaceCnfStats": "BDD DAG、預算與 DPLL",
    "HouSearchReport": "高階合一與雙向 elaborator",
    "HouSearchStatus": "高階合一與雙向 elaborator",
    "ModuleBinaryLoad": "模組分離編譯與連結",
    "ModuleBinaryStatus": "模組分離編譯與連結",
    "SphereLoopExpr": "球面同倫代表元與 Hopf 不變量",
})

for _name in [
    "qpoly_factor_complete", "qpoly_factor_complete_with_budget",
    "qpoly_complete_factorization_expand", "qpoly_is_irreducible",
    "qpoly_sturm_sequence", "qpoly_sturm_variations", "qpoly_real_root_count",
    "qpoly_isolate_real_roots", "qpoly_isolate_complex_roots",
    "qpoly_splitting_field", "qmat_symmetric_eigenvalue_isolations",
    "qcpx_hermitian_charpoly", "qcpx_hermitian_eigenvalue_isolations",
]:
    EXACT[_name] = "完備精確代數與根隔離"
for _name in [
    "dterm_instantiate_levels", "dterm_levels_in_scope", "dlevel_expr_in_scope",
    "extract_positive_functor", "darg_nested_from_type",
    "eval_simultaneous_ir", "circle_level_decl", "list_level_decl",
    "compile_nested_iter_decl", "nat_parity_double_ir",
]:
    EXACT[_name] = "一等宇宙多態與同時宣告 schema"
for _name in [
    "equiv_triangle_type", "equiv_improved_sect_value",
    "equiv_with_improved_sect", "equiv_fiber_center_value",
    "is_contr_type_term", "fiber_type_term", "contractible_fibers_type_term",
    "identity_fibers_contractible_value", "singleton_contraction_value",
]:
    EXACT[_name] = "Adjoint 等價、纖維與命題截斷"
for _name in [
    "loop_space_type_term", "based_map_type_term", "iterated_refl_term",
    "sphere_degree_value", "sphere_degree_function_value",
    "sphere3_swapped_schema", "sphere3_swapped_type_term",
    "sphere3_swapped_north_value", "sphere3_swapped_south_value",
    "sphere3_swapped_meridian_value", "sphere3_to_swapped_value",
    "sphere3_from_swapped_value", "sphere3_swapped_retr_value",
    "sphere3_swapped_sect_value", "sphere3_swapped_equiv_value",
    "suspension_map_value", "suspension_meridian_path_value",
    "suspension_unit_loop_value",
]:
    EXACT[_name] = "球面同倫代表元與 Hopf 不變量"
for _name in ["cube_root_two_modulus", "cube_root_unit_vector"]:
    EXACT[_name] = "認證數值影子與精確立方體"
for _name in [
    "module_decl_abstract", "module_compile", "module_compile_with_compiled",
    "module_link_signature", "module_link_instantiate",
    "module_source_fingerprint", "module_compile_cache_new",
    "module_compile_cache_size", "module_compile_cache_lookup",
    "module_compile_cached", "module_dependency_fingerprint",
    "module_dependency_of_compiled", "abstract_point_module",
    "point_implementation_module", "point_client_module",
]:
    EXACT[_name] = "模組分離編譯與連結"

for _name in [
    "adjointify_equiv_value", "equiv_fiber_type_value",
    "equiv_fiber_path_value", "equiv_fiber_contraction_value",
    "equiv_contractible_fibers_value",
]:
    EXACT[_name] = "Adjoint 等價、纖維與命題截斷"
for _name in [
    "face_sat_watched_dpll", "face_eq_watched_dpll", "face_cnf_stats",
]:
    EXACT[_name] = "BDD DAG、預算與 DPLL"
for _name in [
    "integer_schema", "integer_type_term", "integer_type_value",
    "integer_term", "integer_value", "integer_pred_value",
    "integer_succ_value", "homotopy_group_type_term",
    "pi3_sphere_type_term", "pi3_sphere_point_term",
    "iterated_refl_value", "loop_space_type_value",
    "sphere_type_term", "sphere_type_value", "sphere_north_term",
    "sphere_north_value", "suspend_loop_value",
    "sphere_loop_power_value", "sphere_loop_expr_degree",
    "sphere_loop_expr_of_integer", "sphere_loop_compose_value",
    "sphere_loop_expr_value", "dpath_trans_sym_cancel_value",
]:
    EXACT[_name] = "球面同倫代表元與 Hopf 不變量"

CHECK_FAMILY_HINTS = [
    ("general_adjointification", "Adjoint 等價、纖維與命題截斷"),
    ("hou_bounded_search", "高階合一與雙向 elaborator"),
    ("module_binary_format", "模組分離編譯與連結"),
    ("bdd_cost_optimizations", "BDD DAG、預算與 DPLL"),
    ("qpoly_fast_arithmetic", "精確單變量多項式與有理矩陣"),
    ("sphere_loop_representatives", "球面同倫代表元與 Hopf 不變量"),
    ("qpoly_factor_complete", "完備精確代數與根隔離"),
    ("root_isolation", "完備精確代數與根隔離"),
    ("splitting_field", "完備精確代數與根隔離"),
    ("radical_denesting", "完備精確代數與根隔離"),
    ("jacobi_arbitrary_precision", "Jacobi 區間譜迭代"),
    ("level_polymorphic", "一等宇宙多態與同時宣告 schema"),
    ("type_operator", "一等宇宙多態與同時宣告 schema"),
    ("nested_iter", "一等宇宙多態與同時宣告 schema"),
    ("mutual_declaration", "一等宇宙多態與同時宣告 schema"),
    ("simultaneous_induction", "一等宇宙多態與同時宣告 schema"),
    ("hit_moving_dimension", "一等宇宙多態與同時宣告 schema"),
    ("dsystem_repair_phase9", "原始 DSystem 相容性與 first-match 範形"),
    ("adjoint_equivalence", "Adjoint 等價、纖維與命題截斷"),
    ("propositional_truncation", "Adjoint 等價、纖維與命題截斷"),
    ("dline_dimension", "依賴 Kan 線（coe/comp）"),
    ("semantic_dimension", "受檢查語義型別線"),
    ("schema_registry_persistence", "Schema 註冊與 elaboration 快取"),
    ("certified_algebraic", "認證數值影子與精確立方體"),
    ("bdd_dag_native", "BDD DAG、預算與 DPLL"),
    ("sphere_homotopy", "球面同倫代表元與 Hopf 不變量"),
    ("hopf_numeric", "球面同倫代表元與 Hopf 不變量"),
    ("hou_phase9", "高階合一與雙向 elaborator"),
    ("module_compilation", "模組分離編譯與連結"),
    ("cubical_algorithms", "立方體演算法"), ("univalence", "計算性單值性（univalence）"),
    ("finite_univalence", "計算性單值性（univalence）"), ("universe_paths", "計算性單值性（univalence）"),
    ("sphere3", "球面與懸掛 HIT"),
    ("jacobi_interval", "Jacobi 區間譜迭代"),
    ("hou_elaborator", "高階合一與雙向 elaborator"),
    ("module_system", "參數化模組與名字空間"),
    ("container_functor", "Schema 函子、正性與歸納遞迴"),
    ("bdd_and_certified", "認證數值影子與精確立方體"),
    ("algebraic_extensions", "廣義特徵空間與 Jordan 理論"),
    ("phase6_infrastructure", "受檢查語義型別線"),
    ("equiv_ast", "AST 一等 Equiv 與 GlueEquiv"),
    ("dsystem_compatibility", "原始 DSystem 相容性與 first-match 範形"),
    ("dsystem_first_match", "原始 DSystem 相容性與 first-match 範形"),
    ("schema_extensions", "Schema 擴展：互歸納、商與宇宙多態"),
    ("structural_positivity", "Schema 函子、正性與歸納遞迴"),
    ("tarski", "Schema 函子、正性與歸納遞迴"),
    ("nested_rose", "Schema 函子、正性與歸納遞迴"),
    ("hit_schema", "通用 HIT schema"), ("hit_endpoint", "通用 HIT schema"),
    ("generated_hit", "通用 HIT schema"), ("schema", "通用歸納族 schema"),
    ("generated_inductive", "通用歸納族 schema"), ("persistent", "持久環境、惰性與語義快取"),
    ("dsystem", "依賴語義系統與 partial 值"), ("multibranch", "依賴語義系統與 partial 值"),
    ("phase5", "依賴語義系統與 partial 值"),
    ("ast_kan", "AST Kan comp/hcomp"), ("ast_coe", "AST Kan comp/hcomp"),
    ("ast_hcomp", "AST Kan comp/hcomp"), ("ast_bool", "資料型別與 HIT 消去"), ("ast_nat", "資料型別與 HIT 消去"),
    ("ast_list", "資料型別與 HIT 消去"), ("ast_data", "資料型別與 HIT 消去"),
    ("ast_hits", "資料型別與 HIT 消去"), ("ast", "立方 AST 與維度 NbE"),
    ("dep", "依賴型別 NbE（Π/Σ/宇宙）"),
    ("kan_coe", "依賴 Kan 線（coe/comp）"), ("kan_comp", "依賴 Kan 線（coe/comp）"),
    ("kan_embeddings", "依賴 Kan 線（coe/comp）"), ("kan_dep", "依賴 Kan 線（coe/comp）"),
    ("kan_all", "依賴 Kan 線（coe/comp）"),
    ("spectral", "譜投影與仿射唯一填充"), ("symbolic", "譜投影與仿射唯一填充"),
    ("bdd", "面公式與 BDD"), ("eta", "型別化 NbE 與 η"),
    ("wiring", "Wiring 符號等價"),
    ("glue_comp", "Glue comp（有限線）"), ("glue", "有限 Glue"),
    ("karoubi", "Karoubi 包絡"), ("face_poset", "面偏序範疇"),
    ("syntactic", "句法笛卡兒閉範疇"), ("cubical", "立方體與 Kan 填充"),
    ("categories", "範疇化總檢"),
    ("projector", "投影與特徵空間"), ("eigenspace", "投影與特徵空間"),
    ("commuting", "投影與特徵空間"), ("orthogonal", "投影與特徵空間"),
    ("kan", "立方體與 Kan 填充"), ("cube", "立方體與 Kan 填充"),
    ("interval", "面公式與 BDD"), ("systems", "系統與剪枝"),
    ("nbe", "未型別 NbE"), ("coe", "同構、等價、ua、coe"),
    ("hoas", "HOAS"), ("ua", "同構、等價、ua、coe"),
    ("pathp", "PathP、離散路徑與 J"), ("j", "PathP、離散路徑與 J"),
]

PREFIXES = [
    ("algpoly_", "完備精確代數與根隔離"), ("bigint_", "完備精確代數與根隔離"),
    ("complex_root_", "完備精確代數與根隔離"), ("real_root_", "完備精確代數與根隔離"),
    ("splitting_field_", "完備精確代數與根隔離"), ("radical_", "完備精確代數與根隔離"),
    ("level_", "一等宇宙多態與同時宣告 schema"),
    ("dnested_", "一等宇宙多態與同時宣告 schema"),
    ("nested_iter_", "一等宇宙多態與同時宣告 schema"),
    ("bush_", "一等宇宙多態與同時宣告 schema"),
    ("dmutual_", "一等宇宙多態與同時宣告 schema"),
    ("dsimultaneous_", "一等宇宙多態與同時宣告 schema"),
    ("simultaneous_ir_", "一等宇宙多態與同時宣告 schema"),
    ("dtype_operator_", "一等宇宙多態與同時宣告 schema"),
    ("type_operator_", "一等宇宙多態與同時宣告 schema"),
    ("compiled_module_", "模組分離編譯與連結"),
    ("algc_", "認證數值影子與精確立方體"),
    ("alg_cert_", "認證數值影子與精確立方體"),
    ("circle_hit_", "球面同倫代表元與 Hopf 不變量"),
    ("circle_degree_", "球面同倫代表元與 Hopf 不變量"),
    ("hopf_", "球面同倫代表元與 Hopf 不變量"),
    ("adjoint_", "Adjoint 等價、纖維與命題截斷"),
    ("prop_trunc_", "Adjoint 等價、纖維與命題截斷"),
    ("trunc_", "Adjoint 等價、纖維與命題截斷"),
    ("conv_at_under_face_report", "原始 DSystem 相容性與 first-match 範形"),
    ("univalence_", "計算性單值性（univalence）"), ("universe_path_", "計算性單值性（univalence）"),
    ("path_to_equiv", "計算性單值性（univalence）"), ("equiv_to_universe_path", "計算性單值性（univalence）"),
    ("ua_beta", "計算性單值性（univalence）"), ("ua_transport", "計算性單值性（univalence）"),
    ("ua_map_term", "計算性單值性（univalence）"), ("upath_to_equiv", "計算性單值性（univalence）"),
    ("upath_refl", "計算性單值性（univalence）"), ("upath_sym", "計算性單值性（univalence）"),
    ("upath_trans", "計算性單值性（univalence）"), ("finite_transport", "計算性單值性（univalence）"),
    ("transport_roundtrip", "計算性單值性（univalence）"),
    ("transport_", "立方體演算法"), ("dpath_", "立方體演算法"),
    ("dtransport", "立方體演算法"), ("dfunext", "立方體演算法"),
    ("subst_", "立方體演算法"), ("kan_box", "立方體演算法"),
    ("sphere", "球面與懸掛 HIT"), ("suspension_", "球面與懸掛 HIT"),
    ("rat_interval", "Jacobi 區間譜迭代"), ("rat_sqrt_interval", "Jacobi 區間譜迭代"),
    ("rat_cmp_exact", "Jacobi 區間譜迭代"), ("rat_le_exact", "Jacobi 區間譜迭代"),
    ("rat_abs_exact", "Jacobi 區間譜迭代"), ("rat_round_", "Jacobi 區間譜迭代"),
    ("cinterval", "Jacobi 區間譜迭代"), ("qci_", "Jacobi 區間譜迭代"),
    ("qcpx", "Jacobi 區間譜迭代"), ("jacobi_", "Jacobi 區間譜迭代"),
    ("eigen_interval", "Jacobi 區間譜迭代"),
    ("elab_", "高階合一與雙向 elaborator"), ("elaborator_", "高階合一與雙向 elaborator"),
    ("hou_", "高階合一與雙向 elaborator"), ("unifier_", "高階合一與雙向 elaborator"),
    ("uterm_", "高階合一與雙向 elaborator"), ("uty_", "高階合一與雙向 elaborator"),
    ("module_", "參數化模組與名字空間"),
    ("bdd_manager", "BDD DAG、預算與 DPLL"), ("bdd_dag", "BDD DAG、預算與 DPLL"),
    ("bdd_tree_of_dag", "BDD DAG、預算與 DPLL"), ("bdd_worst", "BDD DAG、預算與 DPLL"),
    ("bdd_var_order", "BDD DAG、預算與 DPLL"),
    ("face_sat_dpll", "BDD DAG、預算與 DPLL"), ("face_eq_dpll", "BDD DAG、預算與 DPLL"),
    ("face_sat_within_budget", "BDD DAG、預算與 DPLL"), ("face_eq_within_budget", "BDD DAG、預算與 DPLL"),
    ("checked_", "受檢查語義型別線"),
    ("infer_equiv", "AST 一等 Equiv 與 GlueEquiv"), ("infer_glue_equiv", "AST 一等 Equiv 與 GlueEquiv"),
    ("infer_mk_equiv", "AST 一等 Equiv 與 GlueEquiv"), ("infer_ua", "AST 一等 Equiv 與 GlueEquiv"),
    ("dfunctor_", "Schema 函子、正性與歸納遞迴"), ("positive_functor_", "Schema 函子、正性與歸納遞迴"),
    ("dterm_family_", "Schema 函子、正性與歸納遞迴"), ("dpositivity_", "Schema 函子、正性與歸納遞迴"),
    ("mutual_", "Schema 擴展：互歸納、商與宇宙多態"), ("compile_mutual", "Schema 擴展：互歸納、商與宇宙多態"),
    ("instantiate_", "Schema 擴展：互歸納、商與宇宙多態"), ("dlevel_", "Schema 擴展：互歸納、商與宇宙多態"),
    ("qmat_generalized", "廣義特徵空間與 Jordan 理論"), ("qmat_Jordan", "廣義特徵空間與 Jordan 理論"),
    ("qmat_primary", "廣義特徵空間與 Jordan 理論"), ("qmat_eigen", "廣義特徵空間與 Jordan 理論"),
    ("qmat_diagonalizable", "廣義特徵空間與 Jordan 理論"), ("qmat_is_diagonalizable", "廣義特徵空間與 Jordan 理論"),
    ("qmat_rational_spectrum", "廣義特徵空間與 Jordan 理論"), ("qmat_vector_annihilator", "廣義特徵空間與 Jordan 理論"),
    ("qpoly_", "精確單變量多項式與有理矩陣"), ("qmat_", "精確單變量多項式與有理矩陣"),
    ("qrows_", "精確單變量多項式與有理矩陣"), ("qvec_", "精確單變量多項式與有理矩陣"),
    ("quad_", "代數擴張與根式範形"), ("alg_", "代數擴張與根式範形"),
    ("algmat_", "廣義特徵空間與 Jordan 理論"), ("algrows_", "廣義特徵空間與 Jordan 理論"),
    ("algvec_", "廣義特徵空間與 Jordan 理論"),
    ("cert_", "認證數值影子與精確立方體"), ("certify_", "認證數值影子與精確立方體"),
    ("qcc_", "認證數值影子與精確立方體"), ("numeric_", "認證數值影子與精確立方體"),
    ("cx", "複數標量"), ("cx_", "複數標量"),
    ("vec_", "複向量與內積"), ("inner", "複向量與內積"),
    ("mat_", "矩陣與伴隨"),
    ("is_", "投影與特徵空間"), ("eigen", "投影與特徵空間"),
    ("projector_", "投影與特徵空間"), ("decompose", "投影與特徵空間"),
    ("complement", "投影與特徵空間"),
    ("in_image", "投影與特徵空間"), ("in_kernel", "投影與特徵空間"),
    ("prune_to_eigenspace", "投影與特徵空間"), ("pruning_is_retraction", "投影與特徵空間"),
    ("commuting", "投影與特徵空間"),
    ("karoubi_", "Karoubi 包絡"),
    ("eval_dim", "區間"), ("interval_", "區間"),
    ("bdd_", "面公式與 BDD"), ("dim_", "面公式與 BDD"), ("face_", "面公式與 BDD"),
    ("system_", "系統與剪枝"), ("branch", "系統與剪枝"),
    ("prune_system", "系統與剪枝"), ("pruning_respects", "系統與剪枝"),
    ("compatibility_", "系統與剪枝"), ("union_", "系統與剪枝"),
    ("cube_", "立方體與 Kan 填充"), ("path_line", "立方體與 Kan 填充"),
    ("path_refl", "立方體與 Kan 填充"), ("path_sym", "立方體與 Kan 填充"),
    ("path_eval", "立方體與 Kan 填充"), ("path_start", "立方體與 Kan 填充"),
    ("path_end", "立方體與 Kan 填充"), ("path_trans", "立方體與 Kan 填充"),
    ("restrict_face", "立方體與 Kan 填充"), ("degenerate_", "立方體與 Kan 填充"),
    ("square_fill", "立方體與 Kan 填充"), ("open_box", "立方體與 Kan 填充"),
    ("filler_", "立方體與 Kan 填充"), ("kan_", "立方體與 Kan 填充"),
    ("prune_cube", "立方體與 Kan 填充"), ("bumped_filler", "立方體與 Kan 填充"),
    ("pruning_repairs", "立方體與 Kan 填充"), ("eigenspace_kan", "立方體與 Kan 填充"),
    ("eval", "未型別 NbE"), ("quote", "未型別 NbE"), ("nf", "未型別 NbE"),
    ("def_eq", "未型別 NbE"), ("nbe_", "未型別 NbE"),
    ("vapp", "未型別 NbE"), ("vfst", "未型別 NbE"), ("vsnd", "未型別 NbE"),
    ("happ", "HOAS"), ("hfst", "HOAS"), ("hsnd", "HOAS"), ("hoas_", "HOAS"),
    ("term_to_hoas", "HOAS"),
    ("ty_", "型別化 NbE 與 η"), ("eval_check_t", "型別化 NbE 與 η"),
    ("eval_infer_t", "型別化 NbE 與 η"), ("tapp", "型別化 NbE 與 η"),
    ("tfst", "型別化 NbE 與 η"), ("tsnd", "型別化 NbE 與 η"),
    ("quote_eta", "型別化 NbE 與 η"), ("quote_tneutral", "型別化 NbE 與 η"),
    ("nf_eta", "型別化 NbE 與 η"), ("def_eq_eta", "型別化 NbE 與 η"),
    ("eta_", "型別化 NbE 與 η"),
    ("tm_shift", "句法笛卡兒閉範疇"), ("tm_comp", "句法笛卡兒閉範疇"),
    ("tm_id_at", "句法笛卡兒閉範疇"), ("tm_swap_at", "型別化 NbE 與 η"),
    ("tm_coe_swap_at", "型別化 NbE 與 η"),
    ("elems_of", "有限宇宙型別與值"), ("in_ty", "有限宇宙型別與值"),
    ("pval_", "有限宇宙型別與值"), ("flatten_pval", "Wiring 符號等價"),
    ("leaf_", "Wiring 符號等價"), ("leaves_", "Wiring 符號等價"), ("wiring_", "Wiring 符號等價"),
    ("iso_", "同構、等價、ua、coe"), ("equiv_", "同構、等價、ua、coe"),
    ("ua", "同構、等價、ua、coe"), ("upath_", "同構、等價、ua、coe"),
    ("coe_upath", "同構、等價、ua、coe"), ("coe_computes", "同構、等價、ua、coe"),
    ("swap_naturality", "同構、等價、ua、coe"),
    ("pathp_", "PathP、離散路徑與 J"), ("disc_", "PathP、離散路徑與 J"),
    ("refl_path", "PathP、離散路徑與 J"), ("j_", "PathP、離散路徑與 J"),
    ("glue_data", "Glue comp（有限線）"), ("glue_line", "Glue comp（有限線）"),
    ("glue_comp_finite", "Glue comp（有限線）"),
    ("glue_box", "Glue comp（子空間線）"), ("glue_comp_vec", "Glue comp（子空間線）"),
    ("subline_", "Glue comp（子空間線）"), ("lin_equiv", "Glue comp（子空間線）"),
    ("fill_subline", "Glue comp（子空間線）"), ("map_cube", "Glue comp（子空間線）"),
    ("glue_", "有限 Glue"), ("make_glue", "有限 Glue"), ("unglue", "有限 Glue"),
    ("dep_", "依賴型別 NbE（Π/Σ/宇宙）"),
    ("dline_", "依賴 Kan 線（coe/comp）"), ("dcoe", "依賴 Kan 線（coe/comp）"),
    ("dcomp", "依賴 Kan 線（coe/comp）"), ("dfill", "依賴 Kan 線（coe/comp）"),
    ("dbool_not", "依賴 Kan 線（coe/comp）"), ("path_from", "依賴 Kan 線（coe/comp）"),
    ("pval_to_dvalue", "依賴 Kan 線（coe/comp）"), ("dvalue_", "依賴 Kan 線（coe/comp）"),
    ("rat_", "精確符號代數"), ("int_abs", "精確符號代數"), ("int_gcd", "精確符號代數"),
    ("poly_", "精確符號代數"), ("frac_", "精確符號代數"), ("sc_", "精確符號代數"),
    ("sym_", "精確符號代數"), ("upoly_", "精確符號代數"), ("charpoly_sym", "精確符號代數"),
    ("rpoly_", "譜投影與仿射唯一填充"), ("spectral_", "譜投影與仿射唯一填充"),
    ("spec_", "規格登記"),
    ("denv_", "持久環境、惰性與語義快取"), ("ddim_", "持久環境、惰性與語義快取"),
    ("lazy_", "持久環境、惰性與語義快取"), ("force_value", "持久環境、惰性與語義快取"),
    ("memo_", "持久環境、惰性與語義快取"), ("dterm_cache", "持久環境、惰性與語義快取"),
    ("dim_cache", "持久環境、惰性與語義快取"),
    ("dsystem_", "依賴語義系統與 partial 值"), ("partial_", "依賴語義系統與 partial 值"),
    ("tube_system_", "依賴語義系統與 partial 值"), ("glue_partial_", "依賴語義系統與 partial 值"),
    ("glue_store_", "依賴語義系統與 partial 值"),
    ("darg_", "通用歸納族 schema"), ("dtelescope_", "通用歸納族 schema"),
    ("dconstructor_", "通用歸納族 schema"), ("dinductive_", "通用歸納族 schema"),
    ("inductive_", "通用歸納族 schema"), ("schema_", "通用歸納族 schema"),
    ("telescope_", "通用歸納族 schema"),
    ("dhit_", "通用 HIT schema"), ("hit_", "通用 HIT schema"),
    ("run_all_checks", "定理登記與範例"), ("all_checks_pass", "定理登記與範例"),
    ("print_report", "定理登記與範例"),
]

KIND_LABELS = {
    "zh": {
        "fn": "函數", "struct": "結構", "enum": "列舉", "type": "型別別名",
        "let": "常量", "constructor": "構造子", "field": "欄位",
    },
    "en": {
        "fn": "function", "struct": "struct", "enum": "enum", "type": "type alias",
        "let": "constant", "constructor": "constructor", "field": "field",
    },
}

FAMILIES_EN = {
    "複數標量": ("Complex scalars", "ordered pair (re, im)", "the commutative ring C; conjugation is an involution", "componentwise eps comparison"),
    "複向量與內積": ("Complex vectors and inner products", "component lists", "objects of the Hilbert-space category Hilb; the inner product induces duals", "componentwise computation"),
    "矩陣與伴隨": ("Matrices and adjoints", "lists of rows", "morphisms of Hilb; † is the dagger functor", "matrix computation"),
    "投影與特徵空間": ("Projectors and eigenspaces", "Σ vₖvₖ†; orthogonal decomposition (Pv,(I−P)v)", "self-adjoint idempotent morphisms and their splittings (biproducts) in Hilb", "eigenvalue equations / orthogonality / integrality of trace"),
    "Karoubi 包絡": ("Karoubi envelope", "object P; morphisms are clamped matrices with QAP=A", "idempotent completion; the identity on P is P itself; dagger structure", "QAP=A and the composition laws"),
    "區間": ("Interval", "De Morgan expressions; booleanization at endpoints", "the De Morgan algebra (interval object)", "evaluation and rewrite simplification"),
    "面公式與 BDD": ("Face formulas and BDDs", "ROBDD trees expanded from interned DAGs (compatibility view); primary decisions use manager roots", "canonical representatives of the face lattice (a quotient of the free bounded distributive lattice)", "DAG apply/root equality; the tree API expands formula by formula"),
    "面偏序範疇": ("Face poset category", "BDD equivalence classes", "poset category with ∧ as product, ∨ as coproduct, ⊤/⊥ terminal/initial", "bdd_face_le and universal-property equations"),
    "系統與剪枝": ("Systems and pruning", "branch lists; for the semantic normal form see symbolic system normal forms", "partial elements of presheaves on faces; union gluing", "BDD satisfiability on overlapping faces"),
    "系統符號範形": ("Symbolic system normal forms", "value-labelled disjoint BDD partitions plus the undefined region", "image decomposition of partial elements in slices of the face lattice", "BDD region operations"),
    "立方體與 Kan 填充": ("Cubes and Kan filling", "functions Iⁿ→Cᵐ; affine filler formulas; the cap is the comp result", "realizations of cubical sets over □; Kan structures of retracts", "boundary equations (on grids)"),
    "未型別 NbE": ("Untyped NbE", "βπ-normal forms nf", "morphism representatives of the syntactic category modulo βπ", "structural comparison after eval/quote"),
    "HOAS": ("HOAS", "de Bruijn normal forms after reification", "functor-category binding; equivalent to the first-order syntactic category modulo definitional equality", "reflect/reify round-trips"),
    "型別化 NbE 與 η": ("Typed NbE and η", "η-long βπ-normal forms nf_eta", "morphism representatives of the free cartesian closed category", "bidirectional checking plus type-directed quoting"),
    "依賴型別 NbE（Π/Σ/宇宙）": ("Dependent NbE (Π/Σ/universes)", "η-long dependent normal forms quoted by type; Π/Σ second components are semantic closure families; cumulative Typeᵢ levels", "a categories-with-families (CwF) model: context extension and dependent substitution are closure application", "bidirectional elaboration plus type-directed conversion; equality is normal-form equality"),
    "立方 AST 與維度 NbE": ("Cubical AST and dimension NbE", "separate term/dimension de Bruijn indices in DTerm; line and tube bodies; quoting with dlevel", "a cubical CwF with interval contexts; PathP is the dependent path object and Glue values are (raw/DPartial partial, base) pairs", "bidirectional checking plus Dim/Face simplification and ROBDD semantic predicates"),
    "AST Kan comp/hcomp": ("AST Kan comp/hcomp", "branches are always carried as DSystem; dispatch by type head at a generic dimension; top branches give caps and formal DNComp/DNHComp are the stuck forms", "every type former preserves Kan fibration structure; hcompU is Glue gluing", "system base/overlap compatibility plus recursion on types; coe/fill are segment restrictions of comp"),
    "資料型別與 HIT 消去": ("Data types and HIT elimination", "constructor recursion for Nat/List; Circle loop@r; Torus square@(i,j) modulo opposite-edge identification", "dependent elimination for initial algebras and HITs is a section of the motive and commutes with formal composition", "constructor-pattern recursion, semantic dimension equality, and comp in motives"),
    "持久環境、惰性與語義快取": ("Persistent environments, laziness and semantic caches", "length-carrying persistent lists DEnv/DDimEnv (innermost de Bruijn head); DVThunk is forced at most once; cache keys are simplified dimensions / quoted-term Debug keys", "CwF context extension is cons with a shared tail; lazy values are call-by-need semantic values and memoized families/dimension lines are finite graphs of extensional functions", "environment indexing, force_count and cache-key equality"),
    "依賴語義系統與 partial 值": ("Dependent semantic systems and partial values", "DSystem branches drop ⊥, merge equal bodies by value and sort by quotation; DPartialValue has the BDD effective-region partition DSystemNF", "partial elements in face-lattice slices; multi-branch Glue is a limit-style pairing of a partial type system with a base", "BDD region operations plus type-directed conversion/quotation keys on branch bodies"),
    "通用歸納族 schema": ("Generic inductive-family schemas", "telescopes plus full DTerm argument types (external, direct/nested/functional recursion and constraints); values are DVIntro and neutral eliminations quote by generated case types", "dependent initial algebras of structured strictly positive functors; eliminators are motive sections and comp recurses along earlier argument fillers", "schema structural equality, telescope elaboration, polarity/positivity decision and generated checking"),
    "通用 HIT schema": ("Generic HIT schemas", "cells of arbitrary finite dimension; every endpoint reduces dimensionwise by face expressions; cases are dimensionwise nested PathP", "cellular higher initial algebras with face maps; eliminators preserve cells in every dimension", "face argument/index checks, two-route corner-reduction conversion and semantic dimension equality"),
    "依賴 Kan 線（coe/comp）": ("Dependent Kan lines (coe/comp)", "DLine{at, coe, fill} with comp=fill(1); coe goes backwards in Π domains and along the first-component path in Σ", "a type is a Kan fibration structure; a dependent family is (path)→DLine; together with subspace/Glue lines all project type families are covered", "recursion on type formers; coe(r,r) is definitionally the identity"),
    "精確符號代數": ("Exact symbolic algebra", "multivariate polynomial normal forms over Q (merged, zero-free, sorted); fractions; complex symbolic scalars (re,im)", "matrix algebra over polynomial rings and fraction fields; conjugation is an involution", "polynomial identities / fraction cross-multiplication (exact)"),
    "譜投影與仿射唯一填充": ("Spectral projectors and unique affine filling", "Pₖ=qₖ(A)/qₖ(λₖ); bilinear corner interpolation k00+i k10+j k01+ij k11", "resolutions of the identity and spectral decompositions; bilinearity is tensor gluing of two affine directions", "monic division modulo the minimal polynomial and identities in atoms i,j"),
    "句法笛卡兒閉範疇": ("Syntactic cartesian closed category", "annotated closed arrows, via nf_eta", "the free CCC: universal properties of products and exponentials", "category laws checked by def_eq_eta"),
    "有限宇宙型別與值": ("Finite-universe types and values", "leaf sequences / leaf-value lists", "generated by Bool/Unit under products in the category of finite sets", "tree recursion"),
    "Wiring 符號等價": ("Wiring symbolic equivalences", "signed permutations (Unit outputs are (−1,false))", "morphisms of a free symmetric monoidal category; ⊗, braiding, associators and unitors", "permutation check in O(#leaves); equality is structural equality"),
    "同構、等價、ua、coe": ("Isomorphisms, equivalences, ua and coe", "wirings; coe computes by endpoints", "ua in the finite universe; product swap is a naturality square", "wiring_eq and w;w⁻¹=id"),
    "PathP、離散路徑與 J": ("PathP, discrete paths and J", "canonical PathP elements (far endpoint is a coe image); discrete paths are constant", "dependent path objects; J comes from coe along constant lines being the identity", "endpoint and point checks"),
    "有限 Glue": ("Finite Glue", "(partial, base) pairs; glue_from_base is normalized from the base", "a limit-style construction gluing along equivalences; unglue is the fibration projection", "face_sat plus compatibility equations"),
    "Glue comp（有限線）": ("Glue comp (finite lines)", "outputs (t₁, e₁(t₁))", "the arrow category Ty²: an equivalence line is a morphism and comp is composition along it", "naturality squares by wiring_eq; incoherent data is rejected"),
    "Glue comp（子空間線）": ("Glue comp (subspace lines)", "the k=1 edge of the correction square", "Kan lifting along varying retract lines; the correction is an hcomp", "boundary/cap/membership equations (on grids)"),
    "BDD DAG、預算與 DPLL": ("BDD DAGs, budgets and DPLL", "hash-consed DAG node ids; the reachable-node count of a root is its ROBDD size", "shared canonical graphs of boolean functions at a fixed variable order; apply is a memoized lattice operation", "same-manager root-id equality, sat as root≠0, node-budget FaceDecision, or step-budgeted DPLL (the legacy scanner and the watched-literal engine on Tseitin CNF); candidate-order minimization, bounded sifting that moves each variable through every insertion position with an honest initial/final report, and apply-cache doubling rehash once apply_misses exceeds four times the bucket count, and a 3ⁿ worst-case node bound; watched/list DPLL are differentially checked against 2^n brute force"),
    "原始 DSystem 相容性與 first-match 範形": ("Raw DSystem compatibility and first-match normal forms", "compatible systems reuse the type-directed DSystem normal form; arbitrary first-match systems become disjoint effective regions DTubeNF", "partial elements in face-relative slices; the checked constructor is a reflection into the composition-system subclass", "local-context conversion over BDD-cube enumerations, checking the base and pairwise overlaps; the first conflict is reported"),
    "AST 一等 Equiv 與 GlueEquiv": ("First-class AST Equiv and GlueEquiv", "DEquiv carries fwd/bwd/sect/retr terms; DVGlueEquiv carries full equivalence branches and (partial, base) pairs", "equivalences in the AST are isomorphisms with homotopy inverse proofs; ua is a functor to universe paths and GlueEquiv glues along systems of partial equivalences", "bidirectional checking of the four components and two PathP proofs; conversion/quotation recurse over equivalence components and branch faces; coe along ua is definitionally fwd/bwd"),
    "受檢查語義型別線": ("Checked semantic type lines", "DCheckedTypeLine stores a checked open type body, contexts, environments and a universe level, never a raw host function", "substitutable cubical type lines are syntactic bodies evaluated in dimension environments and therefore commute with dimension substitution", "the body is checked at a fresh dimension against Typeᵢ; at evaluates by dimension and coe/comp dispatch to AST Kan operations"),
    "Schema 註冊與 elaboration 快取": ("Schema registry and elaboration caches", "DInductivePlan/DHitPlan interned in DSchemaRegistry by stable Debug keys, with telescope prefix chains", "schema descriptors are shareable plans; caches store only finite graphs of the same elaboration functions and do not change denotation", "validation booleans and semantic telescope prefixes are looked up by (term,args,args) keys; hit/miss counters are observable"),
    "Schema 函子、正性與歸納遞迴": ("Schema functors, positivity and induction-recursion", "the Id/Const/Product/Sum/List/Pi/Container grammar of DPositiveFunctor and its decoded types; DPositivityReport records occurrences and polarities", "initial algebras of positive type functors with decoded induction hypotheses; DDecode is the decoding function of a Tarski universe (induction-recursion)", "polarity recursion on alias-expanded DTerms: nested functors and positive positions are accepted, negative positions and unknown neutral family applications are rejected; IHs are generated by functor recursion"),
    "Schema 擴展：互歸納、商與宇宙多態": ("Schema extensions: mutual induction, quotients and universe polymorphism", "the Sum-indexed merged schema of DMutualFamily; level schemes DLevelExpr; quotients are HITs with equality 1-cells", "mutual families are one initial algebra over an index sum; a universe scheme is a function of level assignments; quotients are higher cellular gluing", "mutual constructors compile with component index constraints and eliminate with Σ motives; schemes evaluate on level vectors and can be revalidated; constructor equations are checked as Path constraints"),
    "精確單變量多項式與有理矩陣": ("Exact univariate polynomials and rational matrices", "dense low-to-high QPoly coefficients with trailing zeros removed; QMat rational row lists; RREF and pivot columns", "the Euclidean ring Q[x] and the linear category over Qⁿ; characteristic/minimal polynomials are representation invariants of matrix algebras", "multiplication is sparse-convolution or common-denominator BigInt integer scaling with schoolbook/Karatsuba kernels and binary exponentiation; primitive pseudo-remainder gcd, Yun squarefree factorization, the rational-root theorem, Faddeev–LeVerrier and RREF; all equality is rational structural equality"),
    "代數擴張與根式範形": ("Algebraic extensions and radical normal forms", "QuadNum a+b√d with squarefree d; AlgNum remainder polynomials in Q[x]/(m)", "quadratic and general finite algebraic extension fields; norm/trace come from the determinant/trace of multiplication matrices", "residue arithmetic modulo a minimal polynomial and extended-Euclid inversion; radical denesting by square tests; equality is coefficient equality"),
    "廣義特徵空間與 Jordan 理論": ("Generalized eigenspaces and Jordan theory", "nullity chains of powers of (A−λI), Jordan block sizes and chain bases; PJP⁻¹=A", "primary decomposition is a resolution of the identity from coprime polynomial factors; Jordan type is a complete invariant fragment of similarity", "exact decision from characteristic-polynomial multiplicities, kernel dimensions of powers and chain lifting; non-split cases over Q report residual factors and AlgMat continues over extensions"),
    "認證數值影子與精確立方體": ("Certified numeric shadows and exact cubes", "QuadC=QuadNum+i·QuadNum; CertMat and degree-≤2 CertPath/CertSquare coefficients", "exact complex quadratic matrix algebra and polynomial cubes; Double matrices are only approximate representations of exact shadows", "P²=P, P†=P, orthogonal decompositions and box boundaries are checked by exact structural equality; numeric agreement measures only deviation from shadows and floating residuals"),
    "球面與懸掛 HIT": ("Spheres and suspension HITs", "north/south points of Susp(X) with one meridian per point; S²=Susp(S¹), S³=Susp(S²)", "suspension is the HIT quotient collapsing both ends of X×I to points; iterated suspension gives the sphere family", "generic HIT schema validation, meridian endpoint face reduction, dependent elimination and hcomp"),
    "Jacobi 區間譜迭代": ("Jacobi interval spectral iteration", "RatInterval/CInterval rectangular enclosures and dyadically outward-rounded Hermitian interval matrices; every rotation stores before/after matrices and the accumulated unitary transform", "monotone lifting of Hermitian similarity transforms to interval-matrix enclosures; Gershgorin discs give spectral image decompositions and multiplicity clusters", "exact rational square comparisons certify sqrt/phase/c/s enclosures; every rotation recomputes J†J−I∋0 and J†AJ⊆after, and final discs are clustered and counted"),
    "高階合一與雙向 elaborator": ("Higher-order unification and the bidirectional elaborator", "Miller-pattern spines `?F x₁…xₙ` in UTerm and beta/projection-reduced zonked cores; surface STerm resolves names to de Bruijn UTerm", "pattern HOU is the decidable fragment of higher-order unification; bidirectional elaboration sends implicit arguments and dependent motives to the same unifier and compiles to the dependent core", "rigid decomposition after WHNF, pattern abstraction, occurs/scope checks and a closed-term fallback; a bounded Huet-style search above the deterministic fragment tries rigid/spine decomposition, same-head invariant coordinates, distinct flex-flex constants, imitation and projection transactionally under node/depth budgets and reports solved/no-unifier/residual/budget-exceeded honestly (general HOU is undecidable, so no completeness is claimed); check/infer insert implicit metavariables and unsolved ones are rejected before DTerm translation"),
    "參數化模組與名字空間": ("Parameterized modules and namespaces", "module telescopes (parameters→imports→local declarations) with separate name→ordinal bindings; instances are simultaneously substituted closed declarations", "parameterized modules are module functors, import is inlined functor application, and open/alias/rename are name projections of one telescope entry", "cycle detection, dependent checking of parameter arguments, ambiguity rejection for import selection/hiding/renaming, neutralization of opaque exports, and dep_check of every closed instance declaration"),
    "立方體演算法": ("Cubical algorithms", "KanBox packages a line, a system and a base; transport fillers are PathP values; path transitivity is the top edge of an hcomp square", "path-object operations generated by Kan fibration structure in a cubical CwF: inverse, concatenation, functoriality and dependent substitution", "dispatch to kernel coe/comp/fill with endpoint conversion; closed-term builders are accepted again by dep_check_closed"),
    "計算性單值性（univalence）": ("Computational univalence", "finite universe paths are normalized by wiring equivalences; dependent universe paths are checked type lines, pathToEquiv is their coe equivalence, ua is the Glue line, uaβ unglues a transport filler, and the round-trips are an Equiv homotopy and a 2D Glue square", "an equivalence (Equiv A B) ≃ Path U A B between the path category of the universe and equivalences; Glue glues along equivalences and transport is its coe functor", "wiring equality in the finite layer; coe/comp computation and type-directed conversion of round-trip endpoints and square edges in the AST layer; closed-term pathToEquiv fill/coe proofs are checked by the dependent checker"),
    "完備精確代數與根隔離": ("Complete exact algebra and root isolation", "BigInt rationals; irreducible factors and multiplicities in Q[x]; Sturm real-root intervals and disjoint Rouché complex disks; split roots in successive algebraic towers; denested radical expressions", "unique factorization in Q[x], root multisets in an algebraic closure and finite splitting extensions; AlgPoly is polynomial algebra over an extension", "Kronecker/finite-field lifting, Sturm counting, Cauchy-square Taylor exclusion and Rouché subdivision; every certificate is recomputed with exact polynomial arithmetic"),
    "一等宇宙多態與同時宣告 schema": ("First-class universe-polymorphic and simultaneous declaration schemas", "level binders and instantiation in DLevelDecl; positive functors extracted after transparent-operator unfolding; iteratively compiled non-uniform nested families; joint mutual and simultaneous IR specifications", "universe schemes, parameter-iterated initial-algebra families, joint initial algebras of vector functors and synchronous induction-recursion structures", "level scope, positivity reports, generated telescopes and dependent conversion; uninstantiated levels are rejected by core checking"),
    "Adjoint 等價、纖維與命題截斷": ("Adjoint equivalences, fibers and propositional truncation", "a triangle Path(Path) over a quasi-inverse; the improved counit; Σ-points of fibers with singleton contraction; the point/squash HIT for PropTrunc", "half-adjoint equivalences, the contractible-fiber characterization of equivalences and the truncation reflection into propositions", "adjointify_equiv_value and equiv_contractible_fibers_value implement the general lemIso construction with hfill/hcomp/dpath; endpoints and the Path(Path) triangle are checked by dependent checking/conversion (deep adjustment points such as the circle midpoint are checked under face restrictions)"),
    "球面同倫代表元與 Hopf 不變量": ("Spherical homotopy representatives and the Hopf invariant", "nested Path types for Ωⁿ; integer degree maps by iterated suspension; the pole-swapped S³ HIT; the Hopf map and phase fibers on the unit sphere in C²", "representatives for the suspension functor, based maps and loop spaces; the Hopf S¹-fibration and its linking number", "conversion checks on generating meridians; IntegerS is a generated inductive type with unique zero/posSucc/negSucc constructor forms and semantic succ/pred maps, and pi3 is presented as Ω³(Sphereₙ) modulo the propositionally truncated Path relation via QuotientS, and the triply iterated suspension unit is rebased through the transitivity-square cancellation by subst; representative loop expressions reduce to integer powers with end-to-end endpoint checks.  This layer is representatives and canonical powers: it does not claim a general synthetic encode/decode proof that π₃(S³)≅ℤ, nor an internal Hopf-invariant proof that π₃(S²)≅ℤ; algebraic checks of Hopf images/fibers and a Gauss linking integral after stereographic projection numerically decide |lk|=1"),
    "模組分離編譯與連結": ("Separate module compilation and linking", "the flattened checked telescope, exports, dependency fingerprints and public interface projection of CompiledModule; abstract declarations have body=None; the cache is indexed by source fingerprints; the stable external form is the CHMODBIN byte array specified in the Decision column", "compiled objects of module functors and synthetic import-free linking definitions; prefix specialization is partial functor application", "interface hashes omit opaque bodies and implementation hashes cover all entries; implementations supply abstract exports; cache entries invalidate on source or dependency-interface fingerprints; the stable binary format is magic CHMODBIN + version u16 + length u32 + checksum u32 + payload (tag bytes, fixed-width little-endian i32 fields and UTF-16LE strings), and decoding rejects bad magic/version/truncation/checksum/malformed/trailing bytes before rerunning module validation and fingerprint checks"),
    "範疇化總檢": ("Categorification checks", "boolean conjunctions of category laws", "identity/composition/coherence laws of the assembled categories", "law-by-law evaluation"),
    "定理登記與範例": ("Theorem registry and examples", "(name, Bool) registry rows; concrete witness vectors/terms", "realizations of decidable propositions on witnesses", "moon test / the registry"),
    "規格登記": ("Specification registry", "SpecEntry six-tuples", "a specification of the specification; completeness is checked against the generated interface", "spec_registry_sound plus this audit"),
    "輔助工具": ("Utilities", "concrete integer/grid values", "basic set-level utilities", "direct computation"),
}


def parse_mbti(text):
    decls = []
    top = re.compile(r"^pub (fn|struct|enum|type|let) ([A-Za-z_][A-Za-z0-9_]*(?:::[A-Za-z_][A-Za-z0-9_]*)?)")
    block = None  # (name, kind)
    for raw in text.splitlines():
        line = raw.rstrip()
        m = top.match(line)
        if m:
            kind, sym = m.group(1), m.group(2)
            decls.append((sym, kind))
            if kind in ("struct", "enum") and line.rstrip().endswith("{"):
                block = (sym, kind)
            else:
                block = None
            continue
        if block is not None:
            if line.startswith("}"):
                block = None
                continue
            name, kind = block
            if kind == "struct":
                fm = re.match(r"^\s+(?:mut\s+)?([a-z_][A-Za-z0-9_]*)\s*:", line)
                if fm:
                    decls.append((f"{name}.{fm.group(1)}", "field"))
            else:
                vm = re.match(r"^\s+([A-Z][A-Za-z0-9_]*)", line)
                if vm:
                    decls.append((f"{name}::{vm.group(1)}", "constructor"))
    return decls


def load_decls():
    """All public declarations of every manifested local package."""
    arch = json.loads((ROOT / "architecture.json").read_text())
    decls = []
    for pkg in arch["packages"]:
        mbti = ROOT / pkg["path"] / "pkg.generated.mbti"
        assert mbti.exists(), f"missing {mbti}: run `moon info` first"
        for sym, kind in parse_mbti(mbti.read_text()):
            decls.append((pkg["id"], sym, kind))
    return decls


def classify(sym, kind):
    if kind in ("field", "constructor"):
        owner = re.split(r"[.:]", sym)[0]
        return TYPE_FAMILY.get(owner)
    if kind in ("struct", "enum", "type"):
        return TYPE_FAMILY.get(sym)
    if "::" in sym:  # derived Eq/Debug methods belong to their type's family
        return TYPE_FAMILY.get(sym.split("::")[0])
    if sym in EXACT:
        return EXACT[sym]
    if sym.startswith("check_"):
        rest = sym[len("check_"):]
        for hint, fam in CHECK_FAMILY_HINTS:
            if rest == hint or rest.startswith(hint + "_") or rest.startswith(hint):
                return fam
        return "定理登記與範例"
    for prefix, fam in PREFIXES:
        if sym == prefix or sym.startswith(prefix):
            return fam
    return None


def render(decls, lang):
    by_family = {name: [] for name in FAMILIES}
    for pkg, sym, kind in decls:
        fam = classify(sym, kind)
        assert fam in FAMILIES, f"unclassified symbol: {pkg}/{sym} ({kind}) -> {fam}"
        by_family[fam].append((pkg, sym, kind))
    total = len(decls)
    families_used = sum(1 for v in by_family.values() if v)
    per_pkg = {}
    for pkg, _, _ in decls:
        per_pkg[pkg] = per_pkg.get(pkg, 0) + 1
    out = []
    if lang == "zh":
        pkg_text = "、".join(f"`{p}` {n}" for p, n in sorted(per_pkg.items()))
        out.append(f"共 **{total}** 個公共符號（宣告＋構造子＋欄位），分屬 {families_used} 個規格族；按套件：{pkg_text}。")
        labels = ("規範形式", "範疇化", "判定")
        headers = ("符號", "套件", "類別")
        oracle_note = "（差分測試 oracle，非判定路徑）"
    else:
        pkg_text = ", ".join(f"`{p}` {n}" for p, n in sorted(per_pkg.items()))
        out.append(f"**{total}** public symbols (declarations + constructors + fields) in {families_used} specification families; by package: {pkg_text}.")
        labels = ("Canonical form", "Categorification", "Decision")
        headers = ("Symbol", "Package", "Kind")
        oracle_note = " (differential-testing oracle, not a decision path)"
    for fam, (canon, cat, dec) in FAMILIES.items():
        items = sorted(by_family[fam], key=lambda x: (x[1], x[0]))
        if not items:
            continue
        if lang == "en":
            fam_name, canon, cat, dec = FAMILIES_EN[fam]
        else:
            fam_name = fam
        out.append("")
        out.append(f"### {fam_name}")
        out.append("")
        out.append(f"- {labels[0]}：{canon}" if lang == "zh" else f"- {labels[0]}: {canon}")
        out.append(f"- {labels[1]}：{cat}" if lang == "zh" else f"- {labels[1]}: {cat}")
        out.append(f"- {labels[2]}：{dec}" if lang == "zh" else f"- {labels[2]}: {dec}")
        out.append("")
        out.append(f"| {headers[0]} | {headers[1]} | {headers[2]} |")
        out.append("|---|---|---|")
        for pkg, sym, kind in items:
            note = oracle_note if ("oracle" in sym or "extensional" in sym) else ""
            out.append(f"| `{sym}` | {pkg} | {KIND_LABELS[lang][kind]}{note} |")
    return "\n".join(out) + "\n"


def appendix_document(lang, rendered):
    if lang == "zh":
        head = """# cubical-hermitian 規格附錄（逐符號登記）

[English appendix](SPEC-APPENDIX.en.md) · [中文規格正本](SPEC.md) · [English specification](SPEC.en.md)

> 本檔案由 `tools/audit_spec.py --write` 自各套件的 `pkg.generated.mbti`
> （`moon info`）生成，**勿手改**附錄標記之間的內容。套件欄是
> `architecture.json` 登記的 MoonBit 套件（`root` / `algebra` / `cmd-main`）。

"""
    else:
        head = """# cubical-hermitian Specification Appendix (per-symbol registry)

[中文附錄](SPEC-APPENDIX.md) · [English specification](SPEC.en.md) · [中文規格正本](SPEC.md)

> This file is generated by `tools/audit_spec.py --write` from each
> package's `pkg.generated.mbti` (`moon info`).  Do **not** edit the
> content between the appendix markers by hand.  The package column
> is the MoonBit package registered in `architecture.json`
> (`root` / `algebra` / `cmd-main`).

"""
    return head + "<!-- APPENDIX:BEGIN -->\n" + rendered.rstrip("\n") + "\n<!-- APPENDIX:END -->\n"


def appendix_of(text):
    m = re.search(r"<!-- APPENDIX:BEGIN -->\n(.*?)\n<!-- APPENDIX:END -->", text, re.S)
    return m.group(1) if m else None


def symbols_in_appendix(app):
    return [(pkg, sym) for sym, pkg in re.findall(r"^\| `([^`]+)` \| ([A-Za-z0-9_-]+) \|", app, re.M)]


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "--check"
    decls = load_decls()
    identities = [(pkg, sym) for pkg, sym, _ in decls]
    assert len(identities) == len(set(identities)), "duplicate (package, symbol) parsed from mbti files"
    docs = {
        "zh": (APPENDIX_ZH, appendix_document("zh", render(decls, "zh"))),
        "en": (APPENDIX_EN, appendix_document("en", render(decls, "en"))),
    }
    if mode == "--write":
        for path, text in docs.values():
            path.write_text(text)
        print(f"appendices written: {len(identities)} symbols (zh + en)")
    for path, expected in docs.values():
        assert path.exists(), f"missing {path.name}: run with --write"
        text = path.read_text()
        app = appendix_of(text)
        assert app is not None, f"appendix markers not found in {path.name}"
        listed = symbols_in_appendix(app)
        missing = sorted(set(identities) - set(listed))
        extra = sorted(set(listed) - set(identities))
        dup = sorted({s for s in listed if listed.count(s) > 1})
        assert not missing, f"{path.name}: missing from appendix: {missing[:20]}"
        assert not extra, f"{path.name}: not in interface: {extra[:20]}"
        assert not dup, f"{path.name}: duplicated in appendix: {dup[:20]}"
        if mode == "--check":
            assert text == expected, f"{path.name} is stale: run with --write"
    kinds = {}
    pkgs = {}
    for pkg, _, k in decls:
        kinds[k] = kinds.get(k, 0) + 1
        pkgs[pkg] = pkgs.get(pkg, 0) + 1
    print(f"audit ok: {len(identities)} symbols, by kind {kinds}, by package {pkgs}")


if __name__ == "__main__":
    main()
