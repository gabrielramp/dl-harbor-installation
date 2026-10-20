[Setup]
SetupIconFile=art\harbor.ico
WizardStyle=modern dark
DisableWelcomePage=no
WizardImageFile=art\wizard.png
WizardSmallImageFile=art\small.png

[Files]
Source: "art\banner.png"; Flags: dontcopy

[Code]
procedure AddBanner;
var
  Banner: TBitmapImage;
  W, H, PanelH, Bevel1Top, InnerTop, InnerH: Integer;
begin
  ExtractTemporaryFile('banner.png');
  Banner := TBitmapImage.Create(WizardForm);
  Banner.PngImage.LoadFromFile(ExpandConstant('{tmp}\banner.png'));

  W := WizardForm.MainPanel.Width;
  H := W * Banner.PngImage.Height div Banner.PngImage.Width;
  Log(Format('Banner: %dx%d drawn at %dx%d', [Banner.PngImage.Width, Banner.PngImage.Height, W, H]));

  PanelH := WizardForm.MainPanel.Height;
  Bevel1Top := WizardForm.Bevel1.Top;
  InnerTop := WizardForm.InnerNotebook.Top;
  InnerH := WizardForm.InnerNotebook.Height;
  WizardForm.ClientHeight := WizardForm.ClientHeight + H;
  WizardForm.MainPanel.Height := PanelH + H;
  WizardForm.Bevel1.Top := Bevel1Top + H;
  WizardForm.InnerNotebook.Top := InnerTop + H;
  WizardForm.InnerNotebook.Height := InnerH;
  WizardForm.PageNameLabel.Top := WizardForm.PageNameLabel.Top + H;
  WizardForm.PageDescriptionLabel.Top := WizardForm.PageDescriptionLabel.Top + H;
  WizardForm.WizardSmallBitmapImage.Top := WizardForm.WizardSmallBitmapImage.Top + H;

  Banner.Parent := WizardForm.MainPanel;
  Banner.SetBounds(0, 0, W, H);
  Banner.Anchors := [akLeft, akTop, akRight];
  Banner.Stretch := True;
end;
