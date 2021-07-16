Class Astrology.History Extends %Persistent
{

Property Player As Astrology.Players;

Property DayNumber As %Integer;

Property IsLuckyDay As %Integer [ InitialExpression = 0 ];

Property IsMostLuckyDay As %Integer [ InitialExpression = 0 ];

Property TotalMatches As %Integer [ InitialExpression = 0 ];

Property TotalPlayed As %Integer [ InitialExpression = 0 ];

Property TotalSuccess As %Integer [ InitialExpression = 0 ];

Property IsHighLuck As %Integer [ InitialExpression = 0 ];

Property SuccessRate As %Float [ Calculated, SqlComputeCode = {Set {*}=##class(Astrology.History).SuccessRate({TotalPlayed},{TotalSuccess})}, SqlComputed ];

Index IdxOnName On (Player, DayNumber);

ClassMethod SuccessRate(TotalPlayed, TotalSuccess) As %Float
{
	If TotalPlayed>0 Quit (TotalSuccess/TotalPlayed)*100
	Quit 0
}

ClassMethod DataEntry()
{
	Write "Enter Player Name:"
	Read Player
	Write !
	Set RootId=..PlayerPresent(Player)
	Set Team=""
	If RootId'>0
	{
		Write "Enter DOB:"
		Read DOB
		Write !
		Write "Team:"
		Read Team
		Write !
		Set RootId=##class(Astrology.Players).InsertPlayer(Player,DOB,Team)
	}
	Write "DayNumber:"
	Read DayNumber
	Write !
	Write "Has Success?"
	Read HasSuccess
	Write !
	Do ..Update(RootId,DayNumber,Team,1,1,HasSuccess)
	w #
}

ClassMethod AddDay()
{
	Write "Enter Player Name:"
	Read Player
	Write !
	Set RootId=..PlayerPresent(Player)
	Set Team=""
	If RootId'>0
	{
		Write "Enter DOB:"
		Read DOB
		Write !
		Write "Team:"
		Read Team
		Write !
		Set RootId=##class(Astrology.Players).InsertPlayer(Player,DOB,Team)
	}
	Write "DayNumber:"
	Read DayNumber
	Write !
	Write "Has Success?"
	Read HasSuccess
	Write !
	If HasSuccess="" 
	{
		Do ..Update(RootId,DayNumber,Team,0,0,0)
	}
	Else
	{
		Do ..Update(RootId,DayNumber,Team,1,1,HasSuccess)
	}
	w #
}

ClassMethod PlayerPresent(Name) As %Integer
{
	Set Name=$ZCVT(Name,"U")
	Quit $O(^Astrology.PlayersI("IdxPlayerName"," "_Name,""))
}

ClassMethod Update(RootId, DayNumber, Team As %String, TotalMatches As %Integer, TotalPlayed As %Integer, TotalSuccess As %Integer)
{
	If Team'=""
	{
		Set RootObj=##class(Astrology.Players).%OpenId(RootId)
		Set RootObj.Team=Team
		Do RootObj.%Save()
	}
	Set SingleDigit=DayNumber
	For
	{
		Quit:$L(SingleDigit)=1
		Set SingleDigit=$E(SingleDigit,1)+$E(SingleDigit,2,*)
	}
	Set Id=$O(^Astrology.HistoryI("IdxOnName",RootId,SingleDigit,""))
	If Id>0
	{
		Set obj=..%OpenId(Id)
	}
	Else
	{
		Set obj=..%New()
		Set obj.DayNumber=SingleDigit
		Set obj.Player=##class(Astrology.Players).%OpenId(RootId)
	}
	Set obj.TotalMatches=TotalMatches+obj.TotalMatches
	Set obj.TotalPlayed=TotalPlayed+obj.TotalPlayed
	Set obj.TotalSuccess=TotalSuccess+obj.TotalSuccess
	Do obj.%Save()
}

ClassMethod LuckyDayRecalculate()
{
	Set Id=""
	For
	{
		Set Id=$O(^Astrology.HistoryD(Id))
		Quit:Id=""
		Set obj=..%OpenId(Id)
		Set Lucky=..IsLuckyDay(obj.DayNumber,obj.Player.FateNumber)
		Set obj.IsLuckyDay=$P(Lucky,"^",1)
		Set obj.IsMostLuckyDay=$P(Lucky,"^",2)
		Do obj.%Save()
	}
}

ClassMethod Save(Name As %String, DOB As %String, DayNumber As %Integer, Team As %String, TotalMatches As %Integer, TotalPlayed As %Integer, TotalSuccess As %Integer)
{
	Set SingleDigit=DayNumber
	For
	{
		Quit:$L(SingleDigit)=1
		Set SingleDigit=$E(SingleDigit,1)+$E(SingleDigit,2,*)
	}
	Set Name=$ZCVT(Name,"U")
	Set RootId=$O(^Astrology.PlayersI("IdxPlayer"," "_Name," "_DOB,""))
	If RootId'>0 Set RootId=##class(Astrology.Players).InsertPlayer(Name,DOB,Team)
	Set Id=$O(^Astrology.HistoryI("IdxOnName",RootId,SingleDigit,""))
	If Id>0 
	{
		Set obj=..%OpenId(Id)
		Set obj.TotalMatches=obj.TotalMatches+TotalMatches
		Set obj.TotalPlayed=obj.TotalPlayed+TotalPlayed
		Set obj.TotalSuccess=obj.TotalSuccess+TotalSuccess
	}
	Else
	{
		Set obj=..%New()
		Set obj.TotalMatches=TotalMatches
		Set obj.TotalPlayed=TotalPlayed
		Set obj.TotalSuccess=TotalSuccess
	}
	Set Root=##class(Astrology.Players).%OpenId(RootId)
	Set Lucky=..IsLuckyDay(SingleDigit,Root.FateNumber)
	Set obj.DayNumber=SingleDigit
	Set obj.IsLuckyDay=$P(Lucky,"^",1)
	Set obj.IsMostLuckyDay=$P(Lucky,"^",2)
	Do obj.%Save()
}

ClassMethod IsLuckyDay(SingleDigit As %Integer, FateNumber As %Integer) As %String
{
	Set IsLucky=0,IsMostLucky=0
	If SingleDigit=1||(SingleDigit=5) Set IsLucky=$case(FateNumber,1:1,5:1,7:1,3:1,9:1,:0),IsMostLucky=$case(FateNumber,3:1,9:1,:0)
	If SingleDigit=2 Set IsLucky=$case(FateNumber,2:1,4:1,8:1,3:1,6:1,:0),IsMostLucky=$case(FateNumber,3:1,6:1,:0)
	If SingleDigit=3 Set IsLucky=$case(FateNumber,3:1,6:1,9:1,1:1,2:1,5:1,:0),IsMostLucky=$case(FateNumber,2:1,5:1,:0)
	If SingleDigit=4 Set IsLucky=$case(FateNumber,2:1,4:1,8:1,6:1,7:1,:0),IsMostLucky=$case(FateNumber,6:1,7:1,:0)
	If SingleDigit=6 Set IsLucky=$case(FateNumber,3:1,6:1,9:1,2:1,4:1,8:1,:0),IsMostLucky=$case(FateNumber,4:1,8:1,:0)
	If SingleDigit=7 Set IsLucky=$case(FateNumber,1:1,5:1,7:1,4:1,:0),IsMostLucky=$case(FateNumber,7:1,4:1,:0)
	If SingleDigit=8 Set IsLucky=$case(FateNumber,2:1,4:1,8:1,6:1,:0),IsMostLucky=$case(FateNumber,8:1,6:1,:0)
	If SingleDigit=9 Set IsLucky=$case(FateNumber,3:1,6:1,9:1,1:1,5:1,:0),IsMostLucky=$case(FateNumber,1:1,5:1,:0)
	Quit IsLucky_"^"_IsMostLucky
}

ClassMethod FateNumber(DOB) As %Integer
{
	Set SingleDigit=$TR(DOB,"-")
	For
	{
		Quit:$L(SingleDigit)=1
		Set SingleDigit=$E(SingleDigit,1)+$E(SingleDigit,2,*)
	}
	Quit SingleDigit
}

// 1/5 - 1 5 7 3 9

// 2 - 2 4 8 3 6

// 3 - 3 6 9 1 2 5

// 4 - 2 4 8 6 7

// 6 - 3 6 9 2 4 8

// 7 - 1 5 7 4

// 8 - 2 4 8 6

// 9 - 3 6 9 1 5

/*
1 3 4 5 8 9 - 1 - 4 5
1 2 5 7 8 - 2 - 1 7
2 4 7 8 - 3 - 2
2 4 5 6 7 8 9 - 4 - 5
1 2 3 5 6 7 8 9 - 5 - 2
3 4 5 7 9 - 7  - 5 3 
4 5 6 7 8 - 9 - 6 5 7 8
*/
ClassMethod Populate(Team, FromDayNumber, ToDayNumber)
{
	Set SQL="SELECT Player,Player->FateNumber FROM Astrology.History where Player->Team='"_Team_"' and DayNumber="_FromDayNumber
	Set rs=##class(%ResultSet).%New()
	Set sc=rs.Prepare(SQL)
	Set sc=rs.Execute()
	While(rs.Next())
	{
		Set Id=rs.GetData(1)
		Set obj=..%New()
		Set obj.DayNumber=ToDayNumber
		Set Lucky=..IsLuckyDay(ToDayNumber,rs.GetData(2))
		Set obj.IsLuckyDay=$P(Lucky,"^",1)
		Set obj.IsMostLuckyDay=$P(Lucky,"^",2)
		Set obj.Player=##class(Astrology.Players).%OpenId(Id)
		Do obj.%Save()
	}
}

ClassMethod SuccessNumbers()
{
	Read "Entry your Day Number:",DayNumber,!
	Set rs=##class(%ResultSet).%New()
	Set sc=rs.Prepare("select player->fatenumber,successrate FROM Astrology.History where  DayNumber="_DayNumber)
	Set sc=rs.Execute()
	While(rs.Next())
	{
		//w rs.GetData(3),!
		Set Array("Total",rs.GetData(1))=$G(Array("Total",rs.GetData(1)),0)+1
		If rs.GetData(2)>0 
		{
			Set Array("Success",rs.GetData(1))=$G(Array("Success",rs.GetData(1)),0)+1
			Set Array("Rate",rs.GetData(1))=(Array("Success",rs.GetData(1))/Array("Total",rs.GetData(1)))*100
		}
	}
	zw Array("Rate")
}

ClassMethod CaptainSuccessNumbers()
{
	Read "Entry your Day Number:",DayNumber,!
	Set rs=##class(%ResultSet).%New()
	Set sc=rs.Prepare("select player->fatenumber,IsHighLuck FROM Astrology.History where DayNumber="_DayNumber)
	Set sc=rs.Execute()
	While(rs.Next())
	{
		//w rs.GetData(3),!
		If rs.GetData(2)>0 
		{
			Set Array("Success",rs.GetData(1))=$G(Array("Success",rs.GetData(1)),0)+1
		}
	}
	zw Array("Success")
}

ClassMethod IsHighLuck()
{
	Read "Enter player name:",Player,!
	Set RootId=..PlayerPresent(Player)
	Read "DayNumber:",DayNumber,!
	Set SingleDigit=DayNumber
	For
	{
		Quit:$L(SingleDigit)=1
		Set SingleDigit=$E(SingleDigit,1)+$E(SingleDigit,2,*)
	}
	Set ChildId=$O(^Astrology.HistoryI("IdxOnName",RootId,SingleDigit,""))
	If ChildId>0
	{
		Set obj=##class(Astrology.History).%OpenId(ChildId)
		Set obj.IsHighLuck=obj.IsHighLuck+1
		Do obj.%Save()
		Write "High luck is updated for player : "_Player_" id:"_RootId_" Child Id:"_ChildId
	}
	Else
	{
		Write "Child is not exist",!
	}
	Quit
}

ClassMethod AddStats(DayNumber, FateNumber)
{
	Set ^stats(DayNumber,FateNumber)=$G(^stats(DayNumber,FateNumber),0)+1
}

ClassMethod ViewStats(DayNumber)
{
	Set FateNumber=""
	For
	{
		Set FateNumber=$O(^stats(DayNumber,FateNumber),1,Count)
		Quit:FateNumber=""
		If $L(Count)<=2
		{
			For inc=$L(Count):1:3
			{
				Set Count="0"_Count
			}
		}
		If '$D(Array(Count))
		{
			Set Array(Count)=FateNumber
		}
		Else
		{
			Set Array(Count,$I(Counter(Count)))=FateNumber
		}
	}
	zw Array
}

ClassMethod SingleDigit(TRDate As %Integer) As %Integer
{
	Set Total=0
	For 
	{
		For inc=1:1:$L(TRDate)
		{
			Set Total=Total+$E(TRDate,inc)
		}
		Quit:$L(Total)=1
		Set TRDate=Total,Total=0
	}
	Quit Total
}

ClassMethod Utility()
{
	Write "Menu Options",!
	Write "1.Update High Luck",!
	Write "2.Add Stats",!
	Write "3.SuccessRate of Player Fate Numbers",!
	Write "4.SuccessRate of Captain Fate Numbers",!
	Read "Enter your option:",Opt,!
	If Opt=1 Do ..IsHighLuck()
	If Opt=2 Do ..DataEntry()
	If Opt=3 Do ..SuccessNumbers()
	If Opt=4 Do ..CaptainSuccessNumbers()
}

Storage Default
{
<Data name="HistoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Player</Value>
</Value>
<Value name="3">
<Value>DayNumber</Value>
</Value>
<Value name="4">
<Value>IsLuckyDay</Value>
</Value>
<Value name="5">
<Value>IsMostLuckyDay</Value>
</Value>
<Value name="6">
<Value>TotalMatches</Value>
</Value>
<Value name="7">
<Value>TotalPlayed</Value>
</Value>
<Value name="8">
<Value>TotalSuccess</Value>
</Value>
<Value name="9">
<Value>IsHighLuck</Value>
</Value>
</Data>
<DataLocation>^Astrology.HistoryD</DataLocation>
<DefaultData>HistoryDefaultData</DefaultData>
<IdLocation>^Astrology.HistoryD</IdLocation>
<IndexLocation>^Astrology.HistoryI</IndexLocation>
<StreamLocation>^Astrology.HistoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
