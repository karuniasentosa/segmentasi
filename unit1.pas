unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, lclintf,
  ExtCtrls, ExtDlgs, ComCtrls, math;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnOpen: TButton;
    btnSegmentasi: TButton;
    btnSegmentasiThreshold: TButton;
    btnDeteksiTepi: TButton;
    Image1: TImage;
    OpenPictureDialog1: TOpenPictureDialog;
    TrackBar1: TTrackBar;
    procedure btnDeteksiTepiClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSegmentasiClick(Sender: TObject);
    procedure btnSegmentasiThresholdClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  bitmapR, bitmapG, bitmapB: array[0..1500, 0..1500] of byte;
  width, height: integer;

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

  for y := 1 to height - 2 do
    for x := 1 to width - 2 do begin
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

procedure TForm1.btnSegmentasiClick(Sender: TObject);
var
  y, x: integer;
  avg: integer;
begin
  for y := 0 to image1.height - 1 do
    for x := 0 to image1.width - 1 do begin
      avg := GetRValue(image1.Canvas.Pixels[x, y]);
      avg := avg + GetGValue(image1.canvas.pixels[x, y]);
      avg := avg + getBvalue(image1.canvas.pixels[x, y]);
      avg := avg div 3;
      if avg > Trackbar1.position then
         image1.canvas.pixels[x, y] := RGB(255, 255, 255);
    end;
end;

procedure TForm1.btnSegmentasiThresholdClick(Sender: TObject);
var
  y, x: integer;
  avg: integer;
begin
  for y := 0 to image1.height - 1 do
    for x := 0 to image1.width - 1 do begin
      avg := GetRValue(image1.Canvas.Pixels[x, y]);
      avg := avg + GetGValue(image1.canvas.pixels[x, y]);
      avg := avg + getBvalue(image1.canvas.pixels[x, y]);
      avg := avg div 3;
      if avg > Trackbar1.position then
         image1.canvas.pixels[x, y] := RGB(255, 255, 255)
      else
        image1.canvas.pixels[x, y] := RGB(0, 0, 0);
    end;
end;

end.

