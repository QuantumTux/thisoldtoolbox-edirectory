# thisoldtoolbox-edirectory
**_Please, please, please..._** read this _entire_ page **BEFORE** trying to use this repo.

This repo is part of my **This Old Toolbox** set of repos, which collectively host various system administration/management tools I've written over the years, for a variety of platforms and environments. I'm making them public so that others might find the ideas and/or the accumulated knowledge helpful to whatever they need to create.

<details>
  
<summary>History of this specific tool</summary>
  
In early 2005, I was working in a NetWare environment, and there was a business need to edit almost a thousand eDirectory **User** objects to find and remove specific bits of information. I was tasked with engineering a solution that didn't involve having the admins doing it by hand.
  
My solution leveraged the fact that the OS shipped with the Perl v5.8 interpreter and a set of Novell-supplied Perl modules (**Universal Component Services**, or **UCS**) that enabled interaction with NetWare and eDirectory.

</details>

# About eDirectory
**[eDirectory](https://www.netiq.com/documentation/edirectory-92/)** is a multi-platform directory service, one that is a lot closer to the X.500 ideals than just about anything else. It started on [Novell NetWare](https://en.wikipedia.org/wiki/NetWare), but was subsequently ported to other platforms, including Linux.

IIRC, my tool was written to operate in an **eDirectory v8.7** environment.

# Perl on NetWare
**_Before you dive into my code_**, know that Perl on NetWare had a number of peculiarities that could trip up even an experienced Perl programmer. The [Perl on NetWare NDK](https://www.novell.com/documentation/developer/perl/prl584enu/data/h4cr34aj.html) has a complete listing; however, some items of specific interest here include:

* It is **mandatory** to use _lexically scoped variables_ (with help of the **my()** operator) whenever possible
* A script that introduces infinite loop cannot be terminated (and I can verify this from experience!)
* The Perl debugger **restart** option is not supported

There are additional peculiarities of Perl on NetWare, as it specifically relates to the **Universal Component** APIs:

* If you have a _require_ or a _use_ statement that loads the **UCS API** module, but you never instantiate any object provided by that module in your code, the server may **ABEND**
* The _use strict;_ statement is problematic, because the **UCS APIs** seem to perform some redefinitions that the directive doesn't like; however, the _use warnings;_ statement works, as do the _-c_ and _-w_ parameters on the Perl invocation
* Novell did not publish separate Perl-oriented **UCS** documentation; refer to the [Novell Script for NetWare](https://www.novell.com/developer/ndk/novell_script_for_netware.html) (NSN) UCS documentation; the **Objects**, **Properties** and **Methods** are the same, only the language syntax differs (specifically, reference the _Novell Developer Kit (NDK) NSN Components (Parts One and Two)_, as well as the _NDK Novell eDirectory Schema Reference_)
* eDirectory error codes are not available to the Perl environment; many **UCS** methods return, at best, only Boolean (_yes/no_, _TRUE/FALSE_, _OK/FAIL_) values, and you will have to use **DSTRACE.NLM** to capture eDirectory error information

NetWare and eDirectory introduce some additional wrinkles in terms of syntax:

* Paths to server-local files are referenced using the syntax **VOLUME:/PATH/TO/FILE**
* eDirectory context references are in the form **nds:\\TREE\TOP O\OU**
* Since “\” is a special character in Perl, it must be escaped, and so should be represented in your code as “\\\”

<details>
  
<summary>Adding Perl Modules to NetWare?</summary> 

The Perl community has impressive libraries of add-on Perl modules (such as **CPAN**, the [Comprehensive Perl Archive Network](http://www.cpan.org)). However, adding the typical Perl module to NetWare's Perl installation is a non-trivial exercise, involving either establishing a NetWare development environment, or cross-compiling on another platform. Neither choice is for the inexperienced or faint-of-heart. For the vast majority of admins, you're limited to whatever Perl modules are included in the NetWare distribution.

</details>

# Understanding eDirectory Objects and Attributes
In order to leverage my code, it is first necessary to have a firm grasp of eDirectory, and in particular **Objects** and their **Attributes**.

<details>
  
<summary>A quick overview of basic eDirectory Object concepts</summary>

Fundamentally, an **Object** a collection of groups of data of various types. _Users_ are **Objects**. _Printers_ are **Objects**. _Groups_ are **Objects**.

**Objects** have **Attributes**. The specific **Attributes** of an **Object** are defined by its type; that is, a _User Object_ consists of a different set of **Attributes** than 
a _Group Object_. A particular **Attribute** (for example, the _Full Name_) might appear in many different **Object** types.

**Attributes** have a **Value**; that is, the data that the **Attribute** contains. Some **Attributes** are **Multi-Valued Attributes** (MVAs) and may contain more than one **Value**; the
membership list of a _Group_ is a common example.

In the eDirectory world, the **Schema** defines (among other things) the available **Attributes**, the **Attributes** used by the various **Objects** (this is also called **Layouts**),
the data type(s) of the **Values** (which is known as **Syntax**), and the **Values** associated with the various **Attributes**.

Unlike AD, in eDirectory an **OU** really is an **OU** - it is a "container" (as envisioned in X.500) that contains other **Objects** in an actual 3-dimensional data representation. The **Context** of an **Object** is important; the namespace is **not** flat. 

Understanding these inter-relationships, and the hierarchical nature of eDirectory, is important to understanding how to access and safely manipulate the eDirectory **Tree** when using a direct tool such as the **UCS API**.

</details>

My code confines itself to using **UCS** to access _User Objects_; however, that is an artificial limitation. Many other **Object** types exist and are accessible _via_ the **UCS APIs**, 
and the APIs provide many other methods beyond those presented in my code.

# edir_tool.pl is a template!
While the **edir_tool.pl** file is based on code I actually ran in a production environment, here I would call it **proof-of-concept**. You can _probably_ take it and, with a few minor tweaks, get it to run in an appropriate NetWare environment; but it's almost 20 years old, and I didn't keep up with NetWare after v6.5.

The variables you'd probably need to adjust include (at minimum):

+ **$Tree**
+ **$Top_O**
+ **$OU**
+ **$login_context**
+ **$ServerIP**

Keep in mind that, as written, even when it is working flawlessly, it doesn't do anything except login to eDirectory, perform a simple search, and write a simple log file.

# Additional Perl Code
Now that you understand the basics, to get useful work done, you need to manipulate **Objects**. This repo has a number of code examples that show how to approach various operations. **_These files are not stand-alone code_**; they must be integrated into a larger program like **edir_tool.pl**.

## create_object.pl
Demonstrates the basics of creating a new **Object** in an eDirectory Tree.

## create_object.pl
An example of deleting an existing eDirectory **Object** from the  eDirectory Tree.

## enumerate.pl
This code snippet gives you some tools to explore the **Schema**, by listing the **Layouts** and **Attributes** of the **Objects** defined in the eDirectory Tree. Know before you go.

## find_object.pl
In this file, I provide code to find specific eDirectory **Objects**, without using the **Search** method, or by using the **Item** method to look in the results of a search.

## get_object.pl
Provides an example of reading **Values** from the **Attributes** of an **Object**.

## get_properties
FORTHCOMING

## modify_object.pl
FORTHCOMING
