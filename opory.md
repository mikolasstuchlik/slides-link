# Opory pro Build and Link

---

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

 - **Assembly** aka. *jazyk symbolických adres* je jazyk určený pro čitelnou reprezentaci strojových instrukcí
 - **Assembler** program, který překládá asembler do objektového kódu
 - **Objektový soubor** přípona `.o`, výstup kompilátoru, obsahuje objektový kód
 - **Kompilátor** program, který překládá kód z jednoho jazyka do jiného jazyka
 - **Linker** také. **Linker Editor** je program, který z jednoho nebo vícero objektových souborů (nebo knihoven) sestaví spustitelný soubor, knihovnu, nebo jiný objektový soubor.
 - **Dynamický linker** program, který otevírá a připravuje dynamické knihovny pro potřeby programu v čase jeho běhu. 
 - **Statická knihovna** přípona `.a`, zpravidla archiv, který obsahuje vícero objektovcýh souborů. Je použit během sestavování programu (Linker Editorem), stane se součástí linkovaného objektu a poté již není potřeba.
 - **Dynamická knihovna** přípona `.so` aka. "shared object" (Linux) nebo `.dylib` (Darwin) je soubor, který obsahuje definici symbolů, zpravidla je pozičně nezávislá. Je použita linker editorem při sestavování programu pro vyhodnocení symbolu, ale **není** součástí linkovaného objektu. Dynamická knihovna je během běhu programu načtena do paměti *dynamickým linkerem*.
 - **Pozičně nezávislý kód** který je sestavený tak, aby mohl načten a vykonán nezávisle na tom, do kterého místa v paměti byl nahrán.
 - **Mach-O a ELF** Mach-O (Darwin) nebo ELF (Executable and Linkable Format, Linux) je formát pro spustitelné soubory, knihovny, objektové soubory atd.
 - **Stripped file** je Mach-O/ELF soubor, ze kterého byly odstraněny všechny informace, které nejsou nezbytně nutné pro správný chod programu (tj. odstraněny jsou např. DWARF data).
 - **DWARF** je formát, který byl vytvořen společně s ELF, ale není na něm závislý. Obsahuje "metadata" o programu např. pro potřeby debuggeru atd.
 - **dSYM** je na platformách Darwin archiv, který obsahuje DWARF a jiná metadata, které byly "stripped" ze spustielných souborů a knihoven aplikace.
 - **FAT binary** je souhrnný název pro knihovny a spustitelné soubory, které obsaují kód pro více než jednu platformu/architekturu. 
 - **Symbol** je identifikátor, zpravidla unikátní řetězec, který identifikuje místo v programu, např. proměnné nebo funkce. Není dovolené definovat dva různé symboly stejného jména.
 - **Symbol reference** je všude tam, kde dochází k použití symbolu, např. funkce nebo proměnné daného jména.
 - **Symbol definition** hovoříme o místě v programu, kde se symbol nachází, tj. např. kde je zapsáno tělo funkce nebo kde je vyhrazeno místo pro proměnnou.
 - **Name mangling** je metoda, kterou se vyrovnávají různé jazyky s faktem, že nelze definovat dva symboly stejného jména. Name mangling je zpravidla bijektivní zobrazení. Příklad v C++ `__Z16decorateAndPrintPKc` pro funkci `void decorateAndPrint(const char *)`, Swift např. `s6FooLib0A5HelloV5greet3andySSSg_tF` pro `FooLib.FooHello.greet(and:)`.
 - **LLVM Bitcode** formát strukturovaného (jako např. XML) binárního souboru, který je optimalizován pro velikost a náhodný přístup. Lze analyzovat pomocí programu `llvm-bcanalyzer`.
 - **C/C++: deklarace a prototyp** deklarace symbolu nastává v C/C++ tam, kde dochází k "první zmíňce" o symbolu (nehledě na to, jestli se jedná o definici prototypu nebo použití, což vede k "implicitní deklaraci"). Definice prototypu přisuzuje symbolu jeho typ/návratovou hodnoty a argumenty - ale ne nutně tělo funkce (popř. místo pro data), to může být vyhodnoceno během linkování.
 - **C/C++: hlavičkový soubor** soubor, který obsahuje (mj.) deklarace symbolů (proměnných, funkcí), ale i datových typů (např. `struct`, `typealias`, `enum`, ...).
 - **SIL** Swift Intermediate Language, mezijazyk do kterého je přeložen kód v jazyce Swift.
 - **Swift: .swiftmodule a .swiftdoc soubor** je Swift analogie pro hlavičkové soubory v C/C++. Soubor `.swiftmodule` obsahuje definice funkcí, datových typů a může obsahovat i SIL. Soubor `. swiftdoc` obsahuje další informace o `.swiftmodule` soubor, jako např. veřejnou dokumentaci. Oba soubory jsou v LLVM Bitcode.
 - **Stub object** volně přeložený jako "kousek sdíleného objektu" může mít různé formy, ale zpravidla obsahuje seznam symbolů a architektur, které obsahuje *nějaká existující* sdílená knihovna kterou zastupuje. Neobsahuje ale definice symbolů. Požívá se např. v SDK na Apple platformách.
 
