unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Spin, Buttons, types, FPCanvas, Graphics, Clipbrd,
  // various graphics functions & types
  LCLIntf, LCLType;
  //Windows untuk menggunakan GetKeyState()

type

  { TForm1 }
  elemen = record
  x,y : real;
  end;


  TForm1 = class(TForm)
    bbFillArea: TBitBtn;
    areaColor: TColorButton;
    bbPen: TBitBtn;
    bbGaris: TBitBtn;
    bbReset: TBitBtn;
    bbSegitigaSama: TBitBtn;
    bbSegitigaSiku: TBitBtn;
    bbErase: TBitBtn;
    bbLingkaran: TBitBtn;
    bbSave: TBitBtn;
    bbOpen: TBitBtn;
    cmbFillStyle: TComboBox;
    cmbFillAreaStyle: TComboBox;
    cmbRotate: TComboBox;
    eraserColor: TColorButton;
    cmbPen: TComboBox;
    Label17: TLabel;
    OpenDialog: TOpenDialog;
    penColor: TColorButton;
    Image1: TImage;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    PageControl1: TPageControl;
    pageTools: TPageControl;
    saveDialog: TSaveDialog;
    sbPPanjang: TSpeedButton;
    ScrollBox1: TScrollBox;
    spinEraser: TSpinEdit;
    spinPen: TSpinEdit;
    spinZoom: TFloatSpinEdit;
    Label12: TLabel;
    TabSheet1: TTabSheet;
    btnZoomOut: TButton;
    btnzoomin: TButton;
    garisColor: TColorButton;
    objekColor: TColorButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl2: TPageControl;
    spinGaris: TSpinEdit;
    tabFillArea: TTabSheet;
    tabEraser: TTabSheet;
    tabPen: TTabSheet;
    TabSheet3: TTabSheet;
    procedure bbEraseClick(Sender: TObject);
    procedure bbFillAreaClick(Sender: TObject);
    procedure bbLingkaranClick(Sender: TObject);
    procedure bbOpenClick(Sender: TObject);
    procedure bbPenClick(Sender: TObject);
    procedure bbGarisClick(Sender: TObject);
    procedure bbResetClick(Sender: TObject);
    procedure bbSaveClick(Sender: TObject);
    procedure bbSegitigaSamaClick(Sender: TObject);
    procedure bbSegitigaSikuClick(Sender: TObject);
    procedure cmbFillStyleChange(Sender: TObject);
    procedure cmbRotateChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbPPanjangClick(Sender: TObject);
    procedure spinGarisChange(Sender: TObject);
    procedure btnzoominClick(Sender: TObject);
    procedure garisColorColorChanged(Sender: TObject);
    procedure objekColorColorChanged(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FloodFill;
    procedure FormActivate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Reset;
    procedure Frame;
    function IsPointInPolygon(AX, AY:Integer; APolygon: array of TPoint): Boolean;
    procedure TemporaryGambar(temporaryPolygon: array of TPoint);
    procedure Gambar(APolygon: array of TPoint);
    procedure geserBangun(AX, AY, BX, BY: Integer);
    procedure MidPoint;
    procedure salinBitmap(ABmp: TBitmap);
    procedure pasteBitmap;
    procedure resetPolygon;
    procedure resetStatus;
    procedure btnZoomOutClick(Sender: TObject);
    procedure zoomIn;
    procedure zoomOut;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  APolygon, temporaryPolygon: array of TPoint;
  sebelumGambar, bmp: TBitmap;
  imageRect, temporaryRect, ARect: TRect;
  obj:array[1..25] of elemen;
  eraserArea, npoints, s, i, k, n, titik, xmid, ymid:integer;
  skala, d, r, totalx, totaly:real;
  xmin, ymin, xmax, ymax, min, max, dx, dy, xawal, xakhir, xsekarang, ysekarang, yawal, yakhir:integer;
  namaMode, namaBangun, dimensi : String;
  statusSebelum, statusRotasi, ubahCmbFillStyle, statusSelected, statusTahan, statusGambar, statusGeser : boolean;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
begin
  Image1.Canvas.Pen.Color:=clNone;
  Image1.canvas.Rectangle(0,0,Image1.Width,Image1.Height);
  bmp := Graphics.TBitmap.Create;
  sebelumGambar := Graphics.TBitmap.Create;
  statusSelected:=false;
  statusTahan:=false;
  statusGambar:=false;
  statusGeser:=false;
  namaBangun:='';
  namaMode:='';
  skala:=1;
  Image1.Picture.Bitmap.SetSize(1248, 456);
  Image1.Stretch := True;
  salinBitmap(bmp);
end;

procedure TForm1.resetStatus;
begin
  statusSelected:=false;
  statusTahan:=false;
  statusGambar:=false;
  statusGeser:=false;
  namaBangun:='';
  namaMode:='';
  Image1.Stretch := True;
  salinBitmap(bmp);
end;

procedure TForm1.btnZoomOutClick(Sender: TObject);
begin
  skala:= spinZoom.Value;
  zoomOut;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xawal:=X;
  yawal:=Y;
  if(statusGambar) then
  begin
    salinBitmap(sebelumGambar);
  end;
  if(namaMode='Fill Area') and (statusGambar=false) then
  begin
    xsekarang:=X;
    ysekarang:=Y;
    FloodFill;
  end;
  if(namaMode='Pen') and (statusGambar=false) then
  begin
     if cmbPen.ItemIndex=0 then
       Image1.Canvas.Pen.Style := psDot
     else if cmbPen.ItemIndex=1 then
       Image1.Canvas.Pen.Style := psDash
     else if cmbPen.ItemIndex=2 then
       Image1.Canvas.Pen.Style := psSolid;
     Image1.Canvas.Pen.Width:=spinPen.Value;
     Image1.Canvas.Pen.Color:=penColor.ButtonColor;
     Image1.Canvas.MoveTo(xawal,yawal);
  end;
  if(namaMode='Eraser') and (statusGambar=false) then
  begin
     Image1.Canvas.Pen.Style := psSolid;
     Image1.Canvas.Pen.Color:=clNone;
     Image1.Canvas.Brush.Color:=eraserColor.ButtonColor;
     eraserArea:=spinEraser.value;
  end;
  statusTahan:=true;
  if(IsPointInPolygon(X,Y,APolygon)) and (statusGambar=false) then
  begin
    statusGeser := true;
    salinBitmap(bmp);
    npoints:=length(APolygon);
    for i:=0 to npoints-1 do
    begin
      temporaryPolygon[i].X:=APolygon[i].X; temporaryPolygon[i].Y:=APolygon[i].Y;
    end;
  end;
  if(IsPointInPolygon(X,Y,APolygon)=false) and (Length(APolygon)>0) then
  begin
    statusSelected := false;
    resetPolygon;
  end;
end;

procedure TForm1.FloodFill;
  begin
     if cmbFillAreaStyle.ItemIndex=0 then
        Image1.Canvas.Brush.Style:=bsSolid
     else if cmbFillAreaStyle.ItemIndex=1 then
        Image1.Canvas.Brush.Style:=bsCross
     else if cmbFillAreaStyle.ItemIndex=2 then
        Image1.Canvas.Brush.Style:=bsDiagCross;
    Image1.Canvas.Brush.Color := areaColor.ButtonColor;
    Image1.Canvas.FloodFill(xsekarang, ysekarang, Image1.Canvas.Pixels[xsekarang,ysekarang], fsSurface);
end;

procedure TForm1.Image1MouseLeave(Sender: TObject);
begin
  edit1.text:='';
  edit2.text:='';
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  xmidLingkaran, ymidLingkaran : Integer;
begin
  edit1.text:=inttostr(X);
  edit2.text:=inttostr(Y);
  xakhir:=X;
  yakhir:=Y;
  if(statusGambar=false) then
  begin
     if(namaMode='Pen') and (statusTahan) then
     begin
       pasteBitmap;
       Image1.Canvas.LineTo(xakhir,yakhir);
       salinBitmap(bmp);
     end
     else if(namaMode='Eraser') and (statusTahan) then
     begin
        Image1.canvas.Rectangle(xakhir,yakhir,xakhir+eraserArea-1,yakhir+eraserArea-1);
     end;
  end;
  if(statusTahan) and (statusGambar) then
  begin
    if(namaBangun='Garis') then
    begin
      APolygon[0] := Types.Point(xawal, yawal);
      APolygon[1] := Types.Point(xakhir, yakhir);
    end
    else if(namaBangun='Lingkaran') then
    begin
      dx:=abs(xakhir-xawal);
      dy:=abs(yakhir-yawal);
      xmidLingkaran := round((xawal+xakhir)/2);
      ymidLingkaran := round((yawal+yakhir)/2);
      if GetKeyState(VK_SHIFT)>=0 then
      begin
        APolygon[0] := Types.Point(round(xmidLingkaran-dx/2), round(ymidLingkaran-dy/2));
        APolygon[1] := Types.Point(round(xmidLingkaran+dx/2), round(ymidLingkaran+dy/2));
      end
      else
      begin
        if (dx<dy) then
        begin
          min:=dx;
        end
        else
        begin
          min:=dy;
        end;
        if(xakhir<xawal) and (yakhir<yawal) then
        begin
          APolygon[0] := Types.Point(round(xawal-min), round(yawal-min));
          APolygon[1] := Types.Point(round(xawal), round(yawal));
        end
        else if(xakhir>xawal) and (yakhir<yawal) then
        begin
          APolygon[0] := Types.Point(round(xawal), round(yawal-min));
          APolygon[1] := Types.Point(round(xawal+min), round(yawal));
        end
        else if(xakhir<xawal) and (yakhir>yawal) then
        begin
          APolygon[0] := Types.Point(round(xawal-min), round(yawal));
          APolygon[1] := Types.Point(round(xawal), round(yawal+min));
        end
        else if(xakhir>xawal) and (yakhir>yawal) then
        begin
          APolygon[0] := Types.Point(round(xawal), round(yawal));
          APolygon[1] := Types.Point(round(xawal+min), round(yawal+min));
        end;
      end;
    end
    else if(namaBangun='Persegi Panjang') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
      begin
        APolygon[0] := Types.Point(xawal, yawal);
        APolygon[1] := Types.Point(xakhir, yawal);
        APolygon[2] := Types.Point(xakhir, yakhir);
        APolygon[3] := Types.Point(xawal, yakhir);
      end
      else
      begin
        dx:=abs(xakhir-xawal);
        dy:=abs(yakhir-yawal);
        if(dx<dy) then
        begin
          min:=dx;
        end
        else
        begin
          min:=dy;
        end;
        if (xakhir<xawal) and (yakhir<yawal) then
        begin
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal-min, yawal-min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir<yawal) then
        begin
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal+min, yawal-min);
          APolygon[3] := Types.Point(xawal+min, yawal);
        end
        else if (xakhir<xawal) and (yakhir>yawal) then
        begin
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal+min);
          APolygon[2] := Types.Point(xawal-min, yawal+min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir>yawal) then
        begin
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal+min);
          APolygon[2] := Types.Point(xawal+min, yawal+min);
          APolygon[3] := Types.Point(xawal+min, yawal);
        end;
      end;
    end
    else if(namaBangun='Segitiga Sama') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
            begin
              if(xawal<xakhir) then
              begin
                xmin:=xawal;
                xmax:=xakhir;
              end
              else
              begin
                xmin:=xakhir;
                xmax:=xawal;
              end;
              if(yawal<yakhir) then
              begin
                ymin:=yawal;
                ymax:=yakhir;
              end
              else
              begin
                ymin:=yakhir;
                ymax:=yawal;
              end;
              APolygon[0] := Types.Point(round((xawal+xakhir)/2), ymin);
              APolygon[1] := Types.Point(xmin, ymax);
              APolygon[2] := Types.Point(xmax, ymax);;
            end
            else
            begin
              dx:=abs(xakhir-xawal);
              dy:=abs(yakhir-yawal);
              if(dx<dy) then
              begin
                min:=dx;
              end
              else
              begin
                min:=dy;
              end;
              if (xakhir<xawal) and (yakhir<yawal) then
              begin
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                APolygon[0] := Types.Point(xawal+min, yawal);
                APolygon[1] := Types.Point(xawal+round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                APolygon[0] := Types.Point(xawal-min, yawal+min);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                APolygon[0] := Types.Point(xawal+min, yawal+min);
                APolygon[1] := Types.Point(xawal+round(min/2), yawal);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end;
            end;
    end
    else if(namaBangun='Segitiga Siku') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
            begin
              if xakhir < xawal then
              begin
                xmin:=xakhir;
                xmax:=xawal;
              end
              else
              begin
                xmin:=xawal;
                xmax:=xakhir;
              end;
              if yakhir < yawal then
              begin
                ymin:=yakhir;
                ymax:=yawal;
              end
              else
              begin
                ymin:=yawal;
                ymax:=yakhir;
              end;
              APolygon[0] := Types.Point(xmin, ymin);
              APolygon[1] := Types.Point(xmin, ymax);
              APolygon[2] := Types.Point(xmax, ymax);;
            end
            else
            begin
              dx:=abs(xakhir-xawal);
              dy:=abs(yakhir-yawal);
              if(dx<dy) then
              begin
                min:=dx;
              end
              else
              begin
                min:=dy;
              end;
              if (xakhir<xawal) and (yakhir<yawal) then
              begin
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal);
                APolygon[2] := Types.Point(xawal-min, yawal-min);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal-min);
                APolygon[2] := Types.Point(xawal+min, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal+min);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal+min);
                APolygon[2] := Types.Point(xawal+min, yawal+min);
              end;
            end;
    end;
    if(namaBangun<>'Pen') then
    begin
      Image1.Refresh;
      pasteBitmap;
      TemporaryGambar(APolygon);
    end;
  end;
  if(statusGeser) and (statusSelected) then
  begin
    midPoint;
    xsekarang:=X;
    ysekarang:=Y;
    geserBangun(xawal, yawal, xsekarang, ysekarang);
  end;
