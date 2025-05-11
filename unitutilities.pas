unit unitutilities;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

function FormatSize(ByteSize: Int64): string;

const
  kKB = 1024;
  kMB = 1048576;
  kGB = 1073741824;

implementation

function FormatSize(ByteSize: Int64): string;
begin
  if ByteSize >= kGB then
    result:=FormatFloat('0.##', ByteSize / kGB) + ' GB'
  else if ByteSize >= kMB then
    result:=FormatFloat('0.##', ByteSize / kMB) + ' MB'
  else if ByteSize >= kKB then
    result:=FormatFloat('0.##', ByteSize / kKB) + ' KB'
  else
    result:=IntToStr(ByteSize);
end;

end.

