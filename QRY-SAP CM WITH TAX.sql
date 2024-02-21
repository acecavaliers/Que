--SELECT ObjType,* from inv5

--select ObjType,BaseType,* from rin1

--select ObjType,BaseType,* from oinv


--select * from orin where docnum=192
--select * from rin1 where docentry =192
--select * from rin5 where AbsEntry=192


select t0.CardName,t0.CardCode,t0.docnum,t2.* from orin t0
inner join rin1 t1 on t0.docnum=t1.DocEntry
inner join rin5 t2 on t1.DocEntry=t2.AbsEntry