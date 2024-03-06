#!rsc by RouterOS
# RouterOS script: accesslist-duplicates.capsman
# Copyright (c) 2018-2024 Christian Hesse <mail@eworm.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# requires RouterOS, version=7.12
#
# print duplicate antries in wireless access list
# https://git.eworm.de/cgit/routeros-scripts/about/doc/accesslist-duplicates.md
#
# !! Do not edit this file, it is generated from template!

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:do {
  :local ScriptName [ :jobname ];

  :local Seen ({});

  :foreach AccList in=[ /caps-man/access-list/find where mac-address!="00:00:00:00:00:00" ] do={
    :local Mac [ /caps-man/access-list/get $AccList mac-address ];
    :if ($Seen->$Mac = 1) do={
      /caps-man/access-list/print where mac-address=$Mac;
      :local Remove [ :tonum [ /terminal/ask prompt="\nNumeric id to remove, any key to skip!" ] ];

      :if ([ :typeof $Remove ] = "num") do={
        :put ("Removing numeric id " . $Remove . "...\n");
        /caps-man/access-list/remove $Remove;
      }
    }
    :set ($Seen->$Mac) 1;
  }
} on-error={ }
