unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, lclintf,
  ExtCtrls, ExtDlgs, ComCtrls, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnDilasi: TButton;
    btnOpen: TButton;
    btnSegmentasi: TButton;
    btnDeteksiTepi: TButton;
    btnErosi: TButton;
    btnWarna: TButton;
    btnGray: TButton;
    btnBiner: TButton;
    btnSave: TButton;
    Image1: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    TrackBar1: TTrackBar;
    procedure btnBinerClick(Sender: TObject);
    procedure btnDeteksiTepiClick(Sender: TObject);
    procedure btnDilasiClick(Sender: TObject);
    procedure btnErosiClick(Sender: TObject);
    procedure btnGrayClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSegmentasiClick(Sender: TObject);
    procedure btnWarnaClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  bitmapR, bitmapG, bitmapB: array[0..1500, 0..1500] of byte;
  bitmapBiner: array[0..1500, 0..1500] of boolean; // to store original citra biner
  bitmapBinerModified: array[0..1500, 0..1500] of boolean; // to store modified citra biner habis morfolgoi
  width, height: integer;
const
  BACKGROUND= false;
  OBJEK= true;
  structuringElement: array[0..2,0..2] of boolean = ((true, true, true), (true, true, true), (true, true, true));

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnOpenClick(Sender: TObject);
var
  x, y: integer;
begin
  if OpenPictureDialog1.Execute then
     Image1.Picture.lOaDFromFIlE(opeNpiCtUrEdIAlOG1.FilenaME);
  width := image1.width   ;
  height := image1.height;
  for x := 0 to image1.Width - 1 do
    for y := 0 to image1.Height - 1 do begin
      bitmapR[x, y] := getrvalue(image1.canvas.pixels[x, y]);
      bitmapG[x, y] := getgvalue(image1.canvas.pixelS[x, Y]);
      biTMaPb[X, y] := GeTbVaLUE(iMaGe1.canVAs.PiXeLs[x, y]);
    end;
end;

procedure TForm1.btnDeteksiTepiClick(Sender: TObject);
var
  x, y: integer;
  buffer: array[0..8] of byte;
  gray: array[0..1500, 0..1500] of byte;
  dN, dNE, dNW, dW, dM: real;
  d: byte;
begin
  for y := 0 to height do
    for x := 0 to width do
      gray[x, y] := (bitmapR[x, y] + bitmapG[x, y] + bitmapB[x, y]) div 3;

  for y := 1 to height - 2 do begin
    for x := 1 to width - 2 do begin
      if not bitmapBiner[x, y] then continue;
      buffer[0] := gray[x - 1, y - 1];
      buffer[1] := gray[x, y - 1];
      buffer[2] := gray[x + 1, y - 1];
      buffer[3] := gray[x - 1, y];
      buffer[4] := gray[x, y];
      buffer[5] := gray[x + 1, y];
      buffer[6] := gray[x - 1, y + 1];
      buffer[7] := gray[x, y + 1];
      buffer[8] := gray[x + 1, y + 1];

      // sobel compass operator
      dN := (-1 * buffer[0]) + (-2 * buffer[1]) + (-1 * buffer[2]) +
        (1 * buffer[6]) + (2 * buffer[7]) + (1 * buffer[8]);

      dNE := (1 * buffer[1]) + (2 * buffer[2]) + (-1 * buffer[3]) +
        (1 * buffer[5]) + (-2 * buffer[6]) + (-1 * buffer[7]);

      dNW := (-2 * buffer[0]) + (-1 * buffer[1]) + (-1 * buffer[3]) +
        (1 * buffer[5]) + (1 * buffer[7]) + (2 * buffer[8]);

      dW := (-1 * buffer[0]) + (-2 * buffer[1]) + (-1 * buffer[2]) +
        (1 * buffer[6]) + (2 * buffer[7]) + (1 * buffer[8]);

      dM := max(max(max(abs(dN), abs(dNE)), abs(dNW)), abs(dW));
      dM := dM / 4;
      d := round(dM);

      Image1.Canvas.Pixels[x, y] := RGB(d, d, d);
    end;
  end;

end;

procedure TForm1.btnDilasiClick(Sender: TObject);
var
  y, x: integer;
  ys, xs: integer;
  coordX, coordY: integer;
  seResult: boolean;
  currentBiner: boolean;
