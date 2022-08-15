import FooLib

var myName = FooHello(name: "Miki")

myName.greet()

myName.greet(and: "Matěj")

/*

 swiftc -frontend -scan-dependencies  Execute.swift

 swiftc -I`pwd` libFooLib.dylib Execute.swift
 https://medium.com/a-42-journey/nm-otool-everything-you-need-to-know-to-build-your-own-7d4fef3d7507
 http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html
 https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/000-Introduction/Introduction.html#//apple_ref/doc/uid/TP40001908-SW1
 */
