# Opory pro Build and Link

## Programy a pojmy

**Programy a nástroje**

 - `llvm` "low level virtual machine" framework pro tvobu kompilátorů
 - `clang` kompilátor C z rodiny LLVM
 - `clang++` kompilátor C++ z rodiny LLVM
 - `swiftc` kompilátor Swift
 - `nm` program pro zobrazování seznamu symbolů
 - `otool` nástroj pro zobrazování  objektovách souborů
 - `ar` nástroj na tvorbu archivů knihoven
 - `lipo` nástroj na správu univerzálních (FAT / více architekturových) souborů
 - `sourcekitten` frontend pro práci se sourcekitd
 - `ld` linker editor
 - `dyld` dynamic linker
 - `dwarfdump` nástor pro zobrazování debugovacích dat
 - `dsymutil` nástroj pro tvorbu dSYM souborů

**Pojmy**

 - _Assembly_ aka. *jazyk symbolických adres* je jazyk určený pro čitelnou reprezentaci strojových instrukcí
 - _Assembler_ program, který překládá asembler do objektového kódu
 - _Objektový soubor_ přípona `.o`, obsahuje objektový kód
 - _Kompilátor_ program, který překládá kód z jednoho jazyka do jiného jazyka
 - _Linker_ také. _Linker Editor_ je program, který z jednoho nebo vícero objektových souborů (nebo knihoven) sestaví spustitelný soubor, knihovnu, nebo jiný objektový soubor.
 - _Dynamický linker_ program, který otevírá a připravuje dynamické knihovny pro potřeby programu v čase jeho běhu. 
 - _Statická knihovna_ přípona `.a`, zpravidla archiv, který obsahuje vícero objektovcýh souborů. Je použit během sestavování programu (Linker Editorem), stane se součástí linkovaného objektu a poté již není potřeba.
 - _Dynamická knihovna_ přípona `.so` aka. "shared object" (Linux) nebo `.dylib` (Darwin) je soubor, který obsahuje definici symbolů, zpravidla je pozičně nezávislá. Je použita linker editorem při sestavování programu pro vyhodnocení symbolu, ale **není** součástí linkovaného objektu. Dynamická knihovna je během běhu programu načtena do paměti *dynamickým linkerem*.
 - _Pozičně nezávislý kód_ který je sestavený tak, aby mohl načten a vykonán nezávisle na tom, do kterého místa v paměti byl nahrán.
 - _Mach-O a ELF_ Mach-O (Darwin) nebo ELF (Executable and Linkable Format, Linux) je formát pro spustitelné soubory, knihovny, objektové soubory atd.
 - _Stripped file_ je Mach-O/ELF soubor, ze kterého byly odstraněny všechny informace, které nejsou nezbytně nutné pro správný chod programu (tj. odstraněny jsou např. DWARF data).
 - _DWARF_ je formát, který byl vytvořen společně s ELF, ale není na něm závislý. Obsahuje "metadata" o programu např. pro potřeby debuggeru atd.
 - _dSYM_ je na platformách Darwin archiv, který obsahuje DWARF a jiná metadata, které byly "stripped" ze spustielných souborů a knihoven aplikace.
 - _FAT binary_ je souhrnný název pro knihovny a spustitelné soubory, které obsaují kód pro více než jednu platformu/architekturu. 
 - _Symbol_ je identifikátor, zpravidla unikátní řetězec, který identifikuje místo v programu, např. proměnné nebo funkce. Není dovolené definovat dva různé symboly stejného jména.
 - _Symbol reference_ je všude tam, kde dochází k použití symbolu, např. funkce nebo proměnné daného jména.
 - _Symbol definition_ hovoříme o místě v programu, kde se symbol nachází, tj. např. kde je zapsáno tělo funkce nebo kde je vyhrazeno místo pro proměnnou.
 - _Name mangling_ je metoda, kterou se vyrovnávají různé jazyky s faktem, že nelze definovat dva symboly stejného jména. Name mangling je zpravidla bijektivní zobrazení. Příklad v C++ `__Z16decorateAndPrintPKc` pro funkci `void decorateAndPrint(const char *)`, Swift např. `s6FooLib0A5HelloV5greet3andySSSg_tF` pro `FooLib.FooHello.greet(and:)`.
 - _LLVM Bitcode_ formát strukturovaného (jako např. XML) binárního souboru, který je optimalizován pro velikost a náhodný přístup. Lze analyzovat pomocí programu `llvm-bcanalyzer`.
 - _C/C++: deklarace a prototyp_ deklarace symbolu nastává v C/C++ tam, kde dochází k "první zmíňce" o symbolu (nehledě na to, jestli se jedná o definici prototypu nebo použití, což vede k "implicitní deklaraci"). Definice prototypu přisuzuje symbolu jeho typ/návratovou hodnoty a argumenty - ale ne nutně tělo funkce (popř. místo pro data), to může být vyhodnoceno během linkování.
 - _C/C++: hlavičkový soubor_ soubor, který obsahuje (mj.) deklarace symbolů (proměnných, funkcí), ale i datových typů (např. `struct`, `typealias`, `enum`, ...).
 - _SIL_ Swift Intermediate Language, mezijazyk do kterého je přeložen kód v jazyce Swift.
 - _Swift: .swiftmodule a .swiftdoc soubor_ je Swift analogie pro hlavičkové soubory v C/C++. Soubor `.swiftmodule` obsahuje definice funkcí, datových typů a může obsahovat i SIL. Soubor `. swiftdoc` obsahuje další informace o `.swiftmodule` soubor, jako např. veřejnou dokumentaci. Oba soubory jsou v LLVM Bitcode.  
 
 ## Zdroje
 [1]