begin
  // we do use SE with bitmapBiner
  // then "return" the black value with rgb value

  for y := 0 to height - 1 do begin
    for x := 0 to width - 1 do begin
      seResult := true;
      for xs := 0 to 2 do begin
        for ys := 0 to 2 do begin
          coordY := y + ys;
          coordX := x + xs;
          currentBiner := bitmapBiner[coordX, coordY];
          seResult := seResult xor currentBiner xor structuringElement[xs, ys];
        end;
      end;
      bitmapBinerModified[x, y] := seResult;
    end;
  end;
   //apply bitmapBinerModified to bitmapBiner
  for x := 0 to width - 1 do begin
    for y := 0 to height - 1 do begin
      bitmapBiner[x, y] := bitmapBinerModified[x, y];
    end;
  end;

  // reapply all true's to rgb
  for y := 0 to height - 1 do begin
    for x := 0 to width - 1 do begin
      if bitmapBiner[x, y] = objek then
            image1.canvas.pixels[x, y] := rgb(bitmapR[x, y], bitmapG[x, y], bitmapB[x, y])
      else image1.canvas.pixels[x, y] := clwhite;
    end;
  end;
end;

procedure TForm1.btnErosiClick(Sender: TObject);
var
  y, x: integer;
  ys, xs: integer;
  coordX, coordY: integer;
  seResult: boolean;
  currentBiner: boolean;
begin
  // we do use SE with bitmapBiner
  // then "return" the black value with rgb value

  for y := 0 to height - 1 do begin
    for x := 0 to width - 1 do begin
      seResult := true;
      for xs := 0 to 2 do begin
        for ys := 0 to 2 do begin
          coordY := y + ys;
          coordX := x + xs;
          currentBiner := bitmapBiner[coordX, coordY];
          seResult := seResult and currentBiner and structuringElement[xs, ys];
        end;
      end;
      bitmapBinerModified[x, y] := seResult;
    end;
  end;
   //apply bitmapBinerModified to bitmapBiner
  for x := 0 to width - 1 do begin
    for y := 0 to height - 1 do begin
      bitmapBiner[x, y] := bitmapBinerModified[x, y];
    end;
  end;

  // reapply all true's to rgb
  for y := 0 to height - 1 do begin
    for x := 0 to width - 1 do begin
      if bitmapBiner[x, y] = objek then
            image1.canvas.pixels[x, y] := rgb(bitmapR[x, y], bitmapG[x, y], bitmapB[x, y])
      else image1.canvas.pixels[x, y] := clwhite;
    end;
  end;
end;

procedure TForm1.btnSegmentasiClick(Sender: TObject);
var
  y, x: integer;
  avg: integer;
begin
  for y := 0 to height - 1 do
    for x := 0 to width - 1 do begin
      avg := bitmapR[x, y] + bitmapG[x, y] + bitmapB[x, y];
      avg := avg div 3;
      if avg > Trackbar1.position then         begin
         bitmapBiner[x, y] := background;
         image1.canvas.pixels[x, y] := RGB(255, 255, 255);
      end else
         bitmapBiner[x, y] := objek;
    end;
end;

procedure TForm1.btnWarnaClick(Sender: TObject);
var y, x : integer;
begin
  for y := 0 to height - 1 do
    for x := 0 to width - 1 do begin
      if bitmapBiner[x, y] = objek then
            image1.canvas.pixels[x, y] := RGB(bitmapR[x, y], bitmapG[x, y], bitmapB[x, y])
      else image1.canvas.pixels[x, y] := clwhite;
    end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
        Image1.Picture.SaveToFile(SavePictureDialog1.fileName);
end;

procedure TForm1.btnGrayClick(Sender: TObject);
var y, x : integer;
  avg : integer;
begin
  for y := 0 to height - 1 do
    for x := 0 to width - 1 do begin
      if bitmapBiner[x, y] = objek then begin
         avg := bitmapR[x, y] + bitmapG[x, y] + bitmapB[x, y];
         avg := avg div 3;
         image1.canvas.pixels[x, y] := RGB(avg, avg, avg);
      end
      else image1.canvas.pixels[x, y] := clwhite;
    end;
end;

procedure TForm1.btnBinerClick(Sender: TObject);
var y, x : integer;
begin
  for y := 0 to height - 1 do
    for x := 0 to width - 1 do begin
      if bitmapBiner[x, y] = objek then
            image1.canvas.pixels[x, y] := clblack
      else image1.canvas.pixels[x, y] := clwhite;
    end;

end;

end.

