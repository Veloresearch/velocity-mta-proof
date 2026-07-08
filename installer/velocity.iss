; Velocity installer - Inno Setup script
; Build:  iscc installer\velocity.iss   (or run installer\build_installer.ps1)
; Produces: installer\dist\VelocitySetup.exe
;
; Per-user install (no admin prompt) to %LOCALAPPDATA%\Programs\Velocity.
; The ~2.95 GB model is downloaded from Hugging Face DURING setup (built-in Inno
; downloader, SHA-256 verified) into {app}\models. If the user skips that step, or
; the download fails, velocity.exe downloads and verifies the model on first launch.

#define MyAppName "Velocity"
#define MyAppVersion "0.1"
#define MyAppPublisher "Velo Research"
#define MyAppExeName "velocity.exe"
#define ModelUrl "https://huggingface.co/veloresearch/qwen3.5-4b-adapt-b32/resolve/main/qwen3.5-4b-adapt-b32.mfy"
#define ModelName "qwen3.5-4b-adapt-b32.mfy"
; Keep in sync with HF_MODEL_SHA256 in crates/velocity/src/main.rs when the .mfy changes.
#define ModelSHA256 "0f6a3d3bfff86ef9006383e32955529a8c0949dad690330c6d302c08eef4dd07"

[Setup]
; A stable AppId keeps upgrades/uninstalls linked across versions. Do not change it.
AppId={{7B2C4E10-9A3D-4F52-B8E1-6C0D2A9F4E77}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
VersionInfoVersion={#MyAppVersion}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
OutputDir=dist
OutputBaseFilename=VelocitySetup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=staging\velocity.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} {#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "downloadmodel"; Description: "Download the AI model now (~2.95 GB, one-time). If unchecked, Velocity downloads it on first launch."; GroupDescription: "Model:"
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"

[Files]
Source: "staging\velocity.exe";   DestDir: "{app}"; Flags: ignoreversion
Source: "staging\README.md";      DestDir: "{app}"; Flags: ignoreversion isreadme
Source: "staging\QUICKSTART.md";  DestDir: "{app}"; Flags: ignoreversion
Source: "staging\CHANGELOG.md";   DestDir: "{app}"; Flags: ignoreversion
Source: "staging\LICENSE.txt";    DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}";           Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}";     Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Remove the downloaded model + chat history on uninstall so nothing large is left behind.
Type: filesandordirs; Name: "{app}\models"
Type: filesandordirs; Name: "{app}\chat_history"

[Code]
var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(
    'Downloading the AI model',
    'Velocity is downloading the model from Hugging Face (~2.95 GB). This is a one-time download.',
    @OnDownloadProgress);
end;

function ModelAlreadyPresent: Boolean;
begin
  { On a fresh install the destination does not exist yet, so this is False and we download. }
  Result := FileExists(ExpandConstant('{app}\models\{#ModelName}'));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpReady) and WizardIsTaskSelected('downloadmodel') and (not ModelAlreadyPresent) then
  begin
    DownloadPage.Clear;
    DownloadPage.Add('{#ModelUrl}', '{#ModelName}', '{#ModelSHA256}');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
      except
        if DownloadPage.AbortedByUser then
        begin
          Log('Model download aborted by user.');
          Result := False;  { stay on the Ready page }
        end
        else
        begin
          SuppressibleMsgBox(
            'The model download did not finish:' + #13#10 +
            AddPeriod(GetExceptionMessage) + #13#10#13#10 +
            'Setup will continue - Velocity will download the model on first launch.',
            mbInformation, MB_OK, IDOK);
          Result := True;  { install anyway; velocity.exe fetches it on first run }
        end;
      end;
    finally
      DownloadPage.Hide;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Src, DestDir, Dest: String;
begin
  if CurStep = ssPostInstall then
  begin
    Src := ExpandConstant('{tmp}\{#ModelName}');
    if FileExists(Src) then
    begin
      DestDir := ExpandConstant('{app}\models');
      ForceDirectories(DestDir);
      Dest := DestDir + '\{#ModelName}';
      { Temp and app dir share the LOCALAPPDATA volume -> instant move, no extra disk. }
      if not RenameFile(Src, Dest) then
        if FileCopy(Src, Dest, False) then
          DeleteFile(Src);
    end;
  end;
end;
