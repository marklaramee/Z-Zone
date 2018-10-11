This is an iOS application that I created in 2011 using Objective-C and C (to handle contacts natively in iPhone). It was successfully submitted to Apple and was available publicly in the App store. 

It is a contact management app. It segments contacts you don't want to accidentally call; but, also do not want to delete. It does this by creating a Z-Zone, prefixing all sensitive contacts with "zzz" and storing them all at the end of your contacts list.

You can do this manually; but, it is labor intensive. With this app, you can easily move contacts in and out of the Z-Zone with a click. Dozens of contacts can be moved in seconds this way.

The app has 3 main displays: All Contacts, Normal Contacts and Z-Zone contacts. Normal contacts is a list of non Z-Zone contacts and Z-Zone contacts is a list of all the contacts with "zzz" prefixed names.

The "All Contacts" is the most used screen, displaying a list of all contacts, alphabetized naturally (without regard to their prefix). Z-Zone contacts have a background image (of faint z's) while normal contacts do not. Contacts can be easily moved in and out of the Z-Zone with a click.

There is also a settings screen where you can change the default prefix. 

In 2011, there was no native garbage collection. You can see a post I created here to discuss the issue. I was having memory leaks that would likely have prevented acceptance into the App Store.

https://stackoverflow.com/questions/5200857/memory-leaks-from-multidimensional-array-nsmutablearray-nsarray-addobject-and


TODO: 
- consolidate click events and cell display functionality from views into Z_ZoneAppDelegate
- make contact array keys self-documenting