---

## Jazyk C

###Sestavení se statickou knihovnou:

```bash
 clang -c FooCib.c
 ar -q libFooCib.a FooCib.o
 nm libFooCib.a
 clang libFooCib.a execute.c
```

1. `clang` kompilátor C, `-c` "zastav po výstupu z assembleru", `FooCib.c` vstupní soubor
2. `ar` správce archivů, `-q` "rychle" buďto vytvoř nový archiv, nebo přidej soubor na konec, `libFooCib.a` název výstupu, `FooCib.o` jméno vstupu (výstup předchozího kroku)
3. `nm` zobrazuje symboly
4. `clang` kompiláor C bez argumentů zkompiluje soubory na vsupu a vytvoří spustitelný soubor, nebo skončí s chybou, `libFooCib.a` statická knihovna obsahující symboly, `executable.c` zdrojový kód pro spustitelný soubor 


### Sestavení s dynamickou knihovnou:

```bash
 clang -c -fPIC FooCib.c
 clang -shared -o libFooCib.dylib FooCib.o
 clang libFooCib.dylib execute.c
``` 

 
1. `clang` kompilátor C, `-c` "zastav po výstupu z assembleru", `-fPIC` vygeneruj kód jako "pozicově nezávislý" (viz pojmy), `FooCib.c` vstupní soubor
2. `clang` kompilátor C, `-shared` pokyn k vytvoření sdílené knihovny, `-o libFooCib.dylib` název výstupu, `FooCib.o` jméno vstupu (výstup předchozího kroku)
4. `clang` kompiláor C bez argumentů zkompiluje soubory na vsupu a vytvoří spustitelný soubor, nebo skončí s chybou, `libFooCib.dylib` linker editor (viz pojmy) použije tento soubor k vyhodnocení chybějících symbolů - tento soubor budy vyžadován při spuštění programu dynamickým linkerem, `executable.c` zdrojový kód pro spustitelný soubor 

---

## Jazyk C++

Okomentujeme pouze odlišnosti od C

### Sestavení se staticknou knihovnou

```bash
 clang++ -c FooXccib.cpp
 ar -q libFooXccib.a FooXccib.o
 nm --demangle libFooXccib.a
 clang libFooXccib.a execute.cpp
```

1. -||-
2. -||-
3. `nm` zobrazuje symboly, `--demangle` přeloží "zamanglované" (viz pojmy) jména symbolů do "lidské řeči", `libFooXccib.a` jméno vstupu
4. -||-

### Sestavení s dynamickou knihovnou
```bsh
 clang++ -c -fPIC FooXccib.cpp
 clang++ -shared -o libFooXccib.dylib FooXccib.o
 clang++ libFooXccib.dylib execute.cpp

```

1. -||-
2. -||-
3. -||-

---

## Jazyk Swift

### Příslušenství - závislosti

```bash
swiftc -frontend -scan-dependencies Execute.swift
```

`swiftc` kompilátor Swift (neplést s příkazem `swift`), `-frontend` význam: následující text je argument pro část kompilátoru řídicí průběh kompilace, `-scan-dependencies` vypiš na výstup které závislosti budou potřeba a skonči

### Příslušenství - demangle

```bash
swift demangle s6FooLib0A5HelloV5greet3andySSSg_tF
$s6FooLib0A5HelloV5greet3andySSSg_tF ---> FooLib.FooHello.greet(and: Swift.String?) -> ()
```

Tento příkaz umožňuje demanglovat symbol, který můžeme najít například pomocí `nm` do "lidštiny". Na rozdíl od C++, pro Swift to `nm` neumí automaticky.

### Příslušenství - přečtení obsah souboru `.swiftmodule`

Soubor `.swiftmodule` je binární soubor v LLVM Bitcode, následující programy nám umožňují číst obash

```bash
xcrun swift-api-digester -dump-sdk -module FooLib -o foo -I`pwd`
```

`xcrun` program spouštějící jiné programy v prostředí s vývojovými nástroji, `swift-api-digester` součást swift fontendu načítající rozhraní modulů, `-dump-sdk` vypiš obsah modulu ve formátu JSON, `-module FooLib` modul který chceme vypsat, `-o foo.json` kam chceme výstup uložit, `-I\`pwd\`` přidává absolutní cestu do současného adresáře mezi cesty ve kterých kompilátor hledá soubory `.swiftmodule`

Následující program dělá něco podobného

```bash
sourcekitten module-info --module FooLib -- -sdk "$(xcrun --show-sdk-platform-path)/Developer/SDKs/MacOSX$(xcrun --show-sdk-version).sdk" -I`pwd`
```

`sourcekitten` nástroj zpřístupňující služby sourcekit před JSON rozhraní, `module-info` vypiš informace o modulu, `--module FooLib` jaký modul chceme vypsat, `--` text za tímto znakem bude předán kompilátoru (resp. sourcekitu), `-sdk "$(xcrun --show-sdk-platform-path)/Developer/SDKs/MacOSX$(xcrun --show-sdk-version).sdk"` specifikuje kde se nachází SDK pro macOS ("cena" za to, že nepoužíváme `xcrun`), `-I\`pwd\`` přidává absolutní cestu do současného adresáře mezi cesty ve kterých kompilátor hledá soubory `.swiftmodule`

