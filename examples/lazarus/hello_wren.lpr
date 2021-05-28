program hello_wren;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, wren, cwren
  { you can add units after this };


procedure writeFn(vm : PWrenVM; msg : PChar); cdecl;
begin
  Write(msg);
end;

procedure errorFn(vm : PWrenVM; errorType : WrenErrorType;
             module : PChar; line : Integer;
             msg : PChar); cdecl;
begin
  case errorType of
    WREN_ERROR_COMPILE:
      begin
        WriteLn('[', module, ' line ', line, '] [Error] ', msg);
      end;
    WREN_ERROR_STACK_TRACE:
      begin
        WriteLn('[', module, ' line ', line, '] in ', msg);
      end;
    WREN_ERROR_RUNTIME:
      begin
        WriteLn('[Runtime Error] ', msg);
      end;
  end;
end;


var
  wrenCfg : WrenConfiguration;
  vm : PWrenVM;
  module : AnsiString;
  script : AnsiString;
  res : WrenInterpretResult;

begin

  wrenInitConfiguration(@wrenCfg);
  wrenCfg.writeFn := @writeFn;
  wrenCfg.errorFn := @errorFn;

  vm := wrenNewVM(@wrenCfg);


  module := 'main';
  script := 'System.print("I am running in a VM!")' + #13#10
          + 'var n = 0' + #13#10
          + 'while (n < 10) {' + #13#10
          + '  System.print("  Looped n [" + n.toString + "] times")' + #13#10
          + '  n = n + 1' + #13#10
          + '}';

  WriteLn('Script to run:');
  WriteLn(script);


  res := wrenInterpret(vm, PChar(module), PChar(script));

  case res of
    WREN_RESULT_COMPILE_ERROR:
      WriteLn('Compile Error!');
    WREN_RESULT_RUNTIME_ERROR:
      WriteLn('Runtime Error!');
    WREN_RESULT_SUCCESS:
      WriteLn('Success!');
  end;

  wrenFreeVM(vm);


  WriteLn('Hello Wren-pas');
end.

