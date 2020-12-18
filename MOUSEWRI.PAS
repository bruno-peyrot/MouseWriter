
program MouseWriter2;

uses dos;

{$m $4000,0,0}

var cmdline:string;

begin
    cmdline:='';
    if (paramcount=1) then cmdline:=paramstr(1);
    exec('mousescr.exe','/fad/w3');
    exec('mouseprg.exe',cmdline);
end.