end;

procedure TForm1.spinGarisChange(Sender: TObject);
begin
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xakhir:=X;
  yakhir:=Y;
  statusTahan:=false;
  if(statusSelected) then
  begin
    pasteBitmap;
    Gambar(APolygon);
  end;
  if(statusGambar)then
  begin
    Gambar(APolygon);
    statusSelected:=true;
  end;
  if(statusGeser) and (statusSelected) then
  begin
    for i:=0 to npoints-1 do
    begin
      APolygon[i] := Types.Point(temporaryPolygon[i].X, temporaryPolygon[i].Y);
    end;
    pasteBitmap;
    Gambar(APolygon);
    statusGeser:=false;
  end;
end;

procedure TForm1.bbGarisClick(Sender: TObject);
begin
  resetStatus;
  statusGambar:=true;
  namaBangun:='Garis';
  SetLength(APolygon, 2);
  setLength(temporaryPolygon, 4);
end;

procedure TForm1.bbResetClick(Sender: TObject);
begin
  bmp.FreeImage;
  resetPolygon;
  Image1.Picture.Clear;
  Reset;
end;

procedure TForm1.bbSaveClick(Sender: TObject);
var
  saveBmp: TBitmap;
  pngBmp: TPortableNetworkGraphic;
begin
  if SaveDialog.Execute then
  begin
    saveBmp := TBitmap.Create;
    try
      saveBmp.SetSize(Image1.Canvas.ClipRect.Right, Image1.Canvas.ClipRect.Bottom);
      saveBmp.Assign(Image1.Picture.Bitmap);
      pngBmp := TPortableNetworkGraphic.Create;
      try
        pngBmp.Assign(saveBmp);
        pngBmp.SaveToFile(SaveDialog.FileName);
      finally
        pngBmp.Free;
      end;
    finally
      saveBmp.Free;
    end;
  end;
