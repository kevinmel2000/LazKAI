unit unUtama;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, fpjson, jsonparser, fphttpclient, LazUTF8;

{ TFrUtama }
Const API_KEY ='k=edb4eae8626733eab8d694e395cb3096';
       API_SOURCE='http://ibacor.com/api/kereta-api?';

type
  TFrUtama = class(TForm)
    Button1: TButton;
    Button2: TButton;
    cmb_jadwal: TComboBox;
    cmb_kota_asal: TComboBox;
    cmb_kota_tuj: TComboBox;
    cmb_stasiun_asal: TComboBox;
    cmb_stasiun_tuj: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    sgr_jadwal: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure getDataFromServer;
    procedure cmb_kota_asalChange(Sender: TObject);
    procedure cmb_kota_tujChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrUtama: TFrUtama;
  JDataTanggal : TJSONObject;
  JDataKota : TJSONObject;
  JDataStasiun : TJSONObject;



implementation

{$R *.lfm}

{ TFrUtama }

procedure TFrUtama.FormCreate(Sender: TObject);
begin
   getDataFromServer;
end;



procedure TFrUtama.Button1Click(Sender: TObject);
var jadwal : String;
    stAsal:string;
    stTuj:string;
    JData : TJSONData;
    path:string;
    i:integer;
begin
   jadwal:= 'tanggal='+JDataTanggal.Items[cmb_jadwal.ItemIndex].FindPath('value').AsString;
   stAsal:= 'asal='+JDataKota.Items[cmb_kota_asal.ItemIndex].FindPath('list').Items[cmb_stasiun_asal.ItemIndex].FindPath('value').AsString;
   stTuj:= 'tujuan='+JDataKota.Items[cmb_kota_tuj.ItemIndex].FindPath('list').Items[cmb_stasiun_tuj.ItemIndex].FindPath('value').AsString;
   path:= API_SOURCE+jadwal+'&'+stAsal+'&'+stTuj+'&'+API_KEY;
   JData := GetJSON(TFPHTTPClient.SimpleGet(Path));

   if JData.Items[0].AsString <>'success' then
      ShowMessage('Jadwal Tidak Ditemukan')
   else
   begin
         sgr_jadwal.RowCount:=JData.FindPath('data').Count+1;
         for i  := 0 to JData.FindPath('data').Count-1 do
         begin
               sgr_jadwal.Cells[0,i+1]:= JData.FindPath('data').Items[i].findpath('kereta').findpath('name').AsString;
               sgr_jadwal.Cells[1,i+1]:= JData.FindPath('data').Items[i].findpath('kereta').findpath('class').AsString;
               sgr_jadwal.Cells[2,i+1]:= JData.FindPath('data').Items[i].findpath('harga').findpath('rp').AsString;
               sgr_jadwal.Cells[3,i+1]:= JData.FindPath('data').Items[i].findpath('berangkat').findpath('tanggal').AsString +'('+
                                         JData.FindPath('data').Items[i].findpath('berangkat').findpath('jam').AsString +')';
               sgr_jadwal.Cells[4,i+1]:= JData.FindPath('data').Items[i].findpath('datang').findpath('tanggal').AsString +'('+
                                         JData.FindPath('data').Items[i].findpath('datang').findpath('jam').AsString +')';
               sgr_jadwal.Cells[5,i+1]:= JData.FindPath('data').Items[i].findpath('tiket').AsString;


         end;



   end;

end;

procedure TFrUtama.getDataFromServer;
var i :integer;
    JData : TJSONData;
begin
   try
     TFPHTTPClient.SimpleGet('http://ibacor.com/api/kereta-api?k=edb4eae8626733eab8d694e395cb3096')
   except
      Raise Exception.Create('Tidak Bisa Mengambil Jadwal dari Web ');

   end;

   JData := GetJSON(TFPHTTPClient.SimpleGet('http://ibacor.com/api/kereta-api?k=edb4eae8626733eab8d694e395cb3096'));


   if (JData.Items[0].AsString) = 'success' then
   begin
     JDataTanggal :=  TJSONObject(JData.FindPath('data').FindPath('tanggal'));
     For i:=0 to JDataTanggal.Count-1 do
       cmb_jadwal.Items.Add(JDataTanggal.Items[i].FindPath('name').AsString);
     cmb_jadwal.ItemIndex:=0;

     JDataKota :=  TJSONObject(JData.FindPath('data').FindPath('stasiun'));
     For i:=0 to JDataKota.Count-1 do
       cmb_kota_asal.Items.Add(JDataKota.Items[i].FindPath('kota').AsString);
     cmb_kota_asal.ItemIndex:=0;

     cmb_stasiun_asal.Items.Clear;
     JDataStasiun := TJSONObject(JDataKota.Items[0].FindPath('list'));
      For i:=0 to JDataStasiun.Count-1 do
          cmb_stasiun_asal.Items.Add(JDataStasiun.Items[i].FindPath('name').AsString);
        cmb_stasiun_asal.ItemIndex:=0;

      For i:=0 to JDataKota.Count-1 do
       cmb_kota_tuj.Items.Add(JDataKota.Items[i].FindPath('kota').AsString);
     cmb_kota_tuj.ItemIndex:=0;

      For i:=0 to JDataStasiun.Count-1 do
          cmb_stasiun_tuj.Items.Add(JDataStasiun.Items[i].FindPath('name').AsString);
        cmb_stasiun_tuj.ItemIndex:=0;

   end
   else
   begin
       Raise Exception.Create('Gagal Konek !!!');
   end;


end;

procedure TFrUtama.cmb_kota_asalChange(Sender: TObject);
var i : integer;
begin
  cmb_stasiun_asal.Items.Clear;
  JDataStasiun := TJSONObject(JDataKota.Items[cmb_kota_asal.ItemIndex].FindPath('list'));
   For i:=0 to JDataStasiun.Count-1 do
       cmb_stasiun_asal.Items.Add(JDataStasiun.Items[i].FindPath('name').AsString);
     cmb_stasiun_asal.ItemIndex:=0;

end;

procedure TFrUtama.cmb_kota_tujChange(Sender: TObject);
var i : integer;
begin
  cmb_stasiun_tuj.Items.Clear;
  JDataStasiun := TJSONObject(JDataKota.Items[cmb_kota_tuj.ItemIndex].FindPath('list'));
   For i:=0 to JDataStasiun.Count-1 do
       cmb_stasiun_tuj.Items.Add(JDataStasiun.Items[i].FindPath('name').AsString);
     cmb_stasiun_tuj.ItemIndex:=0;

end;


end.

