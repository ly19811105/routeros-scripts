#!rsc by RouterOS
# RouterOS script: backup-partition
# Copyright (c) 2022-2024 Christian Hesse <mail@eworm.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# provides: backup-script, order=70
# requires RouterOS, version=7.12
#
# save configuration to fallback partition
# https://git.eworm.de/cgit/routeros-scripts/about/doc/backup-partition.md

:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:do {
  :local ScriptName [ :jobname ];

  :global PackagesUpdateBackupFailure;

  :global LogPrintExit2;
  :global ScriptLock;

  :if ([ $ScriptLock $ScriptName ] = false) do={
    :set PackagesUpdateBackupFailure true;
    :error false;
  }

  :if ([ :len [ /partitions/find ] ] < 2) do={
    $LogPrintExit2 error $ScriptName ("Device does not have a fallback partition.") false;
    :set PackagesUpdateBackupFailure true;
    :error false;
  }

  :local ActiveRunning [ /partitions/find where active running ];

  :if ([ :len $ActiveRunning ] < 1) do={
    $LogPrintExit2 error $ScriptName ("Device is not running from active partition.") false;
    :set PackagesUpdateBackupFailure true;
    :error false;
  }

  :local FallbackTo [ /partitions/get $ActiveRunning fallback-to ];

  :do {
    /system/scheduler/add start-time=startup name="running-from-backup-partition" \
        on-event=(":log warning (\"Running from partition '\" . " . \
        "[ /partitions/get [ find where running ] name ] . \"'!\")");
    /partitions/save-config-to $FallbackTo;
    /system/scheduler/remove "running-from-backup-partition";
    $LogPrintExit2 info $ScriptName ("Saved configuration to partition '" . \
        $FallbackTo . "'.") false;
  } on-error={
    /system/scheduler/remove [ find where name="running-from-backup-partition" ];
    $LogPrintExit2 error $ScriptName ("Failed saving configuration to partition '" . \
        $FallbackTo . "'!") false;
    :set PackagesUpdateBackupFailure true;
    :error false;
  }
} on-error={ }