end;


procedure TForm1.bbPenClick(Sender: TObject);
begin
  resetStatus;
  namaMode:='Pen';
end;

procedure TForm1.bbFillAreaClick(Sender: TObject);
begin
  resetStatus;
  namaMode := 'Fill Area';
end;

procedure TForm1.bbLingkaranClick(Sender: TObject);
begin
  resetStatus;
  resetPolygon;
  statusGambar:=true;
  namaBangun:='Lingkaran';
  SetLength(APolygon, 2);
  setLength(temporaryPolygon, 2);
end;

procedure TForm1.bbOpenClick(Sender: TObject);
var
  filename: string;
begin
  if OpenDialog.execute then
  begin
    filename := OpenDialog.Filename;
    Image1.Picture.LoadFromFile(filename);
  end;
end;

procedure TForm1.bbEraseClick(Sender: TObject);
begin
  resetStatus;
  namaMode:='Eraser';
end;

procedure TForm1.sbPPanjangClick(Sender: TObject);
begin
  resetStatus;
  resetPolygon;
  statusGambar:=true;
  namaBangun:='Persegi Panjang';
  SetLength(APolygon, 4);
  setLength(temporaryPolygon, 4);
end;

procedure TForm1.bbSegitigaSamaClick(Sender: TObject);
begin
  resetStatus;
  resetPolygon;
  statusGambar:=true;
  namaBangun:='Segitiga Sama';
  SetLength(APolygon, 3);
  setLength(temporaryPolygon, 3);
