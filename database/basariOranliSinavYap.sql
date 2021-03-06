USE [SinavSistemi]
GO
/****** Object:  StoredProcedure [dbo].[BasariOraniliSinavYap]    Script Date: 15.12.2019 21:01:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[BasariOraniliSinavYap] @sinavID int , @ogrenci int
as

declare @ortBasari float = (select floor (avg(basariOrani)) from tbl_Basari where sinavID = @sinavID and ogrenciID = @ogrenci)
declare @i int =1
declare @j int
declare @basari float 
declare @katsayi float 
declare @toplamKatsayi float = 0
declare @konuSayisi int = (select count(*) from tbl_Konu)
declare @carpimKatsayi int
declare @soruSayisi int
declare @toplamSoruSayisi int


--toplam katsayıyı belirleme
while (@i<=@konuSayisi)
begin
	set @basari = (select basariOrani from tbl_Basari where konuID=@i and sinavID = @sinavID and ogrenciID = @ogrenci)
	if (@basari = 0)
		set @basari = 10
	set @toplamKatsayi += @ortBasari/@basari
	set @i +=1
end
--çarpım katsayısı belirleme
	set @carpimKatsayi = floor(20/@toplamKatsayi)
	set @soruSayisi = 0
	set @i =1

--her konunun katsayısını çarpım katsayısıyla çarpma ve soru sayılarını belirleme
while (@i<=@konuSayisi)
begin
	set @basari = (select basariOrani from tbl_Basari where konuID=@i and sinavID = @sinavID and ogrenciID = @ogrenci)
	if (@basari = 0)
		set @basari = 10
	set @katsayi = @ortBasari/@basari
	set @soruSayisi = floor(@katsayi*@carpimKatsayi)

	update tbl_Basari set soruSayisi = @soruSayisi where konuID = @i and sinavID = @sinavID and ogrenciID = @ogrenci
	set @i +=1
end
set @toplamSoruSayisi = (select sum(soruSayisi) from tbl_Basari where sinavID = @sinavID and ogrenciID = @ogrenci)
set @i = 1

--soru sayısının eksiğini tamamlama
while (@i<=20-@toplamSoruSayisi)
begin
	set @j = @i%@konuSayisi
	if (@j = 0)
		set @j=@konuSayisi
	update tbl_Basari set soruSayisi +=1 where konuID = @j and sinavID = @sinavID and ogrenciID = @ogrenci
	set @i +=1
end

set @i = 1
--konuları soru sayılarına göre sorulan tablosuna ekleme
while (@i<=@konuSayisi)
begin
	INSERT INTO tbl_Sorulan(soruID,soruOnBilgi,soruIcerik,soruA,soruB,soruC,soruD,soruDogruCevap,soruKonuID)
	SELECT TOP(select soruSayisi from tbl_Basari where konuID = @i and sinavID = @sinavID and ogrenciID = @ogrenci) soruID,soruOnBilgi,soruIcerik,soruA,soruB,soruC,soruD,soruDogruCevap,soruKonuID FROM tbl_Soru S JOIN tbl_Konu K 
	ON S.soruKonuID = K.konuID
	WHERE K.konuID = @i ORDER BY NEWID()
	set @i +=1
end