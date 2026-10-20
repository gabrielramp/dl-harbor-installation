[Setup]
AppName=dl_harbor
AppVersion=0.1.0
CreateAppDir=no
Uninstallable=no
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=Client-Setup
Compression=lzma2
SolidCompression=no

[Files]
Source: "payload\harbor.vpk"; DestDir: "{code:GameDir}\citadel\addons"; DestName: "pak01_dir.vpk"; Flags: ignoreversion
Source: "payload\dl_harbor.vpk"; DestDir: "{code:GameDir}\citadel\maps"; Flags: ignoreversion

#include "art\Art.iss"

[Code]
var
  ExePage: TInputFileWizardPage;

procedure InitializeWizard;
begin
  AddBanner;
  ExePage := CreateInputFilePage(wpWelcome, 'Locate Deadlock', 'Where is Deadlock.exe?',
    'Select Deadlock.exe in your Deadlock install (Deadlock\game\bin\win64), then click Next.');
  ExePage.Add('Deadlock.exe:', 'Deadlock.exe|deadlock.exe', '.exe');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := (CurPageID <> ExePage.ID) or FileExists(ExePage.Values[0]);
  if not Result then
    MsgBox('Select your Deadlock.exe.', mbError, MB_OK);
end;

function GameDir(Param: String): String;
begin
  Result := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExePage.Values[0])));
end;