end;

procedure TForm1.bbSegitigaSikuClick(Sender: TObject);
begin
  resetStatus;
  resetPolygon;
  statusGambar:=true;
  namaBangun:='Segitiga Siku';
  SetLength(APolygon, 3);
  setLength(temporaryPolygon, 3);
end;

procedure TForm1.cmbFillStyleChange(Sender: TObject);
begin
end;

procedure TForm1.cmbRotateChange(Sender: TObject);
var
  rot:Real;
begin
  if (statusSelected) and (length(APolygon)>=2)then
  begin
     statusRotasi := true;
     if(cmbRotate.ItemIndex=0) then
     begin
       rot:=90*pi/180;
     end
     else if(cmbRotate.ItemIndex=1) then
     begin
       rot:=-(90*pi/180);
     end
     else if(cmbRotate.ItemIndex=2) then
     begin
       rot:=180*pi/180;
     end;
     MidPoint;
     if(cmbRotate.ItemIndex=0) or (cmbRotate.ItemIndex=1) or (cmbRotate.ItemIndex=2) then
     begin
     for i:=0 to npoints-1 do
       begin
           APolygon[i].x:=APolygon[i].x-xmid;
           APolygon[i].y:=APolygon[i].y-ymid;
           TemporaryPolygon[i].x:=round(APolygon[i].x*cos(rot)-APolygon[i].y*sin(rot));
           TemporaryPolygon[i].y:=round(APolygon[i].x*sin(rot)+APolygon[i].y*cos(rot));
           APolygon[i].x:=TemporaryPolygon[i].x;
           APolygon[i].y:=TemporaryPolygon[i].y;
           APolygon[i].x:=APolygon[i].x+xmid;
           APolygon[i].y:=APolygon[i].y+ymid;
       end;
     end
     else if(cmbRotate.ItemIndex=3) then
     begin
       for i:=0 to npoints-1 do
         begin
           if(APolygon[i].y<ymid) then
           begin
             APolygon[i].y:=ymid+(ymid-APolygon[i].y);
           end
           else
           begin
             APolygon[i].y:=ymid-(APolygon[i].y-ymid);
           end;
         end;
     end
     else if(cmbRotate.ItemIndex=4) then
     begin
       for i:=0 to npoints-1 do
         begin
           if(APolygon[i].x<xmid) then
           begin
             APolygon[i].x:=xmid+(xmid-APolygon[i].x);
           end
           else
           begin
             APolygon[i].x:=xmid-(APolygon[i].x-xmid);
           end;
         end;
     end;
    pasteBitmap;
    Gambar(APolygon);
    statusRotasi := false;
  end;
  cmbRotate.Text:='Rotate';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.btnzoominClick(Sender: TObject);
