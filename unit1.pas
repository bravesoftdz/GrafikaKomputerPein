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
    bbFreeHand: TBitBtn;
    bbGaris: TBitBtn;
    bbReset: TBitBtn;
    bbSegitigaSama: TBitBtn;
    bbSegitigaSiku: TBitBtn;
    cmbFillStyle: TComboBox;
    editdlm: TEdit;
    Image1: TImage;
    PageControl1: TPageControl;
    sbPPanjang: TSpeedButton;
    ScrollBox1: TScrollBox;
    spinZoom: TFloatSpinEdit;
    Label11: TLabel;
    Label12: TLabel;
    TabSheet1: TTabSheet;
    btnZoomOut: TButton;
    rkanan: TButton;
    rkiri: TButton;
    btnzoomin: TButton;
    garisColor: TColorButton;
    objekColor: TColorButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
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
    spinRotate: TSpinEdit;
    spinGaris: TSpinEdit;
    TabSheet3: TTabSheet;
    procedure bbFillAreaClick(Sender: TObject);
    procedure bbFreeHandClick(Sender: TObject);
    procedure bbGarisClick(Sender: TObject);
    procedure bbResetClick(Sender: TObject);
    procedure bbSegitigaSamaClick(Sender: TObject);
    procedure bbSegitigaSikuClick(Sender: TObject);
    procedure cmbFillStyleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure objekColorClick(Sender: TObject);
    procedure areaColorClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rkananClick(Sender: TObject);
    procedure rkiriClick(Sender: TObject);
    procedure sbPPanjangClick(Sender: TObject);
    procedure spinGarisChange(Sender: TObject);
    procedure btnzoominClick(Sender: TObject);
    procedure garisColorColorChanged(Sender: TObject);
    procedure objekColorColorChanged(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FloodFill;
    procedure FormActivate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
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
  npoints, s, i, k, n, titik, xmid, ymid:integer;
  skala, d, r, totalx, totaly:real;
  xmin, ymin, xmax, ymax, min, max, dx, dy, xawal, xakhir, xsekarang, ysekarang, yawal, yakhir:integer;
  namaMode, namaBangun, dimensi : String;
  statusSelected, statusTahan, statusGambar, statusGeser : boolean;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
begin
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
  temporaryRect := TRect.Create(10,10,150,150);
  ARect := TRect.Create(10,10,150,150);
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

procedure TForm1.Image1Click(Sender: TObject);
begin
  if(IsPointInPolygon(xawal,yawal,APolygon)) then
  begin
    editDlm.Text:='OK';
  end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  current: integer;
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
  if(namaBangun='Free Hand') then
  begin
    Image1.Canvas.MoveTo(xawal,yawal);
  end;
  statusTahan:=true;
  if(IsPointInPolygon(X,Y,APolygon)) and (statusGambar=false) then
  begin
    statusGeser := true;
    salinBitmap(bmp);
  end;
  if(IsPointInPolygon(X,Y,APolygon)=false) and (Length(APolygon)>0) then
  begin
    statusSelected := false;
    resetPolygon;
  end;
end;

procedure TForm1.FloodFill;
  begin
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
begin
  edit1.text:=inttostr(X);
  edit2.text:=inttostr(Y);
  editdlm.Text:=GetKeyState(VK_SHIFT).ToString;
  if(statusTahan) and (statusGambar) then
  begin
    xakhir:=X;
    yakhir:=Y;
    if(namaBangun='Garis') then
    begin
      APolygon[0] := Types.Point(xawal, yawal);
      APolygon[1] := Types.Point(xakhir, yakhir);
    end
    else if(namaBangun='Free Hand') then
    begin
     editdlm.Text:='Free Hand';
     if ComboBox1.ItemIndex=0 then
       Image1.Canvas.Pen.Style := psDot
     else if ComboBox1.ItemIndex=1 then
       Image1.Canvas.Pen.Style := psDash
     else if ComboBox1.ItemIndex=2 then
       Image1.Canvas.Pen.Style := psSolid;
     Image1.Canvas.Pen.Width:=spinGaris.Value;
     Image1.Canvas.Pen.Color:=garisColor.ButtonColor;
     pasteBitmap;
     Image1.Canvas.LineTo(xakhir,yakhir);
     salinBitmap(bmp);
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
          editdlm.Text:='xakhir<xawal yakhir<yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal-min, yawal-min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir<yawal) then
        begin
          editdlm.Text:='xakhir>xawal yakhir<yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal+min, yawal-min);
          APolygon[3] := Types.Point(xawal+min, yawal);
        end
        else if (xakhir<xawal) and (yakhir>yawal) then
        begin
          editdlm.Text:='xakhir<xawal yakhir>yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal+min);
          APolygon[2] := Types.Point(xawal-min, yawal+min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir>yawal) then
        begin
          editdlm.Text:='xakhir>xawal yakhir>yawal';
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
                editdlm.Text:='xakhir<xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal+min, yawal);
                APolygon[1] := Types.Point(xawal+round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal-min, yawal+min);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir>yawal';
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
                editdlm.Text:='xakhir<xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal);
                APolygon[2] := Types.Point(xawal-min, yawal-min);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal-min);
                APolygon[2] := Types.Point(xawal+min, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal+min);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal+min);
                APolygon[2] := Types.Point(xawal+min, yawal+min);
              end;
            end;
    end;
    if(namaBangun<>'Free Hand') then
    begin
      Image1.Refresh;
      pasteBitmap;
      TemporaryGambar(APolygon);
    end;
  end;
  if(statusGeser) and (statusSelected) then
  begin
    editDlm.Text:='Geser';
    midPoint;
    xsekarang:=X;
    ysekarang:=Y;
    geserBangun(xawal, yawal, xsekarang, ysekarang);
  end;