### Sestavení se statickou knihovnou

```bash
swiftc -parse-as-library -emit-library -static -emit-module FooLib.swift
swiftc -I`pwd` libFooLib.a Execute.swift
```

První příkaz:

 1. `swiftc` kompilátor swift
 2. `-parse-as-library` chovej se k modulu jako ke knihovně, tj. **neumožni** spustitelný kód mimo scope funkce a **nevytvářej** funkci `main`
 3. `-emit-library` vystup kompilace nechť je knihovna (výchozí nastavení je dynamická)
 4. `-static` pokud je výstupem knihovna, nechť je statická
 5. `-emit-module` vygeneruj soubory `.swiftmodule` a `.swiftdoc` nutné pro to, aby byl modul "importovatelný"

Druhý příkaz:

 1. `swiftc` kompilátor Swift
 2. `-I\`pwd\`` přidej současnou složku do složek, ve kterých hledá kompilátor moduly 
 3. `libFooLib.a` soubor s knihovnou
 4. `Executable.swift` Swift soubor, který bude zkompilován jako spustitelný

### Sestavení s dynamickou knihovnou

```bash
swiftc -parse-as-library -emit-library -emit-module FooLib.swift
swiftc -I`pwd` libFooLib.dylib Execute.swift
```

Postup je ekvivalentní, jako u statické knihovny, kromě:

První příkaz:

 - Všimněte si, že chybí přepínač `-static`

---

## Průchod prezentací

### Úvod a motivace
 
O čem se budeme bavit

 - **Všechny** naše programy používají knihovny, ať už ty na iOS nebo jiné Swift moduly
 - Spoustu těch věcí za nás dělá Xcode (SPM) sám 
 - Bude toho hodně
 - Řekneme si, co jsou *statické* a *dynamické* knihovny
 - Ukážeme si, jak je vytvářet
 - Ukážeme si, jak je používat
 - ... tvrzení si dokážeme
 
Proč se zabívat tímto tématem
 
 - Řešení chyb, porozumění chybovým hláškám
 - Hodí se znát při setupování projektu
 - Pochopení/připomenutí jak fungují knihovny
 - Dobrý základ pro další věci užitečné při vývoji

Osnova

 - Nejprve se podíváme na to, co to vůbec je knihovna
 - Ukážeme si jak se pracuje s knihovnami v C a na tomto základě si vysvětlíme jak funguje proces kompilace
 - Ukážeme si jak do toho všeho zapadá Swift
 
Bonus
 - Co je .tbd
 - Co je uvnitř Frameworků 
 - Co jsme viděli u C si zopakujeme v C++ ale zaměříme se na rozdíly
 - DWARF vs dSYM

---

## Zdroje
 [1] Proč Clang automaticky generuje dSYM pro spustitelné binárky na macOS? [https://stackoverflow.com/questions/32297349/why-does-a-2-stage-command-line-build-with-clang-not-generate-a-dsym-directory](https://stackoverflow.com/questions/32297349/why-does-a-2-stage-command-line-build-with-clang-not-generate-a-dsym-directory)
 
 [2] Diagram kompilace Swift [https://qiita.com/rintaro/items/3ad640e3938207218c20](https://qiita.com/rintaro/items/3ad640e3938207218c20)
 
 [3] Rozdíly mezy `nm`, `otool` a poznámky o `Mach-O` [https://medium.com/a-42-journey/nm-otool-everything-you-need-to-know-to-build-your-own-7d4fef3d7507](https://medium.com/a-42-journey/nm-otool-everything-you-need-to-know-to-build-your-own-7d4fef3d7507)
 
 [4] Linkování a kompilace obecně [http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html](http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html)

 [5] Diagramy statické x dynamické knihovny. Dokumentace Apple ohledně dynamických knihoven [https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40001908-SW1](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40001908-SW1)
 
 [6] Co je `.swiftmodule` [https://forums.swift.org/t/whats-in-the-file-of-swiftmodule-how-to-open-it/1032/2](https://forums.swift.org/t/whats-in-the-file-of-swiftmodule-how-to-open-it/1032/2)

 [7] Forma `.tbd` viz [https://stackoverflow.com/questions/31450690/why-xcode-7-shows-tbd-instead-of-dylib](https://stackoverflow.com/questions/31450690/why-xcode-7-shows-tbd-instead-of-dylib), definice "Stub object" viz Oracle [https://docs.oracle.com/cd/E23824_01/html/819-0690/chapter2-22.html](https://docs.oracle.com/cd/E23824_01/html/819-0690/chapter2-22.html) 
 
 [8] Diagram kompilace C [https://csgeekshub.com/c-programming/c-program-compilation-steps-example-with-gcc-linux/](https://csgeekshub.com/c-programming/c-program-compilation-steps-example-with-gcc-linux/)
 
 [9] Vysvětlivky pro nastavení Xcode [https://xcodebuildsettings.com](https://xcodebuildsettings.com)