begin
  skala:= spinZoom.Value;
  zoomIn;
end;
procedure TForm1.garisColorColorChanged(Sender: TObject);
begin
end;

procedure TForm1.objekColorColorChanged(Sender: TObject);
begin
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
end;

procedure TForm1.Reset;
begin
   Image1.Canvas.Pen.Style:=psSolid;
   Image1.Canvas.Pen.Color:=clNone;
   Image1.Canvas.Pen.Width:=1;
   Image1.Canvas.Brush.Color:=TColor($FFFFFF);
   image1.canvas.Rectangle(0,0,Image1.Width,Image1.Height);
end;

procedure TForm1.Frame;
begin
  Image1.Canvas.Pen.Style:=psSolid;
  Image1.Canvas.Pen.Color:=clblack;
  Image1.Canvas.Pen.Width:=1;
  Image1.Canvas.MoveTo(0,0);
  Image1.Canvas.LineTo(Image1.Width,0);
  Image1.Canvas.LineTo(Image1.Width,Image1.Height);
  Image1.Canvas.LineTo(0,Image1.Height);
  Image1.Canvas.LineTo(0,0);
end;

function TForm1.IsPointInPolygon(AX, AY:Integer; APolygon: array of TPoint): Boolean;
 var
   xnew, ynew : Cardinal;
   xold, yold : Cardinal;
   x1,y1 : Cardinal;
   x2,y2 : Cardinal;
   i, npoints : Integer;
   inside : Integer=0;
