About BltrVersion for QuickSilver on Github
===============================

BltrVersion is a drop-in replacement for the original "bltrversion" application included with the Quicksilver source code.  This version of bltrversion is X86/PPC compatible, eliminating the need for Intel users to install Rosetta on their system.

For certain Xcode Quicksilver builds, bltrversion is run from the shell to increment the CFBundleVersion key/value pair in "info.plist", used with Quicksilver plugins. This keeps the plugin bundle version number in sync with Quicksilver.

Usage
-----

After compiling the release build of BltrVersion, copy the new executable to "/Quicksilver/PlugIns-Main/bltrversion" overwriting the original PPC only bltrversion version.

Now you can build the "Quicksilver Distribution" target without having to install Rosetta.

Legal Stuff 
-----------

By downloading and/or using this software you agree to the following terms of use:

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this software except in compliance with the License.
    You may obtain a copy of the License at
    
      http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


Which basically means: whatever you do, I can't be held accountable if something breaks.  
