[Setup]
AppName=dl_harbor server
AppVersion=0.1.0
CreateAppDir=no
Uninstallable=no
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=Server-Setup
Compression=lzma2
SolidCompression=no

[Files]
Source: "payload\harbor-plugin.dll"; DestDir: "{code:GameDir}\bin\win64\managed\plugins"; Flags: ignoreversion
Source: "payload\harbor-balance.yaml"; DestDir: "{code:GameDir}\bin\win64\managed\plugins"; Flags: onlyifdoesntexist
Source: "payload\dl_harbor.vpk"; DestDir: "{code:GameDir}\citadel\maps"; Flags: ignoreversion
Source: "payload\harbor.vpk"; DestDir: "{code:GameDir}\citadel\deadworks_mods\vpks"; Flags: ignoreversion

#include "art\Art.iss"

[Messages]
FinishedLabelNoIcons=Setup has finished installing [name] on your computer.%n%nREMINDER to update your run-server.bat so your server launches into dl_harbor. Have fun!
FinishedLabel=Setup has finished installing [name] on your computer.%n%nREMINDER to update your run-server.bat so your server launches into dl_harbor. Have fun!

[Code]
var
  ExePage: TInputFileWizardPage;

procedure OpenLink(Sender: TObject; const Link: string; LinkType: TSysLinkType);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', Link, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

function NoticeText(const Caption: String; Top: Integer): TNewStaticText;
begin
  Result := TNewStaticText.Create(WizardForm);
  Result.AutoSize := False;
  Result.WordWrap := True;
  Result.Left := WizardForm.WelcomeLabel1.Left;
  Result.Top := Top;
  Result.Width := WizardForm.WelcomeLabel1.Width;
  Result.Caption := Caption;
  Result.Parent := WizardForm.WelcomePage;
  Result.AdjustHeight;
end;

procedure MakeHeading(Text: TNewStaticText);
begin
  Text.Font.Name := WizardForm.WelcomeLabel1.Font.Name;
  Text.Font.Size := WizardForm.WelcomeLabel1.Font.Size + 6;
  Text.Font.Style := [fsBold];
  Text.AdjustHeight;
end;

procedure ShowServerNotice;
var
  Warning, Intro, Heading, Body: TNewStaticText;
  Docs: TNewLinkLabel;
begin
  WizardForm.WelcomeLabel1.Visible := False;
  WizardForm.WelcomeLabel2.Visible := False;

  Intro := NoticeText('This installer is for automating the installation of dl_harbor on a',
    WizardForm.WelcomeLabel1.Top);

  Heading := NoticeText('DEADWORKS SERVER!', Intro.Top + Intro.Height + ScaleY(8));
  MakeHeading(Heading);

  Body := NoticeText('It''s expected you already have a working Deadworks server and know how to run one. ' +
    'If you don''t have a working Deadworks server, read the documentation here:',
    Heading.Top + Heading.Height + ScaleY(12));

  Docs := TNewLinkLabel.Create(WizardForm);
  Docs.AutoSize := False;
  Docs.Left := Body.Left;
  Docs.Top := Body.Top + Body.Height + ScaleY(8);
  Docs.Width := Body.Width;
  Docs.Caption := '<a href="https://docs.deadworks.net/getting-started/server-admins/run-a-server">' +
    'docs.deadworks.net/getting-started/server-admins/run-a-server</a>';
  Docs.UseVisualStyle := True;
  Docs.OnLinkClick := @OpenLink;
  Docs.Parent := WizardForm.WelcomePage;
  Docs.AdjustHeight;

  Warning := NoticeText(#$26A0 + ' PLEASE READ THIS PAGE, DO NOT SKIP!', 0);
  MakeHeading(Warning);
  Warning.Top := WizardForm.WelcomePage.Height - Warning.Height - WizardForm.WelcomeLabel1.Top;
end;

procedure InitializeWizard;
begin
  AddBanner;
  ShowServerNotice;
  ExePage := CreateInputFilePage(wpWelcome, 'Locate your server', 'Where is the server''s Deadlock.exe?',
    'Select Deadlock.exe in your Deadworks server (game\bin\win64), then click Next.');
  ExePage.Add('Deadlock.exe:', 'Deadlock.exe|deadlock.exe', '.exe');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := (CurPageID <> ExePage.ID) or FileExists(ExePage.Values[0]);
  if not Result then
    MsgBox('Select your server''s Deadlock.exe.', mbError, MB_OK);
end;

function GameDir(Param: String): String;
begin
  Result := ExtractFileDir(ExtractFileDir(ExtractFileDir(ExePage.Values[0])));
end;

function PosFrom(const Sub, S: AnsiString; Start: Integer): Integer;
begin
  Result := Pos(Sub, Copy(S, Start, Length(S)));
  if Result > 0 then
    Result := Result + Start - 1;
end;

procedure AddHarborToContentAddons;
var
  ConfigPath: String;
  Config, Entry: AnsiString;
  KeyAt, OpenAt, CloseAt: Integer;
begin
  ConfigPath := GameDir('') + '\bin\win64\configs\deadworks.jsonc';
  if not LoadStringFromFile(ConfigPath, Config) then
    Config := '';

  if Pos('"harbor"', Config) > 0 then
    exit;

  KeyAt := Pos('"content_addons"', Config);
  OpenAt := 0;
  CloseAt := 0;
  if KeyAt > 0 then
    OpenAt := PosFrom('[', Config, KeyAt);
  if OpenAt > 0 then
    CloseAt := PosFrom(']', Config, OpenAt);
  if CloseAt = 0 then begin
    SuppressibleMsgBox('Add "harbor" to "content_addons" in ' + ConfigPath + ' by hand.', mbError, MB_OK, IDOK);
    exit;
  end;

  if Trim(Copy(Config, OpenAt + 1, CloseAt - OpenAt - 1)) = '' then
    Entry := '"harbor"'
  else
    Entry := '"harbor", ';
  Insert(Entry, Config, OpenAt + 1);
  SaveStringToFile(ConfigPath, Config, False);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    AddHarborToContentAddons;
end;