begin
 Result := False;
 npoints := Length(APolygon);
 if(npoints=2) then
 begin
   if (APolygon[0].X>APolygon[1].X) then
   begin
     xmin:=APolygon[1].X;
     xmax:=APolygon[0].X;
   end
   else
   begin
     xmin:=APolygon[0].X;
     xmax:=APolygon[1].X;
   end;
   if (APolygon[0].Y>APolygon[1].Y) then
   begin
     ymin:=APolygon[1].Y;
     ymax:=APolygon[0].Y;
   end
   else
   begin
     ymin:=APolygon[0].Y;
     ymax:=APolygon[1].Y;
   end;
   if (AX>=xmin) and (AX<=xmax) and (AY>=ymin) and (AY<=ymax) then
   begin
     Result:=inside=0;
   end;
 end;
 if(npoints<3) then Exit;
 xold := APolygon[npoints-1].X;
 yold := APolygon[npoints-1].Y;
 for i:=0 to npoints-1 do
     begin
       xnew := APolygon[i].X;
       ynew := APolygon[i].Y;
       if(APolygon[i].X<0) then
       begin
         xnew:=0;
       end;
       if(APolygon[i].Y<0) then
       begin
         ynew:=0;
       end;
       if (xnew>xold) then
         begin
           x1:=xold;
           x2:=xnew;
           y1:=yold;
           y2:=ynew;
         end
       else
         begin
           x1:=xnew;
           x2:=xold;
           y1:=ynew;
           y2:=yold;
         end;
       if (((xnew<AX) = (AX <= xold))
         and ((AY-y1)*(x2-x1) < (AX-x1)*(y2-y1))) then
           begin
             inside := not inside;
           end;
       xold:=xnew;
       yold:=ynew;
     end;
 Result:=inside<>0;
end;

procedure TForm1.TemporaryGambar(temporaryPolygon: array of TPoint);
begin
    Image1.Canvas.Pen.Style:=psSolid;
    Image1.Canvas.Pen.Color:=clBlue;
    Image1.Canvas.Pen.Width:=1;
    Image1.Canvas.Brush.Style:=bsClear;
    if(namaBangun<>'') and (namaBangun<>'Lingkaran')then
    begin
      Image1.Canvas.Polygon(temporaryPolygon);
    end
    else if(namaBangun<>'') and (namaBangun='Lingkaran')then
    begin
      Image1.Canvas.Ellipse(temporaryPolygon[0].X, temporaryPolygon[0].Y, temporaryPolygon[1].X, temporaryPolygon[1].Y);
    end;
end;

