USE [SinavSistemi]
GO
/****** Object:  StoredProcedure [dbo].[Sinav]    Script Date: 15.12.2019 21:03:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[Sinav] @ogrenciID int 
as

declare @yapilacakSinav int = (select count(DISTINCT sinavID) from tbl_Basari where ogrenciID = @ogrenciID) +1
DELETE FROM tbl_Sorulan
if(@yapilacakSinav = 1)
begin
	exec İlkSinavYap
end

else
begin
set @yapilacakSinav -= 1
exec BasariOraniliSinavYap @sinavID = @yapilacakSinav , @ogrenci = @ogrenciID
end