end;

procedure TForm1.spinGarisChange(Sender: TObject);
begin
  pasteBitmap;
  Gambar(APolygon);
end;

procedure TForm1.objekColorClick(Sender: TObject);
begin

end;

procedure TForm1.areaColorClick(Sender: TObject);
begin

end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xakhir:=X;
  yakhir:=Y;
  statusTahan:=false;
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

procedure TForm1.rkananClick(Sender: TObject);
var
  rot:real;
begin
  rot:=spinRotate.Value;
  rot:=rot*pi/180;
  totalx:=0;
  totaly:=0;
  npoints:=length(APolygon);
  for i:=0 to npoints-1 do
        begin
          totalx:=totalx+APolygon[i].x;
          totaly:=totaly+APolygon[i].y;
        end;
  if npoints>1 then
  begin
    xmid:=round(totalx/npoints);
    ymid:=round(totaly/npoints);
  end;
  for i:=0 to npoints-1 do
    begin
         APolygon[i].x:=APolygon[i].x-xmid;
         APolygon[i].y:=APolygon[i].y-ymid;
         TemporaryPolygon[i].x:=round(APolygon[i].x*cos(rot)-APolygon[i].y*sin(rot));
         TemporaryPolygon[i].y:=round(APolygon[i].x*sin(rot)+APolygon[i].y*cos(rot));
         TemporaryPolygon[i].x:=TemporaryPolygon[i].x+xmid;
         TemporaryPolygon[i].y:=TemporaryPolygon[i].y+ymid;
         APolygon[i].x:=APolygon[i].x+xmid;
         APolygon[i].y:=APolygon[i].y+ymid;
    end;
  Gambar(TemporaryPolygon); //digambar Temporary karena koordinat hasil rotasi merupakan pembulatan
end;

procedure TForm1.rkiriClick(Sender: TObject);
var
  rot:real;
begin
  rot:=spinRotate.Value;
  rot:=-(rot*pi/180);
  totalx:=0;
  totaly:=0;
  npoints:=length(APolygon);
  for i:=0 to npoints-1 do
        begin
          totalx:=totalx+APolygon[i].x;
          totaly:=totaly+APolygon[i].y;
        end;
  if npoints>1 then
  begin
    xmid:=round(totalx/npoints);
    ymid:=round(totaly/npoints);
  end;
  for i:=0 to npoints-1 do
    begin
         APolygon[i].x:=APolygon[i].x-xmid;
         APolygon[i].y:=APolygon[i].y-ymid;
         TemporaryPolygon[i].x:=round(APolygon[i].x*cos(rot)-APolygon[i].y*sin(rot));
         TemporaryPolygon[i].y:=round(APolygon[i].x*sin(rot)+APolygon[i].y*cos(rot));
         APolygon[i]:=TemporaryPolygon[i];
         APolygon[i].x:=APolygon[i].x+xmid;
         APolygon[i].y:=APolygon[i].y+ymid;
    end;
  Gambar(APolygon);
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

procedure TForm1.bbFreeHandClick(Sender: TObject);
begin
  resetStatus;
  statusGambar:=true;
  namaBangun:='Free Hand';
end;

procedure TForm1.bbFillAreaClick(Sender: TObject);
begin
  resetStatus;
  namaMode := 'Fill Area';
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
  gambar(APolygon);
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
  Gambar(APolygon);
end;

procedure TForm1.objekColorColorChanged(Sender: TObject);
begin
  Gambar(APolygon);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  pasteBitmap;
  Gambar(APolygon);
end;

procedure TForm1.Reset;
begin
   Image1.Canvas.Pen.Style:=psSolid;
   Image1.Canvas.Pen.Color:=clblack;
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
 if(npoints<3) then Exit;
 xold := APolygon[npoints-1].X;
 yold := APolygon[npoints-1].Y;
 for i:=0 to npoints-1 do
     begin
       xnew := APolygon[i].X;
       ynew := APolygon[i].Y;
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
       if (((xnew<AX) = (AX <= xold)) //edge "open" at left end
         and ((AY-y1)*(x2-x1) < (y2-y1)*(AX-x1))) then
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
    if(namaBangun<>'') then
    begin
      Image1.Canvas.Polygon(temporaryPolygon);
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
        Image1.Canvas.Brush.Style:=bsCross;
     if cmbFillStyle.ItemIndex<>0 then
        Image1.Canvas.Brush.Color:=objekColor.ButtonColor;
     Image1.Canvas.Polygon(APolygon);
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
   if(npoints<3) then Exit;
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
  if(statusGeser) and (statusSelected) then
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