procedure TForm1.Gambar(APolygon: array of TPoint);
begin
     //macam-macam brush style
     //1: Brush.Style:=bsHorizontal;
     //2: Brush.Style:=bsVertical;
     //3: Brush.Style:=bsFDiagonal;
     //4: Brush.Style:=bsBDiagonal;
     //5: Brush.Style:=bsCross;
     //6: Brush.Style:=bsDiagCross;
     //7: Brush.Style:=bsSolid;
     //8: Brush.Style:=bsClear;
     if ComboBox1.ItemIndex=0 then
       Image1.Canvas.Pen.Style := psDot
     else if ComboBox1.ItemIndex=1 then
       Image1.Canvas.Pen.Style := psDash
     else if ComboBox1.ItemIndex=2 then
       Image1.Canvas.Pen.Style := psSolid;
     Image1.Canvas.Pen.Width:=spinGaris.Value;
     Image1.Canvas.Pen.Color:=garisColor.ButtonColor;
     if cmbFillStyle.ItemIndex=0 then
        Image1.Canvas.Brush.Style:=bsClear
     else if cmbFillStyle.ItemIndex=1 then
        Image1.Canvas.Brush.Style:=bsSolid
     else if cmbFillStyle.ItemIndex=2 then
        Image1.Canvas.Brush.Style:=bsCross
     else if cmbFillStyle.ItemIndex=3 then
        Image1.Canvas.Brush.Style:=bsDiagCross;
     if cmbFillStyle.ItemIndex<>0 then
        Image1.Canvas.Brush.Color:=objekColor.ButtonColor;
     if(namaBangun<>'') and (namaBangun<>'Lingkaran')then
     begin
       Image1.Canvas.Polygon(APolygon);
     end
     else if(namaBangun<>'') and (namaBangun='Lingkaran')then
     begin
       Image1.Canvas.Ellipse(APolygon[0].X, APolygon[0].Y, APolygon[1].X, APolygon[1].Y);
     end;
     if(statusGeser=false) and (statusSelected=false) then
     begin
       salinBitmap(bmp);
     end;
     statusGambar:=false;
end;

procedure TForm1.MidPoint;
var
  totalx, totaly : Integer;
begin
   totalx:=0;
   totaly:=0;
   npoints := Length(APolygon);
   if(npoints<3) and (namaBangun<>'Lingkaran') then Exit;
   for i:=0 to npoints-1 do
   begin
        totalx:=totalx+APolygon[i].x;
        totaly:=totaly+APolygon[i].y;
   end;
     xmid:=round(totalx/npoints);
     ymid:=round(totaly/npoints);
end;

procedure TForm1.geserBangun(AX, AY, BX, BY: Integer);
begin
  dx:=BX-AX;
  dy:=BY-AY;
  for i:=0 to npoints-1 do
  begin
    temporaryPolygon[i]:=Types.Point(APolygon[i].X+dx, APolygon[i].Y+dy);
  end;
    pasteBitmap;
    TemporaryGambar(temporaryPolygon);
    gambar(APolygon);
end;
procedure TForm1.salinBitmap(Abmp: TBitmap);
begin
   Abmp.Canvas.Clear;
   Abmp.SetSize(Image1.Width,Image1.Height);
   Abmp.Canvas.CopyRect(TRect.Create(0,0,Image1.Width,Image1.Height),Image1.Canvas,TRect.Create(0,0,Image1.Width,Image1.Height));
end;
procedure TForm1.pasteBitmap;
var
  ACanvas : TCanvas;
begin
  if((statusGeser) and (statusSelected)) or (ubahCmbFillStyle) or (statusRotasi) or (statusSebelum) then
    ACanvas := sebelumGambar.Canvas
  else
    ACanvas := bmp.Canvas;
  Image1.Canvas.CopyRect(TRect.Create(0,0,Image1.Width,Image1.Height),ACanvas,TRect.Create(0,0,Image1.Width,Image1.Height));
end;

procedure TForm1.resetPolygon;
begin
  for i:=0 to npoints-1 do
  begin
    APolygon[i].X:=0; APolygon[i].Y:=0;
    temporaryPolygon[i].X:=0; temporaryPolygon[i].Y:=0;
  end;
end;

procedure TForm1.zoomIn;
begin
  Image1.SetBounds(0,0,round(Image1.Picture.Width*skala),round(Image1.Picture.Height*skala));
end;

procedure TForm1.zoomOut;
begin
  Image1.SetBounds(0,0,round(Image1.Picture.Width/skala),round(Image1.Picture.Height/skala));
end;

end.

